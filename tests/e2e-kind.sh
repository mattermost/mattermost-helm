#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

changed=$( docker run --rm -u "$(id -u):$(id -g)" \
        --entrypoint '/bin/sh' \
        -v "$(pwd):/src" \
        -w /src \
        "${DOCKER_IMAGE_CT}" \
        -c \
        "ls > /dev/null && ct list-changed --config ${CT_CONFIG}")
    
		
if [[ -z "$changed" ]]; then
    echo 'No chart changes detected.'
    exit 0
fi

echo "Chart changes detected.Changed Charts:"
echo "${changed}"

cluster_name=$(kind get clusters | grep "${CLUSTER_NAME:-N/A}" || echo "N/A")

if [[ "$cluster_name" != "${CLUSTER_NAME}" ]]; then
    kind create cluster --name "$CLUSTER_NAME" --config "${KIND_CONFIG}" --wait 120s
fi

docker run --rm -u "$(id -u):$(id -g)" --interactive --network host \
    --entrypoint '/bin/sh' \
    -v "$HOME/.kube/config:/root/.kube/config" \
    -v "$(pwd):/src" \
    -w /src \
    "${DOCKER_IMAGE_CT}" \
    -c \
    "ls > /dev/null && ct install --config ${CT_CONFIG}"
