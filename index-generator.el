;; index-generator --- Summary:
;; Hack on top of `org-static-blog' package, designed to give me more power to
;; use the default org mode publishing scheme, with a /pageinated/ index page

;;; Commentary:

;;;; How it starts:
;;

;;;; Understanding it better / Principles:
;; 1. I have tried to avoid modifying functions. As such you will see me use
;; `org-static-blog' functions a lot
;; 2. All my functions title with `chatziiola/org-static-blog-...' are but minor
;; modifications on top of already existing functions

;;; Code:
(load (expand-file-name "org-static-blog.el" default-directory))

(defun chatziiola/org-static-blog-get-date (post-filename)
  "Extract the `#+date:` from POST-FILENAME as date-time."
  (let ((case-fold-search t))
    (with-temp-buffer
      (insert-file-contents post-filename)
      (goto-char (point-min))
      (if (search-forward-regexp "^\\#\\+date:[ ]*<\\([^]>]+\\)>$" nil t)
	(let ((date-string (match-string 1)))
            (if (string-match "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}" date-string)
                (date-to-time date-string)
              (date-to-time (concat date-string " 00:00:00"))))
        (time-since 0)))))

;;; List of files
;;;; This needed to be modified because I wanted to exclude `index.org' files. I
;;;; like the way I have organized my blog, and I intend to keep it simple that
;;;; way. In the future this may become unnecessary (if I overload functions to
;;;; automatically create indx files at the root of each subdirectory)
(defun chatziiola/org-static-blog-get-post-filenames ()
 "Return a list of all .org files in the directory tree, excluding
index.org files. Namely return a list of all blog post files"
 (let ((files (directory-files-recursively org-static-blog-posts-directory ".*\\.org$" )))
    (dolist (filename files)
	(if (string-match "index.org" (file-name-nondirectory filename))
	    (setq files (delete filename files))))
   files))
	 

;;;; Modified to use my version of the `org-static-blog' functions
;;;; Essentially this is the heart of the `index-generator.el'
;;;; - [ ] Make it add the contents of index.org so that I can also put manually stuff in there.
;;;;;;;; - [ ] Nah I cant add the contents of index.org, I need the contents of index.html
;(defun chatziiola/org-static-blog-assemble-index ()
;  "See `org-static-blog-assemble-index'."
;  (let ((post-filenames (chatziiola/org-static-blog-get-post-filenames)))
;    ;; reverse-sort, so that the later `last` will grab the newest posts
;    (setq post-filenames (sort post-filenames (lambda (x y) (time-less-p (chatziiola/org-static-blog-get-date x)
;                                                                         (chatziiola/org-static-blog-get-date y)))))
;    (chatziiola/org-static-blog-assemble-multipost-page
;     ;; The filename to which you will create the index.html file
;     (concat-to-dir org-static-blog-publish-directory org-static-blog-index-file)
;     ;; Last `org-static-blog-index-length' articles
;     (last post-filenames org-static-blog-index-length)
;     org-static-blog-index-front-matter
;     t)))

(defun chatziiola/org-static-blog-assemble-index-no-content (&optional index-length)
  "See `org-static-blog-assemble-index'."
  (let ((post-filenames (chatziiola/org-static-blog-get-post-filenames)))
    ;; reverse-sort, so that the later `last` will grab the newest posts
    (setq post-filenames (sort post-filenames (lambda (x y) (time-less-p (chatziiola/org-static-blog-get-date x)
                                                                         (chatziiola/org-static-blog-get-date y)))))

    (chatziiola/org-static-blog-assemble-multipost-page
	;; The filename to which you will create the index.html file
	(concat-to-dir org-static-blog-publish-directory org-static-blog-index-file)
	;; Last `org-static-blog-index-length' articles
	(last post-filenames (or index-length org-static-blog-index-length))
	;; FIXME wth this option
	org-static-blog-index-front-matter
	;; Exclude toc
	t)))

(defun chatziiola/org-static-blog-get-post-content (post-filename &optional exclude-title exclude-content)
  "Get the rendered HTML body without headers from POST-FILENAME.
Preamble and Postamble are excluded, too."
  ;; NB! The following code assumes the post is using default template.
  ;; See: org-static-blog-publish-file
  (with-temp-buffer
    (message "Now checking file %s" post-filename)
    ;; Yup that is interesting
    (let* ((published-filename (org-static-blog-matching-publish-filename post-filename))
	   ;; This is essentially the url to follow 
	    (published-link (substring published-filename 8)))
	(message "Published filename: %s" published-filename)
	(message "Published link: %s" published-link)
	(insert-file-contents published-filename)
	(concat 
	 "<li>"
	    ;; Add Date. 
	    "<p class=\"timestamp\"><"
		;; The substring trick is to ensure that dates exist only in the
		;; yyyy-mm-dd format, with no extra information
	    (substring
		(with-temp-buffer
		    (insert-file-contents post-filename)
		    (goto-char (point-min))
		    (if (search-forward-regexp "^\\#\\+date:[ ]*<\\([^]>]+\\)>$" nil t)
			(match-string 1)))
		0 10)
	    ">  </p>"
	    ;; Get title
	    (unless exclude-title
		(concat
		"<a href=\"" published-link "\">  "
		;; Get title string
		(buffer-substring-no-properties
		    (progn
			(goto-char (point-min))
			(search-forward "<title>")
			(point))
		    (progn
			(goto-char (point-max))
			(search-backward "</title>")
			(point))
		)
		"</a>"
		)
	    )
	    ;; Get Content
	    (unless exclude-content
		(buffer-substring-no-properties
		    (progn
			(goto-char (point-min))
			; FIXME add exception for posts with notoc
			(if result (search-forward "<div id=\"text-table-of-contents\"" nil t)
			    (progn
			        (message "%s filename with toc" post-filename)
				(search-forward "</div>")
				(search-forward "</div>"))
			    (progn
			        (message "%s filename without toc" post-filename)
				(goto-char (point-min))
				(search-forward "<h1 class=\"title\">")
				(search-forward "</h1>")))
			(point))
		    (progn
			(goto-char (point-max))
			(search-backward "<div id=\"postamble\" class=\"status\">")
			(search-backward "</div>")
			(search-backward "<div id=\"footnotes\">" nil t)
			(point))))
	    "</li>\n"
	))))

(defun chatziiola/org-static-blog-paginated-post-template (tTitle tContent &optional tDescription)
  "Create the template that is used to generate the static pages."
  (concat
   "<!DOCTYPE html>\n"
   "<html lang=\"" org-static-blog-langcode "\">\n"
   "<head>\n"
   "<link rel=\"stylesheet\" href=\"" css-path "\"/>\n"
    "<link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">\n"
    "<meta charset=\"UTF-8\" name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
   (when tDescription
     (format "<meta name=\"description\" content=\"%s\">\n" tDescription))
   "<title>" tTitle "</title>\n"
   ;;This is for mathjax support
;    "<script type=\"text/x-mathjax-config\">\n MathJax.Hub.Config({\n displayAlign: \"center\",\n displayIndent: \"0em\",\n \"HTML-CSS\": { scale: 100,\n linebreaks: { automatic: \"false\" },\n webFont: \"TeX\"\n },\n SVG: {scale: 100,\n linebreaks: { automatic: \"false\" },\n font: \"TeX\"},\n NativeMML: {scale: 100},\n TeX: { equationNumbers: {autoNumber: \"AMS\"},\n MultLineWidth: \"85%\",\n TagSide: \"right\",\n TagIndent: \".8em\"\n }\n });\n </script>\n" "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_HTML\"></script>\n"
   "</head>\n"
   "<body>\n"
"<div id=\"org-div-home-and-up\">"
" <a accesskey=\"h\" href=\"/index.html\"> UP </a>"
" |"
" <a accesskey=\"H\" href=\"/index.html\"> HOME </a>"
"</div>"
   "<div id=\"preamble\" class=\"status\">"
    " <div id=\"navigation\">\n"
    " /   \\    _________         ___\n"
    "|  |  |  /         \\__/\\   /   \\\n"
    "\\ | /  |               |  \\  \\/\n"
    "  |||   |           ___/    \\  \\\n"
    "  ###   |   ___   _/       / \\  /\n"
    "   #    |__|/ |__|/        \\___/\n"
    "<a href=\"/index.html\">home</a> / <a href=\"/posts/lectures/index.html\">lectures</a> / <a href=\"/posts/books/index.html\">books</a> / <a href=\"https://github.com/chatziiola\">github</a>\n"
    "</div>\n"
   "</div>\n"
   "<div id=\"content\">\n"
   tContent
   "</div>\n"
   "<div id=\"postamble\" class=\"status\">"
   org-static-blog-page-postamble
   "</div>\n"
   "</body>\n"
   "</html>\n"))

(defun chatziiola/org-static-blog-assemble-multipost-page (pub-filename post-filenames &optional front-matter exclude-content include-archive)
  "Assemble a page that contains multiple posts one after another.
Posts are sorted in descending time."
  (setq post-filenames (sort post-filenames (lambda (x y) (time-less-p (chatziiola/org-static-blog-get-date y)
                                                                  (chatziiola/org-static-blog-get-date x)))))
  (org-static-blog-with-find-file
   pub-filename
   (chatziiola/org-static-blog-paginated-post-template 
    ;; Title
    org-static-blog-publish-title
    ;; Content
   (concat
    (when front-matter front-matter)
    ;; Posts' contents
    (concat
     "<ul class=\"org-ul indexul\">\n"
    (apply 'concat (mapcar
		    #'(lambda (x) (chatziiola/org-static-blog-get-post-content x nil exclude-content))
		    post-filenames))
      "</ul>")
    ;; Archive list
    ;; FIXME an archive list would be nic
    (if include-archive
      (concat
    "<div id=\"archive\">\n"
    "<a href=\"" (org-static-blog-get-absolute-url org-static-blog-archive-file) "\">"
    (org-static-blog-gettext 'other-posts) "</a>\n"
    "</div>\n")))
   )))
