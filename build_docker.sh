#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

# Compute repo's dir
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

IMAGE_PREFIX="karalabe/xgo"

function build_image() {
    local folder=$1
    local name=$2
    local version=$3

    docker build -t ${name}:${version} ${folder}
}

function build_image_file() {
    local dockerfile=$1
    local name=$2
    local version=$3

    local fixed_dockerfile=$(cat ${dockerfile} | sed -E "s/FROM (.*)$/FROM \\1:${version}/")

    echo "${fixed_dockerfile}" | docker build -t "${name}:${version}" -
}

function get_version() {
    cat "${DIR}/VERSION"
}

# subdirs returns a list of directories in a folder
function subdirs() {
    local folder=$1
    bash -c "cd ${folder} && ls -d */" | sed 's/\/$//'
}

function go_versions() {
    subdirs "${DIR}/docker" | grep -v base | grep -v latest | sed 's/^go-//'
}

function main() {
    # Get ver
    local version=$(get_version)

    echo "Building base"
    build_image "${DIR}/docker/base" "${IMAGE_PREFIX}-base" "${version}"

    # Run builds in parallel
    local N=4
    local i=0
    for goVersion in $(go_versions | grep -v ".x"); do
        ((i=i%N)); ((i++==0)) && wait
        echo
        echo "Building ${goVersion}"
        build_image_file "${DIR}/docker/go-${goVersion}/Dockerfile" "${IMAGE_PREFIX}-${goVersion}" "${version}" &
    done
    # Wait for all tasks to be finished
    wait

    # Build .x versions (quick and easy to build since they simply refer to other images)
    for goVersion in $(go_versions | grep ".x"); do
        echo
        echo "Building ${goVersion}"
        build_image_file "${DIR}/docker/go-${goVersion}/Dockerfile" "${IMAGE_PREFIX}-${goVersion}" "${version}"
    done

    # Build go-latest last (since it depends on earlier builds)
    echo
    echo "Building latest"
    build_image_file "${DIR}/docker/go-latest/Dockerfile" "${IMAGE_PREFIX}-latest" "${version}"
}

# Run main
main
