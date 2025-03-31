# Mattermost Helm Charts [![Release](https://github.com/mattermost/mattermost-helm/actions/workflows/release.yml/badge.svg)](https://github.com/mattermost/mattermost-helm/actions/workflows/release.yml)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/mattermost)](https://artifacthub.io/packages/search?repo=mattermost)

This repository collects a set of [Helm](https://helm.sh) charts curated by [Mattermost](https://www.mattermost.com).

## Charts

If you are looking to deploy Mattermost, start with the official Mattermost Operator helm chart:

- [mattermost-operator](charts/mattermost-operator/)

Other charts are provided which support or extend existing deployments:

- [mattermost-rtcd](charts/mattermost-rtcd/)
- [mattermost-calls-offloader](charts/mattermost-calls-offloader/)
- [mattermost-push-proxy](charts/mattermost-push-proxy/)
- [mattermost-chaos-engine](charts/mattermost-chaos-engine/)
- [focalboard](charts/focalboard/)

## Usage

[Helm](https://helm.sh) must be installed and initialized to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash
$ helm repo add mattermost https://helm.mattermost.com
```

## Contributing

We welcome contributions.
Please refer to our [contribution guidelines](CONTRIBUTING.md) for details.

## Local Development

### Requirements

1. Install [GNU make](https://www.gnu.org/software/make/).
2. Install [Docker](https://docs.docker.com/engine/install/).
3. Install [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/).

### Verify Changes

To verify changes and execute lint, please execute below command:

```
make lint
```

### Testing

To execute chart tests locally, please execute below command:

```
make test
```
