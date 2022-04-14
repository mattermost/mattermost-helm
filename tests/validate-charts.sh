#!/usr/bin/env bash

################################################################################
# This script executed the `helm template` command on all shart defined in the 
# `./charts` directory. It enables common features for all templates, such as
# ingress and persistence.
#
# This is neccessary since `chart-testing` does not catch templating errors
# even when the new `helm-extra-set-args` values are defined.
#
# STDOUT is redirected to null to keep the logs clean, and only errors will be
# displayed.
################################################################################

set -o errexit
set -o nounset
set -o pipefail

for CHART_YAML in charts/**/Chart.yaml
do
  CHART_DIR="$(dirname "${CHART_YAML}")"

  helm template "${CHART_DIR}" \
    --values "${CHART_DIR}/values.yaml" \
    --set=ingress.enabled=true \
    --set=presistence.enabled=true \
    --set=autoscaling.enabled=true > /dev/null
done
