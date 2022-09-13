#!/usr/bin/env bash
set -euo pipefail

PYTHON3_VERSION="${PYTHON3_VERSION:-3.8.14}"
LIBSELINUX_VERSION="${LIBSELINUX_VERSION:-2.5}"

IMAGE_NAME="selinux-builder_${LIBSELINUX_VERSION}_py-${PYTHON3_VERSION}"

docker build . -t "${IMAGE_NAME}" --target builder \
    --build-arg "PYTHON3_VERSION=${PYTHON3_VERSION}" \
    --build-arg "LIBSELINUX_VERSION=${LIBSELINUX_VERSION}"

mkdir -p ./build
docker run --rm -t \
    -v "$(pwd)/build:/build" \
    -e "RELEASE_FULL_ARCHIVE=true" \
    -e "RELEASE_PYTHON_BINDINGS_ARCHIVE=true" \
    -e "DELETE_AFTER_RELEASE=false" \
    "${IMAGE_NAME}"
