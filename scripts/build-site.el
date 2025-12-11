;; build-site.el -- Summary

;;; Commentary:
;;;; TODO Someday I will write something here. Till then ;)

;;; Code:
;; Load Configuration specifics
(add-to-list 'load-path "~/Github/chatziiola.github.io/scripts")

;; ;; Load the publishing system
(require 'config)
(require 'org-publish-rss)
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)
(require 'htmlize)

(setq make-backup-files nil)
(setq org-use-property-inheritance t)
(setq org-use-tag-inheritance t)
(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'css)
(setq org-export-use-broken-links t)
(setq org-html-doctype "html5")

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
      org-html-head org-blog-head
      org-html-preamble "<div id=\"org-div-home-and-up\"><a accesskey=\"H\" href=\"/index.html\"> HOME </a> | <button id=\"theme-toggle\" title=\"Toggle theme\">🌓</button></div>"
      org-html-postamble comments-postamble)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t) (gnuplot . t) (haskell . nil) (latex . t) (octave . t)
   (python . t) (matlab . t) (shell . t) (ruby . t) (sql . nil) (sqlite . t)))

;; Whether or not to include
(defun file-is-blog-post (filename)
  "Whether a non-index file is a draft or not"
  (when (not (file-is-index filename))
    (with-temp-buffer
      (insert-file-contents filename)
      (goto-char (point-min))
      (not (re-search-forward "^#\\+DRAFT:\\s-*t" nil t)))))

(defun file-is-index (filename)
  "Whether a file is an index file"
  (let ((f (file-name-nondirectory filename)))
    (member f index-file-list)))

(defun my-publish-index (plist filename pub-dir)
  "Publish FILENAME only if it is an index.org file."
  (when (file-is-index filename)
    (org-html-publish-to-html plist filename pub-dir)))

(defun my-publish-blog-posts (plist filename pub-dir)
  "Publish FILENAME only if it does not have a DRAFT property set to t."
  (if (file-is-blog-post filename)
      (org-html-publish-to-html plist filename pub-dir)
    "index.html"))

(defun my-sitemap-entry (entry style project)
  "Customized sitemap entry creation function, to use my /nicer/ formatting.

It filters out drafts and indices, returning empty strings."
  (if (and (not (directory-name-p entry))
	   (file-is-blog-post (expand-file-name entry posts-dir)))
      (let* ((date (org-publish-find-date entry project)))
	(format "%s[[file:%s][%s]]"
		(if date (format-time-string "[%Y-%m-%d] " date) "")
		entry
		(org-publish-find-title entry project)))
    "")
  )

(defun my-sitemap-function (title list)
  "Customized sitemap function to exclude the empty entries created by `my-sitemap-entry'"
  (let ((fixedlist (seq-filter (lambda (i) ( if (listp i) (not (member "" i)) t)) list)))
    (concat "#+TITLE: " title "\n\n"
	    (org-list-to-org fixedlist))))

(setq org-publish-project-alist
      (list
       (list "blog-posts"
       	     :base-directory posts-dir
       	     :recursive t
       	     :html-postamble  comments-postamble
       	     :publishing-directory posts-public-dir
       	     :publishing-function 'my-publish-blog-posts
       	     :with-author t
       	     :with-creator t
       	     :with-drawers t
       	     :with-date t
       	     :headline-level 4
       	     :with-toc t
       	     :section-numbers nil
       	     :time-stamp-file nil
	     :auto-rss t
	     :rss-file "rss.xml"
	     :rss-root-url "posts"
	     :rss-title "Chasing simplicity"
	     :rss-description "Shiiiz"
	     :rss-link "https://chatziiola.github.io/rss"
	     :rss-filter-function 'file-is-blog-post
	     :rss-with-content nil
	     :completion-function 'org-publish-rss
	     :auto-sitemap t
	     :sitemap-filename "recents.org"
	     :sitemap-title "Archive"
	     :sitemap-sort-files 'anti-chronologically
	     :sitemap-format-entry 'my-sitemap-entry
	     :sitemap-function 'my-sitemap-function
	     :sitemap-style 'list
	     )
       ;; Moved indices after blog posts, because index.org reads recents.org,
       ;; which is generated there
       (list "indices"
	     :base-directory base-dir
	     :recursive t
	     :html-postamble general-postamble
	     :publishing-directory public-dir
	     :publishing-function 'my-publish-index
	     :with-author nil
	     :with-creator nil
	     :with-drawers t
	     :headline-level 4
	     :with-toc nil
	     :section-numbers nil
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
       	     :base-extension "html\\|css\\|ico\\|png"
       	     :publishing-directory src-public-dir
       	     :publishing-function 'org-publish-attachment
       	     :recursive t
       	     )
       (list "Sitemap and Rss"
	     :base-directory base-dir
	     :base-extension "xml"
       	     :publishing-directory public-dir
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
	    (shell-command (format "magick %s -resize 1920x1080\\> +dither -colors 16 -depth 4 %s" filename dst-file))
	  (copy-file filename dst-file t)))))

(org-publish-all)
;; (chatziiola/org-static-blog-assemble-index-no-content)
;;; build-site.el ends here.
