;;; init.el --- Emacs initialization -*- lexical-binding: t -*-

;; Bootstrap straight.el
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

;; Install and configure use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; Install and load org-mode before tangling
(straight-use-package 'org)

;; Tangle and load config.org
(let ((config-org (expand-file-name "config.org" user-emacs-directory)))
  (when (file-exists-p config-org)
    (require 'org)
    (org-babel-load-file config-org)))

;; Restore GC settings after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; Use gcmh for better GC management
(use-package gcmh
  :config
  (gcmh-mode 1))
