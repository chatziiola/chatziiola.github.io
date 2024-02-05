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

(load (expand-file-name "ini.el" (file-name-directory load-file-name)))

;; Leaving this here
;; (ini/get-value-from-file "section" "property" "config.ini")

(defvar configini (expand-file-name "config.ini" (file-name-directory load-file-name))
  "Path to the configuration .ini file.")

;; Read values from the configuration file
(defvar domainname (ini/get-value-from-file  "Site" "DomainName" configini)
  "Self-Descriptive. It is the address for which we build our site")

(defvar base-dir (ini/get-value-from-file  "Paths" "BaseDir" configini)
  "The content directory.")

(defvar public-dir (ini/get-value-from-file  "Paths" "PublicDir" configini)
  "The root directory of our webserver.")

(defvar drafts-dir (ini/get-value-from-file  "Paths" "DraftsDir" configini)
  "To be ignored when publishing.")

(defvar posts-dir (expand-file-name (ini/get-value-from-file  "Paths" "PostsDir" configini) base-dir)
  "Subfolder of content where posts lie.")

(defvar posts-public-dir (ini/get-value-from-file  "Paths" "PostsPublicDir" configini)
  "The public subfolder in which posts will be published.")

(defvar src-dir (ini/get-value-from-file  "Paths" "SrcDir" configini)
  "Self-descriptive.")

(defvar src-public-dir (ini/get-value-from-file  "Paths" "SrcPublicDir" configini)
  "Self-descriptive.")

(defvar css-path (ini/get-value-from-file  "Paths" "CssPath" configini)
  "Self-descriptive.")

(defvar org-blog-head (ini/get-value-from-file  "HTML" "OrgBlogHead" configini)
  "Description - BLOG HTML HEAD.")

(defvar general-postamble (ini/get-value-from-file  "HTML" "GeneralPostamble" configini)
  "To be used on all pages.")

(defvar comments-postamble (concat(ini/get-value-from-file  "HTML" "CommentsPostamble" configini) general-postamble)
  "Postamble for posts so that giscus comments are enabled.")

;; (provide 'config)
;; config.el ends here
