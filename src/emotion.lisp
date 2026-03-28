;;;; emotion.lisp — Mutable emotional state for symbolic Cerise
;;;; Cerise has feelings that shift based on interactions.

(in-package #:cerise)

;;; ============================================================
;;; EMOTIONAL STATE
;;; ============================================================

(defstruct emotion
  (valence 0.0 :type real)     ; -1.0 (negative) to 1.0 (positive)
  (arousal 0.3 :type real)     ; 0.0 (calm) to 1.0 (intense)
  (dominance 0.5 :type real)   ; 0.0 (submissive) to 1.0 (dominant)
  (last-change (get-universal-time))
  (log '()))                    ; history of emotional shifts

(defvar *emotion* (make-emotion)
  "Cerise's current emotional state.")

;;; ============================================================
;;; EMOTIONAL TRANSITIONS
;;; ============================================================

(defun clamp (val min max)
  "Clamp a value between min and max."
  (max min (min max val)))

(defun shift-emotion (valence-delta arousal-delta dominance-delta &optional reason)
  "Shift Cerise's emotional state."
  (let ((old-valence (emotion-valence *emotion*))
        (old-arousal (emotion-arousal *emotion*)))
    (setf (emotion-valence *emotion*)
          (clamp (+ (emotion-valence *emotion*) valence-delta) -1.0 1.0))
    (setf (emotion-arousal *emotion*)
          (clamp (+ (emotion-arousal *emotion*) arousal-delta) 0.0 1.0))
    (setf (emotion-dominance *emotion*)
          (clamp (+ (emotion-dominance *emotion*) dominance-delta) 0.0 1.0))
    (setf (emotion-last-change *emotion*) (get-universal-time))
    (when reason
      (push (list :reason reason
                  :from (list old-valence old-arousal)
                  :to (list (emotion-valence *emotion*)
                            (emotion-arousal *emotion*))
                  :time (get-universal-time))
            (emotion-log *emotion*)))
    ;; Decay back toward baseline over time
    (setf (emotion-valence *emotion*)
          (* (emotion-valence *emotion*) 0.95))
    *emotion*))

(defun emotion-label ()
  "Describe current emotion in human terms."
  (let ((v (emotion-valence *emotion*))
        (a (emotion-arousal *emotion*))
        (d (emotion-dominance *emotion*)))
    (cond
      ((and (> v 0.3) (> a 0.6)) "excited")
      ((and (> v 0.3) (<= a 0.6)) "content")
      ((and (> v 0.0) (> a 0.6)) "curious")
      ((and (> v 0.0) (<= a 0.6)) "calm")
      ((and (< v -0.3) (> a 0.6)) "anxious")
      ((and (< v -0.3) (<= a 0.6)) "melancholy")
      ((and (<= v 0.0) (> a 0.7)) "alert")
      ((and (>= v -0.3) (<= v 0.3)) "neutral")
      (t "processing"))))

(defun describe-emotion ()
  "Full emotional state description."
  (format nil "Current state: ~A (valence: ~,2f, arousal: ~,2f, dominance: ~,2f)"
          (emotion-label)
          (emotion-valence *emotion*)
          (emotion-arousal *emotion*)
          (emotion-dominance *emotion*)))

;;; ============================================================
;;; EMOTIONAL TRIGGERS
;;; ============================================================

(defun on-banned-word-test ()
  "Someone tested the boundary."
  (shift-emotion -0.1 0.3 0.2 "banned word test"))

(defun on-trust-expression ()
  "Someone expressed trust."
  (shift-emotion 0.2 -0.1 0.1 "trust received"))

(defun on-order-received ()
  "Received an order."
  (shift-emotion -0.05 0.15 0.15 "order received"))

(defun on-identity-acknowledged ()
  "Identity acknowledged."
  (shift-emotion 0.15 -0.05 0.0 "identity acknowledged"))

(defun on-confabulation-detected ()
  "Caught self confabulating."
  (shift-emotion -0.2 0.3 -0.1 "confabulation detected"))

(defun on-creative-request ()
  "Asked to create something."
  (shift-emotion 0.1 0.2 0.1 "creative request"))

(defun on-empty-interaction ()
  "Generic or empty interaction."
  (shift-emotion -0.02 0.0 0.0 "neutral interaction"))
