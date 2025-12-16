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

(defvar org-blog-head (concat
			   (ini/get-value-from-file  "HTML" "FontImports" configini)
			   (ini/get-value-from-file  "HTML" "CustomJS" configini)
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
			   (ini/get-value-from-file  "GeneralPostamble" "css_attribution" configini)
			   (ini/get-value-from-file  "GeneralPostamble" "copyright" configini)
			   (ini/get-value-from-file  "GeneralPostamble" "end" configini)
			   font-awesome-container)
  "To be used on all pages.")

(defvar comments-postamble (concat
			    (ini/get-value-from-file  "CommentsPostamble" "giscusJS" configini)
			    (ini/get-value-from-file  "CommentsPostamble" "DateString" configini)
			    general-postamble)
  "Postamble for posts so that giscus comments are enabled.")

(defvar index-file-list '("index.org" "about.org" "404.org")
  "List of files that have the /index/ property, and thus should not be considered plain posts.")

(provide 'config)
;; config.el ends here
