#!/bin/zsh

SAVENAME="data.tar.gpg"

set -e

if [[ -e data ]] {
    echo "already opened"
    exit 0
}

gpg -q -d $SAVENAME | tar x
echo "opened"
read
mv $SAVENAME $SAVENAME.bak
tar c data | gpg -e -r mojyack -o $SAVENAME
find data -type f -exec shred -u {} +
rm -r data
echo "closed"
