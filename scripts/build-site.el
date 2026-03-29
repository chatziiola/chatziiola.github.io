;; build-site.el -- Summary

;;; Commentary:
;;;; TODO Someday I will write something here. Till then ;)

;;; Code:
;; Load Configuration specifics
(add-to-list 'load-path "~/Github/chatziiola.github.io/scripts")
(add-to-list 'load-path "~/Github/org-cache")

;; ;; Load the publishing system
(require 'config)
(require 'org-publish-rss)
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)
(require 'htmlize)

;; TODO migrate to org-cache
(require 'org-cache)
(require 'blog-index)

;; TODO REMOVE
(setq blog-index-dir posts-dir)

;; TODO REMOVE
(if (blog-index-get-posts)
    (message "Index generated"))

;; TODO to config
(setq tags-blacklist '("index"))
(setq tags-dir (expand-file-name "tags" base-dir))

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
      org-html-preamble org-blog-navigation
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


(defun post-entry (file title &optional date description)
  (concat
   (format "<a class=\"home-post-item\" href=\"/%s.html\">" file )
   (format "<span class=\"home-post-title\">%s</span>" title)
   (if date (format "<span class=\"home-post-date timestamp\">%s</span>" date))
   (if description (format "<span class=\"home-post-description timestamp\">%s</span>" description))
   "</a>"
   ))

(defun post-section (title content &optional description subtitle)
  (concat "#+TITLE: " title "\n"
	  (if subtitle (concat "#+SUBTITLE:" subtitle "\n"))
	  description "\n"
	  "#+begin_export html\n"
	  "<section class=\"home-posts\">\n"
	  content "\n"
	  "</section>"
	  "\n#+end_export"))

(defun my-sitemap-entry (entry style project)
  "Customized sitemap entry creation function with Date, Title, Description, and Tags.
Filters out drafts and indices, returning empty strings."
  (if (and (not (directory-name-p entry))
	   (file-is-blog-post (expand-file-name entry blog-index-dir)))
      (let* ((post (blog-index-get-post entry))
	     (file (file-name-sans-extension (file-relative-name (plist-get post :file) base-dir)))
	     (date (plist-get post :date))
	     (title (plist-get post :title)))
	(post-entry file title date)
	)
    ""))

(defun my-sitemap-function (title list)
  "Customized sitemap function to exclude empty entries and handle the style symbol."
  (let* ((entries (cdr list)) ;; Removes 'unordered symbol
	 (fixedlist (seq-filter (lambda (i)
				  (and (listp i)
				       (not (string-empty-p (car i)))))
				entries)))
    (post-section title (mapconcat (lambda (x) (format "%s" (car x))) fixedlist "\n") nil  "[[https://www.youtube.com/watch?v=jPWNcfrZzBE][again?!]]")))

(defun create-tag-index (tag-list)
  (let* ((file-path (expand-file-name "tags/index.org" base-dir))
	 (content (mapconcat (lambda (c)
			       (let ((tag (car c))
				     (taglen (cdr c)))
				 (post-entry (concat "tags/" tag) tag nil taglen)))
			     tag-list "\n")))
    (write-region (post-section "Tags" content "Not half bad") nil file-path)))

(defun tag-entry (entry)
  "Customized sitemap entry creation function with Date, Title, Description, and Tags.
Filters out drafts and indices, returning empty strings."
  (let* ((filepath (org-mnode-file entry))
	 (file (file-name-sans-extension (file-relative-name filepath base-dir)))
	 (title (org-mnode-title entry))
	 (date (plist-get (org-mnode-properties entry) :date)))
    (post-entry file title date)))

(defun create-tag-file (tag tag-entries)
  "Creates an org mode index file for TAG using a list of TAG-ENTRIES."
  (let* ((file-path (expand-file-name (concat "tags/" tag ".org") base-dir))
	 ;; TODO implement sorting here
	 (content (mapconcat #'tag-entry tag-entries "\n")))
    (write-region (post-section tag content) nil file-path)))

(let* ((org-cache-mnode-default-properties-list '("DATE" "DRAFT"))
       (c (org-cache-get posts-dir t))
       (h (make-hash-table :test 'equal)))
  ;; 1: Populate Hash Table with lists of entries
  (dolist (entry c)
    (let ((draft (plist-get (org-mnode-properties entry) :draft))
	  (tags (org-mnode-tags entry)))
      (unless (string= draft "t")
	(dolist (tag tags)
	  (unless (member tag tags-blacklist)
	    (puthash tag
		     (cons entry (gethash tag h))
		     h))
	  ))))
  ;; 2.0: Ensure that the tags directory is empty:
  (delete-directory tags-dir t)
  (make-directory tags-dir)

  ;; 2: Create tags file for every tag
  (dolist (tag (hash-table-keys h))
    (create-tag-file tag (gethash tag h)))


  ;; 3: Create master tag file index
  (let ((tag-list (mapcar (lambda (k) (cons k (length (gethash k h))))
			  (hash-table-keys h))))
    (create-tag-index tag-list))
  )
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
       (list "tags"
	     :base-directory (expand-file-name "tags" base-dir)
	     :recursive t
	     :html-postamble general-postamble
	     :publishing-directory (expand-file-name "tags" public-dir)
	     :publishing-function 'org-html-publish-to-html
	     :headline-level 4
	     :with-toc nil
	     :section-numbers nil
	     :time-stamp-file nil)
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
;;; build-site.el ends here.
