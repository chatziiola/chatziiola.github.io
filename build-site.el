;; build-site.el -- Summary
;;; Commentary:
;;;  TODO update the .org file
;;;  - [ ] add disclaimer to never edit this file again
;;;  - [ ] updates taken from https://her.esy.fun/posts/0001-new-blog/index.html

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variable declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar domainname "https://chatziiola.github.io"
  "Self-Descriptive.")

(defvar base-dir "./content/"
  "The content directory.")

(defvar public-dir "./public/"
  "The root directory of our webserver.")

(defvar drafts-dir (concat base-dir "drafts/")
  "To be ignored when publishing.")

(defvar posts-dir (expand-file-name "posts/" base-dir)
  "Subfolder of content where posts lie.")

(defvar posts-public-dir (expand-file-name "posts/" public-dir)
  "The public subfolder in which posts will be published.")

(defvar src-dir "./content/src/"
  "Self-descriptive.")

(defvar src-public-dir "./public/src/"
  "Self-descriptive.")

(defvar css-path "/src/rougier.css"
  "Self-descriptive.")

(defvar org-blog-head
  (concat
   "<link rel=\"preconnect\" href=\"https://fonts							.	googleapis.com\">"
   "<link rel=\"preconnect\" href=\"https://fonts							.	gstatic.com\" crossorigin=\"\">"
   "<link href=\"https://fonts									.	googleapis.com/css2?family=Fira+Sans+Condensed&amp;family=Manrope&amp;family=Roboto+Condensed:wght@300&amp;display=swap\" rel=\"stylesheet\">"
   "<link rel=\"stylesheet\" href=\"" css-path "\" />
    <link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">"
   "<meta charset=\"UTF-8\" name=\"viewport\" content=\"width=device-width, initial-scale=1	.	0\">"
   "<link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/styles/default.min.css\">"
   "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.7.0/highlight.min.js\"></script>"
   "<script>hljs.highlightAll();</script>"
   )
  "Description - BLOG HTML HEAD.")

(defvar general-postamble
  "<p class=\"footer\"> Made with Emacs and Org.<br>CSS theme based on the one developed by <a href=\"https://github.com/rougier\">@rougier</a>.</p>"
  "To be used on all pages.")

(defvar comments-postamble
  (concat
   "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script>"
   "<p class=\"date footer\"> Originally created on %d </p>"
   general-postamble)
  "Postamble for posts so that giscus comments are enabled.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-static-blog index variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; These were set up on a need-to-set basis

(setq org-static-blog-enable-tags t)
(setq org-static-blog-index-file "recents.html")
(setq org-static-blog-index-front-matter org-blog-head)
(setq org-static-blog-index-length 50)
(setq org-static-blog-posts-directory "./content/posts/")
(setq org-static-blog-page-postamble general-postamble)
(setq org-static-blog-publish-directory "./public/posts/")
(setq org-static-blog-publish-title "Recent Articles")
(setq org-static-blog-publish-url "https://chatziiola.github.io")
(setq org-static-blog-index-front-matter "")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Avoid trash - Basic Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(setq user-emacs-directory (expand-file-name "./.packages"))
(setq package-user-dir user-emacs-directory)

;;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))


;; Load the publishing system
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)

;; Install dependencies
;; htmlize is needed for proper code formatting:
;; https://stackoverflow.com/questions/24082430/org-mode-no-syntax-highlighting-in-exported-html-page
(eval-when-compile
  (add-to-list 'load-path (expand-file-name "use-package" default-directory))
  (require 'use-package))

(use-package htmlize)

; DO NOT UNCOMMENT THESE LINES. THE PROBLEM LIES WITH USE PACKAGE. The alternative is to use org-ref locally and export to org buffers before publishing
;(use-package org-ref)
;(setq bibtex-completion-bibliography org-ref-default-bibliography)
;(setq bibtex-completion-library-path org-ref-pdf-directory)
;(setq bibtex-completion-notes-path org-ref-notes-directory)
;(setq bibtex-autokey-name-case-convert-function 'capitalize)
;(setq bibtex-autokey-name-year-separator "")
;(setq bibtex-autokey-titleword-length 5)
;(setq bibtex-autokey-titleword-separator "")
;(setq bibtex-autokey-titlewords 2)
;(setq bibtex-autokey-titlewords-stretch 1)
;(setq bibtex-autokey-year-length 4)
;(setq bibtex-autokey-year-title-separator "")

(message "And this is my default directory: %s" default-directory)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Beautification - org publish settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'css)
					;(setq org-html-htmlize-font-prefix "org-")

(setq org-src-fontify-natively t		; Fontify code in code blocks.
      org-adapt-indentation nil			; Adaptive indentation
      org-src-tab-acts-natively t		; Tab acts as in source editing
      org-confirm-babel-evaluate nil		; No confirmation before executing code
      org-edit-src-content-indentation 2	; No relative indentation for code blocks
      org-fontify-whole-block-delimiter-line t) ; Fontify whole block


;; Customize the HTML output
(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-indent nil
      org-html-self-link-headlines t
      org-export-with-tags t
      org-export-with-smart-quotes t
      org-html-head org-blog-head)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Babel
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (gnuplot . t)
   (haskell . nil)
   (latex . t)
   (octave . t)
   (python . t)
   (matlab . t)
   (shell . t)
   (ruby . t)
   (sql . nil)
   (sqlite . t)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Publishing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-publish-project-alist
      (list
       ;; Unnecesary and time consuming
       ;; FIXME: org-static-blog.el for index files
       (list "Index files"
	     :base-directory base-dir
	     :base-extension "org"
	     :exclude drafts-dir
	     :headline-level 4
	     :html-link-home "/index.html"
	     :html-link-up "../index.html"
	     :html-postamble general-postamble
	     :publishing-directory public-dir
	     :publishing-function 'org-html-publish-to-html
	     :recursive t
	     :section-numbers nil    ;; Don't include section numbers
	     :time-stamp-file nil
	     :with-drawers t
	     :with-toc nil
	     )
       (list "Blog posts"
	     :base-directory posts-dir
	     :base-extension "org"
	     :exclude ".*index.org"
	     :headline-level 4
	     :html-link-home "/index.html"
	     :html-link-up "./index.html"
	     :html-postamble  comments-postamble
	     :publishing-directory posts-public-dir
	     :publishing-function 'org-html-publish-to-html
	     :recursive t
	     :section-numbers nil    ;; Don't include section numbers
	     :time-stamp-file nil
	     :with-date t
	     :with-drawers t
	     :with-toc t             ;; Include a table of contents
	     )
       (list "Images"
	     :base-directory posts-dir
	     :base-extension "png"
	     :publishing-directory posts-public-dir
	     :publishing-function 'org-blog-publish-attachment
	     :recursive t
	     )
       (list "Website static stuff"
	     :base-directory src-dir
	     :base-extension "html\\|css\\|ico"
	     :publishing-directory src-public-dir
	     :publishing-function 'org-publish-attachment
	     :recursive t
	     )
       )
      )


;; Automatic image conversion
(defun org-blog-publish-attachment (plist filename pub-dir)
  "Publish a file with no transformation of any kind.
FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.
Take care of minimizing the pictures using imagemagick.
Return output file name."
  (unless (file-directory-p pub-dir)
    (make-directory pub-dir t))
  (or (equal (expand-file-name (file-name-directory filename))
	     (file-name-as-directory (expand-file-name pub-dir)))
      (let ((dst-file (expand-file-name (file-name-nondirectory filename) pub-dir)))
	(if (string-match-p ".*\\.\\(png\\|jpg\\|gif\\)$" filename)
	    (shell-command (format "convert %s -resize 800x800\\> +dither -colors 16 -depth 4 %s" filename dst-file))
	  (copy-file filename dst-file t)))))

					; Generate the site output
(org-publish-all t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-static-blog for index creation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load (expand-file-name "index-generator.el" default-directory))
(chatziiola/org-static-blog-assemble-index-no-content)

;;; build-site.el ends here.
