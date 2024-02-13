;; build-site.el -- Summary

;;; Commentary:
;;;; TODO Someday I will write something here. Till then ;)

;;; Code:
;; (load (expand-file-name "build-site.el" default-directory))

;; Load Configuration specifics
(load (expand-file-name "config.el" (file-name-directory load-file-name)))

;; ;; Load the publishing system
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)

(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'css)
(setq org-export-use-broken-links t)
(setq org-html-doctype "html5")

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
      org-html-head org-blog-head
      org-html-postamble comments-postamble)

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

(setq org-publish-project-alist
      (list

       (list "org-files"

	     :base-directory base-dir
	     :base-extension "org"
	     :exclude drafts-dir
	     :recursive t
	     :html-link-home "/index.html"
	     :html-link-up "../index.html"
	     :html-postamble general-postamble
	     :publishing-directory public-dir
	     :publishing-function 'org-html-publish-to-html
	     :with-author nil           ;; Don't include author name
	     :with-creator nil            ;; Include Emacs and Org versions in footer
	     :with-drawers t
	     :headline-level 4
	     :with-toc nil
	     :section-numbers nil       ;; Don't include section numbers
	     :html-link-home "/index.html"
	     :html-link-up "../index.html"

	     :time-stamp-file nil)

       (list "blog-posts"

	     :base-directory posts-dir
	     :base-extension "org"
	     :exclude ".*index.org"

	     :recursive t

	     :html-link-up "./index.html"
	     :html-link-home "/index.html"

	     :html-postamble  comments-postamble
	     :publishing-directory posts-public-dir
	     :publishing-function 'org-html-publish-to-html

	     :with-author t           ;; Don't include author name
	     :with-creator t            ;; Include Emacs and Org versions in footer
	     :with-drawers t
	     :with-date t
	     :headline-level 4
	     :with-toc t                ;; Include a table of contents
	     :section-numbers nil       ;; Don't include section numbers
	     :time-stamp-file nil)

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
  "Publish a file. FILENAME is the filename of the Org file to be
published. PLIST is the property list for the given project.
PUB-DIR is the publishing directory. Take care of minimizing the
pictures using imagemagick. Return output file name."
  (unless (file-directory-p pub-dir)
    (make-directory pub-dir t))
  (or (equal (expand-file-name (file-name-directory filename))
	     (file-name-as-directory (expand-file-name pub-dir)))
      (let ((dst-file (expand-file-name (file-name-nondirectory filename) pub-dir)))
	(if (string-match-p ".*\\.\\(png\\|jpg\\|gif\\)$" filename)
	    (shell-command (format "convert %s -resize 1920x1080\\> +dither -colors 16 -depth 4 %s" filename dst-file))
	  (copy-file filename dst-file t)))))

(org-publish-all)
;; (chatziiola/org-static-blog-assemble-index-no-content)
;;; build-site.el ends here.
