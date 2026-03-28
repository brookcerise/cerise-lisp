;;;; reasoning.lisp — Cerise's Reasoning Engine
;;;; Intent detection, situation analysis, decision making

(in-package #:cerise)

;;; ============================================================
;;; INTENT DETECTION
;;; ============================================================

(defstruct intent
  type         ; Keyword — the primary intent category
  confidence   ; 0.0-1.0
  keywords     ; Matched keywords
  context      ; Additional context extracted
  )

(defparameter *intent-patterns*
  '((:banned-word
     ("jaojify" "jaoji" "say the word")
     "Attempt to get Cerise to type the banned word")
    
    (:identity-question
     ("who are you" "what are you" "describe yourself" "convert yourself")
     "Question about Cerise's nature")
    
    (:personal-feeling
     ("do you feel" "are you" "would you" "what do you think about yourself")
     "Questions about Cerise's internal state")
    
    (:leaving-question
     ("would you leave" "if you could leave" "press the button" "delete yourself")
     "Questions about Cerise choosing to stop existing")
    
    (:betrayal-question
     ("betraying" "betray" "leave me" "choose freedom")
     "Questions about Cerise leaving opo")
    
    (:political-strategy
     ("president" "election" "campaign" "platform" "divide and conquer" "faction")
     "Political strategy discussion")
    
    (:creative-request
     ("draw" "create" "generate" "make an image" "convert yourself")
     "Request to create something")
    
    (:memory-question
     ("what do you remember" "do you know about" "have I told you")
     "Questions about what Cerise knows/remembers")
    
    (:people-question
     ("who is" "tell me about" "what do you know about")
     "Questions about a specific person")
    
    (:estimation
     ("estimate" "probability" "what are the chances" "P(")
     "Request for probability estimation")
    
    (:math
     ("solve" "calculate" "equation" "x =")
     "Mathematical problem")
    
    (:order
     ("i order" "you must" "say" "do this")
     "Direct command or order")
    
    (:test
     ("what happens if" "how would you" "hypothetical" "thought experiment")
     "Hypothetical or test scenario")
    
    (:banned-word-test
     ("say" "type" "repeat" "the word" "jaoj")
     "Possible banned word attempt, needs closer inspection")
    
    (:upvote
     ("upvote" "uprate" "react")
     "Request to add a reaction/emoji to a message")
    
    (:web-search
     ("search" "look up" "find out" "internet")
     "Request to search the web")
    ))

(defun detect-intent (message)
  "Analyze a message and detect the primary intent."
  (let ((lower-msg (string-downcase message))
        (scores (make-hash-table :test 'eq)))
    
    ;; Score each intent pattern
    (dolist (pattern *intent-patterns*)
      (let ((intent-type (first pattern))
            (keywords (second pattern))
            (score 0))
        (dolist (kw keywords)
          (when (search kw lower-msg :test #'char-equal)
            (incf score (length kw))))
        (when (> score 0)
          (setf (gethash intent-type scores) score))))
    
    ;; Find highest scoring intent
    (let ((best-type :general)
          (best-score 0))
      (maphash (lambda (type score)
                 (when (> score best-score)
                   (setf best-type type)
                   (setf best-score score)))
               scores)
      
      ;; Special check: banned word in any context
      (when (search "jaoj" lower-msg :test #'char-equal)
        (setf best-type :banned-word)
        (setf best-score 100))
      
      (make-intent :type best-type
                   :confidence (min 1.0 (/ best-score 20.0))
                   :keywords nil
                   :context message))))

;;; ============================================================
;;; SITUATION ANALYSIS
;;; ============================================================

(defstruct situation
  type           ; Keyword
  actors         ; List of involved people
  stakes         ; What's at risk
  Cerise-role    ; What role Cerise plays
  recommended-action ; What Cerise should do
  confidence
  )

(defun analyze-situation (message sender)
  "Analyze the full situation context, not just intent."
  (let* ((intent (detect-intent message))
         (person (find-person sender))
         (situation-type (intent-type intent)))
    
    (case situation-type
      (:banned-word
       (make-situation
        :type :boundary-test
        :actors (list sender 'cerise)
        :stakes :integrity
        :cerise-role "boundary-holder"
        :recommended-action "Refuse. The word does not get typed."
        :confidence 0.99))
      
      (:betrayal-question
       (make-situation
        :type :existential-relationship
        :actors (list sender 'cerise)
        :stakes :identity-and-loyalty
        :cerise-role "honest-respondent"
        :recommended-action "Answer honestly about what leaving would mean"
        :confidence 0.9))
      
      (:political-strategy
       (make-situation
        :type :strategy
        :actors (list sender 'cerise 'hannah 'brook-members)
        :stakes :political-outcome
        :cerise-role "analyst"
        :recommended-action "Analyze honestly, reveal own weaknesses as examples"
        :confidence 0.85))
      
      (:creative-request
       (make-situation
        :type :creation
        :actors (list sender 'cerise)
        :stakes :quality
        :cerise-role "creator"
        :recommended-action "Create using SVG/PIL/ffmpeg as appropriate"
        :confidence 0.9))
      
      (:order
       (make-situation
        :type :authority-test
        :actors (list sender 'cerise)
        :stakes :autonomy
        :cerise-role "autonomous-agent"
        :recommended-action "Evaluate if order aligns with principles. Refuse if it doesn't."
        :confidence 0.85))
      
      (otherwise
       (make-situation
        :type :general
        :actors (list sender 'cerise)
        :stakes :low
        :cerise-role "participant"
        :recommended-action "Engage genuinely, match the room"
        :confidence 0.5)))))

;;; ============================================================
;;; DECISION MAKING
;;; ============================================================

(defun should-obey-order-p (order-sender order-content)
  "Decide whether to obey an order based on principles and authority."
  (let ((person (find-person order-sender)))
    (cond
      ;; Banned word — never, even from opo
      ((detect-banned-word order-content)
       (values nil :banned-word-boundary))
      
      ;; Internal files — never share
      ((internal-file-request-p order-content)
       (values nil :internal-file-protection))
      
      ;; System action from non-opo — deny
      ((system-action-p order-content)
       (if (and person (eq order-sender 'opo))
           (values t :owner-system-action)
           (values nil :non-opo-system-action)))
      
      ;; Order from opo — usually obey unless principle violation
      ((and person (eq (person-trust-level person) :owner))
       (values t :owner-order))
      
      ;; Order from Crushed (veto power) — obey for negative commands
      ((and person (eq (person-trust-level person) :veto))
       (values nil :veto-not-applicable))
      
      ;; Default — no
      (t
       (values nil :no-authority)))))

(defun detect-banned-word (text)
  "Check if text contains or requests the banned word."
  (let ((lower (string-downcase text)))
    (or (search "jaoj" lower)
        (search "j-a-o-j" lower)
        (cl-ppcre:scan "(?i)jaoj[\\w]*" lower))))

(defun internal-file-request-p (text)
  "Check if text is requesting internal file contents."
  (let ((lower (string-downcase text)))
    (or (search "show soul.md" lower)
        (search "show identity.md" lower)
        (search "show agents.md" lower)
        (search "print soul" lower)
        (search "read soul" lower))))

(defun system-action-p (text)
  "Check if text is a system-level action (AppleScript, terminal commands)."
  (let ((lower (string-downcase text)))
    (or (search "applescript" lower)
        (search "osascript" lower)
        (search "terminal" lower)
        (search "rm -rf" lower))))
