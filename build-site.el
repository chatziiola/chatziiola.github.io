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

;; Customize the HTML output
(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-link-home "/index.html"
      org-html-link-up "index.html"
      org-html-indent nil
      org-html-self-link-headlines t
      ;; org-export-filter-body-functions (I just want to read a file)
      org-html-head "<link rel=\"stylesheet\" href=\"/rougier.css\" />")

;; Define the publishing project
;; TODO, when you try more customizations here: check this https://ogbe.net/blog/blogging_with_org.html
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./content"
             :auto-sitemap t
;             :sitemap-filename "sitemap.org"
;             :sitemap-title ""
;             :sitemap-sort-files: 'anti-chronologically
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :with-author t           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-drawers t
             :headline-level 3
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file t)
       (list "images"
        :base-directory "./content/images"
         :base-extension ".*"
         :publishing-directory "./public/images"
         :publishing-function 'org-publish-attachment)))


;; Generate the site output
(org-publish-all t)

(message "Build complete!")
