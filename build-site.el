;;Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.

;; TODO update the .org file
;; - [ ] add disclaimer to never edit this file again

(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
;; htmlize is needed for proper code formatting:
;; https://stackoverflow.com/questions/24082430/org-mode-no-syntax-highlighting-in-exported-html-page
(package-install 'htmlize)
(setq org-src-fontify-natively t)

;; Load the publishing system
(require 'ox-publish)

;; Customize the HTML output
(setq org-html-validation-link nil
     org-html-head-include-scripts nil
     org-html-head-include-default-style nil
     org-html-indent nil
     ; FIXME this is not working
     org-html-self-link-headlines t
     org-export-with-tags t
     org-export-with-smart-quotes t
     org-html-head "<link rel=\"stylesheet\" href=\"/src/rougier.css\" /> <link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">")

(setq org-publish-project-alist
      (list
       (list "org-files"
             :base-directory "./content/"
             :exclude "./content/drafts/"
             :recursive t
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
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
             :base-directory "./content/posts"
             :exclude ".*index.org"
             :recursive t
             :html-link-up "./index.html"
             :html-link-home "/index.html"
             :auto-sitemap t
             :sitemap-filename "sitemap.org"
             :sitemap-title "Sitemap"
             :sitemap-sort-files 'anti-chronologically
             :sitemap-date-format "Published: %a %b %d %Y"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public/posts"
             :html-postamble "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script> <p class=\"footer\"> Made with Emacs and Org. CSS theme developed by @rougier.</p>"
             :with-author t           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-drawers t
             :headline-level 4
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil)

       (list "images"
        :base-directory "./content/images"
         :base-extension ".*"
         :recursive t
         :publishing-directory "./public/images"
         :publishing-function 'org-publish-attachment)
    (list "post-images"
        :base-directory "./content/posts"
         :base-extension "png"
         :recursive t
         :publishing-directory "./public/posts"
         :publishing-function 'org-publish-attachment)
       (list "static"
        :base-directory "./content/src"
         :base-extension "html\\|css"
         :recursive t
         :publishing-directory "./public/src"
         :publishing-function 'org-publish-attachment)
       )
      )

;; Generate the site output
(org-publish-all t)
