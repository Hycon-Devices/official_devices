#!/bin/bash

git config --global user.email "rzlamrr.dvst@protonmail.com"
git config --global user.name "rzlamrr"

python tools/merge.py

for i in $(find . -type f -iname '*.json')
do
    mkdir tmp
    python -m json.tool < $i > tmp/format.json
    mv tmp/format.json $i
    rm -rf tmp
done