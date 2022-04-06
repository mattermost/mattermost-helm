# Mattermost Helm Charts ![CircleCI branch](https://img.shields.io/circleci/project/github/mattermost/mattermost-helm/master.svg)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/mattermost)](https://artifacthub.io/packages/search?repo=mattermost)

This repository collects a set of [Helm](https://helm.sh) charts curated by [Mattermost](https://www.mattermost.com).

Click on the following links to see installation instructions for each chart:

- [mattermost-team-edition](charts/mattermost-team-edition/)
- [mattermost-enterprise-edition](charts/mattermost-enterprise-edition/)
- [mattermost-push-proxy](charts/mattermost-push-proxy/)
- [mattermost-operator](charts/mattermost-operator/)
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
