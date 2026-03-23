#!/bin/env zsh

mkdir -p docs/

files=($(find content/posts/ -type f -not -name '*.org'))
for f in $files; do
    filename=$(basename "$f")
    if ! rg -q -- "$filename" content/ scripts/ docs/; then
        echo "$f does not have a link, removing"
        rm $f
    fi
done

find content/posts -type f -name '*.org#' -exec rm {} \;
