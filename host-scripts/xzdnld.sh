#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <id>"
    exit 1
fi

ID="$1"
FILENAME="/d100/armbian/build/output/images/*-${ID}_*.img.xz"

echo "Look around $FILENAME"

FILE=$(ssh dmn@fz "ls ~/d100/armbian/build/output/images/*-${ID}_*.img.xz 2>/dev/null | head -1")

if [ -z "$FILE" ]; then
    echo "File not found for id: $ID"
    FILEIMG=$(ssh dmn@fz "ls ~/d100/armbian/build/output/images/*-${ID}_*.img 2>/dev/null | head -1")
    if [ "$FILEIMG" ]; then
       echo "-->Found IMG, compress it first to xz! "	   
    fi
    exit 1
fi

echo "Found: $FILE"
scp dmn@fz:$FILE .
