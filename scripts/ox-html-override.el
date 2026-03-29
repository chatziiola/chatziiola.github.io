(require 'config)
(require 'blog-collections)
;; This function was deliberately modified to keep things simple
;; DO NOT USE THIS FUNCTION (if you ain't me)


(defun org-html-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   (when (and (not (org-html-html5-p info)) (org-html-xhtml-p info))
     (let* ((xml-declaration (plist-get info :html-xml-declaration))
	    (decl (or (and (stringp xml-declaration) xml-declaration)
		      (cdr (assoc (plist-get info :html-extension)
				  xml-declaration))
		      (cdr (assoc "html" xml-declaration))
		      "")))
       (when (not (or (not decl) (string= "" decl)))
	 (format "%s\n"
		 (format decl
			 (or (and org-html-coding-system
				  (coding-system-get org-html-coding-system :mime-charset))
			     "iso-8859-1"))))))
   (org-html-doctype info)
   "\n"
   (concat "<html"
	   (cond ((org-html-xhtml-p info)
		  (format
		   " xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\""
		   (plist-get info :language) (plist-get info :language)))
		 ((org-html-html5-p info)
		  (format " lang=\"%s\"" (plist-get info :language))))
	   ">\n")
   "<head>\n"
   (org-html--build-meta-info info)
   (org-html--build-head info)
   (org-html--build-mathjax-config info)
   ;; <meta name="keywords" content="emacs, org-mode, blogging, lisp">
   "</head>\n"
   "<body>\n"
   ;; chatziiola: REMOVED LINK UP / LINK HOME

   ;; Preamble.
   (org-html--build-pre/postamble 'preamble info)
   ;; Document contents.
   (let ((div (assq 'content (plist-get info :html-divs))))
     (format "<%s id=\"%s\" class=\"%s\">\n"
             (nth 1 div)
             (nth 2 div)
             (plist-get info :html-content-class)))
   ;; Document title.
   ;; chatziiola: core modifications
   (when (plist-get info :with-title)
     (let ((title (and (plist-get info :with-title)
		       (plist-get info :title)))
	   (subtitle (plist-get info :subtitle))
	   (html5-fancy (org-html--html5-fancy-p info)))
       (when title
	 (format
	    "<header>\n<h1 class=\"title\">%s</h1>\n%s%s</header>"
	  (org-export-data title info)
	  (if subtitle
	      (format "<p class=\"subtitle\" role=\"doc-subtitle\">%s</p>\n"
		      (org-export-data subtitle info))
	    "")
	  (let* ((mnode (file-is-blog-post (plist-get info :input-file)))
		 (tags (if mnode (org-mnode-tags mnode) nil)))
	    (if tags
		(progn
		  (format "<nav class=\"post-tags\">\n<span>%s</span> %s\n</nav>"
			  tags-blog-post-prefix
			  (mapconcat #'tag-link-function tags " ")))
	      (message "%s: NO TAGS" title)
	      ""))
	  ))))
   contents
   (format "</%s>\n" (nth 1 (assq 'content (plist-get info :html-divs))))
   ;; Postamble.
   (org-html--build-pre/postamble 'postamble info)
   ;; Closing document.
   "</body>\n</html>"))


(provide 'ox-html-override)
