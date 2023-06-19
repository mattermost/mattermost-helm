# Mattermost Team Edition

[Mattermost](https://mattermost.com/) is a hybrid cloud enterprise messaging workspace that brings your messaging and tools together to get more done, faster.

## TL;DR;

```bash
$ helm repo add mattermost https://helm.mattermost.com
$ helm install mattermost/mattermost-team-edition \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword \
```

## Introduction

This chart creates a [Mattermost Team Edition](https://mattermost.com/) deployment on a [Kubernetes](http://kubernetes.io)
cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.9+ with Beta APIs enabled
- Helm v2/v3
- [Tiller](https://rancher.com/docs/rancher/v2.x/en/installation/ha/helm-init/) (the Helm v2 server-side component) installed on the cluster
- [Migrate from Helm v2 to Helm v3](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/)

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release mattermost/mattermost-team-edition
```
 **Helm v3 command**
```bash
$ helm install my-release mattermost/mattermost-team-edition
```

The command deploys Mattermost on the Kubernetes cluster in the default configuration. The [configuration](#configuration)
section lists the parameters that can be configured during installation.

## Upgrading the Chart to 3.0.0+

Breaking Helm chart changes was introduced with version 3.0.0. The easiest
method of resolving them is to simply upgrade the chart and let it fail with and
provide you with a custom message on what you need to change in your
configuration. Note that this failure will occur before any changes have been
made to the k8s cluster.

## Upgrading the Chart to 4.0.0+

The Chart version 4.0.0+ supports only Helm v3, follow the [guide](https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/)

## Upgrading the Chart to 5.0.0+

There were some changes that was introduced in Mattermost version 5.30+ that made this helm chart incompatible and caused the upgrade to fail. To fix that a new Major version of the chart was released, and now the configuration is moved to the database and environment variables.

Steps to migrate:

1 - Copy the existing configuration file from your Secret save it (for backup)

```
$ kubectl get secrets mm-te-mattermost-team-edition-config-json -o=go-template='{{index .data "config.json"}}' | base64 -d | jq . > config-mm.json
```

2 - Access the Mattermost pod

```
$ kubectl exec -it mm-te-mattermost-team-edition-799cc8b475-twglt /bin/sh
```

3 - Copy the exist config.json to a temp folder, run this inside the container you accessed on Item 2

```
$ cp config/config.json /tmp
```

4 - Migrate the config.json to the database (run inside the container that you accessed in the Item 2)

```
~ $ ./bin/mattermost config migrate /tmp/config.json "mysql://mmuser:mmuser123@tcp(mm-te-mysql:3306)/mattermost?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s"
{"level":"warn","msg":"DefaultServerLocale must be one of the supported locales. Setting DefaultServerLocale to en as default value."}
{"level":"warn","msg":"DefaultClientLocale must be one of the supported locales. Setting DefaultClientLocale to en as default value."}
{"level":"warn","msg":"DefaultServerLocale must be one of the supported locales. Setting DefaultServerLocale to en as default value."}
{"level":"warn","msg":"DefaultClientLocale must be one of the supported locales. Setting DefaultClientLocale to en as default value."}
{"level":"info","msg":"Successfully migrated config."}
```

5 - Update the helm repo

```
$ helm repo update
```

6 - Upgrade your mattermost helm, check your existing values, you remove the section `config.json` from your custom values
and **important** need to keep the existing image tag in this case was 5.29.0

```
$ helm upgrade  mm-te -f custom_values.yaml --set image.tag=5.29.0 mattermost/mattermost-team-edition
```

7 - It should deploy and in a few seconds the new Pod for the Mattermost server should be up and running

8 - After all up and running you can upgrade it again to get the latest image tag

```
$ helm upgrade  mm-te -f custom_values.yaml mattermost/mattermost-team-edition
```

If in your `custom_values.yaml` you set the image.tag, please update that to the latest available, at the time of this doc was write the version is `5.35.3`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Mattermost Team Edition chart and their default values.

Parameter                             | Description                                                                                     | Default
---                                   | ---                                                                                             | ---
`configJSON`                          | The `config.json` configuration to be used by the mattermost server. The values you provide will by using Helm's merging behavior override individual default values only. See the [example configuration](#example-configuration) and the [Mattermost documentation](https://docs.mattermost.com/administration/config-settings.html) for details. |  See `configJSON` in [values.yaml](https://github.com/helm/charts/blob/master/stable/mattermost-team-edition/values.yaml)
`image.repository`                    | Container image repository                                                                      | `mattermost/mattermost-team-edition`
`image.tag`                           | Container image tag                                                                             | `5.39.0`
`image.imagePullPolicy`               | Container image pull policy                                                                     | `IfNotPresent`
`initContainerImage.repository`       | Init container image repository                                                                 | `appropriate/curl`
`initContainerImage.tag`              | Init container image tag                                                                        | `latest`
`initContainerImage.imagePullPolicy`  | Container image pull policy                                                                     | `IfNotPresent`
`revisionHistoryLimit`                | How many old ReplicaSets for Mattermost Deployment you want to retain                           | `1`
`ingress.enabled`                     | If `true`, an ingress is created                                                                | `false`
`ingress.hosts`                       | A list of ingress hosts                                                                         | `[mattermost.example.com]`
`ingress.tls`                         | A list of [ingress tls](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) items | `[]`
`mysql.enabled`                       | Enables deployment of a mysql server                                                            | `true`
`mysql.mysqlRootPassword`             | Root Password for Mysql (Optional)                                                              | ""
`mysql.mysqlUser`                     | Username for Mysql (Required)                                                                   | ""
`mysql.mysqlPassword`                 | User Password for Mysql (Required)                                                              | ""
`mysql.mysqlDatabase`                 | Database name (Required)                                                                        | "mattermost"
`externalDB.enabled`                  | Enables use of an preconfigured external database server                                        | `false`
`externalDB.externalDriverType`       | `"postgres"` or `"mysql"`                                                                       | ""
`externalDB.externalConnectionString` | See the section about [external databases](#External-Databases).                                | ""
`extraPodAnnotations`                 | Extra pod annotations to be used in the deployments                                             | `[]`
`extraEnvVars`                        | Extra environments variables to be used in the deployments                                      | `[]`
`extraInitContainers`                 | Additional init containers                                                                      | `[]`
`service.annotations`                 | Service annotations                                                                             | `{}`
`service.loadBalancerIP`              | A user-specified IP address for service type LoadBalancer to use as External IP (if supported)  | `nil`
`service.loadBalancerSourceRanges`    | list of IP CIDRs allowed access to load balancer (if supported)                                 | `[]`
`serviceAccount.create`               | Enables creation and use of a service account for the mattermost pod                            | `false`
`serviceAccount.name`                 | Name of the service account to create and use                                                   | ""
`serviceAccount.annotations`          | The service account annotations                                                                 | `{}`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set image.tag=5.35.3 \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword \
  mattermost/mattermost-team-edition
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml mattermost/mattermost-team-edition
```

### Example configuration

A basic example of a `.yaml` file with values that could be passed to the `helm`
command with the `-f` or `--values` flag to get started.

```yaml
ingress:
  enabled: true
  hosts:
    - mattermost.example.com

configJSON:
  ServiceSettings:
    SiteURL: "https://mattermost.example.com"
  TeamSettings:
    SiteName: "Mattermost on Example.com"
```

### External Databases
There is an option to use external database services (PostgreSQL or MySQL) for your Mattermost installation.
If you use an external Database you will need to disable the MySQL chart in the `values.yaml`

```yaml
mysql:
  enabled: false
```

#### PostgreSQL
To use an external **PostgreSQL**, You need to set Mattermost **externalDB** config

**IMPORTANT:** Make sure the DB is already created before deploying Mattermost services

```yaml
externalDB:
  enabled: true
  externalDriverType: "postgres"
  externalConnectionString: "<USERNAME>:<PASSWORD>@<HOST>:5432/<DATABASE_NAME>?sslmode=disable&connect_timeout=10"
```

#### MySQL
To use an external **MySQL**, You need to set Mattermost **externalDB** config

**IMPORTANT:** Make sure the DB is already created before deploying Mattermost services

```yaml
externalDB:
  enabled: true
  externalDriverType: "mysql"
  externalConnectionString: "<USERNAME>:<PASSWORD>@tcp(<HOST>:3306)/<DATABASE_NAME>?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s"
```

#### Expose extra ports
To use plugins that require extra ports to be exposed, you can use the following config

```yaml
extraPorts:
    - name: plugin-name
      port: 8585
      protocol: TCP
```

### Local development

For local testing use [minikube](https://github.com/kubernetes/minikube)

Create local cluster using with specified Kubernetes version (e.g. `1.15.6`)

```bash
$ minikube start --kubernetes-version v1.15.6
```

Initialize helm

```bash
$ helm init
```
Above command is not required for Helm v3

Get dependencies

```bash
$ helm dependency update
```

Perform local installation

```bash
$ helm install . \
    --set image.tag=5.35.3 \
    --set mysql.mysqlUser=sampleUser \
    --set mysql.mysqlPassword=samplePassword
```

 **Helm v3 command**
```bash
$ helm install . \
    --generate-name \
    --set image.tag=5.35.3 \
    --set mysql.mysqlUser=sampleUser \
    --set mysql.mysqlPassword=samplePassword
```

#### Limitations

For the Team Edition you can have just one replica running.
