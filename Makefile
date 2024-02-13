# Makefile for building and publishing a site
# Directories
PUBLIC_DIR := ./docs
POSTS_PUBLIC_DIR := $(PUBLIC_DIR)/posts
LOCAL_DIR := content
SHELL := /bin/bash

# Targets
.DEFAULT_GOAL := local

runPy:
	python3 scripts/working.py
# Remove local directory
clean:
	echo "Cleaning public dir"
	@if [ -d $(PUBLIC_DIR) ]; then \
	    rm -rf $(PUBLIC_DIR) && echo "Local directory deleted"; \
	fi
	rm ~/.org-timestamps/*.cache

# Necessary for publishing purposes
add_cname:
	echo "blog.chatziiola.live" > $(PUBLIC_DIR)/CNAME

# Build the site using Emacs
build: runPy
	echo "Building the site"
	emacs -Q --script scripts/build-site.el >/dev/null

copy_static:
	cp -r $(LOCAL_DIR)/src $(PUBLIC_DIR)

# Add latest posts to /index.html
add_latest_posts:
	echo "Adding latest posts (archive) on /index.html"
	echo '<ul class="org-ul indexul">' > /tmp/index
	grep "^<li>" $(POSTS_PUBLIC_DIR)/recents.html | head -5 >> /tmp/index
	echo '</ul>' >> /tmp/index
	sed -i -e '/Latest Articles<\/a><\/h2>/r /tmp/index' $(PUBLIC_DIR)/index.html

# Serve the public directory on localhost using Python
serve_local:
	cd $(PUBLIC_DIR) && python3 -m http.server

# Build the site locally

local: build copy_static add_cname serve_local 
