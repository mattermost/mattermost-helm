# mattermost-chaos-engine

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for Kubernetes and Mattermost Application Chaos Engine

## How to install this chart

Add Mattermost public chart repo:

```console
helm repo add mattermost https://helm.mattermost.com
```

A simple install with default values:

```console
helm install mattermost/mattermost-chaos-engine
```

To install the chart with the release name `my-release`:

```console
helm install my-release mattermost/mattermost-chaos-engine
```

To install with some set values:

```console
helm install my-release mattermost/mattermost-chaos-engine --set values_key1=value1 --set values_key2=value2
```

To install with custom values file:

```console
helm install my-release mattermost/mattermost-chaos-engine -f values.yaml
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| containers.envVars | object | `{}` | The environment variables to be used in Deployment |
| containers.ports | list | `[{"containerPort":3000,"name":"http","protocol":"TCP"}]` | The ports which needed to be exposed |
| containers.secrets | object | `{"data":{},"stringData":{}}` | The secrets environment variables to be used in Deployment |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"mattermost/mattermost-app-chaosengine"` |  |
| image.tag | string | `"c153e43"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].backend.serviceName | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].backend.servicePort | int | `3000` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `3000` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

