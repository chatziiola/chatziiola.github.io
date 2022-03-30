;; Source: https://systemcrafters.net/publishing-websites-with-org-mode/building-the-site/
;; Big thanks to an extraordinary member of the emacs community
;;
;;Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

;; Load the publishing system
(require 'ox-publish)
; TODO ox-rss

;; Customize the HTML output
(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-indent nil
      org-html-self-link-headlines t
      org-html-head "<link rel=\"stylesheet\" href=\"/src/rougier.css\" />")

(setq org-publish-project-alist
      (list
       (list "org-files"
             :recursive t
             :base-directory "./content/"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :with-author nil           ;; Don't include author name
             :with-creator nil            ;; Include Emacs and Org versions in footer
             :with-drawers t
             :headline-level 4
             :with-toc nil
             :html-link-home "/index.html"
             :section-numbers nil       ;; Don't include section numbers
             :html-link-up "../index.html"
             :time-stamp-file nil)
       (list "blog-posts"
             :recursive t
             :html-link-up "./index.html"
             :html-link-home "/index.html"
             :base-directory "./content/posts"
             :exclude ".*index.org"
             :auto-sitemap t
             :sitemap-filename "sitemap.org"
             :sitemap-title "Sitemap"
             ;; custom sitemap generator function
             :sitemap-sort-files 'anti-chronologically
             :sitemap-date-format "Published: %a %b %d %Y"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public/posts"
;             :html-postamble "<script src=\"https://utteranc.es/client.js\" repo=\"chatziiola/chatziiola.github.io\" issue-term=\"pathname\" label=\"comment\" theme=\"github-light\" crossorigin=\"anonymous\" async> </script>"
             :html-postamble "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script>"
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

(message "Build complete!")

(provide 'build-site)
;; build-site.el ends here
