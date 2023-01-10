#!/bin/sh

# This is for when working locally, to test changes
if [[ -d public ]]
then
    rm -rf public && echo "Local directory deleted"
fi

emacs -Q --script build-site.el

# Add latest posts at the end of
echo "Adding mini archive on /index.html"
echo '<ul class="org-ul indexul">' >/tmp/index
grep "^<li>" public/posts/recents.html | head -5  >> /tmp/index
echo '</ul>' >> /tmp/index
# TODO make it add a ul environment as wel
sed -i -e '/Latest Articles<\/a><\/h2>/r /tmp/index'  ./public/index.html

# Copy /index.html to /posts/index.html
echo "Copying /index to /posts/index"
cp public/index.html public/posts/index.html
