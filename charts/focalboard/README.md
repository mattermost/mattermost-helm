Focalboard Helm Chart
====================================================

This is the Helm chart for the [Focalboard](https://www.focalboard.com/).

Focalboard is an open source, self-hosted alternative to Trello, Notion, and Asana.

It helps define, organize, track and manage work across individuals and teams.


The Focalboard source code lives [here](https://github.com/mattermost/focalboard).

# 1. Prerequisites

## 1.1 Kubernetes Cluster

You need a running Kubernetes cluster v1.16+. If you do not have one, find options and installation instructions here:

https://kubernetes.io/docs/setup/pick-right-solution/

## 1.2 Helm

See: https://docs.helm.sh/using_helm/#quickstart

We recommend installing Helm v3.5.3 or later.

Once Helm is installed and initialized, run the following:

```bash
helm repo add mattermost https://helm.mattermost.com
```

## 1.3 Run locally
```bash
git clone git@github.com:mattermost/mattermost-helm.git (or use a fork of yours)
cd charts/focalboard
helm install focalboard . -n focalboard -f values.yaml
```
# 2. Configuration

To start, copy [focalboard/values.yaml](https://github.com/mattermost/mattermost-helm/blob/master/charts/focalboard/values.yaml) and name it `config.yaml`. This will be your configuration file for the Focalboard Helm chart.

# 3. Install Focalboard

You can launch the Mattermost push proxy chart with:
```bash
$ helm repo add mattermost https://helm.mattermost.com
$ helm install mattermost/focalboard
```

To list options for focalboard:

```bash
$ helm inspect values mattermost/focalboard
```

# 4. Developing

If you are going to modify the helm charts, it is helpful to use `--dry-run` (doesn't do an actual deployment) and `--debug` (print the generated config files) when running `helm install`.

Helm has partial support for pulling values out of a subchart via the requirements.yaml. It also has limited support for pushing values into subcharts. It does not support using templating inside a values.yaml file.

We recommend using [kind](https://github.com/kubernetes-sigs/kind) for local development if you do not have access to Kubernetes cluster running in the cloud.