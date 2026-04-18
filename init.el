
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;; ====================
;; Font config
;; ====================
(defvar my/font-name "Monospace")
(defvar my/font-size 110)

(set-face-attribute 'default nil
                    :font my/font-name
                    :height my/font-size)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-reset)

;; ====================
;; Package management
;; ====================
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

;; Refresh package contents if use-package is not installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Ensure packages are available
(unless (package-installed-p 'doom-modeline)
  (package-refresh-contents)
  (condition-case nil
      (package-install 'doom-modeline)
    (error
     (message "Warning: Could not install doom-modeline automatically. Install with M-x package-install RET doom-modeline RET"))))

(unless (package-installed-p 'dashboard)
  (package-refresh-contents)
  (condition-case nil
      (package-install 'dashboard)
    (error
     (message "Warning: Could not install dashboard automatically. Install with M-x package-install RET dashboard RET"))))

(require 'use-package)
(setq use-package-always-ensure t)

;; ====================
;; Undo
;; ====================
(use-package undo-tree
  :init
  (global-undo-tree-mode))
  (setq undo-tree-auto-save-history nil)
;; ====================
;; Evil
;; ====================
(use-package evil
  :ensure t
  :init
  (setq evil-undo-system 'undo-tree)
  (setq evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-respect-visual-line-mode t)
  :config
  (evil-mode 1))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(evil-ex-define-cmd "w" 'save-buffer)
(evil-ex-define-cmd "q" 'evil-quit)
(evil-ex-define-cmd "wq" 'evil-save-and-close)
(evil-ex-define-cmd "qa" 'evil-quit-all)

(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'visual (kbd "SPC"))

(evil-define-key 'normal 'global
  (kbd "<leader> c c") #'compile
  (kbd "<leader> c r") #'recompile
  (kbd "<leader> f f") #'find-file
  (kbd "<leader> b b") #'switch-to-buffer
  (kbd "<leader> w s") #'split-window-below
  (kbd "<leader> w v") #'split-window-right)

;; ====================
;; Dired
;; ====================
(setq dired-kill-when-opening-new-dired-buffer t
      dired-recursive-copies 'always
      dired-recursive-deletes 'always
      dired-dwim-target t ; suggest target directory from other window
      delete-by-moving-to-trash t)

(put 'dired-find-alternate-file 'disabled nil)

(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map
    (kbd "h") #'dired-up-directory
    (kbd "l") #'dired-find-file
    (kbd "m") #'dired-mark
    (kbd "u") #'dired-unmark
    (kbd "R") #'dired-do-rename
    (kbd "C") #'dired-do-copy
    (kbd "D") #'dired-do-delete
    (kbd "+") #'dired-create-directory
    (kbd "i") #'wdired-change-to-wdired-mode ; Edit file names as text
    (kbd "g r") #'revert-buffer))

;; ====================
;; Theme
;; ====================
(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi-deuteranopia t))

;; ====================
;; Doom modeline
;; ====================
(use-package doom-modeline
  :ensure t
  :defer 1
  :init
  (with-eval-after-load 'doom-modeline
    (doom-modeline-mode 1))
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-enable-word-count nil)
  (doom-modeline-time-icon t)
  (doom-modeline-time-string "%H:%M")
  (doom-modeline-env-version t)
  (doom-modeline-project-detection 'projectile)
  (doom-modeline-icon t)
  (doom-modeline-display-icons t)
  (doom-modeline-unicode-fallback nil)  ; Disable emoji/fancy unicode characters
  (doom-modeline-vcs-icon t)
  (doom-modeline-buffer-encoding-icon nil)  ; Disable encoding icon to keep it minimal
  (doom-modeline-highlight-insert t)
  (doom-modeline-mu4e nil)
  (doom-modeline-gnus nil)
  (doom-modeline-gui-separator-construct 'nil)  ; Clean separator
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-minor-modes nil)  ; Keep minor modes hidden for minimalism
  (doom-modeline-enable-org-clock-progress-bar nil))

;; ====================
;; Dashboard
;; ====================
(use-package dashboard
  :ensure t
  :config
  ;; Inline banner content
  (defconst my-dashboard-banner
    "        .-~~-.--.
       :         )
 .~ ~ -.\       /.- ~~ .
 >       \`.   .\'       <
(         .- -.         )
 `- -.-~  \`- -\'  ~-.- -'
   (        :        )           _ _ .-:
    ~--.    :    .--~        .-~  .-~  }
        ~-.-^-.-~ \\_      .~  .-~   .~
                 \\\'     \\\' '_ _ -~
                  \\`\\    ///
         . - ~ ~-.__\\`.-.///
     .-~   . - ~  }~ ~ ~-.~-.
   .\' .-~      .-~       :/~-.~-./:
  /_~_ _ . - ~                 ~-.~-._
                                   ~-.<"
    "ASCII art banner for dashboard.")

  ;; Write the banner to a temporary file
  (let ((banner-file (make-temp-file "emacs-banner" nil ".txt")))
    (with-temp-file banner-file
      (insert my-dashboard-banner))
    (setq dashboard-startup-banner banner-file))

  ;; Disable line numbers in dashboard
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (display-line-numbers-mode -1)))

  ;; Initialize recentf at startup to prevent issues with recent files
  (recentf-mode 1)

  ;; Ensure recentf list is loaded at startup
  (run-at-time "0.1 sec" nil 'recentf-load-list)

  (setq dashboard-center-content t
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-show-shortcuts t
        dashboard-set-navigator t
        ;; Increase banner height to accommodate our ASCII art
        dashboard-banner-length 25
        ;; Customize the dashboard items
        dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)))

  ;; Configure projectile to work with dashboard
  (setq dashboard-projects-backend 'projectile)

  (setq dashboard-set-init-info t)

  (dashboard-setup-startup-hook))

(defun my-choose-initial-buffer ()
  (if (or (not (boundp 'server-args))
          (null server-args)
          (and (listp server-args)
               (<= (length server-args) 1)))
      (progn
        (dashboard-insert-startupify-lists)
        (get-buffer "*dashboard*"))
    (get-buffer "*scratch*")))

(setq initial-buffer-choice 'my-choose-initial-buffer)

;; ====================
;; Ivy stack
;; ====================
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-height 15))

(use-package counsel
  :ensure t
  :after ivy
  :config
  (counsel-mode 1)
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . counsel-switch-buffer)))

(use-package swiper
  :ensure t
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper-backward)))

;; ====================
;; Lightweight completion
;; ====================
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  (setq corfu-auto t
        corfu-cycle t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-symbol))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode))

(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)
         ("C-h x" . helpful-command)))

;; ====================
;; Evil extras
;; ====================
(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode))

;; ====================
;; Flymake
;; ====================
(add-hook 'prog-mode-hook 'flymake-mode)

;; ====================
;; Ripgrep
;; ====================
(use-package rg
  :ensure t
  :bind ("C-c r" . rg-menu))

;; ====================
;; Markdown
;; ====================
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode ("\\.md\\'" . markdown-mode)
  :init
  (setq markdown-command "markdown"))

;; ====================
;; Gdscript
;; ====================
(use-package gdscript-mode
  :ensure t
  :mode "\\.gd\\'")

;; ====================
;; Recentf
;; ====================
(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 200)

;; ====================
;; Bookmark
;; ====================
(setq bookmark-save-flag 1)

;; ====================
;; Projectile
;; ====================
(use-package projectile
  :ensure t
  :config
  (projectile-mode 1)
  (setq projectile-completion-system 'ivy)

  (evil-define-key 'normal 'global
    (kbd "<leader> p p") #'projectile-switch-project
    (kbd "<leader> .") #'projectile-find-file))

;; ====================
;; Keybindings
;; ====================
(evil-define-key 'normal 'global
  (kbd "<leader> f r") #'counsel-recentf
  (kbd "<leader> b d") #'kill-this-buffer
  (kbd "<leader> w c") #'delete-window
  (kbd "<leader> w o") #'delete-other-windows
  (kbd "<leader> d") (lambda () (interactive) (dired default-directory))
  (kbd "<leader> D") (lambda () (interactive) (dired "~")))

;; ====================
;; Line numbers
;; ====================
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
;; ====================
;; UI enhancements
;; ====================
(show-paren-mode 1)
(global-hl-line-mode 1)
(electric-pair-mode 1)
(setq column-number-mode t)

;; ====================
;; Sane defaults
;; ====================
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

(setq scroll-margin 5
      scroll-conservatively 101
      scroll-step 1)

(setq-default indent-tabs-mode nil
              tab-width 4)

(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'whitespace-cleanup nil t)))

(save-place-mode 1)
(global-auto-revert-mode 1)

(fset 'yes-or-no-p 'y-or-n-p)

(setq select-enable-clipboard t
      save-interprogram-paste-before-kill t)

(setq history-length 1000)

;; ====================
;; TODO highlight
;; ====================
(font-lock-add-keywords nil
                        '(("\\<\\(FIXME\\|TODO\\|BUG\\|HACK\\|NOTE\\)"
                           1 font-lock-warning-face t)))

(put 'narrow-to-region 'disabled nil)

;; ====================
;; Eglot (LSP support)
;; ====================
(use-package eglot
  :ensure t
  :config
  (setq my/eglot-language-servers
        '((c-mode . "clangd")
          (c++-mode . "clangd")
          (zig-mode . "zls")
          (rust-mode . "rust-analyzer")
          (js-mode . "typescript-language-server --stdio")
          (typescript-mode . "typescript-language-server --stdio")
          (sh-mode . "bash-language-server start")
          (gdscript-mode . "gdscript-lsp")
          (python-mode . "pyright")
          (java-mode . "jdtls")))

  (dolist (pair my/eglot-language-servers)
    (let ((mode (car pair)))
      (add-hook (intern (format "%s-hook" mode))
                #'eglot-ensure)))

  ;; enable/disable functions
  (defun my-eglot-enable ()
    "Enable Eglot in current buffer."
    (interactive)
    (eglot-ensure))

  (defun my-eglot-disable ()
    "Disable Eglot in current buffer."
    (interactive)
    (when (eglot-current-server)
      (eglot-shutdown (eglot-current-server))))

  ;; leader key bindings
  (evil-define-key 'normal 'global
    (kbd "<leader> l e") #'my-eglot-enable
    (kbd "<leader> l d") #'my-eglot-disable))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (cons 'eglot-completion-at-point
                              completion-at-point-functions))))

(add-hook 'eglot-managed-mode-hook #'eldoc-mode)

;; ====================
;; Org Mode
;; ====================
(use-package org
  :ensure nil
  :bind (("C-c c" . org-capture))
  :config
  (setq org-directory "~/org"
        org-agenda-files '("~/org/todo.org"
                           "~/org/life-todo.org"
                           "~/org/study-todo.org"
                           "~/org/dev-todo.org"
                           "~/org/ideas.org"
                           "~/org/links.org")
        org-todo-keywords '((sequence "TODO(t)" "IDEA(i)" "LINK(l)" "|" "DONE(d)" "CANCELED(c)"))
        org-auto-align-tags nil
        org-tags-column 0
        ;; Disabling indent mode as requested to fix double stars
        org-startup-indented nil
        ;; Show images on startup
        org-startup-with-inline-images t
        ;; Redisplay images after manipulation
        org-image-actual-width nil)

  ;; Enable GIF and image animations
  (setq image-animate-loop t)
  (add-hook 'org-mode-hook #'org-display-inline-images)
  (defun my/org-capture-context ()
    (let ((ctx (string-trim (read-string "Context (life/study/dev, empty=task): "))))
      (cond
       ((string= ctx "life")  (cons "~/org/life-todo.org"  "life"))
       ((string= ctx "study") (cons "~/org/study-todo.org" "study"))
       ((string= ctx "dev")   (cons "~/org/dev-todo.org"   "dev"))
       (t                     (cons "~/org/todo.org"       "task")))))

  (defun my/org-capture-math-file ()
    (let* ((name (read-string "Paper name: "))
           (filename (format "%s/math/%s.org" org-directory name)))
      (make-directory (file-name-directory filename) t)
      filename))

  ;; Capture Templates
  (setq org-capture-templates
        '(("t" "Task (Context)" entry
           (file+headline (lambda () (let ((c (my/org-capture-context))) (setq my/org-capture-selected c) (car c))) "Tasks")
           "* TODO %?\n  Added: %U\n%(when (not (string-empty-p (cdr my/org-capture-selected))) (concat \" :\" (cdr my/org-capture-selected) \":\"))\n\n")

          ("i" "Quick Idea" entry
           (file+headline "~/org/ideas.org" "Inbox")
           "* IDEA %?\n  :PROPERTIES:\n  :CREATED: %U\n  :END:\n  %i"
           :prepend t :empty-lines 1)

          ("l" "Web Link" entry
           (file+headline "~/org/links.org" "To Read")
           "* LINK %? :LINK:\n  Added: %U\n  Source: %a\n"
           :prepend t)

          ("m" "Math Paper" plain
           (file my/org-capture-math-file)
           "#+TITLE: %^{Title}\n#+FILETAGS: :math:\n\n* %?\n"
           :jump-to-captured t)))

  ;; Keybindings
  (evil-define-key 'normal org-mode-map
    (kbd "TAB") #'org-cycle
    (kbd "S-TAB") #'org-shifttab)

  (evil-define-key 'normal 'global
    (kbd "<leader> o a") #'org-agenda
    (kbd "<leader> o w") (lambda () (interactive) (org-agenda nil "a"))
    (kbd "<leader> o c") #'org-capture
    (kbd "<leader> o b") #'org-switchb)

  ;; Quick Access to Org Directories
  (evil-define-key 'normal 'global
    (kbd "<leader> o m") (lambda () (interactive) (dired "~/org/math"))
    (kbd "<leader> o d") (lambda () (interactive) (dired "~/org/dev"))
    (kbd "<leader> o j")   (lambda () (interactive) (dired "~/org/journal")))

  ;; Agenda settings
  (setq org-agenda-span 'week
        org-agenda-start-on-weekday 1
        org-agenda-show-all-dates t))







;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(cape corfu counsel dashboard doom-modeline ement evil-commentary
          evil-surround gdscript-mode helpful marginalia markdown-mode
          modus-themes projectile rg undo-fu
          undo-tree)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
