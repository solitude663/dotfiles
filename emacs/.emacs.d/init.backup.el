(save-place-mode 1)
(global-auto-revert-mode 1)
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(setq-default tab-width 4)


(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(setq inhibit-startup-message t)  ;; Disable startup message
(setq ring-bell-function 'ignore) ;; Disable the alert bell
(setq undo-limit 20000000)        ;; Increase amount of undos
(setq undo-strong-limit 40000000) ;; Limit the max amount of undos
(setq create-lockfiles nil)       ;; Files starting and ending with # no longer gets created
(setq-default truncate-lines t)   ;; Truncate all lines. Don't fold
(setq savehist-mode t)            ;; Persists minibuffer history between sessions.

;; Trucncate lines in markdown documents
(add-hook 'markdown-mode-hook (lambda () (setq truncate-lines nil)))

;; No screwing with my middle mouse button
(global-unset-key [mouse-2])

;; Set backup directory and keep my project folders clean
(setq backup-directory-alist '(("." . "~/.emacs_saves")))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(electric-pair-mode 1)     ;; Auto create closing braces  
(show-paren-mode 1)        ;; Show matching parens
(display-time)             ;; Display time on mode line
(column-number-mode)       ;; Show column number
(blink-cursor-mode -1)     ;; Don't flash cursor

(setq show-paren-delay 0.0) ;; Highlight matching delimiters instantly

(load-theme 'tango-dark t)

(when (display-graphic-p)
  (global-hl-line-mode))      ;; Higlight the line I am on



(set-face-attribute 'default nil :height 135)  ;; Set the font size
;; (set-face-attribute 'default nil :family "Fira Code" :height 110)  ;; Set the font size
(setq-default line-spacing 0.10)               ;; Set the line spacing

;; Don't change text color when the line is highlighted. Do after
;; turning on global-hl-line-mode.
;; (set-face-attribute 'hl-line nil :inherit nil :background "#333333")

;; (set-face-attribute 'default nil :family "Fira Code" :height 110)  ;; Set the font size
(setq-default line-spacing 0.05)               ;; Set the line spacing

;; Don't change text color when the line is highlighted. Do after
;; turning on global-hl-line-mode.
;; (set-face-attribute 'hl-line nil :inherit nil :background "#333333")

(add-to-list 'default-frame-alist '(font . "Fira Code 14"))

;; (set-face-attribute 'default nil :height 125)  ;; Set the font size

(defvar anthony-makescript (cond ((eq system-type 'windows-nt) "build.bat")	  
								 ((eq system-type 'ms-dos) "build.bat")
								 ((eq system-type 'gnu/linux) "./build.sh")
								 ((eq system-type 'gnu) "./build.sh")
								 (t "./build.sh")) "The default script to call to compile")

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p anthony-makescript) t
	(cd "../")
	(find-project-directory-recursive)))


(defun make-without-asking ()
  "Make the current build."
  (interactive)
  (if (find-project-directory-recursive) (compile anthony-makescript))
  (other-window 1))

(setq compilation-context-lines 0)
(global-set-key (kbd "M-m") 'make-without-asking)

;; My preferred C-Style coding format
(c-add-style "anthony-cc-style"
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

(setq c-default-style  
      '((java-mode . "anthony-cc-style")
        (csharp-mode . "anthony-cc-style")
        (other . "anthony-cc-style")))



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

  (defun add-header-file-format()
    "Adds header guards for .h/hpp files"
    (interactive)
    (setq baseFileName (file-name-sans-extension (file-name-nondirector buffer-file-name)))
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


(defun new-line-below-and-move()
  (interactive)
  (move-end-of-line 1)
  (open-line 1)
  (next-line))

(defun new-line-above-and-move()
  (interactive)
  (move-beginning-of-line 1)
  (open-line 1))


(defun open-file-other-window()
  (interactive)
  (setq old-buffer-name (buffer-name))
  (counsel-find-file)
  (setq new-buffer-name (buffer-name))
  (switch-to-buffer old-buffer-name)
  (other-window 1)
  (switch-to-buffer new-buffer-name))

;; Buffer Navigation
(global-set-key (kbd "<home>") 'beginning-of-buffer)
(global-set-key (kbd "<end>") 'end-of-buffer)

;; Zooming
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)

;; Opening buffers
(global-set-key (kbd "M->") 'open-file-other-window)

;; Execting custom commands
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

;; Errors
(global-set-key (kbd "C-\\") 'next-error)

;; Creating new lines
(global-set-key (kbd "C-o") 'new-line-below-and-move)
(global-set-key (kbd "C-S-o") 'new-line-above-and-move)

;; Saving
(global-set-key (kbd "M-s") 'save-buffer) 

;; Search and Replace
(global-set-key (kbd "M-/") 'query-replace)

(global-set-key (kbd "M-.") 'find-file)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

