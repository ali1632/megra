;; generic event-processor
(defclass event-processor ()
  ((pull-events)
   (pull-transition)       
   (successor :accessor successor :initform nil)
   (predecessor :accessor predecessor :initform nil)   
   (current-events)      ;; abstract
   (current-transition)  ;; abstract   
   (chain-bound :accessor chain-bound :initform nil)   
   (name :accessor name :initarg :name)
   (clones :accessor clones :initform nil)
   (update-clones :accessor update-clones :initarg :update-clones :initform nil)))

(defmethod pull-events ((e event-processor) &key)
  (if (successor e)
      (apply-self e (pull-events (successor e)))
      (current-events e)))

(defmethod pull-transition ((e event-processor) &key)
  (if (successor e)
      (progn
	(current-transition e) ;; trigger node selection ...
	(pull-transition (successor e)))
      (current-transition e)))

;; pass -- default 
(defmethod current-transition ((m event-processor) &key))

;; dummy processor for testing, development and debugging ..
(defclass dummy-event-processor (event-processor)
  ((name :accessor dummy-name)))

(defmethod apply-self ((e dummy-event-processor) events &key)
  (fresh-line)
  (princ "applying ")
  (current-events e))

(defmethod current-events ((e dummy-event-processor) &key)
  (fresh-line)
  (princ "dummy events from ")
  (princ (dummy-name e)))

(defmethod current-transition ((e dummy-event-processor) &key)
  (fresh-line)
  (princ "dummy transition from ")
  (princ (dummy-name e)))

(defclass generic-population-control ()
  ((variance :accessor population-control-var :initarg :variance)
   (method :accessor population-control-method :initarg :method)
   (durs :accessor population-control-durs :initarg :durs)
   (phoe :accessor population-control-higher-order-probability :initarg :phoe)
   (hoe-max :accessor population-control-higher-order-max-order :initarg :hoe-max)
   (exclude :accessor population-control-exclude :initarg :exclude)))

(defclass probability-population-control (stream-event-processor generic-population-control)
  ((pgrowth :accessor population-control-pgrowth :initarg :pgrowth)
   (pprune :accessor population-control-pprune :initarg :pprune)))

(defun probctrl (variance pgrowth pprune method
		&key durs (hoe 4) (hoe-max 4) exclude)
  (make-instance 'probability-population-control
		 :name (gensym)
		 :mod-prop nil		 
		 :affect-transition nil
		 :event-filter nil
		 :variance variance
		 :pgrowth pgrowth
		 :pprune pprune
		 :method method
		 :durs durs
		 :phoe hoe
		 :hoe-max hoe-max
		 :exclude exclude))

(defmethod apply-self ((g probability-population-control) events &key)
  (let ((ev-src (car (event-source (car events)))))
    (when (< (random 100) (population-control-pgrowth g))
      (let ((order (if (< (random 100)
			  (population-control-higher-order-probability g))
		       (+ 2 (random
			     (- (population-control-higher-order-max-order g) 2)))
		       nil)))
	;; append growth event
	(push (growth
	       ev-src
	       (population-control-var g)
	       :durs (population-control-durs g)
	       :method (population-control-method g)
	       :higher-order order)
	      events)))		  
    (when (< (random 100) (population-control-pprune g))
      ;; append prune event
      (push (shrink
	     ev-src					 
	     :exclude (population-control-exclude g))	    
	    events))
    events))

;;;;;;;;;;;;;;;; Simple Artifical Life Model ;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :megra)
(defclass lifemodel-control (stream-event-processor generic-population-control)
  ((growth-cycle :accessor lmc-growth-cycle :initarg :growth-cycle)
   (lifecycle-count :accessor lmc-lifecycle-count :initform 0)
   (apoptosis :accessor lmc-apoptosis :initarg :apoptosis :initform t)
   (node-lifespan :accessor lmc-node-lifespan :initarg :node-lifespan :initform *average-node-lifespan*)
   (node-lifespan-var :accessor lmc-node-lifespan-var :initarg :node-lifespan-var :initform *node-lifespan-variance*)
   (autophagia :accessor lmc-autophagia :initarg :autophagia :initform t)
   (local-resources :accessor lmc-local-resources :initarg :local-resources :initform *default-local-resources*)
   (local-cost :accessor lmc-local-Cost :initarg :local-cost-modifier :initform *growth-cost*)
   (local-apoptosis-regain :accessor lmc-local-apoptosis-regain :initarg :apoptosis-regain :initform *apoptosis-regain*)
   (local-autophagia-regain :accessor lmc-local-autophagia-regain :initarg :autophagia-regain :initform *autophage-regain*)))

(defmethod apply-self ((l lifemodel-control) events &key)
  (incf (lmc-lifecycle-count l))
  ;; growth point reached
  (let* ((src (car (event-source (car events))))
	 (cur-proc (gethash src *processor-directory*))
	 (cur-node-id (current-node cur-proc))
	 (cur-node (gethash cur-node-id (graph-nodes (source-graph cur-proc))))
	 (eaten-node 0)) ;; node "eaten" by autophagia ...	     
    ;; growth or no growth ?
    (when (>= (lmc-lifecycle-count l) (lmc-growth-cycle l))
      (setf (lmc-lifecycle-count l) 0) ;; reset growth cycle
      (if (> (+ (lmc-local-resources l) *global-resources*) (lmc-local-cost l))
	  ;; first case: enough resoures available
	  (let ((order (if (< (random 100)
			      (population-control-higher-order-probability l))
			   (+ 2 (random
				 (- (population-control-higher-order-max-order l) 2)))
			   nil)))
	    ;; append growth event	    
	    (push (growth
	 	   src
		   (population-control-var l)
		   :durs (population-control-durs l)
		   :method (population-control-method l)
		   :higher-order order)
		  events)
	    ;; decrease resources
	    (if (>= (lmc-local-resources l) (lmc-local-cost l))
		(setf (lmc-local-resources l) (- (lmc-local-resources l)
						 (lmc-local-cost l)))
		(if (>= *global-resources* (lmc-local-cost l))
		    (setf *global-resources* (- *global-resources* (lmc-local-cost l)))
		    ;; otherwise, split ...
		    (let ((tmp-cost (lmc-local-cost l)))
		      (setf tmp-cost (- tmp-cost (lmc-local-resources l)))
		      (setf (lmc-local-resources l) 0.0)
		      (setf *global-resources* (- *global-resources* tmp-cost)))))
	    (incudine::msg info "GROW at ~D - local: ~D global: ~D"
			   src
			   (lmc-local-resources l)
			   *global-resources*))
	  ;; else: autophagia if specified ...
	  (when (and (lmc-autophagia l)
		     (> (graph-size (source-graph cur-proc)) 1))	    
	    ;; send prune/shrink
	    (let ((rnd-node (random-node-id (source-graph cur-proc))))
	      (push (shrink src :node-id rnd-node ) events)
	      (setf eaten-node rnd-node))	    
	    ;; add regain to local	    
	    (setf (lmc-local-resources l)
		  (+ (lmc-local-resources l)
		     (lmc-local-autophagia-regain l)))	    
	    (incudine::msg info "AUTO at ~D - local: ~D global: ~D - ~D is starving!"
			   src
			   (lmc-local-resources l)
			   *global-resources*
			   src))))
    ;; handle apoptosis:
    ;; check if current node is old enough (regarding eventual variance)
    ;; delete if old
    ;; add regain ...
    
    (when (and (or (and *dont-let-die* (> (graph-size (source-graph cur-proc)) 1))
		   (not *dont-let-die*))	       
	       (> (node-age cur-node)
		  (add-var (lmc-node-lifespan l)
			   (lmc-node-lifespan-var l))))
      (unless (eql cur-node-id eaten-node)
	(push (shrink src :node-id cur-node-id) events)
	(setf (lmc-local-resources l)
	      (+ (lmc-local-resources l)
		 (lmc-local-apoptosis-regain l))))      
      (incudine::msg info
		     "APOP at ~D - local: ~D global: ~D - node ~D your time has come !"
		     src		     		     
		     (lmc-local-resources l)
		     *global-resources*
		     cur-node-id)))
  events)

(defun add-var (orig var)
  (floor (+ orig (* (* (- 20000 (random 40000)) var)
	     (/ orig 20000)))))

(< 20 (add-var 20 0.1))

(defun lmctrl (variance method growth-cycle
	       &key (autophagia t)
		 (apoptosis t)
		 durs
		 (hoe 4)
		 (hoe-max 4)
		 (lifespan 20)
		 exclude)
  (make-instance 'lifemodel-control
		 :name (gensym)
		 :growth-cycle growth-cycle
		 :mod-prop nil		 
		 :affect-transition nil
		 :event-filter nil
		 :variance variance		 
		 :method method
		 :durs durs
		 :phoe hoe
		 :node-lifespan lifespan
		 :hoe-max hoe-max
		 :exclude exclude
		 :autophagia autophagia
		 :apoptosis apoptosis))
  
(defclass processor-chain (event-processor)
  ((topmost-processor :accessor topmost-processor :initarg :topmost)
   (synced-chains :accessor synced-chains :initform nil)
   (synced-progns :accessor synced-progns :initform nil)
   ;; think of anschluss-zug -> connection train ... 
   (anschluss-kette :accessor anschluss-kette :initform nil) 
   (wait-for-sync :accessor wait-for-sync :initform nil)
   (active :accessor is-active :initform nil :initarg :is-active)
   (shift :accessor chain-shift :initform 0.0 :initarg :shift)
   (group :accessor chain-group :initform nil :initarg :group)))

(defun activate (chain)
  (incudine::msg info "activating ~D" chain)
  (setf (wait-for-sync chain) nil)
  (setf (is-active chain) t))

;; deactivate ... if it's a modifying event processor, delete it ...
(defun deactivate (chain)
  (incudine::msg info "deactivating ~D" chain)
  (setf (wait-for-sync chain) nil)
  (setf (is-active chain) nil))

(defmethod pull-events ((p processor-chain) &key)
  (pull-events (topmost-processor p)))

(defmethod pull-transition ((p processor-chain) &key)
  (pull-transition (topmost-processor p)))

(defun connect (processor-ids last chain-name unique)
  (let ((current (car processor-ids))
	(next (cadr processor-ids)))
    ;; if you try to hook it into a different chain ... 
    (if (and unique
	     next 
	     (chain-bound next)
	     (not (eql (chain-bound next) chain-name)))
	(progn
	  (incudine::msg
	   error
	   "cannot connect to ~D, already bound ..."
	   (cadr processor-ids))
	  ;; revert the work that has been done so far ... 
	  (detach current))      
	(when next
	  ;; if processor already has predecessor, it means that it is already
	  ;; bound in a chain ... 		
	  (setf (successor current) next)
	  (setf (predecessor next) current)	  
	  (connect (cdr processor-ids) (car processor-ids) chain-name unique)))
    ;;(incudine::msg
    ;;	   error
    ;;	   "fails hjer ?? ~D ~D" current chain-name)
    (setf (chain-bound current) chain-name)))

(defun gen-proc-name (ch-name proc idx)
  (intern (concatenate 'string
		       (string ch-name) "-"
		       (string (class-name (class-of proc))) "-"
		       (format nil "~d" idx))))

;; handle the processor list ...
(defun gen-proc-list (ch-name proc-list)
  (let ((idx 0))
    (mapcar #'(lambda (proc)
		(incf idx)	        
		(cond ((typep proc 'symbol)
		       (gethash proc *processor-directory*))
		      ;; check if proc is already present,
		      ;; if not, name it and insert it
		      ;; the proc constructor will check if
		      ;; there's
		      ;; an old instance of itself,
		      ;; and replace itself in that case
		      ((and (not (typep proc 'graph-event-processor))
			    (not (gethash (name proc) *processor-directory*)))
		       (let ((proc-name (gen-proc-name ch-name proc idx)))
			 (setf (name proc) proc-name)
			 (setf (gethash proc-name *processor-directory*) proc)))
		      ((typep proc 'graph-event-processor) proc)
		      ))
	    proc-list)))

(defmacro chain (name (&key (unique t) (activate nil) (shift 0.0) (group nil)) &body proc-body)
  `(funcall #'(lambda ()
		(let ((event-processors
		       (gen-proc-list ,name (list ,@proc-body))))
		(chain-from-list
		 ,name
		 event-processors
		 :unique ,unique
		 :activate ,activate
		 :shift ,shift
		 :group ,group)))))

;; if no group is given, the current group will be used ... 
(defun assign-chain-to-group (chain chain-name group)
  ;; if no groupname is given, use current group ... 
  (let* ((groupname (if group group *current-group*))
	 (group-list (gethash groupname *group-directory*)))
    (when (not (member chain-name group-list))
      (setf (chain-group chain) group)
      (setf (gethash groupname *group-directory*)
	      (append group-list (list chain-name))))))

(defmethod collect-chain ((c processor-chain) &key)
  (labels ((append-next (proc-list proc)	     
	     (if (successor proc)
		 (append-next (append proc-list (list proc))  (successor proc))
		 (append proc-list (list proc)))))
    (append-next '() (topmost-processor c))))

;; to change - push branch to regular chain directory,
;; just store the name in branch list.
;; that should allow for independent growth of branches ! 
(defun chain-from-list (name event-processors &key (unique t)
						(activate nil)
						(shift 0.0)
						(branch nil)
						(group nil))  
  (connect event-processors nil name unique)
  ;; assume the chaining went well 
  (let ((topmost-proc (car event-processors)))
    (if (chain-bound topmost-proc)
	(let ((new-chain (make-instance
			  'processor-chain
			  :topmost topmost-proc
			  :is-active activate
			  :shift shift)))	  
	  ;; assign chain to a group
	  (assign-chain-to-group new-chain name group)
	  ;; handle branching ...	  
	  (if branch
	      (setf (gethash branch *branch-directory*)
		    (append (gethash branch *branch-directory*) (list name))))
	  (setf (gethash name *chain-directory*) new-chain))
	(incudine::msg error "chain-building went wrong, seemingly ..."))))





