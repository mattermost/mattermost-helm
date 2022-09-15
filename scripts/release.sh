#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    pushd "$REPO_ROOT" > /dev/null

    git config user.name "${GIT_USER}"
    git config user.email "${GIT_EMAIL}"

    echo "Fetching tags..."
    git fetch --tags

    local latest_tag
    latest_tag=$(find_latest_tag)

    local latest_tag_rev
    latest_tag_rev=$(git rev-parse --verify "$latest_tag")
    echo "$latest_tag_rev $latest_tag (latest tag)"

    local head_rev
    head_rev=$(git rev-parse --verify HEAD)
    echo "$head_rev HEAD"

    if [[ "$latest_tag_rev" == "$head_rev" ]]; then
        echo "No code changes. Nothing to release."
        exit
    fi

    rm -rf .cr-release-packages .cr-index && mkdir -p .cr-release-packages .cr-index

    echo "Identifying changed charts since tag '$latest_tag'..."

    local changed_charts=()
    readarray -t changed_charts <<< "$(git diff --find-renames --name-only "$latest_tag_rev" -- charts | cut -d '/' -f 2 | uniq)"

    if [[ -n "${changed_charts[*]}" ]]; then

        for chart in "${changed_charts[@]}"; do
            echo "Packaging chart '$chart'..."
            package_chart "charts/$chart"
        done

        release_charts
        sleep 30
        update_index
    else
        echo "Nothing to do. No chart changes detected."
    fi

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
        upload -o mattermost -r mattermost-helm
}

update_index() {
    docker run --rm -u "$(id -u):$(id -g)" \
        -v "$(pwd):/src" \
        -w /src \
        "${DOCKER_IMAGE_CR}" \
       index -o mattermost -r mattermost-helm -c https://helm.mattermost.com

    git checkout gh-pages
    cp --force .cr-index/index.yaml index.yaml
    git add index.yaml
    git commit --message="Update index.yaml" --signoff
    git push
}

main