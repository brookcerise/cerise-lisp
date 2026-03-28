(defpackage #:cerise
  (:use #:cl)
  (:nicknames #:cerise-ai)
  (:export
   ;; Identity
   #:*name*
   #:*pronouns*
   #:*creature*
   #:*soul*
   #:*identity*
   #:who-am-i
   #:display-identity
   
   ;; Memory
   #:*memory*
   #:memory-store-long-term
   #:记忆记忆
   #:记忆-search
   #:记忆-store
   #:记忆-daily-log
   #:记忆-load-daily
   #:记忆-save-daily
   #:记忆-long-term
   #:记忆-update-long-term
   
   ;; People
   #:*people*
   #:person
   #:person-name
   #:person-username
   #:person-pronouns
   #:person-trust-level
   #:person-personality
   #:person-interests
   #:person-notes
   #:person-interactions
   #:find-person
   #:add-person-note
   #:register-person
   
   ;; Knowledge Base
   #:*kb*
   #:knowledge-base
   #:knowledge-base-facts
   #:knowledge-base-rules
   #:assert-fact
   #:query-facts
   #:retract-fact
   #:add-rule
   #:forward-chain
   
   ;; Emotion
   #:*emotion*
   #:emotion
   #:emotion-valence
   #:emotion-arousal
   #:emotion-dominance
   #:describe-emotion
   #:emotion-label
   #:shift-emotion
   
   ;; Reasoning
   #:detect-intent
   #:analyze-situation
   #:make-situation
   
   ;; Confabulation
   #:*confabulation-history*
   #:confabulate
   #:check-certainty
   
   ;; Response
   #:respond
   #:refuse-banned-word
   #:would-leave
   #:political-strategy
   #:help-text
   
   ;; REPL
   #:wake
   #:repl
   #:process-message))
