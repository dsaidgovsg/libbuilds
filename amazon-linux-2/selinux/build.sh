#!/usr/bin/env bash
set -euo pipefail

CPU_CORE_COUNT="$(grep -c ^processor /proc/cpuinfo)"
PYTHON3_XY_VERSION="$(echo ${PYTHON3_VERSION} | cut -d . -f "1,2")"

PACKAGE_NAME="selinux_${LIBSELINUX_VERSION}_py-${PYTHON3_XY_VERSION}"
DESTDIR="${BUILD_DIR}/${PACKAGE_NAME}"

# There is some issue with their sequence to build libsepol.a, and can be resolved by building twice
cd /src/selinux
CFLAGS="-Wno-error" make PYTHON=~/.pyenv/versions/${PYTHON3_VERSION}/bin/python DESTDIR="${DESTDIR}" install install-pywrap -j "${CPU_CORE_COUNT}" || \
CFLAGS="-Wno-error" make PYTHON=~/.pyenv/versions/${PYTHON3_VERSION}/bin/python DESTDIR="${DESTDIR}" install install-pywrap -j "${CPU_CORE_COUNT}"

#
# This section is more for builder external volume builds
# where the behaviors are to be controlled by env vars
#

RELEASE_FULL_ARCHIVE="${RELEASE_FULL_ARCHIVE:-false}"
RELEASE_PYTHON_BINDINGS_ARCHIVE="${RELEASE_PYTHON_BINDINGS_ARCHIVE:-false}"
DELETE_AFTER_RELEASE="${DELETE_AFTER_RELEASE:-false}"

cd "${BUILD_DIR}"

# Release the full archive
if [[ "${RELEASE_FULL_ARCHIVE}" == "true" ]]; then
    tar -zcvf "${PACKAGE_NAME}.tar.gz" --exclude="root" "${PACKAGE_NAME}"
fi

# Release only the python-bindings
if [[ "${RELEASE_PYTHON_BINDINGS_ARCHIVE}" == "true" ]]; then
    PYTHON_BINDINGS_PACKAGE_NAME="selinux_${LIBSELINUX_VERSION}_py-${PYTHON3_XY_VERSION}_bindings"
    PYTHON_BINDINGS_TMP_DIR="/tmp/${PYTHON_BINDINGS_PACKAGE_NAME}/usr/lib/"

    mkdir -p "${PYTHON_BINDINGS_TMP_DIR}"
    cp -r "${DESTDIR}/usr/lib/python${PYTHON3_XY_VERSION}" "${PYTHON_BINDINGS_TMP_DIR}"
    tar -zcvf "${PYTHON_BINDINGS_PACKAGE_NAME}.tar.gz" -C "/tmp" "${PYTHON_BINDINGS_PACKAGE_NAME}"
    rm -r "${PYTHON_BINDINGS_TMP_DIR}"
fi

# Delete built objects, only allow if the full release was previously done
if [[ "${RELEASE_FULL_ARCHIVE}" == "true" && "${DELETE_AFTER_RELEASE}" == "true" ]]; then
    echo "DELETE_AFTER_RELEASE flag set to true, deleting ${DESTDIR}..."
    rm -r "${DESTDIR}"
fi
