;; must be called after loading viper; doesn't work in .viper; try .emacs
;;
;; copyright 2009 bayle shanks, released under the GPL 3 or later

(load "viperre-lib")


(defun viper-remap-colemak ()

  (setq viper-insert-after-replace nil)
  (setq viper-ESC-moves-cursor-back nil)
  (setq viper-same-line-put-cursor-last-char nil)
  (viper-set-searchstyle-toggling-macros 1) ;; unset '//' and '///' macros

  (define-key viper-vi-global-user-map (kbd "<backspace>") 'vimpulse-visual-mode)
  (define-key viper-vi-global-user-map (kbd "<delete>") 'delete-char)
  (define-key viper-vi-global-user-map (kbd "<return>") 'newline)

  ;;for some reason this gets overridden; put it in .emacs too
  (define-key viper-vi-global-user-map (kbd "<SPC>") 'viper-insert)



  (define-key viper-vi-global-user-map (kbd "`") 'viper-paren-match)


  (define-key viper-vi-global-user-map (kbd "q") 'viper-Open-line)
  (define-key viper-vi-global-user-map (kbd "wg") 'vimpulse-goto-first-line)
  (define-key viper-vi-global-user-map (kbd "wz") 'find-file-at-point)
  (define-key viper-vi-global-user-map "ww" 'ido-switch-buffer)
  (define-key viper-vi-global-user-map "wj" 'jl-jump-backward)
  (define-key viper-vi-global-user-map "wh" 'jl-jump-forward)
  ;;(define-key viper-vi-global-user-map "wq" 'quit-buffer)
  (define-key viper-vi-global-user-map "ws" 'save-buffer)
  (define-key viper-vi-global-user-map "wa" 'viper-ex)
  (define-key viper-vi-global-user-map "wf" 'find-file)
  (define-key viper-vi-global-user-map "wb" 'bookmark-jump)
  (define-key viper-vi-global-user-map "wB" 'bookmark-set)
  (define-key viper-vi-global-user-map "w1" 'delete-other-windows) 
  (define-key viper-vi-global-user-map "wo" 'other-window) 
  (define-key viper-vi-global-user-map "wg" 'pop-global-mark)

  (define-key viper-vi-global-user-map "wu" 'viperre-quick-dvc-pull-update)
  (define-key viper-vi-global-user-map "wc" 'viperre-quick-dvc-commit)
  (define-key viper-vi-global-user-map "wv" 'dvc-log-edit)
  (define-key viper-vi-global-user-map "wl" 'dvc-status)


  (define-key viper-vi-global-user-map (kbd "f") 'viper-backward-paragraph)
;;  (define-key viper-vi-global-user-map (kbd "p") 'viper-scroll-down)
;;  (define-key viper-vi-global-user-map (kbd "p") 'viper-search-backward-or-next)
  (define-key viper-vi-global-user-map (kbd "p") 'viper-isearch-backward-or-next)

;;(define-key viper-vi-global-user-map (kbd "p") 'isearch-backward)
  (define-key viper-vi-global-user-map (kbd "g") 'backward-kill-word)
  (define-key viper-vi-global-user-map (kbd "j") 'kill-word)
;;  (define-key viper-vi-global-user-map (kbd "l") 'viper-search-forward-or-next)
  (define-key viper-vi-global-user-map (kbd "l") 'viper-isearch-forward-or-next)

;; (define-key viper-vi-global-user-map (kbd "l") 'isearch-forward)
;;  (define-key viper-vi-global-user-map (kbd "l") 'viper-scroll-up)
  (define-key viper-vi-global-user-map (kbd "u") 'viper-forward-paragraph)
  (define-key viper-vi-global-user-map (kbd "y") 'viper-change-command)
  (define-key viper-vi-global-user-map (kbd "Y") 'viper-change-to-eol)
  (define-key viper-vi-global-user-map (kbd ";") 'viper-open-line)
  (define-key viper-vi-global-user-map (kbd "a") 'viper-beginning-of-line)
  (define-key viper-vi-global-user-map (kbd "A") 'beginning-of-buffer)
  (define-key viper-vi-global-user-map (kbd "r") 'viper-backward-char)
  (define-key viper-vi-global-user-map (kbd "s") 'viper-backward-word)
  (define-key viper-vi-global-user-map (kbd "S") 'viper-backward-Word)
  (define-key viper-vi-global-user-map (kbd "t") 'viper-previous-line)
  (define-key viper-vi-global-user-map (kbd "d") 'viper-find-char-backward-offset-or-next)
  (define-key viper-vi-global-user-map (kbd "D") 'viper-find-char-backward-or-next)
  (define-key viper-vi-global-user-map (kbd "h") 'viper-find-char-forward-offset-or-next)
  (define-key viper-vi-global-user-map (kbd "H") 'viper-find-char-forward-or-next)
  (define-key viper-vi-global-user-map (kbd "n") 'viper-next-line)
  (define-key viper-vi-global-user-map (kbd "e") 'viper-forward-word)
  (define-key viper-vi-global-user-map (kbd "E") 'viper-forward-Word)
  (define-key viper-vi-global-user-map (kbd "i") 'viper-forward-char)
  (define-key viper-vi-global-user-map (kbd "o") 'viper-goto-eol)
  (define-key viper-vi-global-user-map (kbd "O") 'end-of-buffer)
  (define-key viper-vi-global-user-map (kbd "'") 'viper-end-of-word)
  (define-key viper-vi-global-user-map (kbd "\"") 'viper-end-of-Word)
  (define-key viper-vi-global-user-map (kbd "z") 'undo)
  (define-key viper-vi-global-user-map (kbd "Z") 'redo)

  (define-key viper-vi-global-user-map (kbd "x") 'viper-delete-command)
  (define-key viper-vi-global-user-map (kbd "X") 'viper-delete-to-eol)
  (define-key viper-vi-global-user-map (kbd "c") 'viper-yank-command)
  (define-key viper-vi-global-user-map (kbd "C") 'viper-yank-to-eol)
  (define-key viper-vi-global-user-map (kbd "v") 'viper-Put-back)
  (define-key viper-vi-global-user-map (kbd "V") 'viper-put-back)
  (define-key viper-vi-global-user-map (kbd "b") 'backward-delete-char-untabify)
  (define-key viper-vi-global-user-map (kbd "k") 'delete-char)

  (define-key viper-vi-global-user-map (kbd "m") (viper-construct-viper-goto-registered-mark-keybindings))
  (define-key viper-vi-global-user-map (kbd "m SPC") 'viper-mark-point)
  (define-key viper-vi-global-user-map (kbd "mm") 'viper-goto-mark)
  (define-key viper-vi-global-user-map (kbd "m,") 'set-mark-command-deactivate)
  (define-key viper-vi-global-user-map (kbd "m.") 'exchange-point-and-mark-deactivate)
  (define-key viper-vi-global-user-map (kbd "mt") 'viper-cycle-through-mark-ring)
  (define-key viper-vi-global-user-map (kbd "ma") 'viper-mark-beginning-of-buffer)
  (define-key viper-vi-global-user-map (kbd "mo") 'viper-mark-end-of-buffer) 
  (define-key viper-vi-global-user-map (kbd "m^") (lambda () (interactive) (push-mark viper-saved-mark t t)))
  (define-key viper-vi-global-user-map (kbd "mD") (lambda () (interactive) (mark-defun)))

(define-key viper-vi-global-user-map (kbd ",") 'viper-substitute)
  (define-key viper-vi-global-user-map (kbd ".") 'viper-specify-register) ;; todo
  (define-key viper-vi-global-user-map (kbd "/") 'viper-repeat)
  (define-key viper-vi-global-user-map (kbd "\\") 'viper-escape-to-emacs)

  (define-key viper-vi-global-user-map (kbd "!") 'viper-bang-command)
  ;;(define-key viper-vi-global-user-map (kbd "") 'viper-hash-command)
  (define-key viper-vi-global-user-map (kbd "=") 'viper-equals-command)
  (define-key viper-vi-global-user-map (kbd "<") 'viper-left-shift-command)
  (define-key viper-vi-global-user-map (kbd ">") 'viper-right-shift-command)

  (define-key viper-insert-global-user-map (kbd "C-w") 'close-current-buffer)

  ;; (keymap
  ;;  (22 . vimpulse-visual-mode-block)
  ;;  (16 . yank-rectangle)
  ;;  (23 keymap
  ;;      (83 . split-window-vertically)
  ;;      (115 . split-window-vertically)
  ;;      (99 . delete-window)
  ;;      (111 . delete-other-windows)
  ;;      (119 . vimpulse-cycle-windows)
  ;;      (23 . vimpulse-cycle-windows))
  ;;  (18 . redo)
  ;;  (117 . undo)
  ;;  (20 . pop-tag-mark)
  ;;  (29 . vimpulse-jump-to-tag-at-point)
  ;;  (35 . vimpulse-search-backward-for-symbol-at-point)
  ;;  (42 . vimpulse-search-forward-for-symbol-at-point)
  ;;  (122 keymap
  ;;       (122 . viper-line-to-middle)
  ;;       (116 . viper-line-to-top)
  ;;       (108 . scroll-left)
  ;;       (104 . scroll-right)
  ;;       (98 . viper-line-to-bottom))
  ;;  (75 . woman)
  ;;  (27 . newline)
  ;;  (32 . insert-space)
  ;;  (return . newline)
  ;;  (delete . delete-char)
  ;;  (backspace . backward-delete-char-untabify)
  ;;  (25 . yank)

  (viper-init-keymap)
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-search-backward-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-forward-offset-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-backward-offset-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-forward-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-backward-or-next))
)



(defun viper-remap-qwerty ()
  (setq viper-insert-after-replace nil)
  (setq viper-ESC-moves-cursor-back nil)
  (setq viper-same-line-put-cursor-last-char nil)
;;  (viper-set-searchstyle-toggling-macros 1) ;; unset '//' and '///' macros
;; todo

  (define-key viper-vi-global-user-map (kbd "<backspace>") 'vimpulse-visual-mode)
  (define-key viper-vi-global-user-map (kbd "<delete>") 'delete-char)
  (define-key viper-vi-global-user-map (kbd "<return>") 'newline)

  (define-key viper-vi-global-user-map (kbd "<SPC>") 'viper-insert)



  (define-key viper-vi-global-user-map (kbd "`") 'viper-paren-match)


  (define-key viper-vi-global-user-map (kbd "q") 'viper-Open-line)
  (define-key viper-vi-global-user-map (kbd "wg") 'vimpulse-goto-first-line)
  (define-key viper-vi-global-user-map (kbd "wz") 'find-file-at-point)
  (define-key viper-vi-global-user-map "wj" 'jl-jump-backward)
  (define-key viper-vi-global-user-map "wh" 'jl-jump-forward)
  ;;(define-key viper-vi-global-user-map "wq" 'quit-buffer)
  (define-key viper-vi-global-user-map "ws" 'save-buffer)
  (define-key viper-vi-global-user-map "wa" 'viper-ex)
  (define-key viper-vi-global-user-map "wf" 'find-file)
  (define-key viper-vi-global-user-map "wb" 'bookmark-jump)
  (define-key viper-vi-global-user-map "wB" 'bookmark-set)
  (define-key viper-vi-global-user-map "w1" 'delete-other-windows) 
  (define-key viper-vi-global-user-map "wo" 'other-window) 
  (define-key viper-vi-global-user-map "wg" 'pop-global-mark)

  (define-key viper-vi-global-user-map "wu" 'viperre-quick-dvc-pull-update)
  (define-key viper-vi-global-user-map "wc" 'viperre-quick-dvc-commit)
  (define-key viper-vi-global-user-map "wv" 'dvc-log-edit)
  (define-key viper-vi-global-user-map "wl" 'dvc-status)


  (define-key viper-vi-global-user-map (kbd "e") 'viper-backward-paragraph)
;;  (define-key viper-vi-global-user-map (kbd "p") 'viper-scroll-down)
;;  (define-key viper-vi-global-user-map (kbd "p") 'viper-search-backward-or-next)
  (define-key viper-vi-global-user-map (kbd "r") 'viper-isearch-backward-or-next)

;;(define-key viper-vi-global-user-map (kbd "p") 'isearch-backward)
  (define-key viper-vi-global-user-map (kbd "t") 'backward-kill-word)
  (define-key viper-vi-global-user-map (kbd "y") 'kill-word)
;;  (define-key viper-vi-global-user-map (kbd "l") 'viper-search-forward-or-next)
  (define-key viper-vi-global-user-map (kbd "u") 'viper-isearch-forward-or-next)

;; (define-key viper-vi-global-user-map (kbd "l") 'isearch-forward)
;;  (define-key viper-vi-global-user-map (kbd "l") 'viper-scroll-up)
  (define-key viper-vi-global-user-map (kbd "i") 'viper-forward-paragraph)
  (define-key viper-vi-global-user-map (kbd "o") 'viper-change-command)
  (define-key viper-vi-global-user-map (kbd "O") 'viper-change-to-eol)
  (define-key viper-vi-global-user-map (kbd "p") 'viper-open-line)
  (define-key viper-vi-global-user-map (kbd "a") 'viper-beginning-of-line)
  (define-key viper-vi-global-user-map (kbd "A") 'beginning-of-buffer)
  (define-key viper-vi-global-user-map (kbd "s") 'viper-backward-char)
  (define-key viper-vi-global-user-map (kbd "d") 'viper-backward-word)
  (define-key viper-vi-global-user-map (kbd "D") 'viper-backward-Word)
  (define-key viper-vi-global-user-map (kbd "f") 'viper-previous-line)
  (define-key viper-vi-global-user-map (kbd "g") 'viper-find-char-backward-offset-or-next)
  (define-key viper-vi-global-user-map (kbd "G") 'viper-find-char-backward-or-next)
  (define-key viper-vi-global-user-map (kbd "h") 'viper-find-char-forward-offset-or-next)
  (define-key viper-vi-global-user-map (kbd "H") 'viper-find-char-forward-or-next)
  (define-key viper-vi-global-user-map (kbd "j") 'viper-next-line)
  (define-key viper-vi-global-user-map (kbd "k") 'viper-forward-word)
  (define-key viper-vi-global-user-map (kbd "K") 'viper-forward-Word)
  (define-key viper-vi-global-user-map (kbd "l") 'viper-forward-char)
  (define-key viper-vi-global-user-map (kbd ";") 'viper-goto-eol)
  (define-key viper-vi-global-user-map (kbd ":") 'end-of-buffer)
  (define-key viper-vi-global-user-map (kbd "'") 'viper-end-of-word)
  (define-key viper-vi-global-user-map (kbd "\"") 'viper-end-of-Word)
  (define-key viper-vi-global-user-map (kbd "z") 'undo)
  (define-key viper-vi-global-user-map (kbd "Z") 'redo)

  (define-key viper-vi-global-user-map (kbd "x") 'viper-delete-command)
  (define-key viper-vi-global-user-map (kbd "X") 'viper-delete-to-eol)
  (define-key viper-vi-global-user-map (kbd "c") 'viper-yank-command)
  (define-key viper-vi-global-user-map (kbd "C") 'viper-yank-to-eol)
  (define-key viper-vi-global-user-map (kbd "v") 'viper-Put-back)
  (define-key viper-vi-global-user-map (kbd "V") 'viper-put-back)
  (define-key viper-vi-global-user-map (kbd "b") 'backward-delete-char-untabify)
  (define-key viper-vi-global-user-map (kbd "n") 'delete-char)


  (define-key viper-vi-global-user-map (kbd "m") (viper-construct-viper-goto-registered-mark-keybindings))
  (define-key viper-vi-global-user-map (kbd "m SPC") 'viper-mark-point)
  (define-key viper-vi-global-user-map (kbd "mm") 'viper-goto-mark)
  (define-key viper-vi-global-user-map (kbd "m,") 'set-mark-command-deactivate)
  (define-key viper-vi-global-user-map (kbd "m.") 'exchange-point-and-mark-deactivate)
  (define-key viper-vi-global-user-map (kbd "mt") 'viper-cycle-through-mark-ring)
  (define-key viper-vi-global-user-map (kbd "ma") 'viper-mark-beginning-of-buffer)
  (define-key viper-vi-global-user-map (kbd "mo") 'viper-mark-end-of-buffer) 
  (define-key viper-vi-global-user-map (kbd "m^") (lambda () (interactive) (push-mark viper-saved-mark t t)))
  (define-key viper-vi-global-user-map (kbd "mD") (lambda () (interactive) (mark-defun)))

  (define-key viper-vi-global-user-map (kbd ",") 'viper-substitute)
  (define-key viper-vi-global-user-map (kbd ".") 'viper-specify-register) ;; todo
  (define-key viper-vi-global-user-map (kbd "/") 'viper-repeat)
  (define-key viper-vi-global-user-map (kbd "\\") 'viper-escape-to-emacs)

  (define-key viper-vi-global-user-map (kbd "!") 'viper-bang-command)
  ;;(define-key viper-vi-global-user-map (kbd "") 'viper-hash-command)
  (define-key viper-vi-global-user-map (kbd "=") 'viper-equals-command)
  (define-key viper-vi-global-user-map (kbd "<") 'viper-left-shift-command)
  (define-key viper-vi-global-user-map (kbd ">") 'viper-right-shift-command)

  (define-key viper-insert-global-user-map (kbd "C-w") 'close-current-buffer)

  (viper-init-keymap)
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-search-backward-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-forward-offset-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-backward-offset-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-forward-or-next))
  (add-to-list 'viper-movement-commands (viper-where-is-internal 'viper-find-char-backward-or-next))
)
