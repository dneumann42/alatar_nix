(require 'subr-x)
(require 'use-package)
(require 'cmuscheme)
(require 'eglot)

(setq inhibit-startup-screen t)
(setq initial-scratch-message nil)
(setq ring-bell-function 'ignore)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq use-package-always-ensure nil)
(setq confirm-kill-processes nil)
(setq completion-cycle-threshold 3)
(setq tab-always-indent 'complete)
(setq completion-styles '(orderless basic))
(setq completion-category-defaults nil)
(setq completion-category-overrides '((file (styles basic partial-completion))))
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq eglot-autoshutdown t)
(setq eglot-events-buffer-config '(:size 0 :format full))
(setq eldoc-idle-delay 0.15)
(setq-default indent-tabs-mode nil)

(electric-pair-mode 1)

;; Apply GUI defaults before frames are created.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(use-package doom-themes
  :config
  (setq custom-enabled-themes nil)
  (load-theme 'doom-badger t))

(use-package vertico
  :config
  (vertico-mode 1))

(use-package orderless)

(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c s" . consult-ripgrep)
         ("C-c i" . consult-imenu)
         ("M-y" . consult-yank-pop)))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.05)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  :config
  (global-corfu-mode 1))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(use-package neotree
  :bind (("M-0" . neotree-toggle))
  :config
  (setq neo-smart-open t)
  (setq neo-window-fixed-size nil))

(defconst maindo/project-root
  (expand-file-name ".projects/maindo/" (getenv "HOME")))

(defconst maindo/src-dir
  (expand-file-name "src" maindo/project-root))

(defconst maindo/scheme-buffer-name "*scheme*")

(setenv
 "GUILE_LOAD_PATH"
 (if-let ((existing (getenv "GUILE_LOAD_PATH")))
     (concat maindo/src-dir path-separator existing)
   maindo/src-dir))

(setq default-directory maindo/project-root)
(setq scheme-program-name "guile")
(add-to-list 'eglot-server-programs
             '((scheme-mode) . ("guile-lsp-server")))

(defun maindo--scheme-proc (&optional restart)
  (let* ((buffer (get-buffer-create maindo/scheme-buffer-name))
         (proc (get-buffer-process buffer)))
    (when (and restart proc)
      (delete-process proc)
      (setq proc nil)
      (with-current-buffer buffer
        (let ((inhibit-read-only t))
          (erase-buffer))))
    (unless proc
      (let* ((default-directory maindo/project-root)
             (cmdlist (split-string-and-unquote scheme-program-name))
             (program (car cmdlist))
             (args (cdr cmdlist)))
        (apply #'make-comint-in-buffer
               "scheme"
               buffer
               program
               (scheme-start-file program)
               args)
        (with-current-buffer buffer
          (inferior-scheme-mode))
        (setq proc (get-buffer-process buffer))))
    (setq scheme-buffer maindo/scheme-buffer-name)
    proc))

(defun maindo--send-string (string)
  (let ((proc (maindo--scheme-proc)))
    (comint-send-string proc string)
    (comint-send-string proc "\n")))

(defun maindo--send-region (start end)
  (let ((proc (maindo--scheme-proc)))
    (comint-send-region proc start end)
    (comint-send-string proc "\n")))

(defun maindo--wait-for-token (proc buffer token start-pos)
  (with-current-buffer buffer
    (let ((found nil))
      (while (and (not found)
                  (accept-process-output proc 0.1))
        (save-excursion
          (goto-char start-pos)
          (setq found (search-forward token nil t))))
      found)))

(defun maindo--extract-between-tokens (buffer start-pos start-token end-token)
  (with-current-buffer buffer
    (save-excursion
      (goto-char start-pos)
      (when (search-forward start-token nil t)
        (let ((beg (point)))
          (when (search-forward end-token nil t)
            (buffer-substring-no-properties beg (match-beginning 0))))))))

(defun maindo--eval-string (form)
  (let* ((proc (maindo--scheme-proc))
         (buffer (process-buffer proc))
         (start-token (format "__maindo_start_%s__" (float-time)))
         (end-token (format "__maindo_end_%s__" (float-time)))
         (start-pos (with-current-buffer buffer (point-max)))
         (command
          (format
           "(begin (display %S) (write (eval '(begin %s) (current-module))) (display %S) (newline))"
           start-token
           form
           end-token)))
    (maindo--send-string command)
    (when (maindo--wait-for-token proc buffer end-token start-pos)
      (let ((result (maindo--extract-between-tokens
                     buffer start-pos start-token end-token)))
        (if result
            result
          "<eval-capture-failed>")))))

(defun maindo--eros-overlay (message point)
  (when (featurep 'eros)
    (eros-eval-overlay message point)))

(defun maindo-scheme-eval-dwim ()
  (interactive)
  (let* ((bounds
          (if (use-region-p)
              (cons (region-beginning) (region-end))
            (save-excursion
              (let ((end (point)))
                (backward-sexp)
                (cons (point) end)))))
         (start (car bounds))
         (end (cdr bounds))
         (form (buffer-substring-no-properties start end))
         (result (or (maindo--eval-string form) "")))
    (maindo--eros-overlay result end)))

(defun maindo-run-project ()
  (interactive)
  (let ((proc (maindo--scheme-proc t)))
    (comint-send-string proc "(use-modules (app main))\n")
    (comint-send-string proc "(main '(\"emacs\"))\n")
    (maindo--eros-overlay "=> restarted Guile and ran (app main)" (point))))

(use-package cmuscheme
  :bind (("C-c C-z" . run-scheme)))

(use-package eros)

(use-package eglot
  :custom
  (eglot-sync-connect 1)
  :hook (scheme-mode . eglot-ensure)
  :bind
  (:map eglot-mode-map
        ("M-." . xref-find-definitions)
        ("M-?" . xref-find-references)
        ("M-," . xref-go-back)
        ("C-c e" . eglot)))

(use-package cider
  :custom
  (cider-repl-use-pretty-printer t)
  (cider-selector nil))

(use-package clojure-mode
  :mode ("\\.clj\\'" . clojure-mode)
  :mode ("\\.cljs\\'" . clojure-mode)
  :mode ("\\.cljc\\'" . clojure-mode)
  :hook
  (clojure-mode . display-line-numbers-mode)
  (clojure-mode . (lambda ()
                    (setq-local tab-width 2)
                    (setq-local indent-tabs-mode nil)))
  :bind
  (:map clojure-mode-map
        ("C-c C-k" . cider-compile-ns)
        ("C-c C-z" . cider-switch-to-repl-buffer)
        ("M-/" . completion-at-point)))

(use-package scheme
  :mode ("\\.scm\\'" . scheme-mode)
  :bind
  (:map scheme-mode-map
        ("C-c C-c" . maindo-scheme-eval-dwim)
        ("C-c C-k" . maindo-run-project)
        ("C-c C-z" . run-scheme)
        ("M-/" . completion-at-point)
        ("C-c l ." . xref-find-definitions)
        ("C-c l ," . xref-go-back)
        ("C-c l ?" . xref-find-references)
        ("C-c l r" . eglot-rename)
        ("C-c l a" . eglot-code-actions)
        ("C-c l f" . eglot-format-buffer)
        ("C-c l d" . eldoc)
        ("C-c l e" . eglot)
        ("C-c x x" . flymake-show-buffer-diagnostics)
        ("C-c x n" . flymake-goto-next-error)
        ("C-c x p" . flymake-goto-prev-error))
  :hook
  (scheme-mode . display-line-numbers-mode)
  (scheme-mode . (lambda ()
                    (setq-local tab-width 2)
                    (setq-local indent-tabs-mode nil)
                    (setq-local xref-show-xrefs-function #'consult-xref)
                    (setq-local xref-show-definitions-function #'consult-xref)
                    (setq-local completion-at-point-functions
                                (append (list (cape-capf-super
                                               #'eglot-completion-at-point
                                               #'cape-file
                                               #'cape-dabbrev))
                                        completion-at-point-functions)))))

(let ((main-file (expand-file-name "src/app/main.scm" maindo/project-root)))
  (when (and (null command-line-args-left)
             (file-exists-p main-file))
    (find-file main-file)))
