;;; blog-index.el --- -*- lexical-binding: t -*-

;;; Commentary:
;; Indexing and caching functionality for my blog
;; Stolen from blog

;;; Code:

(require 'org-element)
(require 'seq)
(require 'cl-lib)

(defvar blog-index-dir nil
  "The root directory for the lecture files to be indexed.")

(defvar blog-index--cache nil
  "Cache for the course index data loaded from the index file.")


(defun blog-index--parse-org-file (file fields)
  "Parse FILE and extract FIELDS.
FIELDS must be a plist mapping output keys to Org buffer keywords.
e.g. (:title \"TITLE\" :author \"AUTHOR\").

Automatically adds :file and :mtime to the result."
  (if (and file (file-exists-p file))
      (with-temp-buffer
	(insert-file-contents file)
	(org-mode)
	(let ((plist (list :file file :mtime (file-attribute-modification-time (file-attributes file)))))
	  (dolist (kv (org-collect-keywords fields))
	    (let ((key (intern (concat ":" (downcase (car kv)))))
		  (val (cadr kv)))
	      (setq plist (plist-put plist key val))))
	  plist))
    (error "Error: The Org file you tried to parse does not exist: %s" file)))


(defun org-files-in-dir (dir &optional regex exact)
  "Get all org files in DIR and its subdirectories.
If EXACT is non-nil, matches REGEX.org. Otherwise, matches .*REGEX.*.org."
  (let* ((flag (if exact "" ".*"))
         ;; Construct the full PCRE-style regex for the filename
         (full-regex (concat regex flag "\\.org$")))
    (directory-files-recursively dir full-regex)))

(defun blog-index--parse-post (filepath)
  (message "Parsing post %s" filepath)
  (let* ((data (blog-index--parse-org-file
		filepath
		'("TITLE" "DATE" "DRAFT" "DESCRIPTION" "SUBTITLE" "FILETAGS"))))
    (when data
      (cons (file-relative-name filepath blog-index-dir) data))))

(defun blog-index-get-posts ()
  "Compute the list of posts with metadata. No caching"
  (let* ((blog-posts (org-files-in-dir blog-index-dir))
	 (current-index (blog-index--get))
	 (valid-posts '()))
    (dolist (filepath blog-posts)
      (let* ((new-entry (blog-index--parse-post filepath))
             (cached-entry (assoc filepath current-index))
	     (file-mtime (file-attribute-modification-time (file-attributes filepath))))
	;; If cached-entry exists and is not older than the file
	(if (and cached-entry
		 (not (time-less-p
		       (plist-get (cdr cached-entry) :mtime)
		       file-mtime)))
	    ;; Push cached-entry
	    (push cached-entry valid-posts)
	  ;; Else, generate the new one
	  (push (blog-index--parse-post filepath) valid-posts))
	))
    (blog-index--update (nreverse valid-posts))))

(defun blog-index-get-post (filepath)
  "We consider that the cache here is up to date"
  (let ((entry (cdr (assoc filepath (blog-index--get)))))
    (if (not entry)
	(message "Wrong file asked for: %s" filepath)
      entry)))

(defun blog-index--load-from-file ()
  "Return the index or nil"
  (let ((index-file (expand-file-name ".blog-index.el" blog-index-dir)))
    (when (if (file-exists-p index-file)
	      (setq blog-index--cache
		    (with-temp-buffer
		      (insert-file-contents index-file)
		      (read (current-buffer))))))))

(defun blog-index--update (new-val)
  "Update the entry for COURSE in `blog-index--cache'"
  (setq blog-index--cache new-val)
  (blog-index--write)
  new-val)

(defun blog-index--get ()
  "Load and return the course index.
If the index file does not exist or is stale, it is rebuilt."
  ;; Load cache first to perform checks
  (if (not blog-index--cache)
      (setq blog-index--cache (blog-index--load-from-file))
    blog-index--cache))

(defun blog-index--write ()
  "Write the current in-memory course cache to the index file."
  (let ((index-file (expand-file-name ".blog-index.el" blog-index-dir)))
    (with-temp-buffer
      (require 'pp)
      (pp (blog-index--get) (current-buffer))
      (write-file index-file))))

(provide 'blog-index)
