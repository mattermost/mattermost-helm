Mattermost Operator Helm Chart
====================================================

This is the Helm chart for the Mattermost Operator. To learn more about Helm charts, [see the Helm docs](https://helm.sh/docs/). You can find more information about Mattermost Operator [here](https://github.com/mattermost/mattermost-operator/blob/master/README.md).

The Mattermost Operator source code lives [here](https://github.com/mattermost/mattermost-operator).

# 1. Prerequisites

## 1.1 Kubernetes Cluster

You need a running Kubernetes cluster v1.16+. If you do not have one, find options and installation instructions here:

https://kubernetes.io/docs/home/

## 1.2 Helm

See: https://docs.helm.sh/using_helm/#quickstart

We recommend installing Helm v3.4.0 or later.

Once Helm is installed and initialized, run the following:

```bash
helm repo add mattermost https://helm.mattermost.com
```

# 2. Configuration

To start, copy [mattermost-operator/charts/mattermost-operator/values.yaml](https://github.com/mattermost/mattermost-operator/blob/master/charts/mattermost-operator/values.yaml) and name it `config.yaml`. This will be your configuration file for the Mattermost Operator chart. You can use the default values that will deploy Mattermost-Operator, Mysql-Operator and Minio-Operator together (use of mysql and minio operators is not suggested for production environments) or update accordingly.


# 3. Install

After adding the Mattermost repo (see section 1.2) you can install a version of the preferred chart by running:

```bash
$ helm install <your-release-name> mattermost/mattermost-operator -n <namespace_name>
```

For example:
```bash
$ helm install mattermost-operator mattermost/mattermost-operator -n mattermost-operator
```

If no version is specified the latest version will be installed.


To run with your custom `config.yaml`, install using:

```bash
helm install <your-release-name> mattermost/mattermost-operator -f config.yaml -n mattermost-operator
```

To upgrade an existing release, modify the `config.yaml` with your desired changes and then use:
```bash
helm upgrade -f config.yaml <your-release-name> mattermost/mattermost-operator -n mattermost-operator
```

If the `mysql-operator` and `minio-operator` are enabled their namespaces will be automatically created.

## 3.1 Uninstalling Mattermost Operator Helm Chart

If you are done with your deployment and want to delete it, use `helm delete <your-release-name>`. If you don't know the name of your release, use `helm ls -A` to find it across all namespaces. Make sure to pass the namespace in the helm delete command.


# 4. Developing

If you are going to modify the helm charts, it is helpful to use `--dry-run` (doesn't do an actual deployment) and `--debug` (print the generated config files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the requirements.yaml. It also has limited support for pushing values into subcharts. It does not support using templating inside a values.yaml file.

We recommend using [kind](https://github.com/kubernetes-sigs/kind) for local development if you do not have access to Kubernetes cluster running in the cloud.
