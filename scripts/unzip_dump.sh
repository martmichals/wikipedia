#!/bin/bash

# Bash coloring macros
RED='\033[0;31m'
RESET='\033[0m'

# Exit on any error
set -e

# Path to dump
DUMP=$1
if [ ! -d $DUMP ] || [ "${#DUMP}" -lt 1 ]; then
    echo -e "$RED Invalid dump directory: $RESET$DUMP"
    exit 1
fi

# Output directory
OUTPUT=$DUMP/unzipped
if [ ! -d $DUMP/unzipped ]; then
    echo "Creating directory for unzipped files: $OUTPUT" 
    mkdir $OUTPUT
fi

# Extract all files, move to output directory
for filepath in $DUMP/*.bz2; do
    echo "Unzipping $filepath"
    bzip2 -dk $filepath
    mv "${filepath::-4}" $OUTPUT
done

# TODO: Incorporate the command below into a script
# wikiextractor --processes 32 -o ./plain-text/ ./unzipped/enwiki-20211020-pages-articles-multistream.xml 
