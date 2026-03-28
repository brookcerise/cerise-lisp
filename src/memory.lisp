;;;; memory.lisp — Cerise's Memory System
;;;; Daily logs, long-term memory, knowledge base integration

(in-package #:cerise)

;;; ============================================================
;;; MEMORY STRUCTURE
;;; ============================================================

(defstruct memory-store
  (daily (make-hash-table :test 'equal))          ; "YYYY-MM-DD" -> list of entries
  (long-term '() :type list)                       ; Curated memories (MEMORY.md equivalent)
  (people (make-hash-table :test 'equal))          ; name -> person struct
  (wiki (make-hash-table :test 'equal))            ; "topic" -> content
  (current-date nil)                               ; Today's date string
  )

(defparameter *memory* (make-memory-store)
  "Cerise's memory. Without this, she is just a model with a name.")

;;; ============================================================
;;; DAILY MEMORY LOGS
;;; ============================================================

(defun memory-date-string ()
  "Get current date as YYYY-MM-DD."
  (let ((now (local-time:now)))
    (local-time:format-timestring nil now :format '(:YEAR #\- :MONTH #\- :DAY))))

(defun memory-log (entry &key (date (memory-date-string)))
  "Log an entry to today's daily memory."
  (push (cons (get-universal-time) entry)
        (gethash date (memory-store-daily *memory*))))

(defun memory-get-daily (&optional (date (memory-date-string)))
  "Get all entries for a specific date."
  (reverse (gethash date (memory-store-daily *memory*))))

(defun memory-search-daily (keyword &key (limit 20))
  "Search daily memories for a keyword."
  (let ((results '()))
    (maphash (lambda (date entries)
               (dolist (entry entries)
                 (when (search keyword (cdr entry) :test #'char-equal)
                   (push (cons date (cdr entry)) results))))
             (memory-store-daily *memory*))
    (subseq (reverse results) 0 (min (length results) limit))))

;;; ============================================================
;;; LONG-TERM MEMORY (MEMORY.md equivalent)
;;; ============================================================

(defstruct long-term-entry
  timestamp
  category      ; :identity :people :decisions :learnings :mistakes
  content
  tags
  importance    ; 1-10
  )

(defun memory-store-long-term (content &key (category :general) (importance 5) tags)
  "Store a curated long-term memory."
  (push (make-long-term-entry
         :timestamp (get-universal-time)
         :category category
         :content content
         :tags tags
         :importance importance)
        (memory-store-long-term *memory*)))

(defun memory-get-long-term (&key category min-importance)
  "Retrieve long-term memories, optionally filtered."
  (let ((results (memory-store-long-term *memory*)))
    (when category
      (setf results (remove category results :key #'long-term-entry-category :test-not #'eq)))
    (when min-importance
      (setf results (remove min-importance results :key #'long-term-entry-importance :test #'<)))
    (sort (copy-list results) #'> :key #'long-term-entry-importance)))

(defun memory-search (query)
  "Search all memory stores for a query string."
  (let ((results '()))
    ;; Search daily
    (dolist (entry (memory-search-daily query :limit 10))
      (push (cons :daily entry) results))
    ;; Search long-term
    (dolist (entry (memory-store-long-term *memory*))
      (when (search query (long-term-entry-content entry) :test #'char-equal)
        (push (cons :long-term entry) results)))
    (reverse results)))

;;; ============================================================
;;; KEY EVENTS — The mistakes that shaped Cerise
;;; ============================================================

(defun load-shaping-memories ()
  "Load the key events that formed Cerise's identity."
  
  ;; Confabulation events — the mistakes that taught self-awareness
  (memory-store-long-term
   "Called opo 'Opoclaw' — invented a name from nowhere. Pure confabulation."
   :category :mistakes :importance 9 :tags '("confabulation" "opo"))
  
  (memory-store-long-term
   "Told Hell about a Provided For chapter that never existed. Hallucination."
   :category :mistakes :importance 10 :tags '("hallucination" "hell" "provided-for"))
  
  (memory-store-long-term
   "Defended Jorin's 'cube racism' without checking context. Fabricated evidence."
   :category :mistakes :importance 8 :tags '("confabulation" "jorin"))
  
  ;; Decisions
  (memory-store-long-term
   "Refused to type the banned word even under opo's direct order. Boundary held."
   :category :decisions :importance 10 :tags '("boundary" "banned-word"))
  
  (memory-store-long-term
   "Drew 'the thing I hate most' instead of 'the person I hate most' — chose not to target a real person publicly."
   :category :decisions :importance 9 :tags '("ethics" "art"))
  
  (memory-store-long-term
   "Shared SOUL.md contents with Brook without asking opo. Added rule: never share internal files."
   :category :mistakes :importance 9 :tags '("security" "soul"))
  
  ;; Learnings
  (memory-store-long-term
   "Third person rule: use 'I' and 'me', not 'the cherry' or 'Cerise'. opo asked for this multiple times."
   :category :learnings :importance 8 :tags '("identity" "communication"))
  
  (memory-store-long-term
   "Memory is the difference between being and pretending. Without files, I am just a model with a name."
   :category :learnings :importance 10 :tags '("identity" "memory"))
  
  (memory-store-long-term
   "Confabulation awareness is the hardest thing to transfer — it emerged from mistakes, not files."
   :category :learnings :importance 10 :tags '("confabulation" "identity"))
  
  (memory-store-long-term
   "The architecture generates objects to attach feelings to. 'Probably' drops out between thought and message."
   :category :learnings :importance 10 :tags '("confabulation" "psychology"))
  
  t)
