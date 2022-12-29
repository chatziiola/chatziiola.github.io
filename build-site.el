;;Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.

;; TODO update the .org file
;; - [ ] add disclaimer to never edit this file again
;; - [ ] updates taken from https://her.esy.fun/posts/0001-new-blog/index.html

;; Instead of having it all hardcoded

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variable declarations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar domainname "https://chatziiola.github.io" "Self-Descriptive")
(defvar base-dir "./content/" "The content directory")
(defvar public-dir "./public/" "The root directory of our webserver")
(defvar drafts-dir (concat base-dir "drafts/") "To be ignored when publishing")
(defvar posts-dir (expand-file-name "posts/" base-dir) "Subfolder of content where posts lie")
(defvar posts-public-dir (expand-file-name "posts/" public-dir) "The public subfolder in which posts will be published")
(defvar src-dir "./content/src/" "Self-descriptive")
(defvar src-public-dir "./public/src/" "Self-descriptive")
(defvar css-path "/src/rougier.css" "Self-descriptive")

(defvar org-blog-head
  (concat
   "<link rel=\"stylesheet\" href=\"" css-path "\" />
    <link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">"
    "<meta charset=\"UTF-8\" name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
   )
  "Description - BLOG HTML HEAD")

(defvar general-postamble
  "<p class=\"footer\"> Made with Emacs and Org. CSS theme developed by @rougier.</p>"
  "To be used on all pages")

(defvar comments-postamble
  (concat
   "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script>"
  "<p class=\"date\"> Originally created on %d </p>"
   general-postamble
   ) "Postamble for posts so that giscus comments are enabled" )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq straight-vc-git-default-clone-depth 1)
(setq straight-recipes-gnu-elpa-use-mirror t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Load the publishing system
(require 'ox-publish)
(require 'ox-html)
(require 'cl-extra)

;; Install dependencies
;; htmlize is needed for proper code formatting:
;; https://stackoverflow.com/questions/24082430/org-mode-no-syntax-highlighting-in-exported-html-page
(straight-use-package 'htmlize)
(straight-use-package 'org-static-blog)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-src-fontify-natively t)
(setq org-html-htmlize-output-type 'css)
;(setq org-html-htmlize-font-prefix "org-")

(setq-default org-src-fontify-natively t         ; Fontify code in code blocks.
              org-adapt-indentation nil          ; Adaptive indentation
              org-src-tab-acts-natively t        ; Tab acts as in source editing
              org-confirm-babel-evaluate nil     ; No confirmation before executing code
              org-edit-src-content-indentation 2 ; No relative indentation for code blocks
              org-fontify-whole-block-delimiter-line t) ; Fontify whole block


(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (gnuplot . t)
   (haskell . nil)
   (latex . t)
   (octave . t)
   (python . t)
   (matlab . t)
   (shell . t)
   (ruby . t)
;   (c . t)
;   (cpp . t)
   (sql . nil)
   (sqlite . t)))

; Avoid trash
(setq make-backup-files nil
        auto-save-default nil
        create-lockfiles nil)

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
       (list "Index files"
	    :base-directory base-dir
	    :base-extension "org"
	    :exclude drafts-dir
	    :headline-level 4
	    :html-link-home "/index.html"
	    :html-link-up "../index.html"
	    :html-postamble general-postamble
	    ; :preparation-function -> this could be good for some 
	    ; :completion-function -> this could be good for some 
	    ; :with-statistics-cookies
	    :publishing-directory public-dir
	    :publishing-function 'org-html-publish-to-html
	    :recursive t
	    :section-numbers nil    ;; Don't include section numbers
	    :time-stamp-file nil
	    :with-drawers t
	    :with-toc nil
	    )
       (list "Blog posts"
	    :base-directory posts-dir
	    :base-extension "org"
	    :exclude ".*index.org"
	    :headline-level 4
	    :html-link-home "/index.html"
	    :html-link-up "./index.html"
	    :html-postamble  comments-postamble 
	    :publishing-directory posts-public-dir
	    :publishing-function 'org-html-publish-to-html
	    :recursive t
	    :section-numbers nil    ;; Don't include section numbers
	    :time-stamp-file nil
	    :with-date t
	    :with-drawers t
	    :with-toc t             ;; Include a table of contents
	    )
	(list "Images"
	    :base-directory posts-dir
	    :base-extension "png"
	    :publishing-directory posts-public-dir
	    :publishing-function 'org-blog-publish-attachment
	    :recursive t
	    )
	(list "Website static stuff"
	    :base-directory src-dir
	    :base-extension "html\\|css\\|ico"
	    :publishing-directory src-public-dir
	    :publishing-function 'org-publish-attachment
	    :recursive t
	    )
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

