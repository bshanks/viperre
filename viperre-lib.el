(load "viper-cmds-remap")


(defcustom viper-insert-after-replace 't "If not nil, the substitute command will go to Insert Mode after you exit the subsitution region; otherwise it goes to Vi mode. 't is the default.")
(defcustom viper-same-line-put-cursor-last-char 't "If not nil, after puts containing no newlines, the cursor will be moved onto the last character of the put; otherwise it goes to the first character after the put. 't is the default.")

;; redef from vimpulse to respect viper-ESC-moves-cursor-back

;; __Redefinitions of viper functions to handle visual block-mode__
;; This function is not in viper-functions-redefinitions.el 
;; because its code is closely related to visual mode.
(defun viper-exit-insert-state ()
  (interactive)
  (viper-change-state-to-vi)
  (when vimpulse-visual-insert-coords
    ;; Get the saved info about the visual region
    (let ((i-com (car vimpulse-visual-insert-coords))
	  (pos (cadr vimpulse-visual-insert-coords))
	  (col (caddr vimpulse-visual-insert-coords))
	  (nlines (cadddr vimpulse-visual-insert-coords)))
      (goto-char pos)
      (save-excursion
	(dotimes (i (1- nlines))
	  (forward-line 1)
	  (let ((cur-col (move-to-column col)))
	    ;; If we are in block mode this line but do not hit the correct 
            ;; column, we check if we should convert tabs and/or append spaces
	    (if (and vimpulse-visual-mode-block
		     (or (/= col cur-col) ;; wrong column or 
			 (eolp)))         ;; end of line 
		(cond ((< col cur-col)	  ;; we are inside a tab 
		       (move-to-column (1+ col) 'fill) ;; -> convert to spaces
		       (move-to-column col 'fill) ;; this is needed for ?a
		       (viper-repeat nil))
		      ((and (>= col cur-col) ;; we are behind the end
			    (eq i-com ?a))   ;; and i-com is ?a
		       (move-to-column (1+ col) t) ;; -> append spaces
		       (viper-repeat nil)))
		    
	      (viper-repeat nil)))))
      (setq vimpulse-visual-insert-coords nil)
    
      ;; update the last two undos
      (if (> nlines 1)
	  (if (eq i-com ?c)
	      (connect-undos 3 buffer-undo-list) ; delete, insert, repeat
	    (connect-undos 2 buffer-undo-list))	 ; insert, repeat
	(if (eq i-com ?c)
	    (connect-undos 2 buffer-undo-list)	 ; delete, insert
	  (connect-undos 1 buffer-undo-list))))) ; insert
  (if (and (/= (char-before (point)) ?\r) 
	   (/= (char-before (point)) ?\n)
           viper-ESC-moves-cursor-back)
      (backward-char 1)))               ; <---------- a[ESC] leaves the cursor 
					; where it was before in VIM, without 
					; backward-char it advances 1 character.

    ;; (cond ((and (<= ?a char) (<= char ?z))
    ;; 	   (point-to-register (viper-int-to-char (1+ (- char ?a)))))
    ;; 	  ((viper= char ?<) (viper-mark-beginning-of-buffer))
    ;; 	  ((viper= char ?>) (viper-mark-end-of-buffer))
    ;; 	  ((viper= char ?.) (viper-set-mark-if-necessary))
    ;; 	  ((viper= char ?,) (viper-cycle-through-mark-ring))
    ;; 	  ((viper= char ?^) (push-mark viper-saved-mark t t))
    ;; 	  ((viper= char ?D) (mark-defun))




(defun set-mark-command-deactivate ()
  (interactive)
  (set-mark-command nil)
  (deactivate-mark nil)
)

(defun exchange-point-and-mark-deactivate ()
  (interactive)
  (exchange-point-and-mark nil)
  (deactivate-mark nil)
)





;; redefine


;; this one is the same except interactive -- this one is from viper-util.el 
;;   and made it a defun, not defsubst


;; like (set-mark-command nil) but doesn't push twice, if (car mark-ring)
;; is the same as (mark t).
(defun viper-set-mark-if-necessary ()
  (interactive)
  (setq mark-ring (delete (viper-mark-marker) mark-ring))
  (set-mark-command nil)
  (setq viper-saved-mark (point)))


;; this one is the same except interactive

;; Algorithm: If first invocation of this command save mark on ring, goto
;; mark, M0, and pop the most recent elt from the mark ring into mark,
;; making it into the new mark, M1.
;; Push this mark back and set mark to the original point position, p1.
;; So, if you hit '' or `` then you can return to p1.
;;
;; If repeated command, pop top elt from the ring into mark and
;; jump there.  This forgets the position, p1, and puts M1 back into mark.
;; Then we save the current pos, which is M0, jump to M1 and pop M2 from
;; the ring into mark.  Push M2 back on the ring and set mark to M0.
;; etc.
(defun viper-cycle-through-mark-ring ()
  "Visit previous locations on the mark ring.
One can use `` and '' to temporarily jump 1 step back."
  (interactive)
  (let* ((sv-pt (point)))
       ;; if repeated `m,' command, pop the previously saved mark.
       ;; Prev saved mark is actually prev saved point.  It is used if the
       ;; user types `` or '' and is discarded
       ;; from the mark ring by the next `m,' command.
       ;; In any case, go to the previous or previously saved mark.
       ;; Then push the current mark (popped off the ring) and set current
       ;; point to be the mark.  Current pt as mark is discarded by the next
       ;; m, command.
       (if (eq last-command 'viper-cycle-through-mark-ring)
	   ()
	 ;; save current mark if the first iteration
	 (setq mark-ring (delete (viper-mark-marker) mark-ring))
	 (if (mark t)
	     (push-mark (mark t) t)) )
       (pop-mark)
       (set-mark-command 1)
       ;; don't duplicate mark on the ring
       (setq mark-ring (delete (viper-mark-marker) mark-ring))
       (push-mark sv-pt t)
       (viper-deactivate-mark)
       (setq this-command 'viper-cycle-through-mark-ring)
       ))




;; break out the cases into separate keybindings


(defun viper-goto-registered-mark (char com skip-white)
  (interactive)
;; huh? what's this all about?
;;  (if (eobp)
;;      (if (bobp)
;;	  (error "Empty buffer")
;;	(backward-char 1)))
(if (viper-valid-register char '(letter))
	 (let* ((buff (current-buffer))
	        (reg (viper-int-to-char (1+ (- char ?a))))
	        (text-marker (get-register reg)))
	   ;; If marker points to file that had markers set (and those markers
	   ;; were saved (as e.g., in session.el), then restore those markers
	   (if (and (consp text-marker)
 		    (eq (car text-marker) 'file-query)
 		    (or (find-buffer-visiting (nth 1 text-marker))
 			(y-or-n-p (format "Visit file %s again? "
 					  (nth 1 text-marker)))))
 	       (save-excursion
 		 (find-file (nth 1 text-marker))
 		 (when (and (<= (nth 2 text-marker) (point-max))
 			    (<= (point-min) (nth 2 text-marker)))
 		   (setq text-marker (copy-marker (nth 2 text-marker)))
 		   (set-register reg text-marker))))
	   (if com (viper-move-marker-locally 'viper-com-point (point)))
	   (if (not (viper-valid-marker text-marker))
	       (error viper-EmptyTextmarker char))
	   (if (and (viper-same-line (point) viper-last-jump)
		    (= (point) viper-last-jump-ignore))
	       (push-mark viper-last-jump t)
	     (push-mark nil t)) ; no msg
	   (viper-register-to-point reg)
	   (setq viper-last-jump (point-marker))
	   (cond (skip-white
		  (back-to-indentation)
		  (setq viper-last-jump-ignore (point))))
	   (if com
	       (if (equal buff (current-buffer))
		   (viper-execute-com (if skip-white
					  'viper-goto-mark-and-skip-white
					'viper-goto-mark)
				    nil com)
		 (switch-to-buffer buff)
		 (goto-char viper-com-point)
		 (viper-change-state-to-vi)
		 (error "Viper bell"))))

  (error viper-InvalidTextmarker char))

)


;; i'm trying to use partial function application to bind a partially applied function to a bunch of different keys, with different values given to the first argument depending on what key was typed. (i guess there might be some way for the function to just ask emacs what keystroke it was called from at runtime, but that seems less clean to me). in this case the function is 'viper-goto-registered-mark (which takes three arguments, a character, "(viper-getCom arg)" and "'t").
;;
;; i tried this but it didn't work, i got error "funcall: Symbol's value as variable is void: letter" when i called one of
;; the bound keys. i think perhaps that the dolist iteration variable "letter" is dynamically, not lexically scoped, and therefore it is undefined at the time of execution of the bound function. which makes it really inconvenient to do this sort of thing; presumably there's some standard (e)Lisp macro that goes into a block of code and performs variable substitution in it? i guess this is why people think it's a big deal that elisp doesn't have lexical closures.
;;
;; any suggestions?
;;
;;(defun viper-construct-viper-goto-registered-mark-keybindings ()
;;  (let ((letters '(?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z)) (bindings (make-sparse-keymap)))
;;  (dolist (letter letters bindings) 
;;  (define-key bindings (vector letter) (lambda (arg) (interactive "P") (funcall (apply-partially 'viper-goto-registered-mark letter) (viper-getCom arg) 't))))))
;;
;;(define-key viper-vi-global-user-map (kbd "m") (viper-construct-viper-goto-registered-mark-keybindings))

(require 'cl)
(defun viper-construct-viper-goto-registered-mark-keybindings ()
  (let ((letters '(?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z)) (bindings (make-sparse-keymap)))
  (dolist (letter letters bindings) 
  (define-key bindings (vector letter) (lexical-let ((letter letter)) (lambda (arg) (interactive "P") (funcall (apply-partially 'viper-goto-registered-mark letter) (viper-getCom arg) nil)))))))



(defun viper-goto-prev-mark (char com)
  (interactive)
	 (if com (viper-move-marker-locally 'viper-com-point (point)))
	 (if (and (viper-same-line (point) viper-last-jump)
		  (= (point) viper-last-jump-ignore))
	     (goto-char viper-last-jump))
	 (if (null (mark t)) (error "Mark is not set in this buffer"))
	 (if (= (point) (mark t)) (pop-mark))
	 (exchange-point-and-mark)
	 (setq viper-last-jump (point-marker)
	       viper-last-jump-ignore 0)
	 (if com (viper-execute-com 'viper-goto-mark nil com)))


(defun viper-goto-prev-mark-bol (char com)
  (interactive)
	 (if com (viper-move-marker-locally 'viper-com-point (point)))
	 (if (and (viper-same-line (point) viper-last-jump)
		  (= (point) viper-last-jump-ignore))
	     (goto-char viper-last-jump))
	 (if (= (point) (mark t)) (pop-mark))
	 (exchange-point-and-mark)
	 (setq viper-last-jump (point))
	 (back-to-indentation)
	 (setq viper-last-jump-ignore (point))
	 (if com (viper-execute-com 'viper-goto-mark-and-skip-white nil com)))



(defun viper-repeat-find (arg)
  "Repeat previous find command."
  (interactive "P")
  (let ((val (viper-p-val arg))
	(com (viper-getcom arg)))
    (viper-deactivate-mark)
    (if com (viper-move-marker-locally 'viper-com-point (point)))
    (if viper-f-offset
       (if viper-f-forward (forward-char) (backward-char)))
    (viper-find-char val viper-f-char viper-f-forward viper-f-offset)
    (if com
	(progn
	  (if viper-f-forward (forward-char))
	  (viper-execute-com 'viper-repeat-find val com)))))

(defun viper-repeat-find-opposite (arg)
  "Repeat previous find command in the opposite direction."
  (interactive "P")
  (let ((val (viper-p-val arg))
	(com (viper-getcom arg)))
    (viper-deactivate-mark)
    (if com (viper-move-marker-locally 'viper-com-point (point)))
    (if viper-f-offset
       (if viper-f-forward (backward-char) (forward-char)))
    (viper-find-char val viper-f-char (not viper-f-forward) viper-f-offset)
    (if com
	(progn
	  (if viper-f-forward (forward-char))
	  (viper-execute-com 'viper-repeat-find-opposite val com)))))






(defun viper-downgrade-to-insert ()
  (if viper-insert-after-replace
      (progn
	;; Protect against user errors in hooks
       (condition-case conds
	   (run-hooks 'viper-insert-state-hook)
	 (error
	  (viper-message-conditions conds)))
       (setq viper-current-state 'insert-state
	  viper-replace-minor-mode nil))
    (progn
      (setq viper-current-state 'insert-state
	  viper-replace-minor-mode nil)
      (viper-exit-insert-state))))


;; viper-downgrade-to-insert used to be inline (defsubst),
;; so we need to redefine both of the places where it's used:

;; Delete stuff between viper-last-posn-in-replace-region and the end of
;; viper-replace-overlay-marker, if viper-last-posn-in-replace-region is within
;; the overlay and current point is before the end of the overlay.
;; Don't delete anything if current point is past the end of the overlay.
(defun viper-finish-change ()
  (remove-hook
   'viper-after-change-functions 'viper-replace-mode-spy-after 'local)
  (remove-hook
   'viper-before-change-functions 'viper-replace-mode-spy-before 'local)
  (remove-hook
   'viper-post-command-hooks 'viper-replace-state-post-command-sentinel 'local)
  (remove-hook
   'viper-pre-command-hooks 'viper-replace-state-pre-command-sentinel 'local)
  (viper-restore-cursor-color 'after-replace-mode)
  (setq viper-sitting-in-replace nil) ; just in case we'll need to know it
  (save-excursion
    (if (and viper-replace-overlay
	     (viper-pos-within-region viper-last-posn-in-replace-region
				      (viper-replace-start)
				      (viper-replace-end))
	     (< (point) (viper-replace-end)))
	(delete-region
	 viper-last-posn-in-replace-region (viper-replace-end))))

  (if (eq viper-current-state 'replace-state)
      (viper-downgrade-to-insert))
  ;; replace mode ended => nullify viper-last-posn-in-replace-region
  (viper-move-marker-locally 'viper-last-posn-in-replace-region nil)
  (viper-hide-replace-overlay)
  (viper-refresh-mode-line)
  (viper-put-string-on-kill-ring viper-last-replace-region)
  )

(defun viper-finish-R-mode ()
  (remove-hook
   'viper-post-command-hooks 'viper-R-state-post-command-sentinel 'local)
  (remove-hook
   'viper-pre-command-hooks 'viper-replace-state-pre-command-sentinel 'local)
  (viper-downgrade-to-insert))




;; Replace state

(defun viper-change (beg end)
  (if (markerp beg) (setq beg (marker-position beg)))
  (if (markerp end) (setq end (marker-position end)))
  ;; beg is sometimes (mark t), which may be nil
  (or beg (setq beg end))

  (viper-set-complex-command-for-undo)
  (if viper-use-register
      (progn
	(copy-to-register viper-use-register beg end nil)
	(setq viper-use-register nil)))
  (viper-set-replace-overlay beg end)
  (setq last-command nil) ; separate repl text from prev kills

  (if (= (viper-replace-start) (point-max))
      (error "End of buffer"))

  (setq viper-last-replace-region
	(buffer-substring (viper-replace-start)
			  (viper-replace-end)))

  ;; protect against error while inserting "@" and other disasters
  ;; (e.g., read-only buff)
  (condition-case conds
      (if (or viper-allow-multiline-replace-regions
	      (viper-same-line (viper-replace-start)
			       (viper-replace-end)))
	  (progn
	    ;; tabs cause problems in replace, so untabify
	    (goto-char (viper-replace-end))
	    (insert-before-markers "@") ; put placeholder after the TAB
	    (untabify (viper-replace-start) (point))
	    ;; del @, don't put on kill ring
	    (delete-backward-char 1)

	    (viper-set-replace-overlay-glyphs
	     viper-replace-region-start-delimiter
	     viper-replace-region-end-delimiter)
	    ;; this move takes care of the last posn in the overlay, which
	    ;; has to be shifted because of insert.  We can't simply insert
	    ;; "$" before-markers because then overlay-start will shift the
	    ;; beginning of the overlay in case we are replacing a single
	    ;; character.  This fixes the bug with `s' and `cl' commands.
	    (viper-move-replace-overlay (viper-replace-start) (point))
	    (goto-char (viper-replace-start))
	    (viper-change-state-to-replace t))
	(kill-region (viper-replace-start)
		     (viper-replace-end))
	(viper-hide-replace-overlay)
	(if viper-insert-after-replace
	    (viper-change-state-to-insert)
	  (viper-change-state-to-vi))
)
    (error ;; make sure that the overlay doesn't stay.
           ;; go back to the original point
     (goto-char (viper-replace-start))
     (viper-hide-replace-overlay)
     (viper-message-conditions conds))))







(defun viper-put-back (arg)
  "Put back after point/below line."
  (interactive "P")
  (let ((val (viper-p-val arg))
	(text (if viper-use-register
		  (cond ((viper-valid-register viper-use-register '(digit))
			 (current-kill
			  (- viper-use-register ?1) 'do-not-rotate))
			((viper-valid-register viper-use-register)
			 (get-register (downcase viper-use-register)))
			(t (error viper-InvalidRegister viper-use-register)))
		(current-kill 0)))
	sv-point chars-inserted lines-inserted)
    (if (null text)
	(if viper-use-register
	    (let ((reg viper-use-register))
	      (setq viper-use-register nil)
	      (error viper-EmptyRegister reg))
	  (error "Viper bell")))
    (setq viper-use-register nil)
    (if (viper-end-with-a-newline-p text)
	(progn
	  (end-of-line)
	  (if (eobp)
	      (insert "\n")
	    (forward-line 1))
	  (beginning-of-line))
      (if (not (eolp)) (viper-forward-char-carefully)))
    (set-marker (viper-mark-marker) (point) (current-buffer))
    (viper-set-destructive-command
     (list 'viper-put-back val nil viper-use-register nil nil))
    (setq sv-point (point))
    (viper-loop val (viper-yank text))
    (setq chars-inserted (abs (- (point) sv-point))
	  lines-inserted (abs (count-lines (point) sv-point)))
    (if (or (> chars-inserted viper-change-notification-threshold)
	    (> lines-inserted viper-change-notification-threshold))
	(unless (viper-is-in-minibuffer)
	  (message "Inserted %d character(s), %d line(s)"
		   chars-inserted lines-inserted))))
  ;; Vi puts cursor on the last char when the yanked text doesn't contain a
  ;; newline; it leaves the cursor at the beginning when the text contains
  ;; a newline
  (if viper-same-line-put-cursor-last-char
      (if (viper-same-line (point) (mark))
	  (or 
	   (= (point) (mark))
	   (not viper-same-line-put-cursor-last-char)	
	   (viper-backward-char-carefully))
	(exchange-point-and-mark)
	(if (bolp)
	    (back-to-indentation)))
    (viper-deactivate-mark)))

(defun viper-Put-back (arg)
  "Put back at point/above line."
  (interactive "P")
  (let ((val (viper-p-val arg))
	(text (if viper-use-register
		  (cond ((viper-valid-register viper-use-register '(digit))
			 (current-kill
			  (- viper-use-register ?1) 'do-not-rotate))
			((viper-valid-register viper-use-register)
			 (get-register (downcase viper-use-register)))
			(t (error viper-InvalidRegister viper-use-register)))
		(current-kill 0)))
	sv-point chars-inserted lines-inserted)
    (if (null text)
	(if viper-use-register
	    (let ((reg viper-use-register))
	      (setq viper-use-register nil)
	      (error viper-EmptyRegister reg))
	  (error "Viper bell")))
    (setq viper-use-register nil)
    (if (viper-end-with-a-newline-p text) (beginning-of-line))
    (viper-set-destructive-command
     (list 'viper-Put-back val nil viper-use-register nil nil))
    (set-marker (viper-mark-marker) (point) (current-buffer))
    (setq sv-point (point))
    (viper-loop val (viper-yank text))
    (setq chars-inserted (abs (- (point) sv-point))
	  lines-inserted (abs (count-lines (point) sv-point)))
    (if (or (> chars-inserted viper-change-notification-threshold)
	    (> lines-inserted viper-change-notification-threshold))
	(unless (viper-is-in-minibuffer)
	  (message "Inserted %d character(s), %d line(s)"
		   chars-inserted lines-inserted))))
  ;; Vi puts cursor on the last char when the yanked text doesn't contain a
  ;; newline; it leaves the cursor at the beginning when the text contains
  ;; a newline
  (if viper-same-line-put-cursor-last-char
      (if (viper-same-line (point) (mark))
	  (or 
	   (= (point) (mark))
	   (not viper-same-line-put-cursor-last-char)	
	   (viper-backward-char-carefully))
	(exchange-point-and-mark)
	(if (bolp)
	    (back-to-indentation)))
    (viper-deactivate-mark)))
  

;; other fns are at other keymaps
(defun viper-mark-point ()
  "Set mark at point of buffer."
  (interactive)
  (let ((char (read-char)))
    (point-to-register (viper-int-to-char (1+ (- char ?a))))))
;;    (cond ((and (<= ?a char) (<= char ?z))
;;	   (point-to-register (viper-int-to-char (1+ (- char ?a)))))
;;	  (t (error "Marks can only be saved in lowercase letters"))
;;	  )))




;; we renamed some functions
(defun viper-where-is-internal (func)
  (let ((func2 (cond
   ((eq func 'viper-kill-line) 'viper-delete-to-eol)
   ((eq func 'viper-yank-line) 'viper-yank-to-eol)
   ('t func))))

    (let ((w (where-is-internal func2 overriding-local-map 't)))
      (if w (aref w 0) nil))))

;; end redefines



(defun viper-isearch-forward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-isearch-forward-or-next) (eq last-command 'viper-isearch-backward-or-next))
      (if viper-s-forward
	(isearch-repeat-forward)
	(isearch-repeat-backward))
      (progn
	(setq viper-s-forward 't)
	(isearch-forward)
	(setq this-command 'viper-isearch-forward-or-next))))

(defun viper-isearch-backward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-isearch-forward-or-next) (eq last-command 'viper-isearch-backward-or-next))
      (if viper-s-forward
	(isearch-repeat-forward)
	(isearch-repeat-backward))
      (progn
	(setq viper-s-forward nil)
	(isearch-backward)
	(setq this-command 'viper-isearch-backward-or-next))))




;; (defun viper-isearch-forward-or-next (arg)
;;   (interactive "P")
;;   (if
;;       (or (eq last-command 'viper-search-forward-or-next) (eq last-command 'viper-search-backward-or-next))
;;       (if viper-s-forward
;; 	(viper-search-next arg)
;; 	(viper-search-Next arg))
;;       (progn
;; 	(viper-isearch-forward arg)
;; 	(setq this-command 'viper-search-forward-or-next))))
 
;; (defun viper-isearch-backward-or-next (arg)
;;   (interactive "P")
;;   (if
;;       (or (eq last-command 'viper-search-forward-or-next) (eq last-command 'viper-search-backward-or-next))
;;       (if viper-s-forward
;; 	(viper-search-Next arg)
;; 	(viper-search-next arg))
;;       (progn
;; 	 (viper-isearch-backward arg)
;; 	 (setq this-command 'viper-search-forward-or-next))))



(defun viper-search-forward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-search-forward-or-next) (eq last-command 'viper-search-backward-or-next))
      (if viper-s-forward
	(viper-search-next arg)
	(viper-search-Next arg))
      (progn
	(viper-search-forward arg)
	(setq this-command 'viper-search-forward-or-next))))

(defun viper-search-backward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-search-forward-or-next) (eq last-command 'viper-search-backward-or-next))
      (if viper-s-forward
	(viper-search-Next arg)
	(viper-search-next arg))
      (progn
	 (viper-search-backward arg)
	 (setq this-command 'viper-search-forward-or-next))))



(defun viper-find-char-forward-offset-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-find-char-forward-or-next) (eq last-command 'viper-find-char-backward-or-next) (eq last-command 'viper-find-char-forward-offset-or-next) (eq last-command 'viper-find-char-backward-offset-or-next))
      (if viper-f-forward
	(viper-repeat-find arg)
	(viper-repeat-find-opposite arg))
      (viper-goto-char-forward arg)))

(defun viper-find-char-backward-offset-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-find-char-forward-or-next) (eq last-command 'viper-find-char-backward-or-next) (eq last-command 'viper-find-char-forward-offset-or-next) (eq last-command 'viper-find-char-backward-offset-or-next))
      (if viper-f-forward
	(viper-repeat-find-opposite arg)
	(viper-repeat-find arg))
      (viper-goto-char-backward arg)))


(defun viper-find-char-forward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-find-char-forward-or-next) (eq last-command 'viper-find-char-backward-or-next) (eq last-command 'viper-find-char-forward-offset-or-next) (eq last-command 'viper-find-char-backward-offset-or-next))
      (if viper-f-forward
	(viper-repeat-find arg)
	(viper-repeat-find-opposite arg))
      (viper-find-char-forward arg)))

(defun viper-find-char-backward-or-next (arg)
  (interactive "P")
  (if
      (or (eq last-command 'viper-find-char-forward-or-next) (eq last-command 'viper-find-char-backward-or-next) (eq last-command 'viper-find-char-forward-offset-or-next) (eq last-command 'viper-find-char-backward-offset-or-next))
      (if viper-f-forward
	(viper-repeat-find-opposite arg)
	(viper-repeat-find arg))
      (viper-find-char-backward arg)))

;; actually this is the same code as viper-kill-line,
;; but i thought that was confusingly named.
(defun viper-delete-to-eol (arg)
  "Delete line."
  (interactive "P")
  (viper-goto-eol (cons arg (viper-where-is-internal 'viper-delete-command))))


(defun viper-yank-to-eol (arg)
  "Yank ARG lines."
  (interactive "P")
  (viper-goto-eol (cons arg (viper-where-is-internal 'viper-yank-command))))



(defun viperre-quick-dvc-commit ()
  (interactive)
  (save-buffer)
  (dvc-log-edit)
  (insert "modified")
  (dvc-log-edit-done)
  (run-with-timer 6 nil 'close-current-buffer)
  (run-with-timer 6 nil 'delete-other-windows)
)

(defun viperre-quick-dvc-pull-update ()
  (interactive)
  (save-buffer)
  (dvc-pull)
  (dvc-update)
  (run-with-timer 6 nil 'dvc-revert-some-buffers)
  (run-with-timer 6 nil 'delete-other-windows)
)
