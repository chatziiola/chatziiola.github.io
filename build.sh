#!/bin/sh

 This is for when working locally, to test changes
if [[ -d public ]]
then
    rm -rf public && echo "Local directory deleted"
fi

emacs -Q --script build-site.el
