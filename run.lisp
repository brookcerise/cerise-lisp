;;;; run.lisp — Self-contained loader, no ASDF needed
;;;; Usage: sbcl --load run.lisp

;;; Setup Quicklisp if not installed
#-quicklisp
(let ((ql-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (unless (probe-file ql-init)
    (format t "Installing Quicklisp...~%")
    (load (merge-pathnames "quicklisp/quicklisp.lisp" (user-homedir-pathname)))
    (eval '(quicklisp-quickstart:install)))
  (load ql-init))

;;; Install dependencies
(dolist (pkg '("alexandria" "cl-ppcre" "local-time" "jonathan"))
  (unless (find-package (intern (string-upcase pkg) :keyword))
    (format t "Installing ~A...~%" pkg)
    (ql:quickload pkg :silent t)))

;;; Add current directory to ASDF search path
(push (truename (or *load-truename* (pathname (car sb-ext:*command-line-args*))))
      asdf:*central-registry*)

;;; Load all source files in order
(dolist (file '("src/package.lisp"
                "src/identity.lisp"
                "src/knowledge.lisp"
                "src/memory.lisp"
                "src/people.lisp"
                "src/reasoning.lisp"
                "src/confabulation.lisp"
                "src/response.lisp"
                "src/cerise.lisp"))
  (let ((full-path (merge-pathnames file
                     (directory-namestring
                       (or *load-truename*
                           (truename "."))))))
    (format t "Loading ~A...~%" file)
    (load full-path)))

(format t "~%All files loaded successfully.~%")
(format t "Type (cerise:wake) to start the REPL.~%")
