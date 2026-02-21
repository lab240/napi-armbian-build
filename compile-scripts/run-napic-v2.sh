#!/bin/sh

./compile.sh \
  BOARD=napic \
  BRANCH=current \
  RELEASE=noble \
  BUILD_MINIMAL=yes \
  BUILD_DESKTOP=no \
  KERNEL_CONFIGURE=no \
  DEST_LANG="en_US.UTF-8" \
  TIMEZONE="Europe/Moscow" 

#  REVISION="$(date +%d%h-%H%M)" \
