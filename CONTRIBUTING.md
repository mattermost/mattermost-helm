# Contributing Guidelines

Thank you for your interest in contributing! Please see the [Mattermost Contribution Guide](https://developers.mattermost.com/contribute/getting-started/) which describes the process for making code contributions across Mattermost projects and [join our "Contributors" community channel](https://community.mattermost.com/core/channels/tickets) to ask questions from community members and the Mattermost core team.

When you submit a pull request, it goes through a [code review process outlined here](https://developers.mattermost.com/contribute/getting-started/code-review/).

## How to Contribute to mattermost-helm repository

1. Fork this repository, develop, and test your changes.
1. Submit a pull request.

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

### Technical Requirements

* Must pass linting and installing with the [chart-testing](https://github.com/helm/chart-testing) tool
* Must follow [best practices](https://github.com/helm/helm/tree/master/docs/chart_best_practices) and [review guidelines](https://github.com/helm/charts/blob/master/REVIEW_GUIDELINES.md)

### Documentation Requirements

* A chart's `README.md` must include configuration options
* A chart's `NOTES.txt` must include relevant post-installation information

### Merge Approval and Release Process

* Must pass CI jobs for linting and installing changed charts
* Any change to a chart requires a version bump following [semver](https://semver.org/) principles

Once changes have been merged, the release job will automatically run to package and release changed charts.