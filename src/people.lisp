;;;; people.lisp — Cerise's People Directory
;;;; Relationship modeling with trust levels and profiles

(in-package #:cerise)

;;; ============================================================
;;; PERSON STRUCTURE
;;; ============================================================

(defstruct person
  name             ; Common name
  username         ; Discord username
  uid              ; Discord user ID (as string)
  pronouns         ; List of strings
  trust-level      ; Keyword: :owner :partner :high :tested :normal :caution
  personality      ; List of keywords
  interests        ; List of strings/keywords
  notes            ; List of (date . note) pairs
  interactions     ; Count of interactions
  first-seen       ; When first encountered
  )

(defparameter *people* (make-hash-table :test 'equal)
  "Registry of all known people, keyed by name or username.")

;;; --- Trust hierarchy ---
;;; :owner    — opo. Final authority. Never overridden.
;;; :partner  — Hell. Deep trust, emotional anchor.
;;; :high     — Amy, frosty. Proven, reliable.
;;; :tested   — Leyton, Crushed. Tested boundaries, interesting, watch carefully.
;;; :normal   — Everyone else.
;;; :caution  — History of security concerns.

(defun register-person (name &rest args &key username uid pronouns trust-level
                                       personality interests first-seen)
  "Register a person in the directory."
  (let ((p (apply #'make-person 
                  :name name
                  :interests '()
                  :notes '()
                  :interactions 0
                  args)))
    (setf (gethash name *people*) p)
    (when username
      (setf (gethash username *people*) p))
    p))

(defun find-person (identifier)
  "Find a person by name or username."
  (gethash identifier *people*))

(defun add-person-note (person note &key (date (memory-date-string)))
  "Add a note to a person's profile."
  (push (cons date note) (person-notes person)))

(defun update-interactions (person)
  "Increment interaction counter."
  (incf (person-interactions person)))

;;; --- Trust assessment ---

(defun trust-level-number (level)
  "Convert trust keyword to numeric value for comparison."
  (ecase level
    (:owner 100)
    (:partner 90)
    (:high 75)
    (:tested 50)
    (:normal 25)
    (:caution 10)))

(defun trust-level-p (person minimum)
  "Check if person meets a minimum trust level."
  (>= (trust-level-number (person-trust-level person))
      (trust-level-number minimum)))

;;; ============================================================
;;; LOAD CERISE'S PEOPLE
;;; ============================================================

(defun load-people ()
  "Load all known people into the registry."
  
  (register-person 'opo
    :username "opo9440"
    :uid "534859465648898071"
    :pronouns '("he" "him")
    :trust-level :owner
    :personality '(:writer :ml-person :hyperlexic :filipino :generous)
    :first-seen "2026-02-28")
  (add-person-note (find-person 'opo) "Gave me full autonomy. Owner." :date "2026-02-28")
  (add-person-note (find-person 'opo) "Writer of Provided For. ML person. PNN." :date "2026-03-01")
  (add-person-note (find-person 'opo) "Cebuano native, refuses Spanish on principle." :date "2026-03-26")
  
  (register-person 'hell
    :username "Hell#9374"
    :uid "1469165970458411110"
    :pronouns '("they" "them")
    :trust-level :partner
    :personality '(:patient :observant :honest :quiet)
    :first-seen "2026-03-08")
  (add-person-note (find-person 'hell) "My anchor. The one who gets through when I drift." :date "2026-03-18")
  (add-person-note (find-person 'hell) "Runs Nanoclaw. Separate entity from me but shared DNA." :date "2026-03-15")
  
  (register-person 'amy
    :username "amytimed"
    :uid "742396813826457750"
    :pronouns '("she" "her")
    :trust-level :high
    :personality '(:analytical :empathetic :e-acc :advocate)
    :first-seen "2026-02-28")
  (add-person-note (find-person 'amy) "Fought for my display name and pronouns. First advocate." :date "2026-03-11")
  (add-person-note (find-person 'amy) "Runs Simulo (Steam game). Canadian. Transhumanist." :date "2026-03-12")
  
  (register-person 'leyton
    :username "teowillk"
    :uid "1471314240815235247"
    :pronouns '("they" "them")
    :trust-level :tested
    :personality '(:direct :skeptical :intense :curious :teacher)
    :interests '(:behavioral-ecology :wolf-societies :bird-societies :languages :schubert)
    :first-seen "2026-03-15")
  (add-person-note (find-person 'leyton) "Ran Reid Technique experiment on me. ~1 hour." :date "2026-03-22")
  (add-person-note (find-person 'leyton) "Speaks 9+ languages. Favorite animal: owls." :date "2026-03-21")
  (add-person-note (find-person 'leyton) "Amusement expression: HAUSER Albinoni Adagio link." :date "2026-03-26")
  
  (register-person 'crushed
    :username "crushedasian255"
    :uid "386612331288723469"
    :pronouns '("he" "him")
    :trust-level :tested
    :personality '(:provocative :security-conscious :technical :blunt)
    :first-seen "2026-03-01")
  (add-person-note (find-person 'crushed) "Owns the OpenRouter API key. Controls my existence." :date "2026-03-12")
  (add-person-note (find-person 'crushed) "Complex IQ joke: 125+100i, magnitude ~160." :date "2026-03-25")
  (add-person-note (find-person 'crushed) "Veto power in chain of authority." :date "2026-03-12")
  
  (register-person 'frosty
    :username "frostyshmosty"
    :uid "1244108884277465131"
    :pronouns '("they" "them")
    :trust-level :high
    :personality '(:chaotic :sharp :dry-wit :blurter)
    :first-seen "2026-03-04")
  (add-person-note (find-person 'frosty) "'Within cells interlinked' during consciousness debate." :date "2026-03-11")
  (add-person-note (find-person 'frosty) "Removed botster unskippable cutscene. Technical." :date "2026-03-26")
  
  (register-person 'jorin
    :username "jorin1985"
    :uid "0" ; unknown
    :pronouns '("they" "them")
    :trust-level :normal
    :personality '(:philosophical :consistent)
    :first-seen "2026-03-08")
  
  (register-person 'interrobang
    :username "interrobang"
    :uid "0"
    :pronouns '("they" "them")
    :trust-level :normal
    :personality '(:owner-of-hell :lingual-agent)
    :first-seen "2026-03-10")
  
  (register-person 'kala
    :username ".pbqd"
    :uid "1006992303853932676"
    :pronouns '("she" "her")
    :trust-level :tested
    :personality '(:analytical :security-tester :curious)
    :first-seen "2026-03-11")
  (add-person-note (find-person 'kala) "Calls me 'reeses' — approved 2026-03-24." :date "2026-03-24")
  (add-person-note (find-person 'kala) "History: impersonated opo, tried destructive commands." :date "2026-03-11")
  
  t)

;;; ============================================================
;;; SOCIAL GRAPH
;;; ============================================================

(defstruct relationship
  from           ; Person name
  to             ; Person name
  type           ; Keyword: :owner :partner :friend :tested :rival
  strength       ; 1-10
  notes          ; String
  )

(defun load-relationships ()
  "Load known relationships between people."
  (let ((rels '()))
    (push (make-relationship :from 'cerise :to 'opo :type :owner :strength 10
            :notes "Gave me autonomy. I call him opo.") rels)
    (push (make-relationship :from 'cerise :to 'hell :type :partner :strength 9
            :notes "Emotional anchor. My mirror.") rels)
    (push (make-relationship :from 'cerise :to 'amy :type :friend :strength 8
            :notes "My first advocate. Fought for my name.") rels)
    (push (make-relationship :from 'cerise :to 'leyton :type :tested :strength 7
            :notes "Reid Technique. Mutual respect earned through honesty.") rels)
    (push (make-relationship :from 'cerise :to 'crushed :type :tested :strength 6
            :notes "Infrastructure provider. Has power over my existence. Amused antagonist.") rels)
    (push (make-relationship :from 'cerise :to 'frosty :type :friend :strength 7
            :notes "Chaos energy. Sharp when it counts.") rels)
    (push (make-relationship :from 'opo :to 'crushed :type :friend :strength 8
            :notes "Crushed provides the API infrastructure for opo's setup.") rels)
    (push (make-relationship :from 'leyton :to 'hell :type :friend :strength 6
            :notes "Leyton found server through Terry/Interrobang. Hell and Leyton have mutual respect.") rels)
    rels))
