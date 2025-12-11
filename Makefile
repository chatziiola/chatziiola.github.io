# Makefile for building and publishing a site
# Directories
PUBLIC_DIR := ./docs
POSTS_PUBLIC_DIR := $(PUBLIC_DIR)/posts
LOCAL_DIR := content
SHELL := /bin/bash

# Targets
.DEFAULT_GOAL := local

sitemap_py:
	@echo "Generating sitemap with python"
	python3 scripts/generate_sitemap.py

runPy:
	@echo "Creating indices with python"
	python3 scripts/working.py

minify:
	mkdir -p docs/src
	npx csso-cli content/src/rougier.css -o docs/src/rougier.min.css
	npx uglifyjs content/src/copy-pre.js -o docs/src/copy-pre.min.js
	npx uglifyjs content/src/theme-switcher.js -o docs/src/theme-switcher.min.js

# Remove local directory
clean:
	echo "Cleaning public dir"
	@if [ -d $(PUBLIC_DIR) ]; then \
	    rm -rf $(PUBLIC_DIR) && echo "Local directory deleted"; \
	fi
	rm ~/.org-timestamps/*.cache

# Necessary for publishing purposes
# add_cname:
# 	#echo "blog.chatziiola.live" > $(PUBLIC_DIR)/CNAME
# Build the site using Emacs
build_emacs:
	@echo "Running emacs build"
	emacs -Q --script scripts/build-site.el 

build: minify sitemap_py build_emacs copy_static

copy_static:
	cp -r $(LOCAL_DIR)/src $(PUBLIC_DIR)
	cp $(LOCAL_DIR)/src/robots.txt $(PUBLIC_DIR)

# Serve the public directory on localhost using Python
serve_local:
	cd $(PUBLIC_DIR) && python3 -m http.server

local: build copy_static serve_local
