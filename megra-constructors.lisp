					; structural
(defun node (id &rest content)
  (make-instance 'node :id id :content content))

(defun edge (src dest &key prob dur)
  (make-instance 'edge :src src :dest dest :prob prob :content `(,(make-instance 'transition :dur dur))))

(defun graph (name &rest graphdata)
  (let ((new-graph (make-instance 'graph)))
    (setf (graph-id new-graph) name)    
    (mapc #'(lambda (obj)
	      (cond ((typep obj 'edge) (insert-edge new-graph obj))
		    ((typep obj 'node) (insert-node new-graph obj))))
	  graphdata)
    (if (gethash name *processor-directory*)
	(setf (source-graph (gethash name *processor-directory*)) new-graph)
	(setf (gethash name *processor-directory*) (make-instance 'graph-event-processor :graph new-graph :current-node 1))))
  name)

					; dispatching
(defun dispatch (&rest event-processors)
  (let ((dispatcher (make-instance 'event-dispatcher)))
    (labels
	((connect (processors)
	   (when (cadr processors)
	     (setf (successor (gethash (car processors) *processor-directory* ))
		   (gethash (cadr processors) *processor-directory*))
	     (connect (cdr processors)))))
      (connect event-processors))
    (unless (is-active (gethash (car event-processors) *processor-directory*))
      (activate (car event-processors))      
      (perform-dispatch dispatcher (car event-processors) (incudine:now))))) 

					; modifying
(defun brownian-motion (name param &key step wrap limit ubound lbound)
  (setf (gethash name *processor-directory*) (make-instance 'brownian-motion :step step :mod-prop param
							    :upper-boundary ubound
							    :lower-boundary lbound
							    :is-bounded limit
							    :is-wrapped wrap)) name)

					; events
(defun string-event (msg)
  (make-instance 'string-event :msg msg))

(defun mid (pitch &key dur lvl)
  (make-instance 'midi-event :pitch pitch :level lvl :duration dur))

					; miscellaneous


(defun deactivate (event-processor-id)
  (setf (is-active (gethash event-processor-id *processor-directory*)) nil))

(defun activate (event-processor-id)
  (setf (is-active (gethash event-processor-id *processor-directory*)) t))
