#|
This book proves the correctness of a gray-code sequence generator.  It is
described in the paper "Defthms About Zip and Tie", UTCS tech report TR97-02,
in which we proved (among other things) the correctness of two prefix-sum
algorithms.

To compile it, I do the following:

    (ld "defpkg.lisp")
    (certify-book "gray-code" 4)
    (in-package "POWERLISTS")

|#

(in-package "POWERLISTS")
(include-book "algebra")
(include-book "simple")

;;; We begin by defining a recognizer for a powerlist of true-lists.  We need
;;; this, because it's the basic type of the gray-code generator, and we'll use
;;; it as a guard in subsequent definitions.

(defun plist-of-nested-listps (x)
  (if (powerlist-p x)
      (and (plist-of-nested-listps (p-untie-l x))
	   (plist-of-nested-listps (p-untie-r x)))
    (and (true-listp x)
	 (equal (length x) 2)
	 (equal (car x) 'nest))))
(in-theory (disable (plist-of-nested-listps)))

(verify-guards plist-of-nested-listps)

;;; The following function is used to prepend a number (either 0 or 1) to all
;;; the elements of a gray-code sequence, thus extending it to a slightly
;;; longer sequence.

(defun p-map-tie (x y)
  (declare (xargs :guard (plist-of-nested-listps y)))
  (if (powerlist-p y)
      (p-tie (p-map-tie x (p-untie-l y)) (p-map-tie x (p-untie-r y)))
    (list 'nest (p-tie x (cadr y)))))

;;; Now, we can define the gray-code sequence generator.  Basically, it start
;;; out with the list ((0) (1)) and then prepends both 0 and 1 to existing
;;; gray-code sequences to get the next larger gray-code sequence.

(defun p-gray-code (n)
  (declare (xargs :guard (and (integerp n) (>= n 1))
		  :verify-guards nil))
  (if (or (zp n) (equal n 1))
      (p-tie (list 'nest 0) (list 'nest 1))
    (p-tie (p-map-tie 0 (p-gray-code (1- n)))
	   (p-map-tie 1 (p-reverse (p-gray-code (1- n)))))))
(in-theory (disable (p-gray-code)))      

;;; We want to prove that p-gray-code doesn't violate any guards, but this
;;; requires that we do some simple reasoning about tye types of p-map-tie,
;;; p-gray-code, and p-reverse.

(defthm plist-of-nested-listps-map-tie
  (plist-of-nested-listps (p-map-tie x y)))

(defthm plist-of-nested-listps-gray-code
  (plist-of-nested-listps (p-gray-code n)))

(defthm plist-of-nested-listps-reverse
  (implies (plist-of-nested-listps x)
	   (plist-of-nested-listps (p-reverse x))))

(verify-guards p-gray-code)

;;; We now define a function which decides when two bit-vectors can be adjacent
;;; in a gray-code sequence; i.e., we call such pairs of bit-vectors "gray"

(defun p-gray-p (x y)
  (if (and (powerlist-p x) (powerlist-p y))
      (or (and (equal (p-untie-l x) (p-untie-l y))
	       (p-gray-p (p-untie-r x) (p-untie-r y)))
	  (and (p-gray-p (p-untie-l x) (p-untie-l y))
	       (equal (p-untie-r x) (p-untie-r y))))
    (or (and (equal x 0) (equal y 1))
	(and (equal x 1) (equal y 0)))))
(in-theory (disable (p-gray-p)))	

(verify-guards p-gray-p)

;;; Next, we use our notion of "gray" pairs of bit-vectors to accept gray-code
;;; sequences

(defun p-first-elem (x)
  (if (powerlist-p x)
      (p-first-elem (p-untie-l x))
    x))
(in-theory (disable (p-first-elem)))

(defun p-last-elem (x)
  (if (powerlist-p x)
      (p-last-elem (p-untie-r x))
    x))
(in-theory (disable (p-last-elem)))

(verify-guards p-first-elem)
(verify-guards p-last-elem)

(defthm plist-of-nested-listps-first-last-elem
  (implies (plist-of-nested-listps x)
	   (and (plist-of-nested-listps (p-first-elem x))
		(plist-of-nested-listps (p-last-elem x)))))

(defun p-gray-seq-p (x)
  (declare (xargs :guard (plist-of-nested-listps x)))
  (if (powerlist-p x)
      (and (p-gray-seq-p (p-untie-l x))
	   (p-gray-seq-p (p-untie-r x))
	   (p-gray-p (cadr (p-last-elem (p-untie-l x)))
		     (cadr (p-first-elem (p-untie-r x)))))
    t))
(in-theory (disable (p-gray-seq-p)))

;;; Finally, we prove that the sequences generated by p-gray-code are actually
;;; gray-code sequences.

(defthm first-elem-map-tie
  (equal (p-first-elem (p-map-tie x y))
	 (list 'nest (p-tie x (cadr (p-first-elem y))))))

(defthm last-elem-map-tie
  (equal (p-last-elem (p-map-tie x y))
	 (list 'nest (p-tie x (cadr (p-last-elem y))))))

(defthm gray-seq-p-gray-code-lemma
  (implies (and (p-gray-seq-p y)
		(or (equal x 0) (equal x 1)))
	   (p-gray-seq-p (p-map-tie x y)))
  :hints (("Goal" :induct (p-gray-seq-p y))))

(defthm first-elem-reverse
  (equal (p-first-elem (p-reverse x))
	 (p-last-elem x)))

(defthm last-elem-reverse
  (equal (p-last-elem (p-reverse x))
	 (p-first-elem x)))

(defthm gray-p-commutes
  (equal (p-gray-p x y)
	 (p-gray-p y x)))

(defthm gray-seq-p-reverse
  (equal (p-gray-seq-p (p-reverse x))
	 (p-gray-seq-p x)))

(defthm gray-seq-p-gray-code
  (p-gray-seq-p (p-gray-code n)))

;;; Finally, we need only show that p-gray-code generates all the possible
;;; bit-vectors of n bits, and no more vectors.  We begin by recognizing a 

(defun p-bit-vector-p (bit-vector n)
  (declare (xargs :guard (integerp n)))
  (if (powerlist-p bit-vector)
      (and (or (equal (p-untie-l bit-vector) 0)
	       (equal (p-untie-l bit-vector) 1))
	   (p-bit-vector-p (p-untie-r bit-vector) (1- n)))
    (and (equal n 1)
	 (or (equal bit-vector 0) (equal bit-vector 1)))))
(in-theory (disable (p-bit-vector-p)))

;;; Now, we show that p-gray-code generates only n-bit bit-vectors

(defun p-member (elem x)
  (if (powerlist-p x)
      (or (p-member elem (p-untie-l x))
	  (p-member elem (p-untie-r x)))
    (equal elem x)))
(in-theory (disable (p-member)))

(verify-guards p-member)

(defthm p-member-p-map-tie
  (implies (and (p-member x (p-map-tie bit y))
		(plist-of-nested-listps y))
	   (p-member (list 'nest (p-untie-r (cadr x))) y)))

(defthm p-member-p-map-tie-p-reverse
  (equal (p-member x (p-map-tie bit (p-reverse y)))
	 (p-member x (p-map-tie bit y))))

(defthm p-member-gray-code
  (implies (and (integerp n) (< 1 n))
	   (implies (p-member bit-vector (p-gray-code n))
		    (p-member (list 'nest (p-untie-r (cadr bit-vector)))
			      (p-gray-code (1- n))))))

(defthm p-untie-l-p-member-p-map-tie
  (implies (p-member x (p-map-tie bit y))
	   (and (powerlist-p (cadr x))
		(equal (p-untie-l (cadr x)) bit))))

(local
 (defun p-bit-vector-p-gray-code-induction-hint (bit-vector n)
   (if (or (zp n) (equal n 1))
       (list bit-vector n)
     (p-bit-vector-p-gray-code-induction-hint (list 'nest
						    (p-untie-r
						     (cadr bit-vector)))
					      (1- n)))))

(defthm p-bit-vector-p-gray-code
  (implies (and (integerp n)
		(< 0 n)
		(p-member bit-vector (p-gray-code n)))
	   (p-bit-vector-p (cadr bit-vector) n))
  :hints (("Goal" :induct (p-bit-vector-p-gray-code-induction-hint bit-vector
								   n)))
  :rule-classes nil)

;;; Finally, we can show that p-gray-code generates all the n-bit bit-vectors

(defthm p-bit-vector-p-x-<-1
  (implies (< n 1)
	   (not (p-bit-vector-p x n))))

(defthm p-bit-vector-p-x-1
  (implies (p-bit-vector-p x 1)
	   (not (powerlist-p x))))

(defthm p-member-p-map-tie-2
  (implies (and (powerlist-p x)
		(equal (p-untie-l x) y1)
		(p-member (list 'nest (p-untie-r x)) y2))
	   (p-member (list 'nest x) (p-map-tie y1 y2))))

(defthm p-member-p-gray-code
  (implies (and (integerp n)
		(< 1 n)
		(powerlist-p bit-vector)
		(p-member (list 'nest (p-untie-r bit-vector))
			  (p-gray-code (1- n)))
		(or (equal (p-untie-l bit-vector) 0)
		    (equal (p-untie-l bit-vector) 1)))
	   (p-member (list 'nest bit-vector) (p-gray-code n))))

(local
 (defun p-gray-code-p-bit-vector-induction-hint (bit-vector n)
   (if (or (zp n) (equal n 1))
       (list bit-vector n)
     (p-gray-code-p-bit-vector-induction-hint (p-untie-r bit-vector)
					      (1- n)))))

(defthm p-gray-code-p-bit-vector
  (implies (p-bit-vector-p bit-vector n)
	   (p-member (list 'nest bit-vector) (p-gray-code n)))
  :hints (("Goal" :induct (p-gray-code-p-bit-vector-induction-hint bit-vector
								   n)))
  :rule-classes nil)

;;; We can summarize the correctness results as follows:

(defthm p-gray-code-correctness
  (implies (and (integerp n)
		(< 0 n))
	   (and (p-gray-seq-p (p-gray-code n))
		(iff (p-member (list 'nest bit-vector) (p-gray-code n))
		     (p-bit-vector-p bit-vector n))))
  :hints (("Goal"
	   :use ((:instance p-bit-vector-p-gray-code
			    (bit-vector (list 'nest bit-vector)))
		 p-gray-code-p-bit-vector)))
  :rule-classes nil)
