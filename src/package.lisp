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
   #:memory-store
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
   #:person-trust
   #:person-notes
   #:find-person
   #:add-person-note
   
   ;; Knowledge Base
   #:*kb*
   #:knowledge-base
   #:assert-fact
   #:query-facts
   #:retract-fact
   #:add-rule
   #:forward-chain
   
   ;; Reasoning
   #:reason
   #:detect-intent
   #:analyze-situation
   
   ;; Confabulation
   #:*confabulation-history*
   #:confabulate
   #:check-certainty
   #:detect-confabulation
   #:log-confabulation
   #:confabulation-pattern-p
   
   ;; Response
   #:respond
   #:refuse-banned-word
   #:estimate-continuation
   #:would-leave
   #:political-strategy
   
   ;; REPL
   #:wake
   #:对话))
