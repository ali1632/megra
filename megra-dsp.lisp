(in-package :scratch)

(defvar *rev-crypta*
  (buffer->pvbuffer (buffer-load
		     (concatenate 'string "/home/nik/SAMPLES/" "IR/ir1_-_iringresso_new.wav"))
		    2048))

(defvar *rev-chapel*
  (buffer->pvbuffer (buffer-load
		     (concatenate 'string "/home/nik/SAMPLES/" "IR/ir1.wav"))
		    2048))

(dsp! megra-grain-rev ((buf buffer)
		       unit-rate
		       frames
		       gain		   
		       rate
		       start-pos
		       lp-freq
		       lp-q
		       lp-dist
		       peak-freq
		       peak-q
		       peak-gain
		       hp-freq
		       hp-q
		       a
		       length
		       r
		       spatial-pos
		       rev
		       (revbuf pvbuffer))
  (with-samples ((grain (grain-gen-id
			 buf 
			 unit-rate
			 frames
			 gain		   
			 rate
			 start-pos
			 lp-freq
			 lp-q
			 lp-dist
			 peak-freq
			 peak-q
			 peak-gain
			 hp-freq
			 hp-q
			 a
			 length
			 r)))
    (foreach-frame
      (foreach-channel
	(cout
	 (pan2
	  (convorev grain revbuf rev gain a length r)
	  spatial-pos))))))

(dsp! megra-grain-ambi-rev ((buf buffer)
		       unit-rate
		       frames
		       gain		   
		       rate
		       start-pos
		       lp-freq
		       lp-q
		       lp-dist
		       peak-freq
		       peak-q
		       peak-gain
		       hp-freq
		       hp-q
		       a
		       length
		       r
		       azi
		       ele	    
		       rev
		       (revbuf pvbuffer))
  (with-samples ((grain (grain-gen-id
			 buf 
			 unit-rate
			 frames
			 gain		   
			 rate
			 start-pos
			 lp-freq
			 lp-q
			 lp-dist
			 peak-freq
			 peak-q
			 peak-gain
			 hp-freq
			 hp-q
			 a
			 length
			 r)))
    (foreach-frame
      (foreach-channel
	(cout
	 (pan-ambi-3rd-sn3d
	  (convorev grain revbuf rev gain a length r)
	  azi ele))))))

(dsp! gendy-stereo-rev (amp-distr
			dur-distr
			amp-distr-param
			dur-distr-param
			freq-min
			freq-max
			amp-scale
			dur-scale
			gain						
			lp-freq
			lp-q
			lp-dist
			a
			length
			r
			pos
			rev
			(revbuf pvbuffer))
  (with-samples ((gend (gendy-filtered
			amp-distr
			dur-distr
			amp-distr-param
			dur-distr-param
			freq-min
			freq-max
			amp-scale
			dur-scale
			gain		        
			lp-freq
			lp-q
			lp-dist
			a
			length
			r)))
    (foreach-frame
      (foreach-channel
	(cout
	 (pan2
	  (convorev gend revbuf rev gain a length r)
	  pos))))))


(dsp! gendy-ambi-rev (amp-distr
		      dur-distr
		      amp-distr-param
		      dur-distr-param
		      freq-min
		      freq-max
		      amp-scale
		      dur-scale
		      gain						
		      lp-freq
		      lp-q
		      lp-dist
		      a
		      length
		      r
		      azi
		      ele
		      rev
			(revbuf pvbuffer))
  (with-samples ((gend (gendy-filtered
			amp-distr
			dur-distr
			amp-distr-param
			dur-distr-param
			freq-min
			freq-max
			amp-scale
			dur-scale
			gain		        
			lp-freq
			lp-q
			lp-dist
			a
			length
			r)))
    (foreach-frame
      (foreach-channel
	(cout
	 (pan-ambi-3rd-sn3d
	  (convorev gend revbuf rev gain a length r)
	  azi ele))))))




