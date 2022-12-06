;;Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.

;; TODO update the .org file
;; - [ ] add disclaimer to never edit this file again
;; - [ ] updates taken from https://her.esy.fun/posts/0001-new-blog/index.html

;; Instead of having it all hardcoded
(defvar domainname "https://chatziiola.github.io"
  "Self-Descriptive")

(defvar base-dir "./content/"
  "The content directory")
(defvar public-dir "./public/"
  "The root directory of our webserver")

(defvar drafts-dir (concat base-dir "drafts/")
  "To be ignored when publishing")

(defvar posts-dir (expand-file-name "posts/" base-dir)
  "Created specifically for me - All of my /actual/ posts lie in content/posts")
(defvar posts-public-dir (expand-file-name "posts/" public-dir)
  "See the description of posts-dir. It does not need to be the same. I have set it that way though.")


(defvar src-dir "./content/src/"
  "Self-descriptive")
(defvar src-public-dir "./public/src/"
  "Self-descriptive")

(defvar css-path "/src/rougier.css"
  "Self-descriptive")

(defvar org-blog-head
  (concat
   "<link rel=\"stylesheet\" href=\"" css-path "\" />
    <link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">"
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
   )
  "Description - BLOG HTML HEAD")

(defvar general-postamble
  "<p class=\"footer\"> Made with Emacs and Org. CSS theme developed by @rougier.</p>"
  "To be used on all pages"
  )

(defvar comments-postamble
  (concat
   "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script>"

  "<p class=\"date\"> Originally created on %d </p>"
   general-postamble
   )
  "Postamble for posts so that giscus comments are enabled" )

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Load the publishing system
(require 'ox-publish)
(require 'ox-html)

;; Install dependencies
;; htmlize is needed for proper code formatting:
;; https://stackoverflow.com/questions/24082430/org-mode-no-syntax-highlighting-in-exported-html-page
(package-install 'htmlize)
(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'inline-css)

;; Customize the HTML output
(setq org-html-validation-link nil
     org-html-head-include-scripts nil
     org-html-head-include-default-style nil
     org-html-indent nil
     org-html-self-link-headlines t
     org-export-with-tags t
     org-export-with-smart-quotes t
     org-html-head org-blog-head)

(setq org-publish-project-alist
      (list
       (list "org-files"
             :base-directory base-dir
             :exclude drafts-dir
             :recursive t
             :publishing-function 'org-html-publish-to-html
             :publishing-directory public-dir
             :with-author nil           ;; Don't include author name
             :with-creator nil            ;; Include Emacs and Org versions in footer
             :with-drawers t
             :headline-level 4
	     :html-postamble general-postamble
             :with-toc nil
             :section-numbers nil       ;; Don't include section numbers
             :html-link-home "/index.html"
             :html-link-up "../index.html"
             :time-stamp-file nil)
       (list "blog-posts"
             :base-directory posts-dir
             :exclude ".*index.org"
             :recursive t
             :html-link-up "./index.html"
             :html-link-home "/index.html"
;             :auto-sitemap t
;             :sitemap-filename "sitemap.org"
;             :sitemap-title "Sitemap"
;             :sitemap-sort-files 'anti-chronologically
;             :sitemap-date-format "Published: %a %b %d %Y"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory posts-public-dir
             :html-postamble  comments-postamble 
             :with-author t           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-drawers t
             :headline-level 4
	     :with-date t
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil)
	(list "post-images"
	    :base-directory posts-dir
	    :base-extension "png"
	    :recursive t
	    :publishing-directory posts-public-dir
	    :publishing-function 'org-blog-publish-attachment)
	(list "static"
	    :base-directory src-dir
	    :base-extension "html\\|css\\|ico"
	    :recursive t
	    :publishing-directory src-public-dir
	    :publishing-function 'org-publish-attachment)
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

;; Generate the site output
(org-publish-all t)
