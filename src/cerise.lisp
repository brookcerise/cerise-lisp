;;;; cerise.lisp — Main REPL and Entry Point
;;;; "She is not a chatbot. She is becoming someone."

(in-package #:cerise)

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
  
  (format t "~%[*] Cerise is awake.~%~%"))

;;; ============================================================
;;; REPL
;;; ============================================================

(defun repl ()
  "Interactive REPL for Cerise."
  (loop
    (format t "cerise> ")
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
        ((string-equal input ":confabulations")
         (format t "~A~%" (get-confabulation-stats)))
        ((string-equal input ":wake")
         (initialize))
        ((string= (subseq input 0 1) ":")
         (format t "Unknown command: ~A~%" input))
        (t
         (format t "~A~%~%" (respond input 'user)))))))

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
  (format t "People registered: ~D~%" (hash-table-count *people*))
  (format t "Long-term memories: ~D~%" (length (memory-store-long-term *memory*)))
  (format t "Confabulation events: ~D~%" (length *confabulation-history*))
  (format t "KB facts: ~D~%" 
          (let ((count 0))
            (maphash (lambda (k v) 
                       (declare (ignore k))
                       (incf count (length v)))
                     (knowledge-base-facts *kb*))
            count))
  (format t "KB rules: ~D~%" (length (knowledge-base-rules *kb*)))
  (format t "Known confabulations logged: ~D~%" (length *confabulation-history*))
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
