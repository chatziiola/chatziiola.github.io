;; config.el -- Summary

;;; Author: Lamprinos Chatziioannou

;;; Description: This file aims to hold all the variables needed among
;;; the different elisp files of my configuration. Not only do I want
;;; it to be the *only* non-functional point to edit in case something
;;; needs to change in my blog, but I also want to limit that
;;; functionality by basing as many of its options as reasonable in
;;; config.ini, to allow for easy variable modification throughout the
;;; blog's codebase

;;; Commentary:
;; DO BA DO BA DI

(load (expand-file-name "ini.el" (file-name-directory load-file-name)))

;; Leaving this here
;; (ini/get-value-from-file "JSON" "filename" "config.ini")

(defvar domainname "https://blog.chatziiola.live"
  "Self-Descriptive. It is the address for which we build our site")

(defvar base-dir "./content/"
  "The content directory.")

(defvar public-dir "./docs/"
  "The root directory of our webserver.")

(defvar drafts-dir (concat base-dir "drafts/")
  "To be ignored when publishing.")

(defvar posts-dir (expand-file-name "posts/" base-dir)
  "Subfolder of content where posts lie.")

(defvar posts-public-dir (expand-file-name "posts/" public-dir)
  "The public subfolder in which posts will be published.")

(defvar src-dir "./content/src/"
  "Self-descriptive.")

(defvar src-public-dir "./docs/src/"
  "Self-descriptive.")

(defvar css-path "/src/rougier.css"
  "Self-descriptive.")

(defvar org-blog-head
  (concat
   "<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">"
   "<link href=\"https://fonts.googleapis.com/css2?family=Fira+Sans&display=swap\"rel=\"stylesheet\">"
   "<link href=\"https://fonts.googleapis.com/css2?family=Roboto+Condensed&display=swap\"rel=\"stylesheet\">"
   "<script src=\"https://cdn.jsdelivr.net/gh/oyvindstegard/ox-tagfilter-js/ox-tagfilter.js\"></script>"
   "<link rel=\"stylesheet\" href=\"" css-path "\" />
    <link rel=\"icon\" type=\"image/x-icon\" href=\"/src/favicon.ico\">"
   "<meta charset=\"UTF-8\" name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
   )
  "Description - BLOG HTML HEAD.")

(defvar general-postamble
  "<p class=\"footer\"> Made with Emacs and Org.<br>CSS theme based on the one developed by <a href=\"https://github.com/rougier\">@rougier</a>.</p>"
  "To be used on all pages.")

(defvar comments-postamble
  (concat
   "<script src=\"https://giscus.app/client.js\" data-repo=\"chatziiola/chatziiola.github.io\" data-repo-id=\"R_kgDOGq8p0g\" data-category=\"Announcements\" data-category-id=\"DIC_kwDOGq8p0s4COSFW\" data-mapping=\"pathname\" data-reactions-enabled=\"1\" data-emit-metadata=\"0\" data-input-position=\"bottom\" data-theme=\"light\" data-lang=\"en\" data-loading=\"lazy\" crossorigin=\"anonymous\" async> </script>"
   "<p class=\"date footer\"> Originally created on %d </p>"
   general-postamble)
  "Postamble for posts so that giscus comments are enabled.")

;;;; These were set up on a need-to-set basis
(setq org-static-blog-enable-tags t)
(setq org-static-blog-index-file "recents.html")
(setq org-static-blog-index-front-matter "")
(setq org-static-blog-index-length 50)
(setq org-static-blog-posts-directory "./content/posts/")
(setq org-static-blog-page-postamble general-postamble)
(setq org-static-blog-publish-directory "./docs/posts/")
(setq org-static-blog-publish-title "Recent Articles")
(setq org-static-blog-publish-url "https://chatziiola.github.io")


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
   "</head>\n"
   "<body>\n"
"<div id=\"org-div-home-and-up\">"
" <a accesskey=\"h\" href=\"/index.html\"> UP </a>"
" |"
" <a accesskey=\"H\" href=\"/index.html\"> HOME </a>"
"</div>"
   "<div id=\"preamble\" class=\"status\">"
    " <div id=\"navigation\">\n"
    ;; TODO sketchy solution, should include as a variable here, and properly set everything
    ;; " /   \\    _________         ___\n"
    ;; "|  |  |  /         \\__/\\   /   \\\n"
    ;; "\\ | /  |               |  \\  \\/\n"
    ;; "  |||   |           ___/    \\  \\\n"
    ;; "  ###   |   ___   _/       / \\  /\n"
    ;; "   #    |__|/ |__|/        \\___/\n"
    ;; "<a href=\"/index.html\">home</a> / <a href=\"/posts/lectures/index.html\">lectures</a> / <a href=\"/posts/books/index.html\">books</a> / <a href=\"https://github.com/chatziiola\">github</a>\n"
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
