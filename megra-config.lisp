(in-package :megra)

;; ------------------------ USER CONFIG -------------------------------- ;;

;; sample root folder ... note trailing "/" !
(defparameter *sample-root* "/home/nik/REPOSITORIES/music-needs-texture/")
;; sample type aka file extension - wav or flac !
;; (currently not possible to mix ...)
(defparameter *sample-type* "flac" )

;; the impulse response to use for the reverb (no file extension)
(defparameter *reverb-ir* "ir1" )

;; ---------------------- END USER CONFIG ------------------------------- ;;

;; helper structure to store sample data
(defstruct buffer-data 
  buffer
  buffer-rate
  buffer-frames)

;; storage for sample buffers 
(defparameter *incu-buffer-directory* (make-hash-table :test 'equal))
(defparameter *sc-buffer-directory* (make-hash-table :test 'equal))

;; consecutive buffer numbers for scsynth
;; start with two as 0 and 1 are reserved for the reverb buffers ...
(defparameter *sc-sample-bufnums* 2)

(defparameter *eval-on-copy* nil)

;; make int a little bit longer, because the first one or two elements will be dropped
(defparameter *global-trace-length* 10)

(defvar *encourage-percentage* 5)
;; what might be the justification for this split ?
;; "Un-Learning" things is harder for humans, but for machines ?
;;(in-package :megra)
(defvar *discourage-percentage* 5)

;; main storage for emvent processors (a processor can be used without
;; being kept here, but at least historically it has been practical
;; to keep track of certain things)
(defparameter *processor-directory* (make-hash-table :test 'eql))

;; when branching, keep the previous states ... 
(defparameter *prev-processor-directory* (make-hash-table :test 'eql))

;; chains and branches 
(defparameter *chain-directory* (make-hash-table :test 'eql))
(defparameter *branch-directory* (make-hash-table :test 'eql))

;; chain groups ... 
(defparameter *group-directory* (make-hash-table :test 'eql))

(defparameter *pi* 3.14159265359)

(defparameter *midi-responders* (make-hash-table :test 'eql))
(defparameter *pad-toggle-states* (make-hash-table :test 'eql))

(defparameter *global-azimuth-offset* 0.0)
(defparameter *global-elevation-offset* 0.0)

(defparameter *global-midi-delay* 0.16)

(defparameter *global-osc-delay* 0.16)

(defparameter *current-group* 'DEFAULT)

;; the default backend for DSP
;; 'inc -> incudine
;; 'sc -> SuperCollider

;;(defparameter *default-dsp-backend* 'inc)
(defparameter *default-dsp-backend* 'sc)
