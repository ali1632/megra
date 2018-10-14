;;;; megra is a domain-specific language to make probablistic music 
;;;; Copyright 2018 Niklas Reppel
;;;;
;;;; megra is licensed under GPLv3 or later
(asdf:defsystem #:megra
  :serial t
  :author "Niklas Reppel"
  :description "megra probablistic music creation domain specific language"
  :license "GPLv3"
  :depends-on (#:incudine
	       #:cm
	       #:cm-incudine
	       #:cm-fomus
	       #:cl-fad
	       #:cl-libsndfile)
  :components ((:file "megra-package")
               (:file "megra-config")
	       (:file "megra-object-handling")
	       (:file "megra-param-modificators")
	       (:file "megra-event-base")
	       (:file "megra-event-definitions")	
	       (:file "megra-structures")
	       (:file "megra-growth-parameters")
	       (:file "megra-event-processor-base")
	       (:file "megra-graph-event-processor")
	       (:file "megra-event-processor-wrappers")
	       (:file "megra-stream-event-processors")
	       (:file "megra-disencourage")	       
	       (:file "megra-constructors")
	       (:file "megra-helpers")
	       (:file "megra-event-filters")
	       (:file "megra-visualize")
	       (:file "megra-growth")))
