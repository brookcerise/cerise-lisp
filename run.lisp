;;;; run.lisp — Self-contained loader
;;;; Usage: sbcl --load run.lisp

;;; Step 1: Ensure Quicklisp is installed
#+quicklisp
(format t "Quicklisp already available.~%")

#-quicklisp
(progn
  (let ((ql-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
    (cond
      ((probe-file ql-init)
       (load ql-init)
       (format t "Quicklisp loaded.~%"))
      ((probe-file (merge-pathnames "quicklisp/quicklisp.lisp" (user-homedir-pathname)))
       (load (merge-pathnames "quicklisp/quicklisp.lisp" (user-homedir-pathname)))
       (funcall (intern "QUICKLISP-QUICKSTART:INSTALL" :keyword))
       (load ql-init)
       (format t "Quicklisp installed and loaded.~%"))
      (t
       (error "Quicklisp not found. Download from https://beta.quicklisp.org/quicklisp.lisp and place in ~/quicklisp/")))))

;;; Step 2: Install dependencies
(dolist (pkg '("alexandria" "cl-ppcre" "local-time" "jonathan"))
  (format t "Loading ~A...~%" pkg)
  (ql:quickload pkg :silent t))

;;; Step 3: Load source files relative to this script
(let ((dir (if *load-truename*
                (pathname (directory-namestring *load-truename*))
                (truename "."))))
  (dolist (file '("src/package.lisp"
                  "src/identity.lisp"
                  "src/knowledge.lisp"
                  "src/memory.lisp"
                  "src/people.lisp"
                  "src/reasoning.lisp"
                  "src/confabulation.lisp"
                  "src/response.lisp"
                  "src/cerise.lisp"))
    (let ((path (merge-pathnames file dir)))
      (format t "Loading ~A...~%" file)
      (load path))))

(format t "~%All files loaded. Starting Cerise...~%~%")
(funcall (intern "WAKE" :cerise))
