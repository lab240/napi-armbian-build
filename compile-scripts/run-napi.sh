#!/bin/bash

CLEAN_LEVEL=""
BUILD_DESKTOP_ARGS=""
BOARD="napi2"
HAS_ARGS=0
BUILD_TYPE=""
BRANCH=""

for arg in "$@"; do
    case $arg in
        --desktop)
            BUILD_TYPE="desktop"
            HAS_ARGS=1
            ;;
        --minimal)
            BUILD_TYPE="minimal"
            HAS_ARGS=1
            ;;
        --noclean)
            CLEAN_LEVEL="CLEAN_LEVEL=none"
            HAS_ARGS=1
            ;;
        --napic)
            BOARD="napic"
            HAS_ARGS=1
            ;;
        --napi2)
            BOARD="napi2"
            HAS_ARGS=1
            ;;
        --branch=*)
            BRANCH="${arg#--branch=}"
            HAS_ARGS=1
            ;;
        --help|-h)
            HAS_ARGS=0
            break
            ;;
    esac
done

if [ $HAS_ARGS -eq 0 ]; then
    echo "Usage: $0 [options]"
    echo ""
    echo "Board:"
    echo "  --napic          Build for NAPI-C (RK3308), always minimal, default branch: current"
    echo "  --napi2          Build for NAPI2 (RK3568) [default], default branch: vendor"
    echo ""
    echo "Build type:"
    echo "  --desktop        Build with XFCE desktop (napi2 only)"
    echo "  --minimal        Build minimal console image"
    echo ""
    echo "Options:"
    echo "  --branch=NAME    Override branch (current/vendor/edge)"
    echo "  --noclean        Skip cache cleanup"
    echo "  --help           Show this help"
    exit 0
fi

if [ "${BOARD}" = "napic" ] && [ "${BUILD_TYPE}" = "desktop" ]; then
    echo "Error: desktop build is not supported for napic"
    exit 1
fi

# Default branch
if [ -z "${BRANCH}" ]; then
    if [ "${BOARD}" = "napic" ]; then
        BRANCH="current"
    else
        BRANCH="vendor"
    fi
fi

# napic always minimal
if [ "${BOARD}" = "napic" ]; then
    BUILD_DESKTOP_ARGS="BUILD_MINIMAL=yes"
elif [ "${BUILD_TYPE}" = "desktop" ]; then
    BUILD_DESKTOP_ARGS="DESKTOP_ENVIRONMENT=xfce BUILD_DESKTOP=yes DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base DESKTOP_APPGROUPS_SELECTED="
elif [ "${BUILD_TYPE}" = "minimal" ]; then
    BUILD_DESKTOP_ARGS="BUILD_MINIMAL=yes"
fi

./compile.sh BOARD=${BOARD} \
BRANCH=${BRANCH} \
RELEASE=noble \
KERNEL_CONFIGURE=no \
REVISION="$(date +%d%h-%H%M)" \
${CLEAN_LEVEL} \
${BUILD_DESKTOP_ARGS}
