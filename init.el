;;; init.el --- Emacs Meow Kick --- A feature rich Emacs config with meow modal editing -*- lexical-binding: t; -*-

;;; Commentary:
;; Based on emacs-kick (https://github.com/LionyxML/emacs-kick) but using
;; meow (https://github.com/meow-edit/meow) instead of evil-mode.
;; Read top-to-bottom. Modify to suit your needs.

;;; Code:

;; Performance Hacks
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))
(setq native-comp-jit-compilation nil)

;; Bootstrap straight.el
(setq package-enable-at-startup nil)
(setq straight-check-for-modifications nil)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package '(project :type built-in))
(straight-use-package 'use-package)

;; Package archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Nerd fonts toggle
(defcustom mk-use-nerd-fonts t
  "Configuration for using Nerd Fonts Symbols."
  :type 'boolean
  :group 'appearance)
