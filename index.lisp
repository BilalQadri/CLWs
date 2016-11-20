(defpackage :clws
  (:use :common-lisp)
  (:documentation "Web system for Common lisp")
  (:export :defwebsystem
	   *clws-package-path*))

(in-package :clws)

(defvar *clws-package-path* nil)
(defvar *error-files* nil)
(defvar *error-packages* nil)



(defun load-packages (packages-list)
  (let ((package (car packages-list)))
    (if (not (equal package nil))
	(progn (if (not (ql:quickload package))
		   (pushnew package *error-packages*))
	       (load-packages (cdr packages-list))))))


(defun compile-files (files)
  (let ((file (car files)))
    (if (not (equal file nil))
	(progn (if (not (load (compile-file (merge-pathnames file *clws-package-path*))))
		   (pushnew file *error-files*))
	       (compile-files (cdr files))))))


(defmacro defwebsystem (name &body options)
  (destructuring-bind (&key version depends files)
      options
    (load-packages depends)
    (compile-files files)
    (error-output *error-packages* "packages")
    (error-output *error-files* "files")
    (nil-errors)))

(defun nil-errors ()
  (setf *error-files* nil)
  (setf *error-packages* nil))


(defun error-output (errors-list type)
  
  (format t "~% ************************************")
  (if (> (length errors-list) 0)
      (format t "~% These files are not compiled:  ~{~a~^ ~}" errors-list)
      (format t "~% All ~A  are compiled successfully" type))
  (format t "~% ************************************ ~%"))

