#!/bin/sh
FORCE=0
SHOW_ONLY=0
PATTERNS=""

for arg in "$@"; do
    case $arg in
        -y) FORCE=1 ;;
        -s) SHOW_ONLY=1 ;;
        -*) echo "Unknown option: $arg"; exit 1 ;;
        *) PATTERNS="$PATTERNS $arg" ;;
    esac
done

if [ "$SHOW_ONLY" = "1" ]; then
    REMAINING=$(ls output/images/ 2>/dev/null)
    if [ -n "$REMAINING" ]; then
        ls -lh output/images/
    else
        echo "output/images/ is empty"
    fi
    exit 0
fi

if [ -z "$PATTERNS" ]; then
    echo "Usage: $0 [-y] [-s] <pattern1> [pattern2] ... [patternN]"
    echo "Deletes all files matching output/images/*pattern* for each pattern"
    echo "  -y  Skip confirmation"
    echo "  -s  Show contents of output/images/ only"
    exit 1
fi

ALL_FILES=""
for pat in $PATTERNS; do
    FOUND=$(ls output/images/*"$pat"* 2>/dev/null)
    if [ -n "$FOUND" ]; then
        ALL_FILES="$ALL_FILES
$FOUND"
    else
        echo "No files matching: *$pat*"
    fi
done

ALL_FILES=$(echo "$ALL_FILES" | sort -u | sed '/^$/d')

if [ -z "$ALL_FILES" ]; then
    echo "Nothing to delete"
    exit 0
fi

echo "Will delete:"
echo "$ALL_FILES"
echo ""
COUNT=$(echo "$ALL_FILES" | wc -l)
echo "Total: $COUNT file(s)"

DO_DELETE=0
if [ "$FORCE" = "1" ]; then
    DO_DELETE=1
else
    printf "Continue? [y/N] "
    read answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        DO_DELETE=1
    else
        echo "Cancelled"
    fi
fi

if [ "$DO_DELETE" = "1" ]; then
    echo "$ALL_FILES" | xargs rm -f
    echo "Done"
    echo ""
    REMAINING=$(ls output/images/ 2>/dev/null)
    if [ -n "$REMAINING" ]; then
        echo "Remaining in output/images/:"
        ls -lh output/images/
    else
        echo "output/images/ is empty"
    fi
fi
