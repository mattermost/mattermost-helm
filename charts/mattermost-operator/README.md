# Mattermost Operator Helm Chart

This is the Helm chart for the Mattermost Operator which is the recommended way to deploy Mattermost in Kubernetes. [Documentation is provided here](https://docs.mattermost.com/install/install-kubernetes.html) which provides extended guidance on using this chart.

To learn more about Helm charts, [see the Helm docs](https://helm.sh/docs/). You can find more information about Mattermost Operator [here](https://github.com/mattermost/mattermost-operator/blob/master/README.md). The Mattermost Operator source code lives [here](https://github.com/mattermost/mattermost-operator).

## 1. Prerequisites

### 1.1 Kubernetes Cluster

You need a running Kubernetes cluster v1.22+. If you do not have one, find options and installation instructions here:

https://kubernetes.io/docs/home/

### 1.2 Helm

See: https://docs.helm.sh/using_helm/#quickstart

We recommend installing the latest stable release of Helm.

Once Helm is installed and initialized, run the following:

```console
helm repo add mattermost https://helm.mattermost.com
```

## 2. Configuration

To start, copy [mattermost-helm/charts/mattermost-operator/values.yaml](https://github.com/mattermost/mattermost-helm/blob/master/charts/mattermost-operator/values.yaml) and name it `config.yaml`. This will be your configuration file for the Mattermost Operator chart. The default values will deploy the resources necessary to run the Mattermost Operator.

## 3. Install

After adding the Mattermost repo (see section 1.2) you can install a version of the preferred chart by running:

```console
$ helm install <your-release-name> mattermost/mattermost-operator -n <namespace_name>
```

For example:
```console
$ helm install mattermost-operator mattermost/mattermost-operator -n mattermost-operator
```

If no version is specified the latest version will be installed.

---

To run with your custom `config.yaml`, install using:

```console
helm install <your-release-name> mattermost/mattermost-operator -f config.yaml -n mattermost-operator
```

### 3.1 Upgrade

#### Upgrading the CRDs

Helm does not upgrade the CRDs during a release upgrade. Before you upgrade a release, preform the following to ensure you have the appropriate CRDs available.

1. Pull the chart sources:

    ```console
    helm pull mattermost/mattermost-operator --untar --version <VERSION_HERE>
    ```

2. Change your working directory to mattermost-operator:

    ```console
    cd mattermost-operator
    ```

3. Update the CRDs on the cluster:

    ```console
    kubectl apply -f crds/
    ```

#### Upgrading the release

To upgrade an existing release, modify the `config.yaml` with your desired changes and then use:
```console
helm upgrade -f config.yaml <your-release-name> mattermost/mattermost-operator -n mattermost-operator
```

### 3.2 Uninstalling Mattermost Operator Helm Chart

If you are done with your deployment and want to delete it, use `helm delete <your-release-name>`. If you don't know the name of your release, use `helm ls -A` to find it across all namespaces. Make sure to pass the namespace in the helm delete command.

## 4. Developing

If you are going to modify the helm charts, it is helpful to use `--dry-run` (doesn't do an actual deployment) and `--debug` (print the generated config files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the requirements.yaml. It also has limited support for pushing values into subcharts. It does not support using templating inside a values.yaml file.

We recommend using [kind](https://github.com/kubernetes-sigs/kind) for local development if you do not have access to Kubernetes cluster running in the cloud.

## Chart v1.0.0 Upgrade Notes

Upgrading the mattermost-operator helm chart to `v1.0.0` or above from any previous version contains a breaking change if you were using the chart-deployed Minio or MySQL Operator options. If you have deployed these operators independently of this helm chart or are using other filestore or database backends then no action is required.

Config example of using the chart-provided Minio or MySQL operators:

```
minioOperator:
  enabled: true
```

```
mysqlOperator:
  enabled: true
```

These were provided with warnings about usage in production in an effort to provide a demo option for trying out a Mattermost deployment. Chart `v1.0.0` removes these options for the following reasons:
1. We can't guarantee stability and provide ongoing support for these operators as kubernetes releases progress.
2. MySQL 5.7 is end of life. Also, PostgreSQL is the [preferred database choice](https://docs.mattermost.com/deploy/postgres-migration.html) for recent Mattermost releases.
3. Deploying services that we don't directly maintain is a bit of an anti-pattern.

If you deployed either of these operators and they are now providing production data then you will need to backup and migrate your data **before** using `v1.0.0` of this chart. You may find the following docs helpful in this process:

https://docs.mattermost.com/deploy/postgres-migration.html

https://docs.mattermost.com/manage/bulk-export-tool.html

---

After all important data is backed up then the Operators should be disabled:

```
minioOperator:
  enabled: false # WARNING: THIS WILL TEAR DOWN THE MINIO OPERATOR. ENSURE DATA IS BACKED UP.

mysqlOperator:
  enabled: false # WARNING: THIS WILL TEAR DOWN THE MYSQL OPERATOR. ENSURE DATA IS BACKED UP.
```

In an effort to protect users from upgrading to `v1.0.0` with these still enabled we added some failsafes in the chart templating. You should see the following if either of the optional operators are still enabled.

```
Error: UPGRADE FAILED: execution error at (mattermost-operator/templates/_helpers.tpl:6:7): Invalid v1.0.0 config

The MySQL Operator is no longer supported.
Review the upgrade documentation at https://github.com/mattermost/mattermost-helm/blob/master/charts/mattermost-operator/README.md
```