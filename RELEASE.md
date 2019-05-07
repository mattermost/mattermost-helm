Mattermost Helm Chart Releases
====================================================

# Chart Releaser

 The [chart-releaser](https://github.com/helm/chart-releaser) is being used to enable the mattermost-helm [repo](https://github.com/mattermost/mattermost-helm) to self-host Helm Chart releases via the use of Github pages.

# CircleCI

CircleCI is being used to release a new version of the Mattermost Helm Charts. The [release script](https://github.com/mattermost/mattermost-helm/blob/master/.circleci/release.sh) creates a release package of the new Helm Chart version and updates the [index.yaml](https://github.com/mattermost/mattermost-helm/blob/gh-pages/index.yaml) which in this case is hosted in a Github page. The CircleCI is triggered, when a new commit is pushed in the **master** branch.

# How to Release a new Version

For a new Helm Chart release the version of the Helm Chart should be updated in the *Chart.yaml*. The chart-releaser tool will handle the packaging of the new version, will push it to the Github repo as a new [release](https://github.com/mattermost/mattermost-helm/releases) and update the index file to reflect the new version.

# How to Install a New Release

The *index.yaml* is hosted in a Github page and can be accessed via https://helm.mattermost.com/. In order to make use of a Mattermost Helm Chart specific version the Mattermost Helm repo should be added first by running:

```bash
helm repo add mattermost https://helm.mattermost.com
```

And then a version of the preferred chart can be installed by running:

```bash
helm install --repo https://helm.mattermost.com <chart_name> --version <version_number>
```

For example:


```bash
helm install --repo https://helm.mattermost.com mattermost-push-proxy --version v0.1.4
```

If no Helm Chart version is specified the latest version will be installed.
