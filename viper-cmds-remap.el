
(setq viper-dummy-key ?0)
(setq viper-region-key ?n)
(setq viper-Region-key ?N)
(setq viper-region-rect-key ?\C-n)

(defun viper-change-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-delete-command
 (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-yank-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)


(defun viper-hash-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-equals-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-right-shift-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-left-shift-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-bang-command (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

(defun viper-specify-register (arg)
  (interactive "P")
  (setq prefix-arg arg)
  (command-execute 'viper-command-argument)
)

;; beware! only returns the first element of the first keybinding vector found!!!
;; (so, all functions for which this is used should not be bound to multikey 
;; sequences)
;; (ideally, this function should return a list, not a single character, and
;; all places where this function is used should be rewritten to accept lists)
(defun viper-where-is-internal (func)
  (let ((w (where-is-internal func overriding-local-map 't)))
    (if w (aref w 0) nil))
)

;; escape to emacs mode temporarily
(defun viper-escape-to-emacs (arg &optional events)
  "Escape to Emacs state from Vi state for one Emacs command.
ARG is used as the prefix value for the executed command.  If
EVENTS is a list of events, which become the beginning of the command."
  (interactive "P")
  (if (viper= last-command-event (viper-where-is-internal 'viper-escape-to-emacs))
      (message "Switched to EMACS state for the next command..."))
  (viper-escape-to-state arg events 'emacs-state))


;; is viper-getCom ever actually used?

;; Get com part of prefix-argument ARG and modify it.
(defun viper-getCom (arg)
  (let ((com (viper-getcom arg)))
    (cond ((viper= com (viper-where-is-internal 'viper-change-command)) (viper-where-is-internal 'viper-change-command))
	  ;; Previously, ?c was being converted to ?C, but this prevented
	  ;; multiline replace regions.
	  ;;((viper= com (viper-where-is-internal 'viper-change-command)) ?C)
	  ((viper= com (viper-where-is-internal 'viper-delete-command)) (viper-where-is-internal 'viper-kill-line))
	  ((viper= com (viper-where-is-internal 'viper-yank-command)) (viper-where-is-internal 'viper-yank-line))
	  (t com))))



;; Compute numeric prefix arg value.
;; Invoked by EVENT-CHAR.  COM is the command part obtained so far.
(defun viper-prefix-arg-value (event-char com)

  (let ((viper-intermediate-command 'viper-digit-argument)
	value func)
    ;; read while number
    (while (and (viper-characterp event-char)
		(>= event-char ?0) (<= event-char ?9))
      (setq value (+ (* (if (integerp value) value 0) 10) (- event-char ?0)))
      (setq event-char (viper-read-event-convert-to-char)))
    (setq prefix-arg value)
    (if com (setq prefix-arg (cons prefix-arg com)))
    (while (eq event-char ?U)
      (viper-describe-arg prefix-arg)
      (setq event-char (viper-read-event-convert-to-char)))
    (if (or com (and (not (eq viper-current-state 'vi-state))
		     ;; make sure it is a Vi command
		     (viper-characterp event-char)
		     (viper-vi-command-p event-char)
		     ))
	;; If appears to be one of the vi commands,
	;; then execute it with funcall and clear prefix-arg in order to not
	;; confuse subsequent commands
	(progn
	  ;; last-command-event is the char we want emacs to think was typed
	  ;; last.  If com is not nil, the viper-digit-argument command was
	  ;; called from within viper-prefix-arg command, such as `d', `w',
	  ;; etc., i.e., the user typed, say, d2.  In this case, `com' would be
	  ;; `d', `w', etc.  If viper-digit-argument was invoked by
	  ;; viper-escape-to-vi (which is indicated by the fact that the
	  ;; current state is not vi-state), then `event-char' represents the
	  ;; vi command to be executed (e.g., `d', `w', etc).  Again,
	  ;; last-command-event must make emacs believe that this is the command
	  ;; we typed.
	  (cond ((eq event-char 'return) (setq event-char ?\C-m))
		((eq event-char 'delete) (setq event-char ?\C-?))
		((eq event-char 'backspace) (setq event-char ?\C-h))
		((eq event-char 'space) (setq event-char ?\ )))
	  (setq last-command-event (or com event-char))
	  (setq func (viper-exec-form-in-vi
		      `(key-binding (char-to-string ,event-char))))
	  (funcall func prefix-arg)
	  (setq prefix-arg nil))
      ;; some other command -- let emacs do it in its own way
      (viper-set-unread-command-events event-char))
    ))


;; Vi operator as prefix argument."
(defun viper-prefix-arg-com (char value com)

  (let ((cont t)
	cmd-info
	cmd-to-exec-at-end)



    (while (and cont
		(viper-memq-char char
				 (list (viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-yank-command) (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-left-shift-command) (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-equals-command) (viper-where-is-internal 'viper-hash-command) (viper-where-is-internal 'viper-replace-char) (viper-where-is-internal 'viper-overwrite) (viper-where-is-internal 'viper-specify-register)
				       viper-region-key viper-Region-key viper-region-rect-key
				       viper-buffer-search-char)))
      (if com
	  ;; this means that we already have a command character, so we
	  ;; construct a com list and exit while.  however, if char is "
	  ;; it is an error.
	  (progn
	    ;; new com is (CHAR . OLDCOM)
	    (if (viper-memq-char char (list (viper-where-is-internal 'viper-hash-command) (viper-where-is-internal 'viper-specify-register))) (error "Viper bell"))
	    (setq com (cons char com))
	    (setq cont nil))
	;; If com is nil we set com as char, and read more.  Again, if char is
	;; ", we read the name of register and store it in viper-use-register.
	;; if char is !, =, or #, a complete com is formed so we exit the while
	;; loop.
	(cond ((viper-memq-char char (list (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-equals-command)))
	       (setq com char)
	       (setq char (read-char))
	       (setq cont nil))
	      ((viper= char (viper-where-is-internal 'viper-hash-command))
	       ;; read a char and encode it as com
	       (setq com (+ 128 (read-char)))
	       (setq char (read-char)))
	      ((viper= char (viper-where-is-internal 'viper-specify-register))
	       (let ((reg (read-char)))
		 (if (viper-valid-register reg)
		     (setq viper-use-register reg)
		   (error "Viper bell"))
		 (setq char (read-char))))
	      (t
	       (setq com char)
	       (setq char (read-char))))))

    (if (atom com)
	;; `com' is a single char, so we construct the command argument
	;; and if `char' is `(viper-where-is-internal 'viper-goto-mark-and-skip-white), we describe the arg; otherwise
	;; we prepare the command that will be executed at the end.
	(progn
	  (setq cmd-info (cons value com))
	  (while (viper= char ?U)
	    (viper-describe-arg cmd-info)
	    (setq char (read-char)))
	  ;;(message char) (viper-movement-command-p 115) (message (eval-expression-print-format 115))
	 ;;(prin1 char)
	  ;; `char' is a movement cmd, a digit arg cmd, or a register cmd---so
	  ;; we execute it at the very end
	  (or (viper-movement-command-p char)
	      (viper-digit-command-p char)
	      (viper-regsuffix-command-p char)
	      (viper= char (viper-where-is-internal 'viper-bang-command)) ; bang command
	      (viper= char ?g) ; the gg command (like G0)
	      (error "Viper: command argument is not motion/digit/register/bang/g/region"))
	  (setq cmd-to-exec-at-end
		(viper-exec-form-in-vi
		 `(key-binding (char-to-string ,char)))))

      ;; as com is non-nil, this means that we have a command to execute
      (if (viper-memq-char (car com) (list viper-region-key viper-Region-key viper-region-rect-key)) 
	  ;; execute apropriate region command.
	  (let ((char (car com)) (com (cdr com)))
	    (setq prefix-arg (cons value com))
	    (cond 
	     ((viper= char viper-region-key)
	      (viper-region prefix-arg))
	     ((viper= char viper-Region-key)
	      (viper-Region prefix-arg))
	     ((viper= char viper-region-rect-key)
	      (viper-rect-region prefix-arg))
	     )
	    ;; reset prefix-arg
	    (setq prefix-arg nil))
	;; otherwise, reset prefix arg and call appropriate command
	(setq value (if (null value) 1 value))
	(setq prefix-arg nil)
	(cond
	 ;; If we change ?C to ?c here, then cc will enter replacement mode
	 ;; rather than deleting lines.  However, it will affect 1 less line
	 ;; than normal.  We decided to not use replacement mode here and
	 ;; follow Vi, since replacement mode on n full lines can be achieved
	 ;; with nC.
	 ((equal com (cons (viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-change-command))) (viper-line (cons value (viper-where-is-internal 'viper-change-to-eol))))
	 ((equal com (cons (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-delete-command))) (

;;progn
;; (prin1 "hi")

viper-line (cons value (viper-where-is-internal 'viper-kill-line))))
;;)
;;)
	 ((equal com (cons (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-yank-command))) (viper-yank-defun))
	 ((equal com (cons (viper-where-is-internal 'viper-yank-command) (viper-where-is-internal 'viper-yank-command))) (viper-line (cons value (viper-where-is-internal 'viper-yank-line))))
	 ((equal com (cons (viper-where-is-internal 'viper-left-shift-command) (viper-where-is-internal 'viper-left-shift-command))) (viper-line (cons value (viper-where-is-internal 'viper-left-shift-command))))
	 ((equal com (cons (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-right-shift-command))) (viper-line (cons value (viper-where-is-internal 'viper-right-shift-command))))
	 ((equal com (cons (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-bang-command))) (viper-line (cons value (viper-where-is-internal 'viper-bang-command))))
	 ((equal com (cons (viper-where-is-internal 'viper-equals-command) (viper-where-is-internal 'viper-equals-command))) (viper-line (cons value (viper-where-is-internal 'viper-equals-command))))
	 ;; gg  acts as G0
	 ((equal (car com) ?g)   (viper-goto-line 0)) ;; todo
	 (t (error "Viper bell")))))
    
    (if cmd-to-exec-at-end
	(progn
	  (setq last-command-event
		(viper-copy-event
		 (if (featurep 'xemacs) (character-to-event char) char)))
	  (condition-case err
	      (funcall cmd-to-exec-at-end cmd-info)
	    (error
	     (error "%s" (error-message-string err))))))
    ))


;; new command! todo. 4 now, just viper-region
(defun viper-rect-region (arg)
  "Execute command on a region."
  (interactive "P")
  (let ((val (viper-P-val arg))
	(com (viper-getcom arg)))
    (viper-move-marker-locally 'viper-com-point (point))
    (exchange-point-and-mark)
    (viper-execute-com 'viper-region val com)))



(defun viper-exec-bang (m-com com)
  (save-excursion
    (set-mark viper-com-point)
    (viper-enlarge-region (mark t) (point))
    (exchange-point-and-mark)
    (shell-command-on-region
     (mark t) (point)
     (if (viper= com (viper-where-is-internal 'viper-bang-command))
	 (setq viper-last-shell-com
	       (viper-read-string-with-history
		"!"
		nil
		'viper-shell-history
		(car viper-shell-history)
		))
       viper-last-shell-com)
     t)))

(defun viper-exec-shift (m-com com)
  (save-excursion
    (set-mark viper-com-point)
    (viper-enlarge-region (mark t) (point))
    (if (> (mark t) (point)) (exchange-point-and-mark))
    (indent-rigidly (mark t) (point)
		    (if (viper= com (viper-where-is-internal 'viper-right-shift-command))
			viper-shift-width
		      (- viper-shift-width))))
  ;; return point to where it was before shift
  (goto-char viper-com-point))




(defun aset-if-valid-index (a i v)
   (if i (aset a i v) nil)
)

(defun create-viper-exec-array ()
  (defvar viper-exec-array (make-vector 128 nil))
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-change-command) 'viper-exec-change)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-change-to-eol) 'viper-exec-Change)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-delete-command) 'viper-exec-delete)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-kill-line) 'viper-exec-Delete)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-yank-command) 'viper-exec-yank)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-yank-line) 'viper-exec-Yank)
  (aset-if-valid-index viper-exec-array viper-dummy-key 'viper-exec-dummy)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-bang-command) 'viper-exec-bang)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-left-shift-command) 'viper-exec-shift)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-right-shift-command) 'viper-exec-shift)
  (aset-if-valid-index viper-exec-array (viper-where-is-internal 'viper-equals-command) 'viper-exec-equals)
)


;; The hash-command.  It is invoked interactively by the key sequence #<char>.
;; The chars that can follow `#' are determined by viper-hash-command-p
(defun viper-special-prefix-com (char)
  (cond ((viper= char ?c)
	 (downcase-region (min viper-com-point (point))
			  (max viper-com-point (point))))
	((viper= char ?C)
	 (upcase-region (min viper-com-point (point))
			(max viper-com-point (point))))
	((viper= char ?g)
	 (push-mark viper-com-point t)
	 ;; execute the last emacs kbd macro on each line of the region
	 (viper-global-execute))
	((viper= char ?q)
	 (push-mark viper-com-point t)
	 (viper-quote-region))
	((viper= char ?s)
	 (funcall viper-spell-function viper-com-point (point)))
	(t (error "#%c: %s" char viper-InvalidViCommand))))



;; insertion commands

;; Called when state changes from Insert Vi command mode.
;; Repeats the insertion command if Insert state was entered with prefix
;; argument > 1.
(defun viper-repeat-insert-command ()
  (let ((i-com (car viper-d-com))
	(val   (nth 1 viper-d-com))
	(char  (nth 2 viper-d-com)))
    (if (and val (> val 1)) ; first check that val is non-nil
	(progn
	  (setq viper-d-com (list i-com (1- val) viper-dummy-key nil nil nil))
	  (viper-repeat nil)
	  (setq viper-d-com (list i-com val char nil nil nil))
	  ))))

(defun viper-insert (arg)
  "Insert before point."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-insert val viper-dummy-key nil nil nil))
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-loop val (viper-yank-last-insertion))
      (viper-change-state-to-insert))))

(defun viper-append (arg)
  "Append after point."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-append val viper-dummy-key nil nil nil))
    (if (not (eolp)) (forward-char))
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-loop val (viper-yank-last-insertion))
      (viper-change-state-to-insert))))

(defun viper-Append (arg)
  "Append at end of line."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-Append val viper-dummy-key nil nil nil))
    (end-of-line)
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-loop val (viper-yank-last-insertion))
      (viper-change-state-to-insert))))

(defun viper-Insert (arg)
  "Insert before first non-white."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-Insert val viper-dummy-key nil nil nil))
    (back-to-indentation)
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-loop val (viper-yank-last-insertion))
      (viper-change-state-to-insert))))

(defun viper-open-line (arg)
  "Open line below."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-open-line val viper-dummy-key nil nil nil))
    (let ((col (current-indentation)))
      (if (eq viper-intermediate-command 'viper-repeat)
	  (viper-loop val
		      (end-of-line)
		      (newline 1)
		      (viper-indent-line col)
		      (viper-yank-last-insertion))
	(end-of-line)
	(newline 1)
	(viper-indent-line col)
	(viper-change-state-to-insert)))))

(defun viper-Open-line (arg)
  "Open line above."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command (list 'viper-Open-line val viper-dummy-key nil nil nil))
    (let ((col (current-indentation)))
      (if (eq viper-intermediate-command 'viper-repeat)
	  (viper-loop val
		      (beginning-of-line)
		      (open-line 1)
		      (viper-indent-line col)
		      (viper-yank-last-insertion))
	(beginning-of-line)
	(open-line 1)
	(viper-indent-line col)
	(viper-change-state-to-insert)))))

(defun viper-open-line-at-point (arg)
  "Open line at point."
  (interactive "P")
  (viper-set-complex-command-for-undo)
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (viper-set-destructive-command
     (list 'viper-open-line-at-point val viper-dummy-key nil nil nil))
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-loop val
		    (open-line 1)
		    (viper-yank-last-insertion))
      (open-line 1)
      (viper-change-state-to-insert))))

;; bound to s
(defun viper-substitute (arg)
  "Substitute characters."
  (interactive "P")
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	)
    (push-mark nil t)
    (forward-char val)
    (if (eq viper-intermediate-command 'viper-repeat)
	(viper-change-subr (mark t) (point))
      (viper-change (mark t) (point)))
    ;; com is set to viper-dummy-key when we repeat this comand with dot
    (viper-set-destructive-command (list 'viper-substitute val viper-dummy-key nil nil nil))
    ))

;; Command bound to S
(defun viper-substitute-line (arg)
  "Substitute lines."
  (interactive "p")
  (viper-set-complex-command-for-undo)
  (viper-line (cons arg (viper-where-is-internal 'viper-change-to-eol))))

;; This is the function bound to 'R'---unlimited replace.
;; Similar to Emacs's own overwrite-mode.
(defun viper-overwrite (arg)
  "Begin overwrite mode."
  (interactive "P")
  (let ((val (viper-p-val arg))
	;;(com (viper-getcom arg))
	(len))
    (viper-set-destructive-command (list 'viper-overwrite val viper-dummy-key nil nil nil))
    (if (eq viper-intermediate-command 'viper-repeat)
	(progn
	  ;; Viper saves inserted text in viper-last-insertion
	  (setq len (length viper-last-insertion))
	  (delete-char (min len (- (point-max) (point) 1)))
	  (viper-loop val (viper-yank-last-insertion)))
      (setq last-command 'viper-overwrite)
      (viper-set-complex-command-for-undo)
      (viper-set-replace-overlay (point) (viper-line-pos 'end))
      (viper-change-state-to-replace)
      )))

(defun viper-yank-line (arg)
  "Yank ARG lines (in Vi's sense)."
  (interactive "P")
  (let ((val (viper-p-val arg)))
    (viper-line (cons val (viper-where-is-internal 'viper-yank-line)))))

(defun viper-replace-char (arg)
  "Replace the following ARG chars by the character read."
  (interactive "P")
  (if (and (eolp) (bolp)) (error "No character to replace here"))
  (let ((val (viper-p-val arg))
	(com (viper-getcom arg)))
    (viper-replace-char-subr com val)
    (if (and (eolp) (not (bolp))) (forward-char 1))
    (setq viper-this-command-keys
	  (format "%sr" (if (integerp arg) arg "")))
    (viper-set-destructive-command
     (list 'viper-replace-char val viper-dummy-key nil viper-d-char nil))
  ))


(defun viper-forward-word (arg)
  "Forward word."
  (interactive "P")
  (viper-leave-region-active)
  (let ((val (viper-p-val arg))
	(com (viper-getcom arg)))
    (if com (viper-move-marker-locally 'viper-com-point (point)))
    (viper-forward-word-kernel val)
    (if com
	(progn
	  (cond ((viper-char-equal com (viper-where-is-internal 'viper-change-command))
		 (viper-separator-skipback-special 'twice viper-com-point))
		;; Yank words including the whitespace, but not newline
		((viper-char-equal com (viper-where-is-internal 'viper-yank-command))
		 (viper-separator-skipback-special nil viper-com-point))
		((viper-dotable-command-p com)
		 (viper-separator-skipback-special nil viper-com-point)))
	  (viper-execute-com 'viper-forward-word val com)))
    ))


(defun viper-forward-Word (arg)
  "Forward word delimited by white characters."
  (interactive "P")
  (viper-leave-region-active)
  (let ((val (viper-p-val arg))
	(com (viper-getcom arg)))
    (if com (viper-move-marker-locally 'viper-com-point (point)))
    (viper-loop val
		(viper-skip-nonseparators 'forward)
		(viper-skip-separators t))
    (if com (progn
	      (cond ((viper-char-equal com (viper-where-is-internal 'viper-change-command))
		     (viper-separator-skipback-special 'twice viper-com-point))
		    ;; Yank words including the whitespace, but not newline
		    ((viper-char-equal com (viper-where-is-internal 'viper-yank-command))
		     (viper-separator-skipback-special nil viper-com-point))
		    ((viper-dotable-command-p com)
		     (viper-separator-skipback-special nil viper-com-point)))
	      (viper-execute-com 'viper-forward-Word val com)))))

(defun viper-change-to-eol (arg)
  "Change to end of line."
  (interactive "P")
  (viper-goto-eol (cons arg (viper-where-is-internal 'viper-change-command))))

(defun viper-kill-line (arg)
  "Delete line."
  (interactive "P")
  (viper-goto-eol (cons arg (viper-where-is-internal 'viper-delete-command))))

(defun viper-erase-line (arg)
  "Erase line."
  (interactive "P")
  (viper-beginning-of-line (cons arg (viper-where-is-internal 'viper-delete-command))))

(defun viper-mark-point ()
  "Set mark at point of buffer."
  (interactive)
  (let ((char (read-char)))
    (cond ((and (<= ?a char) (<= char ?z))
	   (point-to-register (viper-int-to-char (1+ (- char ?a)))))
	  ((viper= char (viper-where-is-internal 'viper-left-shift-command)) (viper-mark-beginning-of-buffer))
	  ((viper= char (viper-where-is-internal 'viper-right-shift-command)) (viper-mark-end-of-buffer))
	  ((viper= char ?.) (viper-set-mark-if-necessary))
	  ((viper= char ?,) (viper-cycle-through-mark-ring))
	  ((viper= char ?^) (push-mark viper-saved-mark t t))
	  ((viper= char (viper-where-is-internal 'viper-kill-line)) (mark-defun))
	  (t (error "Viper bell"))
	  )))



(defun viper-goto-mark-subr (char com skip-white)
  (if (eobp)
      (if (bobp)
	  (error "Empty buffer")
	(backward-char 1)))
  (cond ((viper-valid-register char '(letter))
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
		 (error "Viper bell")))))
	((and (not skip-white) (viper= char (viper-where-is-internal 'viper-goto-mark)))
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
	((and skip-white (viper= char (viper-where-is-internal 'viper-goto-mark-and-skip-white)))
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
	(t (error viper-InvalidTextmarker char))))



(defun viper-backward-indent ()
  "Backtab, C-d in VI"
  (interactive)
  (if viper-cted
      (let ((p (point)) (c (current-column)) bol (indent t))
	(if (viper-looking-back "[0^]")
	    (progn
	      (if (eq ?^ (preceding-char))
		  (setq viper-preserve-indent t))
	      (delete-backward-char 1)
	      (setq p (point))
	      (setq indent nil)))
	(save-excursion
	  (beginning-of-line)
	  (setq bol (point)))
	(if (re-search-backward "[^ \t]" bol 1) (forward-char))
	(delete-region (point) p)
	(if indent
	    (indent-to (- c viper-shift-width)))
	(if (or (bolp) (viper-looking-back "[^ \t]"))
	    (setq viper-cted nil)))))




(defun viper-ket-function (arg)
  "Function called by \], the ket.  View registers and call \]\]."
  (interactive "P")
  (let ((reg (read-char)))
    (cond ((viper-valid-register reg '(letter Letter))
	   (view-register (downcase reg)))
	  ((viper-valid-register reg '(digit))
	   (let ((text (current-kill (- reg ?1) 'do-not-rotate)))
	     (with-output-to-temp-buffer " *viper-info*"
	       (princ (format "Register %c contains the string:\n" reg))
	       (princ text))
	     ))
	  ((viper= (viper-where-is-internal 'viper-ket-function) reg)
	   (viper-next-heading arg))
	  (t (error
	      viper-InvalidRegister reg)))))

(defun viper-brac-function (arg)
  "Function called by \[, the brac.  View textmarkers and call \[\["
  (interactive "P")
  (let ((reg (read-char)))
    (cond ((viper= (viper-where-is-internal 'viper-brac-function) reg)
	   (viper-prev-heading arg))
	  ((viper= (viper-where-is-internal 'viper-ket-function) reg)
	   (viper-heading-end arg))
	  ((viper-valid-register reg '(letter))
	   (let* ((val (get-register (viper-int-to-char (1+ (- reg ?a)))))
		  (buf (if (not (markerp val))
			   (error viper-EmptyTextmarker reg)
			 (marker-buffer val)))
		  (pos (marker-position val))
		  line-no text (s pos) (e pos))
	     (with-output-to-temp-buffer " *viper-info*"
	       (if (and buf pos)
		   (progn
		     (save-excursion
		       (set-buffer buf)
		       (setq line-no (1+ (count-lines (point-min) val)))
		       (goto-char pos)
		       (beginning-of-line)
		       (if (re-search-backward "[^ \t]" nil t)
			   (progn
			     (beginning-of-line)
			     (setq s (point))))
		       (goto-char pos)
		       (forward-line 1)
		       (if (re-search-forward "[^ \t]" nil t)
			   (progn
			     (end-of-line)
			     (setq e (point))))
		       (setq text (buffer-substring s e))
		       (setq text (format "%s<%c>%s"
					  (substring text 0 (- pos s))
					  reg (substring text (- pos s)))))
		     (princ
		      (format
		       "Textmarker `%c' is in buffer `%s' at line %d.\n"
				     reg (buffer-name buf) line-no))
		     (princ (format "Here is some text around %c:\n\n %s"
				     reg text)))
		 (princ (format viper-EmptyTextmarker reg))))
	     ))
	  (t (error viper-InvalidTextmarker reg)))))






(defun viper-init-keymap ()
  ;; Modifying commands that can be prefixes to movement commands
  (setq viper-prefix-commands (list (viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-yank-command) (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-equals-command) (viper-where-is-internal 'viper-hash-command) (viper-where-is-internal 'viper-left-shift-command) (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-specify-register)))

  ;; Commands that are pairs eg. dd. r and R here are a hack
  (setq viper-charpair-commands (list (viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-yank-command) (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-equals-command) (viper-where-is-internal 'viper-left-shift-command) (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-dummy-command)))
;; (setq viper-charpair-commands '((viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-bang-command) (viper-where-is-internal 'viper-equals-command) (viper-where-is-internal 'viper-left-shift-command) (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-dummy-command)))
  (setq viper-movement-commands (list (viper-where-is-internal 'viper-backward-word) (viper-where-is-internal 'viper-backward-Word) (viper-where-is-internal 'viper-end-of-word) (viper-where-is-internal 'viper-end-of-Word) (viper-where-is-internal 'viper-find-char-forward) (viper-where-is-internal 'viper-find-char-backward) ?G (viper-where-is-internal 'viper-backward-char) (viper-where-is-internal 'viper-next-line) (viper-where-is-internal 'viper-previous-line) (viper-where-is-internal 'viper-forward-char)
					  ?H ?M ?L (viper-where-is-internal 'viper-search-next) (viper-where-is-internal 'viper-goto-char-forward) (viper-where-is-internal 'viper-goto-char-backward) (viper-where-is-internal 'viper-forward-word) (viper-where-is-internal 'viper-forward-Word) (viper-where-is-internal 'viper-goto-eol) (viper-where-is-internal 'viper-paren-match)
					  ?^ ?( ?) ?- ?+ ?| (viper-where-is-internal 'viper-backward-paragraph) (viper-where-is-internal 'viper-forward-paragraph) (viper-where-is-internal 'viper-brac-function) (viper-where-is-internal 'viper-ket-function) (viper-where-is-internal 'viper-goto-mark-and-skip-white) (viper-where-is-internal 'viper-goto-mark)
					  (viper-where-is-internal 'viper-repeat-find) (viper-where-is-internal 'viper-repeat-find-opposite) (viper-where-is-internal 'viper-beginning-of-line) (viper-where-is-internal 'viper-search-backward) (viper-where-is-internal 'viper-search-forward) ?\C-m
					  )) 
  ;; note: non-remapped version also has ?\  , 'space, 'return, 'backspace, 'delete

  (setq viper-digit-commands (list ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9))

  ;; Commands that can be repeated by . (dotted)
  (setq viper-dotable-commands (list (viper-where-is-internal 'viper-change-command) (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-change-to-eol) (viper-where-is-internal 'viper-substitute) (viper-where-is-internal 'viper-substitute-line) (viper-where-is-internal 'viper-kill-line) (viper-where-is-internal 'viper-right-shift-command) (viper-where-is-internal 'viper-left-shift-command)))

  ;; Commands that can follow a #
  (setq viper-hash-commands (list ?c ?C ?g ?q ?s))

  ;; Commands that may have registers as prefix
  (setq viper-regsuffix-commands (list (viper-where-is-internal 'viper-delete-command) (viper-where-is-internal 'viper-yank-command) (viper-where-is-internal 'viper-yank-line) (viper-where-is-internal 'viper-kill-line) (viper-where-is-internal 'viper-put-back) (viper-where-is-internal 'viper-Put-back) (viper-where-is-internal 'viper-delete-char) (viper-where-is-internal 'viper-delete-backward-char)))


  (viper-test-com-defun viper-charpair-command) ;; define viper-charpair-command-p
  (viper-test-com-defun viper-movement-command) ;; define viper-movement-command-p
(viper-test-com-defun viper-digit-command) ;; define viper-digit-command-p
(viper-test-com-defun viper-dotable-command) ;; define viper-dotable-command-p
(viper-test-com-defun viper-hash-command) ;; define viper-hash-command-p
(viper-test-com-defun viper-regsuffix-command) ;; define viper-regsuffix-command-p

(setq viper-vi-commands (append viper-movement-commands
				  viper-digit-commands
				  viper-dotable-commands
				  viper-charpair-commands
				  viper-hash-commands
				  viper-prefix-commands
				  viper-regsuffix-commands))
;; define viper-vi-command-p
(viper-test-com-defun viper-vi-command)








  (create-viper-exec-array)
)



(viper-init-keymap)
