#!/bin/bash
# compile-overlay.sh <name>
# Example: ./compile-overlay.sh lvds

NAME="$1"
if [ -z "$NAME" ]; then
    echo "Usage: $0 <overlay_name>"
    exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
SRC="${SCRIPT_DIR}/userpatches/overlay/overlays-rk3568-vendor"
KERNEL=${KERNEL:-${SCRIPT_DIR}/cache/sources/linux-kernel-worktree/6.1__rk35xx__arm64}
WORK="/tmp/overlay-compile-work"

DTS_SRC="${SRC}/${NAME}.dts"
if [ ! -f "$DTS_SRC" ]; then
    echo "[ FAIL ] Not found: ${DTS_SRC}"
    exit 1
fi

mkdir -p "$WORK"
cp "$DTS_SRC" "$WORK/"

DTBO="/tmp/${NAME}.dtbo"

cpp -nostdinc \
    -I ${KERNEL}/include \
    -I ${KERNEL}/arch/arm64/boot/dts \
    -I ${KERNEL}/arch/arm64/boot/dts/rockchip \
    -undef -x assembler-with-cpp \
    "${WORK}/${NAME}.dts" | \
dtc -@ -I dts -O dtb -o "$DTBO" - \
&& echo "[ OK ] ${DTBO}" \
|| echo "[ FAIL ] ${NAME}"
