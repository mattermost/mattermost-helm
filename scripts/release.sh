#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
CR_INDEX_DIR=.cr-index
CR_RELEASE_PACKAGES_DIR=.cr-release-packages

main() {
    pushd "$REPO_ROOT" > /dev/null
    git config user.name "${GIT_USER}"
    git config user.email "${GIT_EMAIL}"

    rm -rf $CR_RELEASE_PACKAGES_DIR $CR_INDEX_DIR && mkdir -p $CR_RELEASE_PACKAGES_DIR $CR_INDEX_DIR
    for chart in charts/*; do
        echo "Packaging chart '$chart'..."
        package_chart "$chart"
    done
    release_charts
    sleep 30
    update_index
    popd > /dev/null
}

find_latest_tag() {
    if ! git describe --tags --abbrev=0 2> /dev/null; then
        git rev-list --max-parents=0 --first-parent HEAD
    fi
}

package_chart() {
    local chart="$1"
    docker run --rm -u "$(id -u):$(id -g)" \
        --entrypoint '/bin/sh' \
        -v "$(pwd):/src" \
        -w /src \
        -e XDG_DATA_HOME="/src/.helm/data" \
		-e XDG_CONFIG_HOME="/src/.helm/config" \
		-e XDG_CACHE_HOME="/src/.helm/cache" \
        "${DOCKER_IMAGE_CT}" \
        -c \
        "helm package $chart --destination .cr-release-packages --dependency-update"
    
}

release_charts() {
    docker run --rm -u "$(id -u):$(id -g)" \
        -v "$(pwd):/src" \
        -w /src \
        -e CR_TOKEN="${CR_TOKEN}" \
        "${DOCKER_IMAGE_CR}" \
        upload --skip-existing -o mattermost -r mattermost-helm
}

update_index() {
    docker run --rm -u "$(id -u):$(id -g)" \
        -v "$(pwd):/src" \
        -w /src \
        "${DOCKER_IMAGE_CR}" \
       index -o mattermost -r mattermost-helm -c https://helm.mattermost.com
    if [[ ! -d "$CR_INDEX_DIR" ]]; then
        echo "No changes found for the index.yaml"
        exit 0
    fi

    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff
    git push
}

main
