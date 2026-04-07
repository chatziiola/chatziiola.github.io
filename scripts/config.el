;; config.el -- Summary

;;; Author: Lamprinos Chatziioannou

;;; Description: This file aims to hold all the variables needed among
;;; the different elisp files of my configuration. Not only do I want
;;; it to be the *only* non-functional point to edit in case something
;;; needs to change in my blog, but I also want to limit that
;;; functionality by basing as many of its options as reasonable in
;;; config.ini, to allow for easy variable modification throughout the
;;; blog's codebase

;;; Commentary:
;; DO BA DO BA DI

(require 'ini)

(defvar configini (expand-file-name "config.ini" (file-name-directory load-file-name))
  "Path to the configuration .ini file.")

;; Read values from the configuration file
(defvar domainname (ini/get-value-from-file  "Site" "DomainName" configini)
  "Self-Descriptive. It is the address for which we build our site")

(defvar base-dir (ini/get-value-from-file  "Site" "BaseDir" configini)
  "The content directory.")

(defvar public-dir (ini/get-value-from-file  "Site" "PublicDir" configini)
  "The root directory of our webserver.")

(defvar drafts-dir (ini/get-value-from-file  "Site" "DraftsDir" configini)
  "To be ignored when publishing.")

(defvar posts-dir (expand-file-name (ini/get-value-from-file  "Site" "PostsDir" configini) base-dir)
  "Subfolder of content where posts lie.")

(defvar posts-public-dir (ini/get-value-from-file  "Site" "PostsPublicDir" configini)
  "The public subfolder in which posts will be published.")

(defvar src-dir (ini/get-value-from-file  "Site" "SrcDir" configini)
  "Self-descriptive.")

(defvar src-public-dir (ini/get-value-from-file  "Site" "SrcPublicDir" configini)
  "Self-descriptive.")

(defvar css-path (ini/get-value-from-file  "Site" "CssPath" configini)
  "Self-descriptive.")

(defvar org-blog-navigation (ini/get-value-from-file  "HTML" "Navigation" configini)
  "Org blog navigation: Home, theme-switch")

(defvar org-blog-head (concat
			   ; (ini/get-value-from-file  "HTML" "FontImports" configini) ;; I think they are loaded from css all the same
			   ;; (ini/get-value-from-file  "HTML" "Ox-tagfilter-JS" configini)
			   (ini/get-value-from-file  "HTML" "CopyScript-JS" configini)
			   (ini/get-value-from-file  "HTML" "ThemeSwitcher-JS" configini)
			   (ini/get-value-from-file  "HTML" "Nav-JS" configini)
			   (ini/get-value-from-file  "HTML" "Pagefind-CSS" configini)
			   (ini/get-value-from-file  "HTML" "Pagefind-JS" configini)
			   (ini/get-value-from-file  "HTML" "Search-JS" configini)
			   (ini/get-value-from-file  "HTML" "Stylesheet" configini)
			   (ini/get-value-from-file  "HTML" "Favicon" configini)
			   (ini/get-value-from-file  "HTML" "FontAwesome" configini)
			   (ini/get-value-from-file  "HTML" "OrgBlogHead" configini))
  "Description - BLOG HTML HEAD.")

(defvar font-awesome-container (concat
				(ini/get-value-from-file  "FontAwesome" "start" configini)
				(ini/get-value-from-file  "FontAwesome" "github" configini)
				(ini/get-value-from-file  "FontAwesome" "linkedin" configini)
				(ini/get-value-from-file  "FontAwesome" "rss" configini)
				(ini/get-value-from-file  "FontAwesome" "end" configini))
  "FontAwesome container")

(defvar general-postamble (concat
			   (ini/get-value-from-file  "GeneralPostamble" "start" configini)
			   (ini/get-value-from-file  "GeneralPostamble" "made_with" configini)
			   ; (ini/get-value-from-file  "GeneralPostamble" "css_attribution" configini)
			   (ini/get-value-from-file  "GeneralPostamble" "copyright" configini)
			   (ini/get-value-from-file  "GeneralPostamble" "end" configini)
			   font-awesome-container)
  "To be used on all pages.")

(defvar comments-postamble (concat
			    (ini/get-value-from-file  "CommentsPostamble" "giscusJS" configini)
			    (ini/get-value-from-file  "CommentsPostamble" "DateString" configini)
			    general-postamble)
  "Postamble for posts so that giscus comments are enabled.")


;; TODO to config
(defvar tags-blacklist '("index")
  "TAGS to be excluded when generating TAGS-INDEX")

;; WARNING: Before modifying this know that "tags/" is heavily *hardcoded* in blog-collections.el
(defvar tags-dir (expand-file-name "tags" base-dir)
  "The directory in which TAGS are supposed to reside")

;; This is the "Switch" you can modify inline or via M-x customize
(defvar tag-sorting-function #'tags-sort--articles
  "The function used to sort the tag list.
   Set to `tags-sort--alphabetical' or `tags-sort--articles'.")

(defvar tags-blog-post-prefix "Tags:"
  "Snippet to be used in <header> prior to tags (IN ALL BLOG POSTS)")

(defvar tags-index-subtitle "All categories and keywords. Browse by topic:"
  "Snippet to be used in <header> prior to tags (IN ALL BLOG POSTS)")

(defvar tags-index-description ""
  "Snippet to be used in <header> prior to tags (IN ALL BLOG POSTS)")

(defvar archive-filename "recents.org"
  "Filename for ARCHIVE")

(defvar archive-title "Archive")
(defvar archive-subtitle "And all that is now, and all that is gone, and all that's to come... and everything under the sun")

(defvar index-file-list (list "index.org" "about.org" "404.org" archive-filename)
  "List of files that have the /index/ property, and thus should not be considered plain posts.")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ORG OPTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files nil)
(setq org-use-property-inheritance t)
(setq org-use-tag-inheritance t)
(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'css)
(setq org-export-use-broken-links t)
(setq org-html-doctype "html5")
(setq org-html-html5-fancy t)

(setq org-src-fontify-natively t)		; Fontify code in code blocks.
(setq org-adapt-indentation nil)		; Adaptive indentation
(setq org-src-tab-acts-natively t)		; Tab acts as in source editing
(setq org-confirm-babel-evaluate nil)		; No confirmation before executing code
(setq org-edit-src-content-indentation 2)	; No relative indentation for code blocks
(setq org-fontify-whole-block-delimiter-line t) ; Fontify whole block

;; Customize the HTML output
(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-indent nil
      org-html-self-link-headlines t
      org-export-with-tags t
      org-export-with-smart-quotes t
      org-export-headline-levels 4
      org-export-with-section-numbers nil
      org-export-timestamp-file nil
      org-html-head org-blog-head
      org-html-preamble org-blog-navigation
      org-html-postamble comments-postamble)

(setq org-publish-timestamp-directory "./export-cache/")

(provide 'config)
;; config.el ends here
