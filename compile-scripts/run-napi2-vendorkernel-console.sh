#!/bin/sh

./compile.sh \
BOARD=napi2 \
BRANCH=vendor \
RELEASE=noble \
BUILD_MINIMAL=yes \
BUILD_DESKTOP=no \
KERNEL_CONFIGURE=no \
EXTRA_PACKAGES="vim-tinyi net-tools can-utils mbpoll" 
