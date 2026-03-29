;; blog-collections.el -- Summary

;;; Description
;;;; This file:
;;;; - [X] Handles the generation of tag-specific pages: `create-tags-pages'
;;;;;; - configurable via `tags-dir', `tags-blacklist'
;;;; - [ ] Handles the generation of ARCHIVE: `create-archive'
;;;; - [ ] Handles the generation of sitemap.xml`create-tags-pages'
;;;; - [ ] Handles the generation of rss`create-tags-pages'
;;;; - [ ] Includes the attachment publish function TODO
;;;;   - TODO Make this check for "unlinked" statics

(require 'cl-lib)
(require 'config)
(require 'org-cache)

;; WARNING: FORCE WITH t INSTEAD OF nil if doing major changes
;;(setq posts-dir "~/Github/chatziiola.github.io/content/posts")
(setq blog-cache (org-cache-get posts-dir nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun file-is-index (filename)
  "Whether a file is an index file"
  (let ((f (file-name-nondirectory filename)))
    (member f index-file-list)))

;; Whether or not to include
(defun file-is-blog-post (filename)
  "Whether a non-index file is a draft or not"
  (let* ((filepath (expand-file-name filename))
	 (entry (cl-find filepath blog-cache :test #'string= :key #'org-mnode-file))
	 (post (not (file-is-index filename)))
	 (draft (if entry (string= (plist-get (org-mnode-properties entry) :draft) "t") nil)))
    (message "%s %s %s" entry post draft)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Publishing functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-publish-index (plist filename pub-dir)
  "Publish FILENAME only if it is an index.org file."
  (when (file-is-index filename)
    (org-html-publish-to-html plist filename pub-dir)))

(defun my-publish-blog-posts (plist filename pub-dir)
  "Publish FILENAME only if it does not have a DRAFT property set to t."
  (if (file-is-blog-post filename)
      (org-html-publish-to-html plist filename pub-dir)
      "index.html"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HTML functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-defun html--item-entry (file title &key date description)
  (concat
   (format "<a class=\"home-post-item\" href=\"/%s.html\">" file )
   (format "<span class=\"home-post-title\">%s</span>" title)
   (if date (format "<span class=\"home-post-date timestamp\">%s</span>" date))
   (if description (format "<span class=\"home-post-description timestamp\">%s</span>" description))
   "</a>"
   ))

(cl-defun html--collection-org-file (filename title content &key description subtitle)
  (write-region (concat "#+TITLE: " title "\n"
			(if subtitle (concat "#+SUBTITLE:" subtitle "\n"))
			(if description (concat description "\n"))
			"#+begin_export html\n"
			"<section class=\"home-posts\">\n"
			content "\n"
			"</section>"
			"\n#+end_export")
		nil filename))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Attachment functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define our two sorting strategies as standalone functions
(defun tags-sort--alphabetical (a b)
  "Sort tags alphabetically by name."
  (string< (car a) (car b)))

(defun tags-sort--articles (a b)
  "Sort tags numerically by the number of articles (descending)."
  (> (cdr a) (cdr b)))

(defun tags--mnode-html-entry (entry)
  "Turns an org-mnode ENTRY into a full <html> entry.
Uses `html--item-entry' to ensure conformity."
  (let* ((filepath (org-mnode-file entry))
	 (file (file-name-sans-extension (file-relative-name filepath base-dir)))
	 (title (org-mnode-title entry))
	 (date (plist-get (org-mnode-properties entry) :date)))
    (html--item-entry file title :date date)))

(defun tags--generate-index-org (tag-list)
  "Given TAG-LIST, it creates index.org, using `tag-sorting-function'"
  (let* ((file-path (expand-file-name "index.org" tags-dir))
	 (sorted-list (sort tag-list tag-sorting-function))
	 (content (mapconcat (lambda (c)
			       (let ((tag (car c))
				     (taglen (cdr c)))
				 (html--item-entry (concat "tags/" tag) tag :description taglen)))
			     sorted-list "\n")))
    (html--collection-org-file file-path "Tags" content :description "Not half bad")))


(defun tags--generate-tag-org (tag tag-entries)
  "Creates an org mode index file for TAG using a list of TAG-ENTRIES sorted newest first."
  (let* ((file-path (expand-file-name (concat tag ".org") tags-dir))
         ;; Sort tag-entries by date in descending order
         (sorted-entries (sort (copy-sequence tag-entries)
                               (lambda (a b)
                                 (let ((date-a (plist-get (org-mnode-properties a) :date))
                                       (date-b (plist-get (org-mnode-properties b) :date)))
                                   (string> date-a date-b)))))
         (content (mapconcat #'tags--mnode-html-entry sorted-entries "\n")))
    (html--collection-org-file file-path tag content)))

(defun create-tag-pages ()
  "Handles everything around tags:
1. Populate Hash Table with lists of entries
2. Ensure that the tags directory is empty:
3. Create tags file for every tag
4. Create master tag file index
"
  (let* ((org-cache-mnode-default-properties-list '("DATE" "DRAFT"))
	 (h (make-hash-table :test 'equal)))
    (dolist (entry blog-cache)
      (let ((draft (plist-get (org-mnode-properties entry) :draft))
	    (tags (org-mnode-tags entry)))
	(unless (string= draft "t")
	  (dolist (tag tags)
	    (unless (member tag tags-blacklist)
	      (puthash tag
		       (cons entry (gethash tag h))
		       h))))))
    (delete-directory tags-dir t)
    (make-directory tags-dir)

    (dolist (tag (hash-table-keys h))
      (tags--generate-tag-org tag (gethash tag h)))

    (let ((tag-list (mapcar (lambda (k) (cons k (length (gethash k h))))
			    (hash-table-keys h))))
      (tags--generate-index-org tag-list))
    ))

					;
(defun my-sitemap-entry (entry style project)
  "Customized sitemap entry creation function with Date, Title, Description, and Tags.
Filters out drafts and indices, returning empty strings."
  (if (and (not (directory-name-p entry))
	   (file-is-blog-post (expand-file-name entry blog-index-dir)))
      (let* ((post (blog-index-get-post entry))
	     (file (file-name-sans-extension (file-relative-name (plist-get post :file) base-dir)))
	     (date (plist-get post :date))
	     (title (plist-get post :title)))
	(html--item-entry file title :date date)
	)
      ""))

(defun my-sitemap-function (title list)
  "Customized sitemap function to exclude empty entries and handle the style symbol."
  (let* ((sitemap-file "BULLSHIT")
	 (entries (cdr list)) ;; Removes 'unordered symbol
	 (fixedlist (seq-filter (lambda (i)
				  (and (listp i)
				       (not (string-empty-p (car i)))))
				entries)))
    (html--collection-org-file sitemap-file title
			       (mapconcat (lambda (x) (format "%s" (car x))) fixedlist "\n")
			       :subtitle "[[https://www.youtube.com/watch?v=jPWNcfrZzBE][again?!]]")))

;; (defun create-archive ()
;;   )

(provide 'blog-collections)
