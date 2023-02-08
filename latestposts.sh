#!/bin/sh

# Add latest posts at /index The reason why this was added here and not inside
# of build-site.el is the fact that index.org is published before recents is
# created and before enough html files exist
echo "Adding mini archive on /index.html"
echo '<ul class="org-ul indexul">' >/tmp/index
grep "^<li>" public/posts/recents.html | head -5  >> /tmp/index
echo '</ul>' >> /tmp/index
sed -i -e '/Latest Articles<\/a><\/h2>/r /tmp/index'  ./public/index.html
