(require 'package)
;; elpa.gnu and elpa.nongnu added by default
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(defvar font-name "Fira Code Nerd Font" "My font choice")
(defvar font-size 13.5 "My font size")
(defvar line-height 0.25 "Space between line")

(defvar aj/makescript (cond ((eq system-type 'windows-nt) "build.bat")	  
			    ((eq system-type 'ms-dos) "build.bat")                                 
			    (t "./build.sh")) "The default script to call to compile")

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(blink-cursor-mode 0)
(save-place-mode t)
(column-number-mode t)
(electric-pair-mode t)

(global-auto-revert-mode 1)

(setq inhibit-startup-message 1)
(setq ring-bell-function nil)
(setq visible-bell nil)
(setq show-paren-delay 0.0)

(setq create-lockfiles nil)
(setq backup-directory-alist '(("." . "~/.emacs_saves")))

(use-package mood-line
  :ensure t)
(mood-line-mode t)

(use-package gruvbox-theme 
  :ensure t)
(load-theme 'gruvbox-dark-medium t)

(global-hl-line-mode)
(set-face-attribute 'hl-line nil :inherit nil :background "#333333")
(set-face-attribute 'default nil :font font-name :height (floor (* font-size 10)))
(setq-default line-spacing line-height)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(c-add-style "aj-cc-style"
             '((c-basic-offset . 4)
               (tab-width . 4)				 
               (c-offsets-alist (case-label . +)
                                (substatement-open . 0)
                                (inline-open . 0)
                                (statement-cont . +)
                                (statement-case-open . 0)
                                (statement-cont . +)
                                (brace-list-close  0)
                                )))

(setq c-default-style   '((java-mode . "aj-cc-style")
			  (csharp-mode . "aj-cc-style")
			  (other . "aj-cc-style")))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-mode))

(defun get-base-file-name()
  "Gets a file name without extension or path"
  (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))


(defun anthony-c-hook()
  (defun c/find-corresponding-file ()
    "Find the file that corresponds to this one."
    (interactive)
    (setq CorrespondingFileName nil)
    (setq BaseFileName (file-name-sans-extension buffer-file-name))
    (if (string-match "\\.c" buffer-file-name)
        (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if (string-match "\\.h" buffer-file-name)
        (if (file-exists-p (concat BaseFileName ".c")) (setq CorrespondingFileName (concat BaseFileName ".c"))
          (setq CorrespondingFileName (concat BaseFileName ".cpp"))))
    (if (string-match "\\.hin" buffer-file-name)
        (setq CorrespondingFileName (concat BaseFileName ".cin")))
    (if (string-match "\\.cin" buffer-file-name)
        (setq CorrespondingFileName (concat BaseFileName ".hin")))
    (if (string-match "\\.cpp" buffer-file-name)
        (setq CorrespondingFileName (concat BaseFileName ".h")))
    (if CorrespondingFileName (find-file CorrespondingFileName)
      (error "Unable to find a corresponding file")))

  (defun c/find-corresponding-file-other-window()
    "In C/CPP  Find the file that corresponds to this one."
    (interactive)
    (find-file-other-window buffer-file-name)
    (c/find-corresponding-file)
    (other-window -1))

  (define-key c++-mode-map [f3] 'c/find-corresponding-file)
  (define-key c++-mode-map [f4] 'c/find-corresponding-file-other-window)

  (defun get-char(str i)
    "Gets a character from a string"
    (char-to-string (aref str i)))

  (defun is-uppercase (char)
    "Check if the given character is uppercase."
    (let ((ascii-value (string-to-char char)))
      (and (>= ascii-value 65)
           (<= ascii-value 90))))

  (defun make-macrofied-name(filename)
    (setq pos 1
          result (get-char filename 0))

    (while (< pos (length filename))
      (when (is-uppercase (get-char filename pos))
        (setq result (concat result "_")))
      (setq result (concat result (get-char filename pos)))
      (setq pos (1+ pos)))
    result)

  (defun add-header-file-format()
    "Adds header guards for .h/hpp files"
    (interactive)
    (setq baseFileName (file-name-sans-extension (file-name-nondirectory buffer-file-name)))
    (setq baseFileName (make-macrofied-name baseFileName))
    (insert "#ifndef ")
    (push-mark)
    (insert baseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H\n")  
    (insert "#define ")
    (push-mark)
    (insert baseFileName)
    (upcase-region (mark) (point))
    (pop-mark)
    (insert "_H\n\n\n")
    (insert "#endif // Header guard"))

  (cond ((file-exists-p buffer-file-name) t)
        ((string-match "[.]h" buffer-file-name) (add-header-file-format))
        ((string-match "[.]hpp" buffer-file-name) (add-header-file-format))))

(add-hook 'c-mode-common-hook 'anthony-c-hook)

;; ORG Mode Settings
(defun aj/org-settings()
  (message "ORG Mode")
  (word-wrap-whitespace-mode 1)
  (toggle-truncate-lines -1))

(add-hook 'org-mode-hook 'aj/org-settings)


;; (use-package corfu
;;   :init
;;   (global-corfu-mode))
;;


(defun woman-other-window ()
  "Invoke `woman` and display the result in another window."
  (interactive)
  (switch-to-buffer-other-window "*WoMan*")
  (call-interactively 'woman))

(global-set-key (kbd "C-c w") 'woman-other-window)

(use-package company
  :ensure t
  :init
  (global-company-mode)
  :config
  ;; Disable automatic popups
  (setq company-idle-delay nil
	company-minimum-prefix-length 1)  ;; Show number for each completion

  ;; Use 'company-dabbrev' to restrict completions to buffer contents  
  (setq company-backends '(company-dabbrev-code company-files))
  
  ;; Optional: Limit completion only within the current buffer (no external files)
  (setq company-dabbrev-other-buffers nil)

  ;; Use M-RET (Alt+Enter) to trigger completion
  :bind
  (:map global-map
        ("M-RET" . company-complete)))

;; ;; Make sure company is installed
;; (use-package company
;;   :ensure t
;;   :init
;;   (global-company-mode)     ;; Enable company everywhere
;;   :config
;;   ;; How quickly completions pop up
;;   (setq company-idle-delay 0.2
;;         company-minimum-prefix-length 1
;;         company-tooltip-align-annotations t
;;         company-show-numbers t))

;; (use-package auto-complete
;;   :ensure t)

;; (ac-config-default)
;; (setq ac-ignore-case 'smart)
;; (setq ac-auto-start nil)
;; (global-set-key (kbd "M-<return>") 'auto-complete)

;; (defun ac-enable-auto-popup()
;;   (interactive)
;;   (setq ac-auto-start t))

;; (defun ac-disable-auto-popup()
;;   (interactive)
;;   (setq ac-auto-start nil))


;; IDO Mode
;; (setq ido-enable-flex-matching t)
;; (setq ido-everywhere t)
;; (ido-mode 1)

;; (use-package ido-completing-read+
;;   :ensure t)
;; (ido-ubiquitous-mode 1)

;; (use-package helm
;;   :ensure t)
;; (helm-mode 1)

;; (use-package ido-vertical-mode
;;   :ensure t)
;; (ido-vertical-mode 1)

;; (use-package smex
;;   :ensure t)
;; (global-set-key (kbd "M-x") 'smex)
;; (global-set-key (kbd "M-x") '-M-x)
;; (global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(use-package multiple-cursors
  :ensure t)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-?") 'mc/mark-all-like-this)

(use-package move-text
  :ensure t)

(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(use-package hl-todo
  :ensure t
  :hook
  ((prog-mode rust-mode) . hl-todo-mode))

(setq hl-todo-keyword-faces '(("TODO" . "Red")
			      ("REMOVE" . "magenta1")
			      ("IMPORTANT" . "Yellow")
			      ("NOTE" . "Dark Green")))

(use-package magit
  :ensure t)

(require 'dired-x)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)
(setq-default dired-dwim-target t)

(defun find-project-directory-recursive ()
      "Recursively search for a makefile."
      (interactive)
      (if (file-exists-p aj/makescript) t
	(cd "../")
	(find-project-directory-recursive)))

(defun make-without-asking ()
      "Make the current build."
      (interactive)
      (if (find-project-directory-recursive) (compile aj/makescript))
      (other-window 1))

(use-package devdocs
  :ensure t)
(global-set-key (kbd "C-S-d") 'devdocs-lookup)

(add-hook 'c-mode-hook
	  (lambda () (setq-local devdocs-current-docs '("c"))))

(add-hook 'c++-mode-hook
	  (lambda () (setq-local devdocs-current-docs '("cpp" "c"))))

(add-hook 'go-mode-hook
	  (lambda () (setq-local devdocs-current-docs '("go"))))

(add-hook 'js-mode-hook
	  (lambda () (setq-local devdocs-current-docs '("javascript"))))

(add-hook 'web-mode-hook
	  (lambda () (setq-local devdocs-current-docs '("html" "css" "javascript"))))

(use-package helpful
  :ensure t
  :bind(("C-h f" . #'helpful-callable)
        ("C-h v" . #'helpful-variable)
        ("C-h k" . #'helpful-key)
        ("C-h x" . #'helpful-command)))

(use-package go-mode
  :ensure t
  :mode "\\.go\\'")

(use-package web-mode
  :ensure t
  :mode "\\.html?\\'"
  :hook(css-mode)
  :custom
  (web-mode-css-indent-offset 4)
  (web-mode-code-indent-offset 4)
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-css-colorization t)
  (web-mode-ac-sources-alist
   '(("css" . (ac-source-css-property))
     ("html" . (ac-source-words-in-buffer ac-source-abbrev))))
  :config
  (setq ac-auto-start 2))

(use-package emmet-mode
  :ensure t
  :hook(web-mode))

(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'")

(use-package dumb-jump
  :ensure t
  :hook((prog-mode) . dumb-jump-mode))

(use-package nasm-mode
  :ensure t
  :mode "\\.nasm\\'")

(remove-hook 'xref-backend-functions #'etags--xref-backend)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
(setq xref-show-definitions-function #'xref-show-definitions-completing-read)

(global-set-key (kbd "C-,") 'xref-go-back)
(global-set-key (kbd "C-.") 'xref-find-definitions-other-window)
 

(defun aj/new-line-below-and-move()
  (interactive)
  (move-end-of-line 1)
  (open-line 1)
  (next-line))

(defun aj/new-line-above-and-move()
  (interactive)
  (move-beginning-of-line 1)
  (open-line 1))

(defun aj/find-init-file()
      "Finds and opens the emacs init file on your system"
      (interactive)
      (find-file user-init-file))

;; Compiling
(global-set-key (kbd "M-m") 'make-without-asking)
(global-set-key (kbd "C-\\") 'next-error)

;; Buffer Navigation
(global-set-key (kbd "<home>") 'beginning-of-buffer)
(global-set-key (kbd "<end>") 'end-of-buffer)

;; Zooming
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Opening buffers
(global-set-key (kbd "M-.") 'find-file)
(global-set-key (kbd "M->") 'find-file-other-window)
(global-set-key (kbd "C-x x b") 'switch-to-buffer-other-window)

;; Execting custom commands
(global-set-key [f11] 'search-man-for-function)
(global-set-key [f10] 'shell-command)

;; Switching buffers
(global-set-key (kbd "M-<up>")    'windmove-up)
(global-set-key (kbd "M-<down>")  'windmove-down) 
(global-set-key (kbd "M-<left>")  'windmove-left) 
(global-set-key (kbd "M-<right>") 'windmove-right)

;; Keyboard Macro
(global-set-key (kbd "C-{") 'start-kbd-macro)
(global-set-key (kbd "C-}") 'end-kbd-macro)
(global-set-key (kbd "C-'") 'call-last-kbd-macro)

;; Duplicate line
(global-set-key (kbd "C-]") 'duplicate-line)

;; Saving
(global-set-key (kbd "M-s") 'save-buffer) 

;; Search and Replace
(global-set-key (kbd "M-/") 'query-replace)

;; Creating new lines
(global-set-key (kbd "C-o") 'aj/new-line-below-and-move)
(global-set-key (kbd "C-S-o") 'aj/new-line-above-and-move)
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled nil)
