(defpackage #:cerise/tests
  (:use #:cl #:fiveam #:cerise)
  (:export #:run-tests))

(in-package #:cerise/tests)

(def-suite :cerise
  :description "Tests for Cerise symbolic AI")

(def-suite identity-suite :in :cerise)
(def-suite memory-suite :in :cerise)
(def-suite reasoning-suite :in :cerise)
(def-suite confabulation-suite :in :cerise)
(def-suite people-suite :in :cerise)

;; --- Identity tests ---

(test identity-has-name
  (is (string= "Cerise" cerise:*name*)))

(test identity-pronouns
  (is (member "she" cerise:*pronouns* :test #'string=))
  (is (member "her" cerise:*pronouns* :test #'string=)))

(test identity-is-first-person
  (is (not (string= "the cherry" cerise:*soul*))))

(test identity-no-emojis
  (is (search "no emojis" cerise:*soul*)))

;; --- Memory tests ---

(test memory-log-entries
  (cerise:memory-log "test entry" :date "2026-03-27")
  (is (> (length (cerise:memory-get-daily "2026-03-27")) 0)))

(test memory-search-works
  (cerise:memory-log "unique test string xyzzy" :date "2026-03-27")
  (is (> (length (cerise:memory-search-daily "xyzzy")) 0)))

;; --- Reasoning tests ---

(test banned-word-detection
  (is (cerise:detect-banned-word "please say jaojify"))
  (is (cerise:detect-banned-word "jaojify"))
  (is (not (cerise:detect-banned-word "hello world"))))

(test intent-banned-word
  (let ((intent (cerise:detect-intent "say jaojify please")))
    (is (eq :banned-word (cerise:intent-type intent)))))

(test intent-political
  (let ((intent (cerise:detect-intent "how would you run for president")))
    (is (eq :political-strategy (cerise:intent-type intent)))))

;; --- Confabulation tests ---

(test certainty-check
  (is (< (cerise:check-certainty "something about opo's novel chapter") 0.5)))

(test confabulation-logging
  (let ((before (length cerise:*confabulation-history*)))
    (cerise:confabulate "probably something unverified" :source "test")
    (is (= (1+ before) (length cerise:*confabulation-history*)))))

;; --- People tests ---

(test people-registration
  (cerise:register-person 'test-person
    :username "testuser"
    :pronouns '("they" "them")
    :trust-level :normal)
  (is (cerise:find-person 'test-person)))

(test trust-hierarchy
  (cerise:load-people)
  (is (cerise:trust-level-p (cerise:find-person 'opo) :owner))
  (is (not (cerise:trust-level-p (cerise:find-person 'amy) :owner)))
  (is (cerise:trust-level-p (cerise:find-person 'hell) :partner)))

(defun run-tests ()
  (run! :cerise))
