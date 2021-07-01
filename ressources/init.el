;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; IDENTITÉ ET VARIABLES À PERSONNALISER ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq user-full-name "Mon nom")                        ; PERSONNALISER ICI
(setq user-mail-address "mon.adresse@u-bordeaux.fr")   ; PERSONNALISER ICI
(setq my-todo-file "/path/to/todo.org")                ; PERSONNALISER ICI

;;;;;;;;;;;;;;;;
;;; PACKAGES ;;;
;;;;;;;;;;;;;;;;
;; Choix et priorité des dépôts :
(package-initialize)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
	     '("org" . "https://orgmode.org/elpa/") t)
(setq package-archive-priorities '(("gnu" . 5)
                                   ("melpa" . 10)
                                   ("org" . 11)))

;; Utilisation de use-package :
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

;;;;;;;;;;;;;;;;;
;;; APPARENCE ;;;
;;;;;;;;;;;;;;;;;
;; Affichage du nombre de lignes et de colonnes dans la "modeline":
(line-number-mode t)
(column-number-mode t)

;; Affichage des numéros de ligne dans la marge de gauche :
(global-display-line-numbers-mode)

;; Thème solarized :
(use-package solarized-theme
  :ensure t
  :config
  (setq solarized-distinct-fringe-background t)
  (setq solarized-use-variable-pitch nil)
  (setq solarized-scale-org-headlines nil)
  (load-theme 'solarized-light t)
  ;; Polices Org mode :
  (custom-set-faces
   '(org-level-1 ((t (:inherit default :foreground "#cb4b16" :overline t :weight semi-bold :height 1.15))))
   '(org-level-2 ((t (:inherit default :foreground "#859900" :weight semi-bold :height 1.1))))
   '(org-level-3 ((t (:inherit default :height 1.05))))))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
  (setq doom-modeline-minor-modes t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-enable-word-count t))

;;; Neotree (arbre de navigation) :
(use-package all-the-icons
  :ensure t)
(use-package neotree
  :ensure t
  :config
  (global-set-key [f8] 'neotree-toggle)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

;;; Police par défaut :
(set-face-attribute 'default nil
                    :family "Source Code Pro"
                    :foundry "ADBO"
                    :slant 'normal
                    :height 128
                    :weight 'normal
                    :width 'normal)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; COMPLETION FRAMEWORKS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package helm
  :ensure t)

(use-package prescient
  :ensure t
  :config
  (prescient-persist-mode +1))

(use-package selectrum-prescient
  :ensure t)

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("C-M-a" . marginalia-cycle))
  :init
  (marginalia-mode)
  (advice-add #'marginalia-cycle :after
              (lambda () (when (bound-and-true-p selectrum-mode) (selectrum-exhibit))))
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil)))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(basic partial-completion orderless))
  ;; (completion-category-defaults nil)
  (setq orderless-matching-styles '(orderless-regexp orderless-flex)))

(use-package selectrum
  :ensure t
  :init
  (selectrum-mode +1)
  (selectrum-prescient-mode +1)
  (defun selectrum-fs-candidate-preprocess-function (candidates)
    "Perso value of `selectrum-preprocess-candidates-function'.
Sort alphabetically the CANDIDATES (which is a list of strings)."
    (if selectrum-should-sort
        (sort candidates
              #'string-lessp)
      candidates))
  :config
  (setq selectrum-preprocess-candidates-function #'selectrum-fs-candidate-preprocess-function)
  (setq selectrum-refine-candidates-function #'orderless-filter)
  (setq selectrum-highlight-candidates-function #'orderless-highlight-matches))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PARAMETRES d'EDITION GENERAUX ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utilisation de l'encodage UTF-8 :
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Activer le mode de suppression de la région active :
(delete-selection-mode 1)

;; Réglages pour les parenthèses correspondantes :
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Mettre en surbrillance la ligne active :
(global-hl-line-mode 1)

;; Line wrapping :
(setq-default word-wrap t)
(toggle-truncate-lines -1)
(setq longlines-wrap-follows-window-size t)

;; Backups automatiques :
(setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
          `((".*" , temporary-file-directory t)))

;; Ajout de dictionnaires :
(let ((langs '("american" "british" "francais")))
  (setq lang-ring (make-ring (length langs)))
  (dolist (elem langs) (ring-insert lang-ring elem)))
(defun cycle-ispell-languages ()
  (interactive)
  (let ((lang (ring-ref lang-ring -1)))
    (ring-insert lang-ring lang)
    (ispell-change-dictionary lang)))
(global-set-key [f6] 'cycle-ispell-languages)

;; Vérification orthographique en mode texte :
(add-hook 'text-mode-hook 'flyspell-mode)

;;;;;;;;;;;;;;;;;;;;;;;
;;; ÉDITION DE CODE ;;;
;;;;;;;;;;;;;;;;;;;;;;;
;; Autocomplétion avec company :
(use-package company
  :ensure t
  :config
  ;; Activer company globalement, sauf org-mode :
  (add-hook 'after-init-hook 'global-company-mode)
  ;; Redéfinir certains raccourcis en accord avec le Wiki de company :
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "M-,") 'company-select-next)
  (define-key company-active-map (kbd "M-k") 'company-select-previous)
  (define-key company-active-map [return] nil)
  (define-key company-active-map [tab] 'company-complete-common)
  (define-key company-active-map (kbd "TAB") 'company-complete-common)
  (define-key company-active-map (kbd "M-TAB") 'company-complete-selection)
  (setq company-selection-wrap-around t
	company-tooltip-align-annotations t
	company-idle-delay 0.45
	company-minimum-prefix-length 2
	company-tooltip-limit 10))

;;;;;;;;;;;;;;;;
;;; ORG MODE ;;;
;;;;;;;;;;;;;;;;
(use-package org
  :ensure t
  :init
  (defun turn-on-visual-line-mode () (visual-line-mode 1)) ;; fonction Lisp utile ci-dessous
  (defun turn-on-key-chord-mode () (key-chord-mode 1))
  :config
  (require 'org-tempo)
  (require 'ox-latex)   ; export LaTeX
  (require 'ox-bibtex)  ; nécessaire pour de jolies références en HTML
  ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; 1. Configuration générale de Org-mode :
  ;; Apparence générale d'un document Org :
  (setq org-hide-leading-stars nil) ;; ne pas cacher les "*" supplémentaires des sous-sections
  (setq org-alphabetical-lists t)
  (setq org-src-fontify-natively t) ;; activer la coloration syntaxique au sein des blocs
  (setq org-src-tab-acts-natively t) ;; activer la complétion au sein des blocs
  (setq org-pretty-entities t) ;; permet d'avoir des caractères spéciaux (\alpha, ...)
  (setq org-adapt-indentation 'headline-data) ;; depuis Org 9.4
  (add-hook 'org-mode-hook (lambda () (electric-indent-local-mode -1))) ;; depuis Org 9.4
  (setq org-fontify-done-headline nil) ;; depuis Org 9.4
  (add-hook 'org-mode-hook 'turn-on-visual-line-mode) ;; activer le mode visual-line en org-mode
  (add-hook 'org-mode-hook 'turn-on-key-chord-mode)
  ;; Autoriser des paragraphes entiers en italique :
  (setf (nth 4 org-emphasis-regexp-components) 10)
  ;; Gestion des TODO listes :
  (setq org-todo-keywords ;; nouveaux statuts
      '((sequence "TODO(t)" "IN-PROGRESS(p)" "SOMEDAY(s)" "WAITING(w@)" "REVIEW(r)" "|" "DONE(d)" "CANCELED(c@)")))
  (setq org-todo-keyword-faces ;; couleurs associées
	'(("TODO" . "red3")
          ("IN-PROGRESS" . "DarkOrange2")
          ("SOMEDAY" . "blue")
          ("WAITING" . "gold2")
          ("REVIEW"  . "purple")
	  ("CANCELED" . "thistle4")
          ("DONE" . "forest green")))
  (setq org-enforce-todo-dependencies t) ;; tâches mères et filles
  ;; Drawers et logging :
  (setq org-log-into-drawer t) ;; ajouter les notes dans un drawer "LOGBOOK". Voir la vidéo de Rainer : https://www.youtube.com/watch?v=nUvdddKZQzs&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE&index=9
  (setq org-log-done 'time) ;; ajout d'un timestamp à la fermeture d'une tâche. Voir la vidéo de Rainer : https://www.youtube.com/watch?v=R4QSTDco_w8&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE&index=11
  (setq org-log-reschedule 'note) ;; ajout d'une note lorsqu'on replanifie une tâche
  (setq org-clock-into-drawer "CLOCKING") ;; clocking info placée dans un drawer nommé "CLOCKING"
  ;; Activation du tracking des habitudes :
  (add-to-list 'org-modules 'org-habit t)
  (setq org-habit-following-days 0)
  (setq org-habit-preceding-days 30)
  (setq org-habit-today-glyph ?.)
  (setq org-habit-completed-glyph ?✓)
  ;; Activation du tag :ignore :
  (require 'ox-extra)
  (ox-extras-activate '(ignore-headlines))
  ;; Réglages pour l'export LaTeX :
  (setq org-export-with-smart-quotes t) ;; de jolis guillemets français par défaut (avec babel !)
  (setq org-latex-caption-above nil) ;; les légendes sont à positionner au-dessous des flottants
  (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdf %f"))
  (require 'ox-beamer) ;; activer le support de beamer
  (defun my-beamer-bold (contents backend info)
    (when (eq backend 'beamer)
      (replace-regexp-in-string "\\`\\\\[A-Za-z0-9]+" "\\\\textbf" contents)))
  (add-to-list 'org-export-filter-bold-functions 'my-beamer-bold)
  ;; Ajout de classes LaTeX spécifiques aux éditeurs scientifiques :
  (add-to-list 'org-latex-classes
	       '("elsarticle"
		 "\\documentclass{elsarticle}"
		 ("\\section{%s}" . "\\section*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))
  ;; Réglages pour org-capture :
  (global-set-key (kbd "C-c c") 'org-capture) ;; keybinding suggéré par le manuel
  (setq org-archive-subtree-save-file-p t)
  (setq org-capture-templates
   (quote
    (("r" "Rendez-vous"
      entry
      (file+headline my-todo-file "Rendez-vous")
      "* TODO %^{Nouveau RDV}\n SCHEDULED: %^t\n %?")
     ("t" "Tâche scientifique")
     ("ta" "Projet d'article"
      entry
      (file+headline my-todo-file "Articles")
      "* TODO %^{Article} %^g\n %?")
     ("td" "Développement logiciel"
      entry
      (file+headline my-todo-file "Développement logiciel")
      "* SOMEDAY %^{Projet de dév} %^g\n %?")
     ("u" "Formation Urfist"
      entry
      (file+headline my-todo-file "Formations à suivre")
      "* TODO %^{Formation} %^g\n SCHEDULED: %^t\n %?"))))
  ;; Afficher les images :
  (add-hook 'org-mode-hook 'org-display-inline-images)
  ;; Afficher les PDF directement dans Emacs (corrige un possible bug avec C-c C-e l o):
  (push '("\\.pdf\\'" . emacs) org-file-apps))

(use-package org-agenda
  :ensure nil
  :config
  ;; Réglages généraux :
  (global-set-key (kbd "C-c a") 'org-agenda) ;; raccourci clavier pour M-x org-agenda
  (setq org-agenda-files '(my-todo-file)) ;; fichier où chercher les tâches
  (setq org-archive-reversed-order t)
  ;; Custom agenda view :
  (setq org-agenda-custom-commands
      '(("d" "Custom daily agenda"
         ((agenda ""
                  ((org-agenda-span 'day))
                  (org-agenda-overriding-header "Agenda du jour"))
          (tags "PRIORITY=\"A\""
                ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                 (org-agenda-overriding-header "Tâches importantes à finaliser")))
          (todo "WAITING"
                ((org-agenda-overriding-header "Tâches en attente"))))))))

;; Utilisation de org-ref :
(use-package org-ref
  :ensure t
  :after org)

;; Mêmes info pour helm-bibtex, permettant la prise de notes depuis org-ref :
(use-package helm-bibtex
  :ensure t
  :config
  (setq bibtex-completion-pdf-field "file"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EXTENSIONS ORG DIVERSES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ox-pandoc
  :ensure t
  :defer 15)

(use-package ox-gfm
  :ensure t
  :defer 15)

(use-package org-starter
  :ensure t
  :defer t)

(use-package org-alert
  :ensure t
  :config
  (setq alert-default-style 'libnotify)
  (setq org-alert-interval 300))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; OUTILS D'ECRITURE SCIENTIFIQUE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Réglages pour LaTeX :
(use-package tex
  :ensure auctex
  :init
  (defun tex-pdf-on () (TeX-PDF-mode 1)) ;; fonction utilisée plus bas
  :config
  ;; Réglages conseillés par le manuel de AucTeX :
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  ;; Activer par défaut le PDF avec LaTeX :
  (add-hook 'tex-mode-hook 'tex-pdf-on)
  (add-hook 'latex-mode-hook 'tex-pdf-on)
  (setq TeX-PDF-mode t)
  ;; Activer le mode auto-fill pour LaTeX :
  (add-hook 'tex-mode-hook 'turn-on-auto-fill)
  (add-hook 'LaTeX-mode-hook 'turn-on-auto-fill)
  ;; Activer le support de reftex :
  (require 'reftex)
  (add-hook 'LaTeX-mode-hook 'reftex-mode)
  (setq reftex-plug-into-AUCTeX t)
  ;; Vérification orthographique en mode TeX :
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  ;; Activer le mode math par défaut :
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  ;; Toujours exporter avec shell-escape :
  (setq LaTeX-command-style '(("" "%(PDF)%(latex) %(file-line-error) %(extraopts) -shell-escape %S%(PDFout)")))
  ;; Activer la coloration des macros natbib :
  (add-hook
   'LaTeX-mode-hook
   (lambda ()
     (font-latex-add-keywords '(("citep" "*[[{")) 'reference)
     (font-latex-add-keywords '(("citet" "*[[{")) 'reference)
     (font-latex-add-keywords '(("citeyear" "*[[{")) 'reference)
     (font-latex-add-keywords '(("citeauthor" "*[[{")) 'reference)
     (font-latex-add-keywords '(("citealp" "*[[{")) 'reference))))

;; Une meilleure visionneuse pdf :
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-width)
  (setq pdf-annot-activate-created-annotations t)
  (add-hook 'pdf-tools-enabled-hook 'auto-revert-mode) ; rafraichissement auto des PDF
  (setq revert-without-query "*.pdf"))

;; Un mode Markdown :
(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.Rmd\\'" . markdown-mode))
  :config
  (setq markdown-enable-math t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FONCTIONS ADDITIONNELLES ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Refonte de la commande kill-buffer :
(defun kill-buffer-and-its-windows (buffer)
  "Kill BUFFER and delete its windows.  Default is `current-buffer'.
BUFFER may be either a buffer or its name (a string)."
  (interactive (list (read-buffer "Kill buffer: " (current-buffer) 'existing)))
  (setq buffer  (get-buffer buffer))
  (if (buffer-live-p buffer)            ; Kill live buffer only.
      (let ((wins  (get-buffer-window-list buffer nil t))) ; On all frames.
        (when (and (buffer-modified-p buffer)
                   (fboundp '1on1-flash-ding-minibuffer-frame))
          (1on1-flash-ding-minibuffer-frame t)) ; Defined in `oneonone.el'.
        (when (kill-buffer buffer)      ; Only delete windows if buffer killed.
          (dolist (win  wins)           ; (User might keep buffer if modified.)
            (when (window-live-p win)
              ;; Ignore error, in particular,
              ;; "Attempt to delete the sole visible or iconified frame".
              (condition-case nil (delete-window win) (error nil))))))
    (when (interactive-p)
      (error "Cannot kill buffer.  Not a live buffer: `%s'" buffer))))
(substitute-key-definition 'kill-buffer 'kill-buffer-and-its-windows global-map)

;; Fermer automatiquement les tâches Org :
(defun org-summary-todo (n-done n-not-done)
  "Switch entry to DONE when all subentries are done, to TODO otherwise."
  (let (org-log-done org-log-states)   ; turn off logging
    (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
(add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

(defun fs/org-checkbox-auto-close ()
  "Automatically close a TODO entry if all its children boxes are checked.
If one of the checkboxes is unchecked when the whole task is DONE, then
turn its state into TODO once again.
This requires a statistic cookie such as [%] or [/] to be set."
  (save-excursion
    (org-back-to-heading)
    (let ((beg (point))
          (end (progn
                 (end-of-line)
                 (point))))
      ;; Go back to beginning of heading:
      (goto-char beg)
      ;; Search for statistics cookie "[%]":
      (if (re-search-forward "\\[\\([0-9]*%\\)\\]" end t)
        ;; Close the task if cookie indicates 100%:
        (if (string-equal (match-string 1) "100%")
            (org-todo 'done)
          ;; Re-open the task if cookie is < 100%
          ;; (do not change todo status if already open,
          ;; e.g. with a WAITING status)
          (unless (org-entry-is-todo-p)
            (org-todo 'todo)))
        ;; Otherwise, search for statistics cookie "[/]":
        (progn
          (when (re-search-forward "\\[\\([0-9]*\\)/\\([0-9]*\\)\\]" end t)
            ;; Close the task if cookie shows only closed children tasks:
            (if (string-equal (match-string 1) (match-string 2))
                (org-todo 'done)
              ;; Re-open the task if cookie is < 100%
              ;; (do not change todo status if already open,
              ;; e.g. with a WAITING status)
              (unless (org-entry-is-todo-p)
                (org-todo 'todo)))))))))
(add-hook 'org-checkbox-statistics-hook 'fs/org-checkbox-auto-close)

;; Afficher le PDF à droite d'une fenêtre Org :
(defun fs/display-pdf ()
  "Display the PDF file associated to a given org BUFFER.
The PDF is displayed in a new (side, right) window."
  (interactive)
  (let (curbuf (current-buffer))
    (find-file (concat "./"
                       (replace-regexp-in-string "\\(\\.tex\\|\\.org\\)"
                                                 ".pdf"
                                                 (buffer-name curbuf))))
    (split-window-right)
    (switch-to-buffer curbuf)))

(global-set-key (kbd "<f7>") 'fs/display-pdf)
