;;; org-file-id.el --- Generate unique ID for Org files -*- lexical-binding: t -*-

;; Author: Thomas Ingram <thomas@taingram.org>
;; Version: 0.2
;; Keywords: org, identification
;; Package-Requires: ((emacs "28.1"))

;; This file is not yet part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Small wrapper around `org-id' to generate unique file ID keyword
;; tags for Org files.

;; Useful for keeping track of files if they are moved or renamed.
;; Especially when Org files are being referenced externally like with
;; an RSS feed.

;; Functions:
;; `org-file-id-create'     FILE (or interactively on current buffer)
;; `org-file-id-get'        FILE
;; `org-file-id-get-create' FILE
;; `org-file-id-copy'            (used interactively on current buffer)

;;; Code:

(require 'org)
(require 'org-id)
(require 'org-compat)

(defgroup org-file-id nil
  "Create unique file ID for Org files."
  :tag "Org file ID"
  :group 'org)

(defcustom org-file-id-keyword "ID"
  "Keyword used to set Org file ID.
Should not contain any whitespace."
  :type 'string
  :group 'org-file-id)

(defcustom org-file-id-insert-top nil
  "Insert ID keyword tag at top of file.
Default (nil) will add after the last #+keyword and before the first
headline."
  :type 'boolean
  :group 'org-file-id)


(defun org-file-id--get-in-buffer ()
  "Get file ID keyword from current buffer.

Will move the point and assumes no narrowing is in effect.  For general
usage use `'org-file-id-get'."
  (goto-char (point-min))
  (when (re-search-forward
	 (concat "^#\\+" org-file-id-keyword ":") (point-max) t)
    (string-trim (buffer-substring-no-properties (point) (line-end-position)))))

(defun org-file-id--create-in-buffer (&optional force)
  "Create ID keyword tag in the current buffer.
Returns the file ID that is set in the buffer.

Will move the pointer and assumes no narrowing is in effect.  For
general usage use `org-file-id-create'.

FORCE will overwrite the existing ID if one is already set.

See `org-id-method' to customize how this ID is generated."
  (goto-char (point-min))
  (let ((id (org-file-id--get-in-buffer)))
    (if (and id (not force))
	(message "File ID already exists, skipping.")
      (progn
	;; Position point and delete existing ID if FORCE.
	;; Will use existing ID line position if one is found.
	(if (not (eql (point) (point-min))) ;; Empty ID tag or FORCE
	    (delete-region (line-beginning-position) (line-end-position))
	  (progn
	    (goto-char (point-min))
	    (unless org-file-id-insert-top
	      (org-next-visible-heading 1)
	      (while (not (or (bobp) (org-at-keyword-p)))
		(forward-line -1))
	      (when (org-at-keyword-p)
		(forward-line)))))
	(setq id (org-id-new 'none))
	(insert "#+" org-file-id-keyword ": " id "\n")))
    id))

(defun org-file-id-copy ()
  "Copy file ID key from current Org buffer."
  (interactive)
  (let ((id nil))
    (save-excursion
      (save-restriction
	(widen)
	(setq id (org-file-id--get-in-buffer))
	(if (null id)
	    (message "No file ID found")
	  (org-kill-new id))))))

(defun org-file-id-get (file)
  "Get file ID key from an Org FILE."
  (let ((id nil))
    (with-temp-buffer
      (set-buffer (find-file-noselect file))
      (setq id (org-file-id--get-in-buffer))
      (when (null id)
	(display-warning 'org-file-id "No file ID found")))
    id))

(defun org-file-id-get-create (file)
  "Get ID from Org FILE and new create ID if not set.

See `org-id-method' to customize how this ID is generated."
  (let ((id nil))
    (with-temp-buffer
      (set-buffer (find-file-noselect file))
      (setq id (org-file-id--get-in-buffer))
      (when (null id)
	(setq id (org-file-id--create-in-buffer))
	(save-buffer)))
    id))


(defun org-file-id-create (&optional file force)
  "Generate a file ID in Org FILE or buffer.
When called interactively without a FILE will attempt to update the
current buffer.

FORCE will overwrite the existing ID if one is already set.

See `org-id-method' to customize how this ID is generated."
  (interactive)
  (if (not (null file))
      (with-temp-buffer
	(set-buffer (find-file-noselect file))
	(org-file-id--create-in-buffer force)
	(save-buffer))
    ;; Try to update current buffer
    (when (called-interactively-p 'interactive)
      (unless (eq major-mode 'org-mode)
	(user-error "Cannot be used outside of org-mode buffers"))
      (save-excursion
	(save-restriction
	  (widen)
	  (org-file-id--create-in-buffer force))))))

(provide 'org-file-id)

;;; org-file-id.el ends here
