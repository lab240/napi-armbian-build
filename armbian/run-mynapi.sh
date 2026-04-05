#!/bin/bash
CLEAN_LEVEL=""
BUILD_DESKTOP_ARGS=""
BOARD="napi2"
HAS_ARGS=0
BUILD_TYPE=""
BRANCH=""
KERNEL_ONLY=""
SKIP_ARMBIAN=""
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
        --current)
            BRANCH="current"
            HAS_ARGS=1
            ;;
        --vendor)
            BRANCH="vendor"
            HAS_ARGS=1
            ;;
        --edge)
            BRANCH="edge"
            HAS_ARGS=1
            ;;
        --kernelonly)
            KERNEL_ONLY="yes"
            HAS_ARGS=1
            ;;
        --skiparmbian)
            SKIP_ARMBIAN="yes"
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
    echo "  --napi2          Build for NAPI2 (RK3568) [default]"
    echo ""
    echo "Branch (required for napi2):"
    echo "  --current        Use current branch"
    echo "  --vendor         Use vendor branch"
    echo "  --edge           Use edge branch"
    echo ""
    echo "Build type:"
    echo "  --desktop        Build with XFCE desktop (napi2 only)"
    echo "  --minimal        Build minimal console image"
    echo ""
    echo "Options:"
    echo "  --kernelonly     Build kernel only"
    echo "  --skiparmbian    Skip Armbian repo (if apt.armbian.com is down)"
    echo "  --noclean        Skip cache cleanup"
    echo "  --help           Show this help"
    exit 0
fi
if [ -z "${BRANCH}" ]; then
    if [ "${BOARD}" = "napic" ]; then
        BRANCH="current"
    else
        echo "Error: branch is required for napi2 (--current / --vendor / --edge)"
        exit 1
    fi
fi
if [ "${BOARD}" = "napic" ] && [ "${BUILD_TYPE}" = "desktop" ]; then
    echo "Error: desktop build is not supported for napic"
    exit 1
fi
# napic always minimal
if [ "${BOARD}" = "napic" ]; then
    BUILD_DESKTOP_ARGS="BUILD_MINIMAL=yes"
elif [ "${BUILD_TYPE}" = "desktop" ]; then
    BUILD_DESKTOP_ARGS="DESKTOP_ENVIRONMENT=xfce BUILD_DESKTOP=yes DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base DESKTOP_APPGROUPS_SELECTED="
elif [ "${BUILD_TYPE}" = "minimal" ]; then
    BUILD_DESKTOP_ARGS="BUILD_MINIMAL=yes"
fi
if [ "${KERNEL_ONLY}" = "yes" ]; then
    BUILD_ONLY_ARG="BUILD_ONLY=kernel"
else
    BUILD_ONLY_ARG=""
fi
# --skiparmbian как fallback если московское зеркало недоступно
SKIP_REPO_ARG=""
MIRROR_ARG=""
if [ "${SKIP_ARMBIAN}" = "yes" ]; then
    SKIP_REPO_ARG="SKIP_ARMBIAN_REPO=yes"
else
    MIRROR_ARG="LOCAL_MIRROR=stpete-mirror.armbian.com/apt"
fi

echo "${BRANCH}" > userpatches/overlay/napi-branch.txt

#DOWNLOAD_MIRROR="china"
./compile.sh BOARD=${BOARD} \
BRANCH=${BRANCH} \
RELEASE=noble \
KERNEL_CONFIGURE=no \
INSTALL_HEADERS=yes \
${MIRROR_ARG} \
${BUILD_ONLY_ARG} \
${SKIP_REPO_ARG} \
REVISION="$(date +%d%h-%H%M)" \
KEEP_ORIGINAL_OS_RELEASE="yes" \
${CLEAN_LEVEL} \
${BUILD_DESKTOP_ARGS}
