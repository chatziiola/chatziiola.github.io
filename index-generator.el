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

;;; Date Related Functions:
;;;; These are mainly needed because of the format I have already implemented in
;;;; my files <year-month-date> is not the original format (<year-month-date HH:MM:SS>)
(defun chatziiola/org-static-blog-fix-date (date-string)
    "Fix the date pattern in files where it is incomplete.
    If no change is needed simply return that string For example
    <2022-04-03> needs to be <2022-04-03 00:00>"
  (if (string-match "<\\d{4}-\\d{2}-\\d{2}>" "<2022-04-03>")
      (message "faulty date")
      (message "The date %s is ok" date-string)))

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
(defun chatziiola/org-static-blog-assemble-index ()
  "See `org-static-blog-assemble-index'."
  (let ((post-filenames (chatziiola/org-static-blog-get-post-filenames)))
    ;; reverse-sort, so that the later `last` will grab the newest posts
    (setq post-filenames (sort post-filenames (lambda (x y) (time-less-p (chatziiola/org-static-blog-get-date x)
                                                                         (chatziiola/org-static-blog-get-date y)))))
    (chatziiola/org-static-blog-assemble-multipost-page
     ;; The filename to which you will create the index.html file
     (concat-to-dir org-static-blog-publish-directory org-static-blog-index-file)
     ;; Last `org-static-blog-index-length' articles
     (last post-filenames org-static-blog-index-length)
     org-static-blog-index-front-matter)))

(defun chatziiola/org-static-blog-get-post-content (post-filename &optional exclude-title)
  "Get the rendered HTML body without headers from POST-FILENAME.
Preamble and Postamble are excluded, too."
  ;; NB! The following code assumes the post is using default template.
  ;; See: org-static-blog-publish-file
  (with-temp-buffer
    (message "Now checking file %s" post-filename)
    ;; Yup that is interesting
    (insert-file-contents (org-static-blog-matching-publish-filename post-filename))
    (concat 
	;; Get title
	(buffer-substring-no-properties
	    (progn
		(goto-char (point-min))
		(search-forward "<div id=\"content\" class=\"content\">")
		(point))
	    (progn
	    (goto-char (point-max))
	    (search-backward "<div id=\"table-of-contents\"")
	    (point)))
	;; Add Date
	"<p class=\"date\"> Originally created on "
	(with-temp-buffer
	    (insert-file-contents post-filename)
	    (goto-char (point-min))
	    (if (search-forward-regexp "^\\#\\+date:[ ]*<\\([^]>]+\\)>$" nil t)
		(match-string 1)))
	"</p>"

	;; Get Content
	(buffer-substring-no-properties
	    (progn
		(goto-char (point-min))
		;; Now this should be fixed however I am not sure how I can fix it now.
		;; This puts you at the beginning of the first paragraph
		(search-forward "<div id=\"text-table-of-contents\"")
		(search-forward "</div>")
		(search-forward "</div>")
		(point))
	    (progn
	    (goto-char (point-max))
	    (search-backward "<div id=\"postamble\" class=\"status\">")
	    (search-backward "</div>")
	    (search-backward "<div id=\"footnotes\">" nil t)
	    (point))))))

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
    "<script type=\"text/x-mathjax-config\">\n
	MathJax.Hub.Config({\n
	    displayAlign: \"center\",\n
	    displayIndent: \"0em\",\n
	    \"HTML-CSS\": { scale: 100,\n
			    linebreaks: { automatic: \"false\" },\n
			    webFont: \"TeX\"\n
			},\n
	    SVG: {scale: 100,\n
		linebreaks: { automatic: \"false\" },\n
		font: \"TeX\"},\n
	    NativeMML: {scale: 100},\n
	    TeX: { equationNumbers: {autoNumber: \"AMS\"},\n
		MultLineWidth: \"85%\",\n
		TagSide: \"right\",\n
		TagIndent: \".8em\"\n
		}\n
    });\n
    </script>\n"
    "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS_HTML\"></script>\n"
   "</head>\n"
   "<body>\n"
   "<div id=\"preamble\" class=\"status\">"
    " <div id=\"navigation\">\n"
    " /   \\    _________         ___\n"
    "|  |  |  /         \\__/\\   /   \\\n"
    "\\ | /  |               |  \\  \\/\n"
    "  |||   |           ___/    \\  \\\n"
    "  ###   |   ___   _/       / \\  /\n"
    "   #    |__|/ |__|/        \\___/\n"
    "<a href=\"/posts/lectures/index.html\">lectures</a> / <a href=\"/posts/books/index.html\">books</a> / <a href=\"https://github.com/chatziiola\">github</a>\n"
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

(defun chatziiola/org-static-blog-assemble-multipost-page (pub-filename post-filenames &optional front-matter)
  "Assemble a page that contains multiple posts one after another.
Posts are sorted in descending time."
  (setq post-filenames (sort post-filenames (lambda (x y) (time-less-p (org-static-blog-get-date y)
                                                                  (org-static-blog-get-date x)))))
  (org-static-blog-with-find-file
   pub-filename
   (chatziiola/org-static-blog-paginated-post-template 
    ;; Title
    org-static-blog-publish-title
    ;; Content
   (concat
    (when front-matter front-matter)
    ;; Posts' contents
    (apply 'concat (mapcar
                    'chatziiola/org-static-blog-get-post-content
		    post-filenames))
    ;; Archive list
    "<div id=\"archive\">\n"
    "<a href=\"" (org-static-blog-get-absolute-url org-static-blog-archive-file) "\">"
    (org-static-blog-gettext 'other-posts) "</a>\n"
    "</div>\n")
   )))
