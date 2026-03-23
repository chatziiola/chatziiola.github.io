# Makefile for building and publishing a site
# Directories
PUBLIC_DIR := ./docs
POSTS_PUBLIC_DIR := $(PUBLIC_DIR)/posts
LOCAL_DIR := content
SHELL := /bin/bash

# Targets
.DEFAULT_GOAL := preview

install_js:
	@if [ ! -d "node_modules" ]; then \
		echo "Installing JS dependencies..."; \
		npm install csso-cli uglify-js pagefind; \
	fi

minify: install_js
	mkdir -p docs/src
	npx csso-cli content/src/rougier.css -o docs/src/rougier.min.css
	npx uglifyjs content/src/copy-pre.js -o docs/src/copy-pre.min.js
	npx uglifyjs content/src/theme-switcher.js -o docs/src/theme-switcher.min.js
	@if [ -f content/src/search.js ]; then \
		npx uglifyjs content/src/search.js -o docs/src/search.min.js; \
	fi

pagefind:
	npx pagefind --site $(PUBLIC_DIR)

# Remove local directory
clean:
	echo "Cleaning public dir"
	@if [ -d $(PUBLIC_DIR) ]; then \
	    rm -rf $(PUBLIC_DIR) && echo "Local directory deleted"; \
	fi
	rm -rf ~/.org-timestamps/*.cache

# Necessary for publishing purposes
add_cname:
	echo "blog.chatziiola.live" > $(PUBLIC_DIR)/CNAME

# Build the site using Emacs
build_emacs:
	@echo "Running emacs build"
	emacs -Q --script scripts/build-site.el 


copy_static:
	cp -r $(LOCAL_DIR)/src $(PUBLIC_DIR)
	cp $(LOCAL_DIR)/src/robots.txt $(PUBLIC_DIR)

build: minify build_emacs copy_static pagefind

preview:
	@echo "Will now preview locally; make sure to use publish later on"
	$(MAKE) build 
	trap 'git restore $(PUBLIC_DIR)' SIGINT; python3 -m http.server -d $(PUBLIC_DIR)

publish:
	@echo "Publishing. Make sure to have DRAFT on unfinished posts"
	git restore docs/
	$(MAKE) build 

