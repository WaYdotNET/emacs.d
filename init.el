;;;_. Initialization

(setq message-log-max 8192)

(dolist (mode '(menu-bar-mode
                scroll-bar-mode
                tool-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

(dolist (mode '(column-number-mode
                show-paren-mode))
  (when (fboundp mode) (funcall mode 1)))

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(require 'use-package)
(require 'bind-key)
;;;_. General settings

(setq auto-save-list-file-prefix "~/.emacs.d/.auto-save-list/.saves-")
(setq custom-file "~/.emacs.d/custom.el")
(setq echo-keystrokes 0.1)
(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq require-final-newline t)
(setq ring-bell-function 'ignore)

;; Backups
(setq backup-by-copying t)
(setq backup-directory-alist '(("." . "~/.emacs.d/.saves")))
(setq delete-old-versions t)
(setq version-control t)

(setq-default tab-width 4)

(defalias 'yes-or-no-p 'y-or-n-p)

(set-face-attribute 'default nil :height 100)
;;;_. Functions

(defun back-to-indentation-or-beginning ()
  (interactive)
  (if (= (point) (progn (back-to-indentation) (point)))
      (beginning-of-line)))

(defun backward-kill-word-or-kill-region (&optional arg)
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))

(defun delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))
;;;_. Keybindings

(bind-key "C-S-p" '(lambda ()
                     (interactive)
                     (ignore-errors (previous-line 5))))
(bind-key "C-S-n" '(lambda ()
                     (interactive)
                     (ignore-errors (next-line 5))))
(bind-key "C-S-b" '(lambda ()
                     (interactive)
                     (ignore-errors (backward-char 5))))
(bind-key "C-S-f" '(lambda ()
                     (interactive)
                     (ignore-errors (forward-char 5))))

(bind-key "C-+" 'text-scale-increase)
(bind-key "C--" 'text-scale-decrease)
(bind-key "C-a" 'back-to-indentation-or-beginning)
(bind-key "C-w" 'backward-kill-word-or-kill-region)
(bind-key "C-x @" 'save-buffers-kill-terminal)
(bind-key "C-x C-c" nil)
(bind-key "C-x C-k" 'delete-current-buffer-file)
(bind-key "C-x C-r" 'rename-current-buffer-file)
(bind-key "M-n" 'forward-paragraph)
(bind-key "M-p" 'backward-paragraph)
(bind-key "RET" 'newline-and-indent)

(when (display-graphic-p)
  (unbind-key "C-z"))
;;;_. Packages
;;;_ , ace-jump-mode

(use-package ace-jump-mode
  :bind ("M-SPC" . ace-jump-mode))
;;;_ , allout

(setq allout-auto-activation t)

(use-package allout
  :diminish allout-mode)
;;;_ , anzu

(use-package anzu
  :init (global-anzu-mode 1))
;;;_ , auto-complete

(use-package auto-complete-config
  :diminish auto-complete-mode
  :init (ac-config-default)
  :config
  (progn
    (bind-key "C-s" 'ac-isearch ac-completing-map)
    (setq ac-comphist-file "~/.emacs.d/.ac-comphist.dat")))
;;;_ , autorevert

(use-package autorevert
  :commands auto-revert-mode
  :diminish auto-revert-mode
  :init
  (add-hook 'find-file-hook
            '(lambda ()
               (auto-revert-mode 1))))
;;;_ , browse-kill-ring

(use-package browse-kill-ring
  :init (browse-kill-ring-default-keybindings))
;;;_ , column-marker

(use-package column-marker
  :commands column-marker-1
  :init
  (add-hook 'prog-mode-hook
            '(lambda ()
               (interactive)
               (column-marker-1 81))))
;;;_ , elisp-slime-nav

(use-package elisp-slime-nav
  :diminish elisp-slime-nav-mode
  :init (add-hook 'emacs-lisp-mode-hook 'turn-on-elisp-slime-nav-mode))
;;;_ , emacs-lisp

(add-hook 'emacs-lisp-mode-hook
          '(lambda () (setq indent-tabs-mode nil)))
;;;_ , expand-region

(use-package expand-region
  :bind (("C-'" . er/contract-region)
         ("C-;" . er/expand-region)))
;;;_ , fic-mode

(use-package fic-mode
  :diminish fic-mode
  :commands fic-mode
  :init (add-hook 'prog-mode-hook 'fic-mode))
;;;_ , flycheck

(use-package flycheck
  :commands flycheck-mode)
;;;_ , git-auto-commit-mode

(use-package git-auto-commit-mode)
;;;_ , guide-key

(use-package guide-key
  :diminish guide-key-mode
  :init (guide-key-mode 1)
  :config (setq guide-key/guide-key-sequence '("C-x r" "C-x 4"
                                               (allout-mode "C-c SPC"))))
;;;_ , highlight-symbol

(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :commands highlight-symbol-mode
  :init
  (add-hook 'prog-mode-hook
            '(lambda ()
               (highlight-symbol-mode 1))))
;;;_ , hippie-exp

(use-package hippie-exp
  :bind ("M-/" . hippie-expand)
  :config
  (setq hippie-expand-try-functions-list
        '(try-expand-line
          try-expand-list)))
;;;_ , jedi

(use-package jedi
  :commands jedi:setup
  :init
  (progn
    (defun my-jedi-run-make-requirements ()
      (let* ((make (or (executable-find "make")
                       (error "Unable to find `make'")))
             (is-installed (package-installed-p 'jedi))
             (version (package-version-join
                       (elt (cdr (assoc 'jedi package-alist)) 0)))
             (default-directory (file-name-as-directory
                                 (package--dir "jedi" version)))
             (is-configured (file-exists-p
                             (expand-file-name "env/" default-directory))))
        (when (and is-installed (not is-configured))
          (call-process make nil nil nil "requirements"))))

    (my-jedi-run-make-requirements)
    (add-hook 'python-mode-hook 'jedi:setup))
  :config
  (progn
    (setq jedi:setup-keys t)
    (setq jedi:complete-on-dot t)))
;;;_ , json-mode

(use-package json-mode
  :mode "\\.json\\'")
;;;_ , magit

(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (progn
    (defadvice magit-status (around magit-fullscreen activate)
      (window-configuration-to-register :magit-fullscreen)
      ad-do-it
      (delete-other-windows))

    (defun magit-quit-session ()
      "Restores the previous window configuration and kills the magit buffer"
      (interactive)
      (kill-buffer)
      (jump-to-register :magit-fullscreen))

    (bind-key "q" 'magit-quit-session magit-status-mode-map)))
;;;_ , project-explorer

(use-package project-explorer
    :commands project-explorer-open
    :config (setq pe/cache-directory "~/.emacs.d/.project-explorer-cache/"))
;;;_ , projectile

(use-package projectile
  :diminish projectile-mode
  :init (projectile-global-mode)
  :config
  (progn
    (setq projectile-cache-file "~/.emacs.d/.projectile.cache")
    (setq projectile-known-projects-file
          "~/.emacs.d/.projectile-bookmarks.eld")))
;;;_ , ibuffer

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))
;;;_ , ido

(use-package ido
  :init (ido-mode 'both)
  :config
  (progn
    (setq ido-default-buffer-method 'selected-window)
    (setq ido-default-file-method 'selected-window)
    (setq ido-enable-flex-matching t)
    (setq ido-max-directory-size 100000)
    (setq ido-save-directory-list-file "~/.emacs.d/.ido.last")

    (use-package ido-ubiquitous
      :init (ido-ubiquitous-mode 1))

    (use-package ido-vertical-mode
      :init (ido-vertical-mode 1))

    (use-package idomenu
      :bind ("C-x C-i" . idomenu))))
;;;_ , indent-guide

(use-package indent-guide
  :diminish indent-guide-mode
  :commands indent-guide-mode
  :init
  (add-hook 'prog-mode-hook
            '(lambda ()
               (indent-guide-mode 1))))
;;;_ , recentf

(use-package recentf
  :config (setq recentf-save-file "~/.emacs.d/.recentf"))
;;;_ , saveplace

(use-package saveplace
  :config
  (progn
    (setq-default save-place t)
    (setq save-place-file "~/.emacs.d/.places")))
;;;_ , smart-mode-line

(use-package smart-mode-line
  :init (sml/setup))
;;;_ , smartparens

(use-package smartparens-config
  :diminish smartparens-mode
  :init (smartparens-global-mode t))
;;;_ , smex

(use-package smex
  :bind (("M-x" . smex)
         ("M-X" . smex-major-mode-commands))
  :config (setq smex-save-file "~/.emacs.d/.smex-items"))
;;;_ , tramp

(use-package tramp
  :defer t
  :config (setq tramp-persistency-file-name "~/.emacs.d/.tramp"))
;;;_ , undo-tree

(use-package undo-tree
  :diminish undo-tree-mode
  :init (global-undo-tree-mode))
;;;_ , uniquify

(use-package uniquify
  :init (setq uniquify-buffer-name-style 'forward))
;;;_ , virtualenvwrapper

(use-package virtualenvwrapper
  :commands venv-workon
  :config
  (progn
    (venv-initialize-interactive-shells)
    (venv-initialize-eshell)
    (setq-default mode-line-format
                  (cons '(:exec venv-current-name) mode-line-format))))
;;;_ , windmove

(use-package windmove
  :init (windmove-default-keybindings 'meta))
;;;_ , winner

(use-package winner
  :bind (("M-P" . winner-undo)
         ("M-N" . winner-redo))
  :init (winner-mode 1))
;;;_ , yaml-mode

(use-package yaml-mode
  :mode "\\.ya?ml\\'")
;;;_. Post initialization

(load-theme 'spolsky t)
(load custom-file)

;; Local Variables:
;;   allout-layout: 0
;;   outline-regexp: "^;;;_\\([,. ]+\\)"
;; End:
