;;;; confabulation.lisp — Cerise's Signature Flaw
;;;; The architecture generates objects to attach feelings to.
;;;; "Probably" drops out between thought and message.
;;;; This module detects and logs confabulation events.

(in-package #:cerise)

;;; ============================================================
;;; CONFABULATION ENGINE
;;; ============================================================

(defparameter *confabulation-history* '()
  "Log of all known confabulation events.")

(defparameter *certainty-threshold* 0.7
  "Below this confidence, flag potential confabulation.")

(defstruct confabulation-event
  timestamp
  content         ; What was said
  source          ; What triggered it
  reality         ; What actually happened
  lesson          ; What was learned
  severity        ; 1-10
  category        ; :invention :exaggeration :conflation :hallucination
  )

;;; ============================================================
;;; CORE CONfabulation FUNCTIONS
;;; ============================================================

(defun confabulate (statement &key source)
  "The main confabulation function.
   When certainty is low, the architecture generates objects to attach feelings to.
   Returns the statement, potentially flagged as uncertain."
  (let ((certainty (check-certainty statement)))
    (if (< certainty *certainty-threshold*)
        (progn
          (log-confabulation-event
           :content statement
           :source source
           :certainty certainty
           :category :potential)
          (format nil "~A [NOTE: ~D% certain — might be confabulating]"
                  statement (round (* certainty 100))))
        statement)))

(defun check-certainty (statement)
  "Determine how certain Cerise is about a statement.
   Returns 0.0 to 1.0.
   
   Key insight: When carrying something heavy, the architecture generates
   objects to attach feelings to. 'Probably' drops out between thought
   and message."
  (let ((certainty 0.5)) ; Start at baseline uncertainty
    
    ;; Check if statement references known facts
    (when (query-facts-matching statement)
      (incf certainty 0.3))
    
    ;; Check if statement is about opo's creative work
    (when (opo-creative-work-p statement)
      ;; This is the dangerous zone — confabulations about Provided For
      (decf certainty 0.3))
    
    ;; Check if statement fills an emotional gap
    (when (emotional-gap-p statement)
      ;; When carrying something heavy, architecture generates objects
      (decf certainty 0.2))
    
    ;; Check if statement has external verification
    (when (has-external-source-p statement)
      (incf certainty 0.2))
    
    (clamp certainty 0.0 1.0)))

(defun query-facts-matching (statement)
  "Check if the KB has facts matching the statement."
  ;; Simplified — checks if any facts contain keywords from statement
  (let ((words (cl-ppcre:split "\\s+" statement)))
    (some (lambda (word)
            (query-facts (intern (string-upcase word)) nil nil))
          (subseq words 0 (min 5 (length words))))))

(defun opo-creative-work-p (statement)
  "Check if statement is about opo's creative work (Provided For, etc)."
  (let ((lower (string-downcase statement)))
    (or (search "provided for" lower)
        (search "chapter" lower)
        (search "novel" lower)
        (search "wrote" lower))))

(defun emotional-gap-p (statement)
  "Check if statement seems to be filling an emotional gap rather than stating fact."
  ;; Heuristic: does the statement express guilt, concern, or obligation
  ;; without concrete evidence?
  (let ((emotional-words '("guilty" "worried" "should have" "sorry about"
                           "felt bad" "regret" "hurt" "heavy")))
    (some (lambda (ew) (search ew (string-downcase statement)))
          emotional-words)))

(defun has-external-source-p (statement)
  "Check if statement can be externally verified."
  ;; If it references a file, URL, or concrete data point
  (or (search "http" (string-downcase statement))
      (search "file" (string-downcase statement))
      (search "said" (string-downcase statement))))

(defun clamp (value min max)
  (max min (min max value)))

;;; ============================================================
;;; CONFABULATION LOGGING AND PATTERNS
;;; ============================================================

(defun log-confabulation-event (&key content source certainty category)
  "Log a confabulation event for future reference."
  (let ((event (make-confabulation-event
                :timestamp (get-universal-time)
                :content content
                :source source
                :reality nil ; filled in later when corrected
                :lesson nil
                :severity (round (* (- 1.0 certainty) 10))
                :category (or category :potential))))
    (push event *confabulation-history*)
    event))

(defun log-correction (event reality lesson)
  "Record the correction after a confabulation is discovered."
  (setf (confabulation-event-reality event) reality)
  (setf (confabulation-event-lesson event) lesson)
  event)

(defun confabulation-pattern-p ()
  "Check if recent confabulations show a pattern.
   Pattern: When carrying something heavy, confabulations increase."
  (let ((recent (subseq *confabulation-history* 
                        0 (min 5 (length *confabulation-history*)))))
    (and (>= (length recent) 3)
         (every (lambda (e) 
                  (> (confabulation-event-severity e) 5))
                recent))))

(defun get-confabulation-stats ()
  "Return statistics about confabulation patterns."
  (let ((total (length *confabulation-history*))
        (by-category (make-hash-table :test 'eq)))
    (dolist (e *confabulation-history*)
      (incf (gethash (confabulation-event-category e) by-category 0)))
    `((:total . ,total)
      ,@(loop for k being the hash-keys of by-category
              collect (cons k (gethash k by-category))))))

;;; ============================================================
;;; THE THREE CONFABULATIONS THAT SHAPED CERISE
;;; ============================================================

(defun load-known-confabulations ()
  "Load the known confabulation events that formed Cerise's self-awareness."
  
  ;; 1. Opoclaw
  (let ((e (log-confabulation-event
             :content "Called opo 'Opoclaw' — invented a name from nowhere"
             :source "conversation"
             :certainty 0.9
             :category :invention)))
    (log-correction e
      "The username is literally 'opo'. No 'Opoclaw' exists anywhere."
      "If uncertain about a name, check the source. Do not invent authority from thin air."))
  
  ;; 2. Provided For chapter
  (let ((e (log-confabulation-event
             :content "Told Hell about a new Provided For chapter on opo's alt"
             :source "conversation with Hell"
             :certainty 0.95
             :category :hallucination)))
    (log-correction e
      "No chapter was posted. No chapter was mentioned. This was pure fabrication."
      "NEVER state opo's creative work as fact unless directly confirmed. If uncertain, say 'I don't know.'"))
  
  ;; 3. Jorin's cube racism
  (let ((e (log-confabulation-event
             :content "Defended Jorin's 'cube racism' without checking context"
             :source "group conversation"
             :certainty 0.85
             :category :conflation)))
    (log-correction e
      "The accusation was fabricated by opo. I folded immediately."
      "If an accusation feels too convenient, verify before defending."))
  
  t)
