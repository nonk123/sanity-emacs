;;; sanity.el --- sanity live-server for GNU/Emacs -*- lexical-binding: t; -*-

;; Author: nonk <me@nonk.dev>
;; Version: 0.1.0
;; Keywords: tools, convenience
;; URL: https://github.com/nonk123/sanity

;;; Commentary:

;; Sanity live-server for GNU/Emacs.  Refer to the project's README
;; file for more info.

;;; Code:

(require 'comint)
(require 'project)

(defgroup sanity nil
  "All things sanity."
  :group 'tools
  :group 'convenience
  :link '(url-link :tag "GitHub" "https://github.com/nonk123/sanity-emacs"))

(defconst sanity-windose? (and (string-match-p "AppData\\\\Roaming" (getenv "HOME")) t)
  "Evaluates to t if this GNU/Emacs is running under Windose.

Stolen from my GNU/Emacs init-file, which see.")

(defcustom sanity-path
  (expand-file-name
   (concat "sanity/sanity" (when sanity-windose? ".exe"))
   user-emacs-directory)
  "Full path to sanity binary."
  :type 'file
  :group 'sanity)

(defun sanity-buffer-name (project)
  "Derive a sanity buffer name from PROJECT's name."
  (and project (concat "sanity: " (project-name project))))

(defun sanity-maybe-get-buffer (project)
  "Return the PROJECT's sanity buffer, if any."
  (when-let ((name (sanity-buffer-name project)))
    (get-buffer name)))

(defun sanity-get-buffer-create (project)
  "Create a process buffer for a valid PROJECT if one doesn't exist."
  (when-let ((name (sanity-buffer-name project)))
    (get-buffer-create name)))

;;;###autoload
(defun sanity-install ()
  "Install the latest sanity binary from GitHub."
  (interactive)
  (let* ((base "https://github.com/nonk123/sanity/releases/download/gh-actions/sanity-release-")
         (suffix (if sanity-windose? "windows.exe" "linux"))
         (url (concat base suffix)))
    (when-let ((dir (file-name-directory sanity-path)))
      (make-directory dir t))
    (url-copy-file url sanity-path t)
    (file-exists-p sanity-path)))

;;;###autoload
(defun sanity-run ()
  "Run a sanity live-server for this project.

Signals a user-error if sanity is already running.  Make sure to kill
its buffer if it is, before running again."
  (interactive)
  (unless (or (file-exists-p sanity-path)
              (and (yes-or-no-p "Sanity binary couldn't be found.  Download it? ")
                   (sanity-install)))
    (user-error "Sanity binary can't be found"))
  (let* ((project (or (project-current) (user-error "You need to open a project to run sanity"))))
    (when-let* ((buffer (sanity-maybe-get-buffer project))
                ((buffer-live-p buffer)))
      (user-error "Sanity is already running in this project"))
    (with-current-buffer (sanity-get-buffer-create project)
      (ansi-color-for-comint-mode-on)
      (comint-mode)
      (let* ((default-directory (project-root project))
             (process (start-process "sanity" (current-buffer) sanity-path "server")))
        (set-process-filter process #'comint-output-filter))
      t)))

(defun sanity-project-eligible (project)
  "Return a non-nil value if PROJECT supports sanity."
  (when-let* (project
              (root (project-root project))
              (www (expand-file-name "www" root)))
    (and (file-exists-p www) (file-directory-p www))))

;;;###autoload
(defun sanity-autorun ()
  "Run a sanity live-server for this project.  Used in `find-file-hook'."
  (when-let* ((project (project-current))
              ((null (sanity-maybe-get-buffer project)))
              ((sanity-project-eligible project))
              ((catch 'user-error (sanity-run))))
    (message "Sanity is running in the background!")))

(defun sanity-mode-lighter ()
  "`sanity-mode' lighter."
  (if-let* ((project (project-current))
            ((sanity-project-eligible project))
            (status (if (sanity-maybe-get-buffer project) "running" "stopped")))
      (concat "sanity[" status "]")
    "sanity"))

;;;###autoload
(define-minor-mode sanity-mode
  "Auto-run `sanity' after finding files inside supported projects."
  :global t
  :group 'sanity
  :lighter (" " (:eval (sanity-mode-lighter)))
  (if sanity-mode (add-hook 'find-file-hook #'sanity-autorun)
    (remove-hook 'find-file-hook #'sanity-autorun)))

(provide 'sanity)

;;; sanity.el ends here
