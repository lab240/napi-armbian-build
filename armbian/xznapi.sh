#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <firmware-id>"
    echo "Example: $0 0201"
    exit 1
fi

ID="$1"

XZ=$(ls output/images/*${ID}*.img.xz 2>/dev/null | head -1)

if [ -n "$XZ" ]; then
    echo "Found existing .xz: $XZ"
    echo "Generating checksum..."
    sha256sum "$XZ" > "${XZ}.sha256"
    echo "Done:"
    ls -lh "$XZ" "${XZ}.sha256"
    exit 0
fi

IMG=$(ls output/images/*${ID}*.img 2>/dev/null | head -1)

if [ -z "$IMG" ]; then
    echo "Error: no .img or .img.xz file found for ID=${ID} in output/images/"
    echo "Available images:"
    ls output/images/*.img output/images/*.img.xz 2>/dev/null
    exit 1
fi

echo "Compressing $IMG ..."
xz -9 -kv -T8 "$IMG" -c > "${IMG}.xz"

echo "Generating checksum..."
sha256sum "${IMG}.xz" > "${IMG}.xz.sha256"

echo "Done:"
ls -lh "${IMG}.xz" "${IMG}.xz.sha256"
