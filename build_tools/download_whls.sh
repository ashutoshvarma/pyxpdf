#!/usr/bin/env bash

REL=https://api.github.com/repos/ashutoshvarma/pyxpdf/releases/latest

# make dist
mkdir -p dist

while IFS= read -r j; do 
    echo "Downloading $(basename $j)"
    wget  -q --show-progress --progress=bar:force -P dist $j 2>&1
done < <(curl -s $REL | grep -Pho "(?<=browser_download_url\": \")(.+)(?=\s*\")")



