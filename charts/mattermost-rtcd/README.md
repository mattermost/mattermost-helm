# mattermost-rtcd

A Helm chart for Kubernetes and Mattermost Application RTCD

## How to install this chart

Add Mattermost public chart repo:

```console
helm repo add mattermost https://helm.mattermost.com
```

A simple install with default values:

```console
helm install mattermost/mattermost-rtcd
```

To install the chart with the release name `my-release`:

```console
helm install my-release mattermost/mattermost-rtcd
```

To install with some set values:

```console
helm install my-release mattermost/mattermost-rtcd --set values_key1=value1 --set values_key2=value2
```

To install with custom values file:

```console
helm install my-release mattermost/mattermost-rtcd -f values.yaml
```
