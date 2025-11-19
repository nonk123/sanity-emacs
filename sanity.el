;;; sanity.el --- sanity live-server for GNU/Emacs -*- lexical-binding: t; -*-

;; Author: nonk <me@nonk.dev>
;; Version: 0.1.0
;; Keywords: sanity, live-server
;; URL: https://github.com/nonk123/sanity

;;; Commentary:

;; Sanity live-server for GNU/Emacs.  Refer to the project's README
;; file for more info.

;;; Code:

(require 'comint)
(require 'project)

(defconst sanity-windose? (and (string-match-p "AppData\\\\Roaming" (getenv "HOME")) t)
  "Evaluates to t if this GNU/Emacs is running under Windose.

Stolen from my GNU/Emacs init-file, which see.")

(defvar sanity-path
  (expand-file-name (concat "sanity/sanity" (when sanity-windose? ".exe")) user-emacs-directory)
  "Full path to sanity binary.")

;;;###autoload
(defun sanity-install ()
  "Install the latest sanity binary from GitHub."
  (interactive)
  (let* ((base "https://github.com/nonk123/sanity/releases/download/gh-actions/sanity-release-")
         (suffix (if sanity-windose? "windows.exe" "linux"))
         (url (concat base suffix)))
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
  (if-let* ((project (project-current))
            (buffer-name (concat "sanity: " (project-name project))))
      (let ((buffer (get-buffer buffer-name)))
        (when (buffer-live-p buffer)
          (user-error "Sanity is already running in this project"))
        (setq buffer (or buffer (get-buffer-create buffer-name)))
        (with-current-buffer buffer
          (ansi-color-for-comint-mode-on)
          (comint-mode))
        (let* ((default-directory (project-root project))
               (process (start-process "sanity" buffer sanity-path "server")))
          (set-process-filter process #'comint-output-filter)))
    (user-error "You need to open a project to run sanity")))

(provide 'sanity)

;;; sanity.el ends here
