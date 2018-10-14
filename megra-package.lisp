(require 'closer-mop)
(require 'cl-fad)
(require 'cl-libsndfile)

(defpackage "MEGRA"
 (:use "COMMON-LISP" "CM" "SB-MOP" "CL-FAD" "CL-LIBSNDFILE")
 (:export "graph"
	  "brownian-motion"
	  "dispatch"
	  "node"
	  "edge"
	  "mid"
	  "grain"
	  "megra-init"
	  "megra-stop"
	  "handle-event"))

