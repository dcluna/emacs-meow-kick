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

;;; EMACS
(use-package emacs
  :ensure nil
  :custom
  (auto-save-default nil)
  (column-number-mode t)
  (create-lockfiles nil)
  (delete-by-moving-to-trash t)
  (delete-selection-mode 1)
  (display-line-numbers-type 'relative)
  (global-auto-revert-non-file-buffers t)
  (history-length 25)
  (indent-tabs-mode nil)
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (ispell-dictionary "en_US")
  (make-backup-files nil)
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (ring-bell-function 'ignore)
  (split-width-threshold 300)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (treesit-font-lock-level 4)
  (truncate-lines t)
  (use-dialog-box nil)
  (use-short-answers t)
  (warning-minimum-level :emergency)

  :hook
  (prog-mode . display-line-numbers-mode)

  :config
  (defun skip-these-buffers (_window buffer _bury-or-kill)
    "Function for `switch-to-prev-buffer-skip'."
    (string-match "\\*[^*]+\\*" (buffer-name buffer)))
  (setq switch-to-prev-buffer-skip 'skip-these-buffers)

  (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 100)
  (when (eq system-type 'darwin)
    (setq mac-command-modifier 'meta)
    (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 130))

  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)

  (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

  :init
  (tool-bar-mode -1)
  (menu-bar-mode -1)

  (when scroll-bar-mode
    (scroll-bar-mode -1))

  (global-hl-line-mode -1)
  (global-auto-revert-mode 1)
  (recentf-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (winner-mode 1)
  (xterm-mouse-mode 1)
  (file-name-shadow-mode 1)

  (modify-coding-system-alist 'file "" 'utf-8)

  (add-hook 'after-init-hook
            (lambda ()
              (message "Emacs has fully loaded. This code runs after startup.")
              (with-current-buffer (get-buffer-create "*scratch*")
                (insert (format
                         ";;    Welcome to Emacs (meow-kick)!
;;
;;    Loading time : %s
;;    Packages     : %s
"
                         (emacs-init-time)
                         (length (hash-table-keys straight--recipe-cache))))))))

;;; WINDOW
(use-package window
  :ensure nil
  :custom
  (display-buffer-alist
   '(("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\|[Hh]elp\\|Messages\\|Bookmark List\\|Ibuffer\\|Occur\\|eldoc.*\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))

     ("\\*\\(lsp-help\\)\\*"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 0))

     ("\\*\\(Flymake diagnostics\\|xref\\|ivy\\|Swiper\\|Completions\\)"
      (display-buffer-in-side-window)
      (window-height . 0.25)
      (side . bottom)
      (slot . 1)))))


;;; DIRED
(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-lah --group-directories-first")
  (dired-dwim-target t)
  (dired-guess-shell-alist-user
   '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open" "open")
     ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open")
     (".*" "open" "xdg-open")))
  (dired-kill-when-opening-new-dired-buffer t)
  :config
  (when (eq system-type 'darwin)
    (let ((gls (executable-find "gls")))
      (when gls
        (setq insert-directory-program gls)))))


;;; ERC
(use-package erc
  :defer t
  :custom
  (erc-join-buffer 'window)
  (erc-hide-list '("JOIN" "PART" "QUIT"))
  (erc-timestamp-format "[%H:%M]")
  (erc-autojoin-channels-alist '((".*\\.libera\\.chat" "#emacs"))))


;;; ISEARCH
(use-package isearch
  :ensure nil
  :config
  (setq isearch-lazy-count t)
  (setq lazy-count-prefix-format "(%s/%s) ")
  (setq lazy-count-suffix-format nil)
  (setq search-whitespace-regexp ".*?")
  :bind (("C-s" . isearch-forward)
         ("C-r" . isearch-backward)))


;;; VC
(use-package vc
  :ensure nil
  :defer t
  :bind
  (("C-x v d" . vc-dir)
   ("C-x v =" . vc-diff)
   ("C-x v D" . vc-root-diff)
   ("C-x v v" . vc-next-action))
  :config
  (setq vc-annotate-color-map
        '((20 . "#f5e0dc")
          (40 . "#f2cdcd")
          (60 . "#f5c2e7")
          (80 . "#cba6f7")
          (100 . "#f38ba8")
          (120 . "#eba0ac")
          (140 . "#fab387")
          (160 . "#f9e2af")
          (180 . "#a6e3a1")
          (200 . "#94e2d5")
          (220 . "#89dceb")
          (240 . "#74c7ec")
          (260 . "#89b4fa")
          (280 . "#b4befe"))))


;;; SMERGE
(use-package smerge-mode
  :ensure nil
  :defer t
  :bind (:map smerge-mode-map
              ("C-c ^ u" . smerge-keep-upper)
              ("C-c ^ l" . smerge-keep-lower)
              ("C-c ^ n" . smerge-next)
              ("C-c ^ p" . smerge-previous)))


;;; ELDOC
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-idle-delay 0)
  (setq eldoc-echo-area-use-multiline-p nil)
  (setq eldoc-echo-area-display-truncation-message nil)
  :init
  (global-eldoc-mode))


;;; FLYMAKE
(use-package flymake
  :ensure nil
  :defer t
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicators-string
   '((error "!»" compilation-error) (warning "»" compilation-warning)
     (note "»" compilation-info))))


;;; ORG-MODE
(use-package org
  :ensure nil
  :defer t)


;;; WHICH-KEY
(use-package which-key
  :ensure nil
  :defer t
  :hook
  (after-init . which-key-mode))

;;; ==================== EXTERNAL PACKAGES ====================

;;; VERTICO
(use-package vertico
  :ensure t
  :straight t
  :hook
  (after-init . vertico-mode)
  :custom
  (vertico-count 10)
  (vertico-resize nil)
  (vertico-cycle nil)
  :config
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face '(:foreground "#80adf0" :weight bold))
                   "  ")
                 cand))))


;;; ORDERLESS
(use-package orderless
  :ensure t
  :straight t
  :defer t
  :after vertico
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))


;;; MARGINALIA
(use-package marginalia
  :ensure t
  :straight t
  :hook
  (after-init . marginalia-mode))


;;; CONSULT
(use-package consult
  :ensure t
  :straight t
  :defer t
  :init
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))


;;; EMBARK
(use-package embark
  :ensure t
  :straight t
  :defer t)


;;; EMBARK-CONSULT
(use-package embark-consult
  :ensure t
  :straight t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))


;;; CORFU
(use-package corfu
  :ensure t
  :straight t
  :defer t
  :custom
  (corfu-auto nil)
  (corfu-auto-prefix 1)
  (corfu-quit-no-match t)
  (corfu-scroll-margin 5)
  (corfu-max-width 50)
  (corfu-min-width 50)
  (corfu-popupinfo-delay 0.5)
  :config
  (if mk-use-nerd-fonts
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode t))


;;; NERD-ICONS-CORFU
(use-package nerd-icons-corfu
  :if mk-use-nerd-fonts
  :ensure t
  :straight t
  :defer t
  :after (:all corfu))

;;; TREESITTER-AUTO
(use-package treesit-auto
  :ensure t
  :straight t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))


;;; MARKDOWN-MODE
(use-package markdown-mode
  :defer t
  :straight t
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))


;;; LSP-MODE
(use-package lsp-mode
  :ensure t
  :straight t
  :defer t
  :hook (
         (lsp-mode . lsp-enable-which-key-integration)
         ((js-mode
           tsx-ts-mode
           typescript-ts-base-mode
           css-mode
           go-ts-mode
           js-ts-mode
           prisma-mode
           python-base-mode
           ruby-base-mode
           rust-ts-mode
           web-mode) . lsp-deferred))
  :commands lsp
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-inlay-hint-enable nil)
  (lsp-completion-provider :none)
  (lsp-session-file (locate-user-emacs-file ".lsp-session"))
  (lsp-log-io nil)
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-enable-xref t)
  (lsp-auto-configure t)
  (lsp-enable-links nil)
  (lsp-eldoc-enable-hover t)
  (lsp-enable-file-watchers nil)
  (lsp-enable-folding nil)
  (lsp-enable-imenu t)
  (lsp-enable-indentation nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-suggest-server-download t)
  (lsp-enable-symbol-highlighting t)
  (lsp-enable-text-document-color t)
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-modeline-workspace-status-enable t)
  (lsp-signature-doc-lines 1)
  (lsp-eldoc-render-all t)
  (lsp-completion-enable t)
  (lsp-completion-enable-additional-text-edit t)
  (lsp-enable-snippet nil)
  (lsp-completion-show-kind t)
  (lsp-lens-enable t)
  (lsp-headerline-breadcrumb-enable-symbol-numbers t)
  (lsp-headerline-arrow "▶")
  (lsp-headerline-breadcrumb-enable-diagnostics nil)
  (lsp-headerline-breadcrumb-icons-enable nil)
  (lsp-semantic-tokens-enable nil))


;;; LSP-TAILWINDCSS
(use-package lsp-tailwindcss
  :ensure t
  :straight t
  :defer t
  :config
  (add-to-list 'lsp-language-id-configuration '(".*\\.erb$" . "html"))
  :init
  (setq lsp-tailwindcss-add-on-mode t))


;;; ELDOC-BOX
(use-package eldoc-box
  :ensure t
  :straight t
  :defer t)

;;; DIFF-HL
(use-package diff-hl
  :defer t
  :straight t
  :ensure t
  :hook
  (find-file . (lambda ()
                 (global-diff-hl-mode)
                 (diff-hl-flydiff-mode)
                 (diff-hl-margin-mode)))
  :custom
  (diff-hl-side 'left)
  (diff-hl-margin-symbols-alist '((insert . "┃")
                                  (delete . "-")
                                  (change . "┃")
                                  (unknown . "┆")
                                  (ignored . "i"))))


;;; MAGIT
(use-package magit
  :ensure t
  :straight t
  :config
  (if mk-use-nerd-fonts
      (setopt magit-format-file-function #'magit-format-file-nerd-icons))
  :defer t)


;;; XCLIP
(use-package xclip
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . xclip-mode))


;;; INDENT-GUIDE
(use-package indent-guide
  :defer t
  :straight t
  :ensure t
  :hook
  (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│"))


;;; ADD-NODE-MODULES-PATH
(use-package add-node-modules-path
  :ensure t
  :straight t
  :defer t
  :custom
  (eval-after-load 'typescript-ts-mode
    '(add-hook 'typescript-ts-mode-hook #'add-node-modules-path))
  (eval-after-load 'tsx-ts-mode
    '(add-hook 'tsx-ts-mode-hook #'add-node-modules-path))
  (eval-after-load 'typescriptreact-mode
    '(add-hook 'typescriptreact-mode-hook #'add-node-modules-path))
  (eval-after-load 'js-mode
    '(add-hook 'js-mode-hook #'add-node-modules-path)))


;;; UNDO-TREE
(use-package undo-tree
  :defer t
  :ensure t
  :straight t
  :hook
  (after-init . global-undo-tree-mode)
  :init
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-limit 800000
        undo-strong-limit 12000000
        undo-outer-limit 120000000)
  :config
  (setq undo-tree-history-directory-alist
        `(("." . ,(expand-file-name ".cache/undo" user-emacs-directory)))))


;;; RAINBOW-DELIMITERS
(use-package rainbow-delimiters
  :defer t
  :straight t
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))


;;; DOTENV-MODE
(use-package dotenv-mode
  :defer t
  :straight t
  :ensure t)


;;; PULSAR
(use-package pulsar
  :defer t
  :straight t
  :ensure t
  :hook
  (after-init . pulsar-global-mode)
  :config
  (setq pulsar-pulse t)
  (setq pulsar-delay 0.025)
  (setq pulsar-iterations 10)
  (setq pulsar-face 'pulsar-generic)

  (add-to-list 'pulsar-pulse-functions 'scroll-up-command)
  (add-to-list 'pulsar-pulse-functions 'scroll-down-command)
  (add-to-list 'pulsar-pulse-functions 'flymake-goto-next-error)
  (add-to-list 'pulsar-pulse-functions 'flymake-goto-prev-error)
  (add-to-list 'pulsar-pulse-functions 'meow-save)
  (add-to-list 'pulsar-pulse-functions 'meow-kill)
  (add-to-list 'pulsar-pulse-functions 'meow-block)
  (add-to-list 'pulsar-pulse-functions 'diff-hl-next-hunk)
  (add-to-list 'pulsar-pulse-functions 'diff-hl-previous-hunk)
  (add-to-list 'pulsar-pulse-functions 'avy-goto-char-timer))


;;; AVY
(use-package avy
  :ensure t
  :straight t
  :defer t
  :custom
  (avy-timeout-seconds 0.3)
  (avy-all-windows t)
  :bind
  (("C-'" . avy-goto-char-timer)
   ("M-g g" . avy-goto-line)
   ("M-g w" . avy-goto-word-1)))


;;; SMARTPARENS
(use-package smartparens
  :ensure t
  :straight t
  :defer t
  :hook
  (prog-mode . smartparens-mode)
  (emacs-lisp-mode . smartparens-strict-mode)
  :config
  (require 'smartparens-config))


;;; YASNIPPET
(use-package yasnippet
  :ensure t
  :straight t
  :defer t
  :hook
  (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :ensure t
  :straight t
  :defer t
  :after yasnippet)


;;; EDITORCONFIG
(use-package editorconfig
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . editorconfig-mode))


;;; HELPFUL
(use-package helpful
  :ensure t
  :straight t
  :defer t
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command)
  ([remap describe-symbol] . helpful-symbol))


;;; EXPAND-REGION
(use-package expand-region
  :ensure t
  :straight t
  :defer t
  :bind
  ("C-=" . er/expand-region))


;;; COMMENT-DWIM-2
(use-package comment-dwim-2
  :ensure t
  :straight t
  :defer t
  :bind
  ([remap comment-dwim] . comment-dwim-2))


;;; HL-TODO
(use-package hl-todo
  :ensure t
  :straight t
  :defer t
  :hook
  (prog-mode . hl-todo-mode))


;;; ENVRC
(use-package envrc
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . envrc-global-mode))


;;; CONSULT-PROJECT-EXTRA
(use-package consult-project-extra
  :ensure t
  :straight t
  :defer t
  :bind
  ("C-c p f" . consult-project-extra-find)
  ("C-c p o" . consult-project-extra-find-other-window))


;;; PERSISTENT-SCRATCH
(use-package persistent-scratch
  :ensure t
  :straight t
  :defer t
  :hook
  (after-init . persistent-scratch-setup-default))


;;; VLF
(use-package vlf
  :ensure t
  :straight t
  :defer t
  :config
  (require 'vlf-setup))


;;; GIT-LINK
(use-package git-link
  :ensure t
  :straight t
  :defer t
  :custom
  (git-link-open-in-browser nil)
  (git-link-use-commit t)
  :bind
  ("C-c g l" . git-link)
  ("C-c g c" . git-link-commit)
  ("C-c g h" . git-link-homepage))


;;; DIFFTASTIC
(use-package difftastic
  :ensure t
  :straight t
  :defer t
  :bind (:map magit-blame-read-only-mode-map
              ("D" . difftastic-magit-diff)
              ("S" . difftastic-magit-show))
  :config
  (eval-after-load 'magit-diff
    '(transient-append-suffix 'magit-diff '(-1 -1)
       [("D" "Difftastic diff (dwim)" difftastic-magit-diff)
        ("S" "Difftastic show" difftastic-magit-show)])))


;;; DOOM-MODELINE
(use-package doom-modeline
  :ensure t
  :straight t
  :defer t
  :custom
  (doom-modeline-buffer-file-name-style 'buffer-name)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-name t)
  (doom-modeline-vcs-max-length 25)
  :config
  (if mk-use-nerd-fonts
      (setq doom-modeline-icon t)
    (setq doom-modeline-icon nil))
  :hook
  (after-init . doom-modeline-mode))


;;; NEOTREE
(use-package neotree
  :ensure t
  :straight t
  :custom
  (neo-show-hidden-files t)
  (neo-theme 'nerd)
  (neo-vc-integration '(face char))
  :defer t
  :config
  (if mk-use-nerd-fonts
      (setq neo-theme 'nerd-icons)
    (setq neo-theme 'nerd)))


;;; NERD-ICONS
(use-package nerd-icons
  :if mk-use-nerd-fonts
  :ensure t
  :straight t
  :defer t)


;;; NERD-ICONS-DIRED
(use-package nerd-icons-dired
  :if mk-use-nerd-fonts
  :ensure t
  :straight t
  :defer t
  :hook
  (dired-mode . nerd-icons-dired-mode))


;;; NERD-ICONS-COMPLETION
(use-package nerd-icons-completion
  :if mk-use-nerd-fonts
  :ensure t
  :straight t
  :after (:all nerd-icons marginalia)
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))


;;; CATPPUCCIN-THEME
(use-package catppuccin-theme
  :ensure t
  :straight t
  :config
  (custom-set-faces
   `(diff-hl-change ((t (:background unspecified :foreground ,(catppuccin-get-color 'blue))))))
  (custom-set-faces
   `(diff-hl-delete ((t (:background unspecified :foreground ,(catppuccin-get-color 'red))))))
  (custom-set-faces
   `(diff-hl-insert ((t (:background unspecified :foreground ,(catppuccin-get-color 'green))))))
  (load-theme 'catppuccin :no-confirm))

;;; MEOW
;; Meow is a modal editing system for Emacs with a selection-first paradigm.
;; Unlike evil (vim emulation), meow uses selection → action flow:
;; first select text, then act on it. Keypad mode (SPC in normal state)
;; provides access to all Emacs keybindings via C- prefix translation.
;;
;; Keypad examples:
;;   SPC x f  → C-x C-f (find-file)
;;   SPC h f  → C-h C-f (describe-function)
;;   SPC x ;  → C-x C-; (comment-line)
;;
;; See: https://github.com/meow-edit/meow

(defun mk/meow-setup ()
  "Meow setup with QWERTY layout."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :ensure t
  :straight t
  :config
  (mk/meow-setup)
  (meow-global-mode 1))


;;; HOVER DOCUMENTATION HELPER
(defun mk/lsp-describe-and-jump ()
  "Show hover documentation and jump to *lsp-help* buffer."
  (interactive)
  (lsp-describe-thing-at-point)
  (let ((help-buffer "*lsp-help*"))
    (when (get-buffer help-buffer)
      (switch-to-buffer-other-window help-buffer))))

;; Bind hover docs: eldoc-box on Emacs 31+, fallback to lsp-help buffer
(global-set-key (kbd "C-c k")
  (if (>= emacs-major-version 31)
      #'eldoc-box-help-at-point
    #'mk/lsp-describe-and-jump))


;;; FIRST INSTALL UTILITY
(defun mk/first-install ()
  "Install tree-sitter grammars and nerd-icon fonts on first run."
  (interactive)
  (switch-to-buffer "*Messages*")
  (message ">>> All required packages installed.")
  (message ">>> Configuring Emacs Meow Kick...")
  (message ">>> Configuring Tree Sitter parsers...")
  (require 'treesit-auto)
  (treesit-auto-install-all)
  (message ">>> Configuring Nerd Fonts...")
  (require 'nerd-icons)
  (nerd-icons-install-fonts)
  (message ">>> Emacs Meow Kick installed! Press any key to close the installer and open Emacs normally.")
  (read-key)
  (kill-emacs))

(provide 'init)
