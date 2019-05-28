Mattermost Enterprise Edition Helm Chart
====================================================

This is the Helm chart for the Mattermost Enterprise Edition. It is subject to changes, but is used by Mattermost internally to run CI servers and our [community.mattermost.com](https://community.mattermost.com) server. To learn more about Helm charts, [see the Helm docs](https://helm.sh/docs/).

To read an overview of how to migrate Mattermost to Kubernetes, [see this blog post](https://mattermost.com/blog/mattermost-kubernetes/).

The Mattermost Team Edition Helm chart can be found [here](https://github.com/helm/charts/tree/master/stable/mattermost-team-edition).

To install the Mattermost Team Edition Helm chart in a GitLab Helm chart deployment, [see this documentation](https://docs.mattermost.com/install/install-mmte-helm-gitlab-helm.html).

# 1. Prerequisites

## 1.1 Kubernetes Cluster

You need a running Kubernetes cluster v1.8+. If you do not have one, find options and installation instructions here:

https://kubernetes.io/docs/setup/pick-right-solution/

## 1.2 Helm

See: https://docs.helm.sh/using_helm/#quickstart

We recommend installing Helm v2.13.1 or later.

Once Helm is installed and initialized, run the following:

```bash
helm repo add mattermost https://helm.mattermost.com
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

## 1.3 Ingress

To expose the application outside of your network, configure an ingress if your Kubernetes cluster doesn't already have one.

We suggest using [nginx-ingress](https://github.com/kubernetes/ingress-nginx), which we use internally at Mattermost.

To install nginx-ingress in your Kubernetes cluster, follow [the official installation documentation](https://kubernetes.github.io/ingress-nginx/deploy/). You may also use the [helm charts](https://github.com/helm/charts/tree/master/stable/nginx-ingress) directly.

To get the nginx cache to work, adjust the ConfigMap and Deployment from the above instructions. [See the ingress section of our blog post](https://mattermost.com/blog/mattermost-kubernetes/#ingress) to see how we did it for an AWS installation.

## 1.4 Certificate Manager

If you do not want to manually add SSL/TLS certificates, install [cert-manager](https://github.com/jetstack/cert-manager). You can follow [this documentation](https://cert-manager.readthedocs.io/en/latest/) or install the [helm charts](https://github.com/helm/charts/tree/master/stable/cert-manager).

To run with HTTPS you will need to add a Kubernetes secret for your SSL/TLS certificate, whether you use cert-manager or not.

# 2. Configuration

To start, copy [mattermost-enterprise-edition/values.yaml](https://github.com/mattermost/mattermost-kubernetes/blob/master/mattermost-enterprise-edition/values.yaml) and name it `config.yaml`. This will be your configuration file for the Mattermost Helm chart.

To learn more about the Mattermost configuration file, see https://docs.mattermost.com/administration/config-settings.html.

## 2.1 Required Settings

At minimum there are two settings you must update:

* `global.siteURL` - set this to the URL your users will use to access Mattermost, e.g. `https://mattermost.example.com`
* `global.mattermostLicense` - set this to the contents of your license file

Without these two settings, Mattermost will not run correctly.

## 2.2 Application Version

To set the Mattermost application version, update:

* `mattermostApp.image.tag` - set this to the Mattermost server version you wish to install (e.g. `5.11.0`)

## 2.3 Ingress

If you are using nginx-ingress, set the following under `mattermostApp`:

```yaml
ingress:
  enabled: true
  hosts:
    - mattermost.example.com
```

where `mattermost.example.com` is your domain name and matches `global.siteURL`.

### 2.3.1 HTTPS

To run with HTTPS, add an SSL/TLS certificate as a secret to your Kubernetes cluster, either manually or [using cert-manager](#certificate-manager).

Set the following under `mattermostApp` to enable HTTPS:

```yaml
ingress:
  enabled: true
  hosts:
    - mattermost.example.com
  tls:
    - secretName: your-tls-secret-name
      hosts:
        - mattermost.example.com
```

### 2.3.2 DNS

To route users from your domain name to your Mattermost installation, point your domain name at the external IP or domain that your ingress exposes.

Depending on the DNS service and Ingress you're using, the steps can vary. If you are using nginx-ingress, you would do something like this:

1. Run `kubectl describe svc your-nginx-ingress-controller`
    * Replace `your-nginx-ingress-controller` with the name of your ingress controller service
2. Copy the domain name beside `LoadBalancer Ingress:`
3. On your DNS service, create a CNAME record pointing from the domain you'd like to use to the domain name you just copied
4. Save, and wait 10-15 minutes for the DNS change to propagate

## 2.4 Database

For database configuration, you have two options:

1. Use an internal MySQL database managed by the Mattermost Helm chart
2. Use an external database not managed by the Mattermost Helm chart

By default the chart uses the internal MySQL database.

### 2.4.1 Internal

We use [incubator/mysqlha](https://github.com/helm/charts/tree/master/incubator/mysqlha) to run the internal database.

The internal database is configured by default, but we recommend updating the following settings:

* `mysqlha.mysqlha.mysqlRootPassword`
* `mysqlha.mysqlha.mysqlUser`
* `mysqlha.mysqlha.mysqlPassword`

See the [incubator/mysqlha configuration settings](https://github.com/helm/charts/tree/master/incubator/mysqlha#configuration) for more options you can configure.

To backup / restore your database, please follow this [how-to](mysql-backup/README.md).

### 2.4.2 External

If you would like to use an external database not managed by the Mattermost Helm chart, do the following:

* Set `mysqlha.enabled` to `false`
* Set `global.features.database.useInternal` to `false`
* Set `global.features.database.external.driver` to either `mysql` or `postgres`
* Set `global.features.database.external.dataSource` to your master DB connection string
* (Optional) Set `global.features.database.external.dataSourceReplicas` to an array of read replica connection strings

## 2.5 Push Notifications

By default push notifications are enabled using [HPNS](https://docs.mattermost.com/mobile/mobile-hpns.html). If you prefer to run your own push proxy, do the following:

* Set `global.features.notifications.useHPNS` to `false`
* Install the push proxy Helm chart, [see instructions here](#install-push-proxy)

## 2.6 Storage

We use [stable/minio](https://github.com/helm/charts/tree/master/stable/minio) for file storage.

Minio is configured by default, but we recommend updating the following settings:

* `minio.accessKey`
* `minio.secretKey`

See the [stable/minio configuration settings](https://github.com/helm/charts/tree/master/stable/minio#configuration) for more options you can configure.

# 3. Install

After adding the Mattermost repo (see section 1.2) you can install a version of the preferred chart by running:

```bash
$ helm repo add mattermost https://helm.mattermost.com
$ helm install mattermost/mattermost-enterprise-edition --version <version_number>
```

For example:
```bash
$ helm repo add mattermost https://helm.mattermost.com
$ helm install mattermost/mattermost-enterprise-edition --version v0.8.2
```

If no Helm Chart version is specified the latest version will be installed.

To run with your custom `config.yaml`, install using:
```bash
$ helm install -f config.yaml mattermost/mattermost-enterprise-edition
```

To upgrade an existing release, modify the `config.yaml` with your desired changes and then use:
```bash
$ helm upgrade -f config.yaml <your-release-name> mattermost/mattermost-enterprise-edition
```

## 3.1 Uninstalling Mattermost Enterprise Helm Chart

If you are done with your deployment and want to delete it, use `helm delete <your-release-name>`. If you don't know the name of your release, use `helm ls` to find it.

## 3.2 Install Push Proxy

You can launch the Mattermost push proxy chart with:
```bash
$ helm repo add mattermost https://helm.mattermost.com
$ helm install mattermost/mattermost-push-proxy
```

To list options for mattermost-push-proxy:

```bash
$ helm inspect values mattermost/mattermost-push-proxy
```

# 4. Developing

If you are going to modify the helm charts, it is helpful to use `--dry-run` (doesn't do an actual deployment) and `--debug` (print the generated config files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the requirements.yaml. It also has limited support for pushing values into subcharts. It does not support using templating inside a values.yaml file.

We recommend using [kind](https://github.com/kubernetes-sigs/kind) for local development if you do not have access to Kubernetes cluster running in the cloud.
