;;; packages.el --- Spacemacs Editing Layer packages File
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst spacemacs-editing-packages
      '(aggressive-indent
        avy
        (bracketed-paste :toggle (version<= emacs-version "25.0.92"))
        clean-aindent-mode
        eval-sexp-fu
        expand-region
        (hexl :location built-in)
        hungry-delete
        link-hint
        lorem-ipsum
        move-text
        (origami :toggle (eq 'origami dotspacemacs-folding-method))
        smartparens
        (spacemacs-whitespace-cleanup :location local)
        undo-tree
        uuidgen
        ws-butler))

;; Initialization of packages

(defun spacemacs-editing/init-aggressive-indent ()
  (use-package aggressive-indent
    :defer t
    :init
    (spacemacs|add-toggle aggressive-indent
      :mode aggressive-indent-mode
      :documentation "Always keep code indented."
      :evil-leader "tI")
    (spacemacs|add-toggle aggressive-indent-globally
      :mode aggressive-indent-mode
      :documentation "Always keep code indented globally."
      :evil-leader "t C-I")
    :config
    (add-hook 'diff-auto-refine-mode-hook 'spacemacs/toggle-aggressive-indent-off)
    (spacemacs|diminish aggressive-indent-mode " Ⓘ" " I")))

(defun spacemacs-editing/init-avy ()
  (use-package avy
    :defer t
    :commands (spacemacs/avy-open-url spacemacs/avy-goto-url avy-pop-mark)
    :init
    (setq avy-all-windows 'all-frames)
    (setq avy-background t)
    (spacemacs/set-leader-keys
      "jb" 'avy-pop-mark
      "jj" 'evil-avy-goto-char-timer
      "jl" 'evil-avy-goto-line
      "ju" 'spacemacs/avy-goto-url
      "jw" 'evil-avy-goto-word-or-subword-1
      "xo" 'spacemacs/avy-open-url)
    :config
    (defun spacemacs/avy-goto-url()
      "Use avy to go to an URL in the buffer."
      (interactive)
      (avy--generic-jump "https?://" nil 'pre))
    (defun spacemacs/avy-open-url ()
      "Use avy to select an URL in the buffer and open it."
      (interactive)
      (save-excursion
        (spacemacs/avy-goto-url)
        (browse-url-at-point)))))

(defun spacemacs-editing/init-bracketed-paste ()
  (use-package bracketed-paste
    :defer t
    :init
    ;; Enable bracketed-paste for tty
    (add-hook 'tty-setup-hook 'bracketed-paste-enable)))

(defun spacemacs-editing/init-clean-aindent-mode ()
  (use-package clean-aindent-mode
    :config (clean-aindent-mode)))

(defun spacemacs-editing/init-eval-sexp-fu ()
  ;; ignore obsolete function warning generated on startup
  (let ((byte-compile-not-obsolete-funcs (append byte-compile-not-obsolete-funcs '(preceding-sexp))))
    (require 'eval-sexp-fu)))

(defun spacemacs-editing/init-expand-region ()
  (use-package expand-region
    :defer t
    :init (spacemacs/set-leader-keys "v" 'er/expand-region)
    :config
    ;; add search capability to expand-region
    (when (configuration-layer/package-usedp 'helm-ag)
      (defadvice er/prepare-for-more-expansions-internal
          (around helm-ag/prepare-for-more-expansions-internal activate)
        ad-do-it
        (let ((new-msg (concat (car ad-return-value)
                               ", / to search in project, "
                               "f to search in files, "
                               "b to search in opened buffers"))
              (new-bindings (cdr ad-return-value)))
          (cl-pushnew
           '("/" (lambda ()
                   (call-interactively
                    'spacemacs/helm-project-smart-do-search-region-or-symbol)))
           new-bindings)
          (cl-pushnew
           '("f" (lambda ()
                   (call-interactively
                    'spacemacs/helm-files-smart-do-search-region-or-symbol)))
           new-bindings)
          (cl-pushnew
           '("b" (lambda ()
                   (call-interactively
                    'spacemacs/helm-buffers-smart-do-search-region-or-symbol)))
           new-bindings)
          (setq ad-return-value (cons new-msg new-bindings)))))
    (setq expand-region-contract-fast-key "V"
          expand-region-reset-fast-key "r")))

(defun spacemacs-editing/init-hexl ()
  (use-package hexl
    :defer t
    :init
    (spacemacs/set-leader-keys "fh" 'hexl-find-file)
    (spacemacs/set-leader-keys-for-major-mode 'hexl-mode
      "d" 'hexl-insert-decimal-char
      "c" 'hexl-insert-octal-char
      "x" 'hexl-insert-hex-char
      "X" 'hexl-insert-hex-string
      "g" 'hexl-goto-address)
    (evil-define-key 'motion hexl-mode-map
      "]]" 'hexl-end-of-1k-page
      "[[" 'hexl-beginning-of-1k-page
      "h" 'hexl-backward-char
      "l" 'hexl-forward-char
      "j" 'hexl-next-line
      "k" 'hexl-previous-line
      "$" 'hexl-end-of-line
      "^" 'hexl-beginning-of-line
      "0" 'hexl-beginning-of-line)))

(defun spacemacs-editing/init-hungry-delete ()
  (use-package hungry-delete
    :defer t
    :init
    (spacemacs|add-toggle hungry-delete
      :mode hungry-delete-mode
      :documentation "Delete consecutive horizontal whitespace with a single key."
      :evil-leader "td")
    :config
    (setq-default hungry-delete-chars-to-skip " \t\f\v") ; only horizontal whitespace
    (define-key hungry-delete-mode-map (kbd "DEL") 'hungry-delete-backward)
    (define-key hungry-delete-mode-map (kbd "S-DEL") 'delete-backward-char)))

(defun spacemacs-editing/init-link-hint ()
  (use-package link-hint
    :defer t
    :init
    (spacemacs/set-leader-keys
      "xo" 'link-hint-open-link
      "xO" 'link-hint-open-multiple-links)))

(defun spacemacs-editing/init-lorem-ipsum ()
  (use-package lorem-ipsum
    :commands (lorem-ipsum-insert-list
               lorem-ipsum-insert-paragraphs
               lorem-ipsum-insert-sentences)
    :init
    (spacemacs/declare-prefix "il" "lorem ipsum")
    (spacemacs/set-leader-keys
      "ill" 'lorem-ipsum-insert-list
      "ilp" 'lorem-ipsum-insert-paragraphs
      "ils" 'lorem-ipsum-insert-sentences)))

(defun spacemacs-editing/init-move-text ()
  (use-package move-text
    :defer t
    :init
    (spacemacs|define-transient-state move-text
      :title "Move Text Transient State"
      :bindings
      ("J" move-text-down "move down")
      ("K" move-text-up "move up"))
    (spacemacs/set-leader-keys
      "xJ" 'spacemacs/move-text-transient-state/move-text-down
      "xK" 'spacemacs/move-text-transient-state/move-text-up)))

(defun spacemacs-editing/init-origami ()
  (use-package origami
    :defer t
    :init
    (global-origami-mode)
    (define-key evil-normal-state-map "za" 'origami-forward-toggle-node)
    (define-key evil-normal-state-map "zc" 'origami-close-node)
    (define-key evil-normal-state-map "zC" 'origami-close-node-recursively)
    (define-key evil-normal-state-map "zO" 'origami-open-node-recursively)
    (define-key evil-normal-state-map "zo" 'origami-open-node)
    (define-key evil-normal-state-map "zr" 'origami-open-all-nodes)
    (define-key evil-normal-state-map "zm" 'origami-close-all-nodes)
    (define-key evil-normal-state-map "zs" 'origami-show-only-node)
    (define-key evil-normal-state-map "zn" 'origami-next-fold)
    (define-key evil-normal-state-map "zp" 'origami-previous-fold)
    (define-key evil-normal-state-map "zR" 'origami-reset)
    (define-key evil-normal-state-map (kbd "z <tab>") 'origami-recursively-toggle-node)
    (define-key evil-normal-state-map (kbd "z TAB") 'origami-recursively-toggle-node)

    (spacemacs|define-transient-state fold
      :title "Code Fold Transient State"
      :doc "
 Close^^            Open^^             Toggle^^         Goto^^         Other^^
 ───────^^───────── ─────^^─────────── ─────^^───────── ──────^^────── ─────^^─────────
 [_c_] at point     [_o_] at point     [_a_] at point   [_n_] next     [_s_] single out
 [_C_] recursively  [_O_] recursively  [_A_] all        [_p_] previous [_R_] reset
 [_m_] all          [_r_] all          [_TAB_] like org ^^             [_q_] quit"
      :foreign-keys run
      :on-enter (unless (bound-and-true-p origami-mode) (origami-mode 1))
      :bindings
      ("a" origami-forward-toggle-node)
      ("A" origami-toggle-all-nodes)
      ("c" origami-close-node)
      ("C" origami-close-node-recursively)
      ("o" origami-open-node)
      ("O" origami-open-node-recursively)
      ("r" origami-open-all-nodes)
      ("m" origami-close-all-nodes)
      ("n" origami-next-fold)
      ("p" origami-previous-fold)
      ("s" origami-show-only-node)
      ("R" origami-reset)
      ("TAB" origami-recursively-toggle-node)
      ("<tab>" origami-recursively-toggle-node)
      ("q" nil :exit t)
      ("C-g" nil :exit t)
      ("<SPC>" nil :exit t))))
    ;; Note: The key binding for the fold transient state is defined in
    ;; evil config


(defun spacemacs-editing/init-smartparens ()
  (use-package smartparens
    :defer t
    :commands (sp-split-sexp sp-newline sp-up-sexp)
    :init
    ;; settings
    (setq sp-show-pair-delay 0.2
          ;; fix paren highlighting in normal mode
          sp-show-pair-from-inside t
          sp-cancel-autoskip-on-backward-movement nil
          sp-highlight-pair-overlay nil
          sp-highlight-wrap-overlay nil
          sp-highlight-wrap-tag-overlay nil)
    (spacemacs/add-to-hooks (if dotspacemacs-smartparens-strict-mode
                                'smartparens-strict-mode
                              'smartparens-mode)
                            '(prog-mode-hook comint-mode-hook))
    ;; enable smartparens-mode in `eval-expression'
    (add-hook 'minibuffer-setup-hook 'spacemacs//conditionally-enable-smartparens-mode)
    ;; toggles
    (spacemacs|add-toggle smartparens
      :mode smartparens-mode
      :documentation "Enable smartparens."
      :evil-leader "tp")
    (spacemacs|add-toggle smartparens-globally
      :mode smartparens-mode
      :documentation "Enable smartparens globally."
      :evil-leader "t C-p")
    ;; key bindings
    (spacemacs/set-leader-keys
      "js" 'sp-split-sexp
      "jn" 'sp-newline)
    :config
    (require 'smartparens-config)
    (spacemacs|diminish smartparens-mode " ⓟ" " p")
    (spacemacs//adaptive-smartparent-pair-overlay-face)
    (add-hook 'spacemacs-post-theme-change-hook
              'spacemacs//adaptive-smartparent-pair-overlay-face)
    (show-smartparens-global-mode +1)
    ;; don't create a pair with single quote in minibuffer
    (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)
    (sp-pair "{" nil :post-handlers
             '(:add (spacemacs/smartparens-pair-newline-and-indent "RET")))
    (sp-pair "[" nil :post-handlers
             '(:add (spacemacs/smartparens-pair-newline-and-indent "RET")))
    (when dotspacemacs-smart-closing-parenthesis
      (define-key evil-insert-state-map ")"
        'spacemacs/smart-closing-parenthesis))))

(defun spacemacs-editing/init-spacemacs-whitespace-cleanup ()
  (use-package spacemacs-whitespace-cleanup
    :commands (spacemacs-whitespace-cleanup-mode
               global-spacemacs-whitespace-cleanup-mode)
    :init
    (spacemacs|add-toggle whitespace-cleanup
      :mode spacemacs-whitespace-cleanup-mode
      :documentation "Automatic whitespace clean up."
      :on-message (spacemacs-whitespace-cleanup/on-message)
      :evil-leader "tW")
    (spacemacs|add-toggle global-whitespace-cleanup
      :mode global-spacemacs-whitespace-cleanup-mode
      :status spacemacs-whitespace-cleanup-mode
      :on (let ((spacemacs-whitespace-cleanup-globally t))
            (spacemacs-whitespace-cleanup-mode))
      :off (let ((spacemacs-whitespace-cleanup-globally t))
             (spacemacs-whitespace-cleanup-mode -1))
      :on-message (spacemacs-whitespace-cleanup/on-message t)
      :documentation "Global automatic whitespace clean up."
      :evil-leader "t C-S-w")
    (with-eval-after-load 'ws-butler
      (when dotspacemacs-whitespace-cleanup
        (spacemacs/toggle-global-whitespace-cleanup-on)))
    :config
    (spacemacs|diminish spacemacs-whitespace-cleanup-mode " Ⓦ" " W")
    (spacemacs|diminish global-spacemacs-whitespace-cleanup-mode
                        " Ⓦ" " W")))


(defun spacemacs-editing/init-undo-tree ()
  (use-package undo-tree
    :defer t
    :init
    (setq undo-tree-visualizer-timestamps t
          undo-tree-visualizer-diff t
          ;; See `vim-style-enable-undo-region'.
          undo-tree-enable-undo-in-region t
          ;; 10X bump of the undo limits to avoid issues with premature
          ;; Emacs GC which truncages the undo history very aggresively
          undo-limit 800000
          undo-strong-limit 12000000
          undo-outer-limit 120000000
          undo-tree-history-directory-alist
          `(("." . ,(let ((dir (expand-file-name "undo-tree-history" spacemacs-cache-directory)))
                      (if (file-exists-p dir)
                          (unless (file-accessible-directory-p dir)
                            (warn "Cannot access directory `%s'.
 Perhaps you don't have required permissions, or it's not a directory.
 See variable `undo-tree-history-directory-alist'." dir))
                        (make-directory dir))
                      dir))))
    (global-undo-tree-mode)
    :config
    ;; restore diff window after quit.  TODO fix upstream
    (defun spacemacs/undo-tree-restore-default ()
      (setq undo-tree-visualizer-diff t))
    (advice-add 'undo-tree-visualizer-quit :after #'spacemacs/undo-tree-restore-default)
    (spacemacs|hide-lighter undo-tree-mode)
    (evilified-state-evilify-map undo-tree-visualizer-mode-map
      :mode undo-tree-visualizer-mode
      :bindings
      (kbd "j") 'undo-tree-visualize-redo
      (kbd "k") 'undo-tree-visualize-undo
      (kbd "h") 'undo-tree-visualize-switch-branch-left
      (kbd "l") 'undo-tree-visualize-switch-branch-right)))


(defun spacemacs-editing/init-uuidgen ()
  (use-package uuidgen
    :commands (uuidgen-1 uuidgen-4)
    :init
    (spacemacs/declare-prefix "iU" "uuid")
    (spacemacs/set-leader-keys
      "iU1" 'spacemacs/uuidgen-1
      "iU4" 'spacemacs/uuidgen-4
      "iUU" 'spacemacs/uuidgen-4)))

(defun spacemacs-editing/init-ws-butler ()
  ;; not deferred on purpose, init-spacemacs-whitespace-cleanup need
  ;; it to be loaded.
  (use-package ws-butler
    :config (spacemacs|hide-lighter ws-butler-mode)))
