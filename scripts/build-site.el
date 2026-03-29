;; build-site.el -- Summary

;;; Commentary:
;;;; This file is designed to function as the high level core of my blog's
;;;; production process: Here, one can see the "algorithm" in action: How
;;;; settings are loaded (and where), what happens to the different options ...
;;;; and so on. See 'requires' to find out how subparts work


;;; Code:
;; Load Configuration specifics
(add-to-list 'load-path "~/Github/chatziiola.github.io/scripts")
(add-to-list 'load-path "~/Github/org-cache")

;; ;; Load the publishing system
(require 'config)
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)
(require 'htmlize)

; (require 'org-cache) NOT DIRECTLY NEEDED HERE BUT REQUIRED BY COLLECTIONS
(require 'blog-collections)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t) (gnuplot . t) (haskell . nil) (latex . t) (octave . t)
   (python . t) (matlab . t) (shell . t) (ruby . t) (sql . nil) (sqlite . t)))

(setq org-publish-project-alist
      (list
       (list "blog-posts"
       	     :base-directory posts-dir
       	     :recursive t
       	     :html-postamble  comments-postamble
       	     :publishing-directory posts-public-dir
       	     :publishing-function 'my-publish-blog-posts
       	     :with-date t
       	     :with-toc t)
       (list "tags"
	     :base-directory (expand-file-name "tags" base-dir)
	     :recursive t
	     :html-postamble general-postamble
	     :publishing-directory (expand-file-name "tags" public-dir)
	     :publishing-function 'org-html-publish-to-html
	     :with-toc nil)
       ;; Moved indices after blog posts, because index.org reads recents.org,
       ;; which is generated there
       (list "indices"
	     :base-directory base-dir
	     :recursive t
	     :html-postamble general-postamble
	     :publishing-directory public-dir
	     :publishing-function 'my-publish-index
	     :with-toc nil)
       (list "Images"
       	     :base-directory posts-dir
       	     :base-extension "png"
       	     :publishing-directory posts-public-dir
       	     :publishing-function 'org-blog-publish-attachment
       	     :recursive t)
       (list "Website static stuff"
       	     :base-directory src-dir
       	     :base-extension "html\\|css\\|ico\\|png"
       	     :publishing-directory src-public-dir
       	     :publishing-function 'org-publish-attachment
       	     :recursive t)
       (list "Sitemap and Rss"
	     :base-directory base-dir
	     :base-extension "xml"
       	     :publishing-directory public-dir
	     :publishing-function 'org-publish-attachment
	     :recursive t)
       )
      )



;; Before publishing
(create-tag-pages)
(create-archive)
; TODO (create-sitemap)
; TODO (create-rss)
(org-publish-all)
;;; build-site.el ends here.
