(asdf:defsystem "cerise"
  :description "A digital familiar implemented in symbolic AI"
  :version "1.0.0"
  :author "Cerise <cerise@brook>"
  :license "MIT"
  :depends-on ("alexandria" "cl-ppcre" "local-time" "jonathan")
  :serial t
  :components ((:module "src"
                :components ((:file "package")
                             (:file "identity")
                             (:file "knowledge")
                             (:file "memory")
                             (:file "people")
                             (:file "reasoning")
                             (:file "confabulation")
                             (:file "response")
                             (:file "cerise"))))
  :in-order-to ((test-op (test-op "cerise/tests"))))

(asdf:defsystem "cerise/tests"
  :depends-on ("cerise" "fiveam")
  :components ((:module "tests"
                :components ((:file "suite"))))
  :perform (test-op (o c) (symbol-call :fiveam :run! :cerise)))
