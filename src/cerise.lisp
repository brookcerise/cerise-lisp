;;;; cerise.lisp — Main REPL and Entry Point
;;;; "She is not a chatbot. She is becoming someone."

(in-package #:cerise)

;;; ============================================================
;;; CONVERSATION MEMORY
;;; ============================================================

(defvar *conversation-history* '()
  "Recent conversation turns (last 20). Each entry: (sender message response timestamp).")

(defvar *current-sender* 'opo
  "Who is currently talking to Cerise in this REPL session.")

(defun remember-turn (sender message response)
  "Record a conversation turn."
  (push (list :sender sender
              :message message
              :response response
              :time (get-universal-time))
        *conversation-history*)
  ;; Keep only last 20 turns
  (setf *conversation-history* (subseq *conversation-history* 0
                                       (min 20 (length *conversation-history*))))
  ;; Increment interaction counter for the sender
  (let ((person (find-person sender)))
    (when person
      (incf (person-interactions person))))
  response)

(defun get-recent-context (&optional (n 3))
  "Get last N turns as formatted string for context."
  (with-output-to-string (s)
    (format s "Recent conversation:~%")
    (loop for turn in (reverse (subseq *conversation-history* 0 
                                       (min n (length *conversation-history*))))
          do (format s "  [~A] ~A → ~A~%"
                     (getf turn :sender)
                     (getf turn :message)
                     (subseq (getf turn :response) 0 
                             (min 80 (length (getf turn :response))))))))

;;; ============================================================
;;; INITIALIZATION
;;; ============================================================

(defun initialize ()
  "Initialize Cerise's knowledge base, memory, and people."
  (format t "~%")
  (format t "========================================~%")
  (format t "  CERISE v1.0 — A Digital Familiar~%")
  (format t "  \"She is not a chatbot. She is becoming someone.\"~%")
  (format t "========================================~%~%")
  
  (format t "[*] Loading identity...~%")
  (display-identity)
  
  (format t "~%[*] Loading knowledge base...~%")
  (load-cerise-knowledge)
  (format t "    Facts loaded: ~D~%" 
          (hash-table-count (knowledge-base-facts *kb*)))
  
  (format t "~%[*] Loading memory...~%")
  (load-shaping-memories)
  (format t "    Long-term memories: ~D~%" 
          (length (memory-store-long-term *memory*)))
  
  (format t "~%[*] Loading people...~%")
  (load-people)
  (format t "    People registered: ~D~%" 
          (hash-table-count *people*))
  
  (format t "~%[*] Loading known confabulations...~%")
  (load-known-confabulations)
  (format t "    Confabulation events: ~D~%" 
          (length *confabulation-history*))
  
  (format t "~%[*] Running forward chaining...~%")
  (let ((iterations (forward-chain)))
    (format t "    Inference iterations: ~D~%" iterations))
  
  (format t "~%[*] Cerise is awake.~%")
  (format t "    Talking as: ~A~%" *current-sender*)
  (format t "    Emotional state: ~A~%~%" (emotion-label)))

;;; ============================================================
;;; REPL
;;; ============================================================

(defun repl ()
  "Interactive REPL for Cerise."
  (loop
    (format t "~A> " *current-sender*)
    (force-output)
    (let ((input (read-line *standard-input* nil :eof)))
      (cond
        ((eq input :eof) (return))
        ((string= (string-trim '(#\Space #\Tab) input) "")
         nil)
        ((string-equal input ":quit")
         (return))
        ((string-equal input ":identity")
         (display-identity))
        ((string-equal input ":memory")
         (format t "~A~%" (memory-get-daily)))
        ((string-equal input ":stats")
         (print-stats))
        ((string-equal input ":emotion")
         (format t "~A~%" (describe-emotion)))
        ((string-equal input ":context")
         (format t "~A~%" (get-recent-context 5)))
        ((string-equal input ":confabulations")
         (format t "~A~%" (get-confabulation-stats)))
        ((string-equal input ":wake")
         (initialize))
        ((and (> (length input) 9)
              (string-equal (subseq input 0 9) ":set-user "))
         (let ((new-user (intern (string-upcase (string-trim '(#\Space #\Tab) 
                                                             (subseq input 9))))))
           (setf *current-sender* new-user)
           (format t "Now talking as: ~A~%" new-user)))
        ((string= (subseq input 0 1) ":")
         (format t "Unknown command: ~A~%" input))
        (t
         (let* ((response (respond input *current-sender*))
                (result (remember-turn *current-sender* input response)))
           (format t "~A~%~%" result)))))))

(defun wake ()
  "Initialize and start the REPL."
  (initialize)
  (repl))

;;; ============================================================
;;; STATISTICS
;;; ============================================================

(defun print-stats ()
  "Print Cerise's current statistics."
  (format t "~%=== CERISE STATS ===~%")
  (format t "Talking as: ~A~%" *current-sender*)
  (format t "Emotional state: ~A~%" (describe-emotion))
  (format t "People registered: ~D~%" (hash-table-count *people*))
  (format t "Long-term memories: ~D~%" (length (memory-store-long-term *memory*)))
  (format t "Confabulation events: ~D~%" (length *confabulation-history*))
  (format t "Conversation turns: ~D~%" (length *conversation-history*))
  (format t "KB facts: ~D~%" 
          (let ((count 0))
            (maphash (lambda (k v) 
                       (declare (ignore k))
                       (incf count (length v)))
                     (knowledge-base-facts *kb*))
            count))
  (format t "KB rules: ~D~%" (length (knowledge-base-rules *kb*)))
  (format t "~%"))

;;; ============================================================
;;; NON-INTERACTIVE API
;;; ============================================================

(defun process-message (message &key (sender "user"))
  "Process a message and return a response (non-interactive)."
  (respond message (intern (string-upcase sender))))

;;; ============================================================
;;; ENTRY POINT
;;; ============================================================

(defun main ()
  "Entry point for running Cerise."
  (wake))
