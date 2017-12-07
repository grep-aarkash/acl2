; AIGNET - And-Inverter Graph Networks
; Copyright (C) 2013 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; License: (An MIT/X11-style license)
;
;   Permission is hereby granted, free of charge, to any person obtaining a
;   copy of this software and associated documentation files (the "Software"),
;   to deal in the Software without restriction, including without limitation
;   the rights to use, copy, modify, merge, publish, distribute, sublicense,
;   and/or sell copies of the Software, and to permit persons to whom the
;   Software is furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in
;   all copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;   DEALINGS IN THE SOFTWARE.
;
; Original author: Sol Swords <sswords@centtech.com>

(in-package "AIGNET$C")

(local (include-book "aignet-exec-thms"))

(set-enforce-redundancy t)
; (include-book "centaur/aignet/idp" :dir :system)
(include-book "litp")
(include-book "snodes")
(include-book "std/util/define" :dir :system)
(defmacro const-type () 0)
(defmacro gate-type () 1)
(defmacro in-type () 2)
(defmacro out-type () 3)

(defstobj aignet

  (num-ins     :type (integer 0 *) :initially 0)
  (num-outs    :type (integer 0 *) :initially 0)
  (num-regs    :type (integer 0 *) :initially 0)
  (num-nxsts   :type (integer 0 *) :initially 0)
  ;; num-nodes = the sum of the above + 1 (const)
  (num-nodes   :type (integer 0 *) :initially 1)

  (max-fanin   :type (integer 0 *) :initially 0)

; For space efficiency we tell the Lisp to use unsigned-byte 32's here, which
; in CCL at least will result in a very compact representation of these arrays.
; We might change this in the future if we ever need more space.  We try not to
; let this affect our logical story to the degree possible.
;
; The sizes of these arrays could also complicate our logical story, but we try
; to avoid thinking about their sizes at all.  Instead, we normally think of
; these as having unbounded length.  In the implementation we generally expect
; that:
;
;    num-nodes <= |gates|
;    num-outs    <= |outs|
;    num-regs    <= |regs|
;
; But if these don't hold we'll generally just cause an error, and logically we
; just act like the arrays are unbounded.

  (nodes       :type (array (unsigned-byte 32) (2))
               :initially 0
               :resizable t)
  (ins        :type (array (unsigned-byte 32) (0))
              :initially 0
              :resizable t)
  (outs       :type (array (unsigned-byte 32) (0))
              :initially 0
              :resizable t)
  (regs       :type (array (unsigned-byte 32) (0))
              :initially 0
              :resizable t)

  :inline t
  ;; BOZO do we want to add some notion of the initial state of the
  ;; registers, or the current state, or anything like that?  And if
  ;; so, what do we want to allow it to be?  Or can we deal with that
  ;; separately on a per-algorithm basis?
  )


(defund aignet-sizes-ok (aignet)
  (declare (xargs :stobjs aignet))
  (and (natp (num-ins aignet))
       (natp (num-regs aignet))
       (natp (num-outs aignet))
       (natp (num-nxsts aignet))
       (posp (num-nodes aignet))
       (natp (max-fanin aignet))
       (<= (lnfix (num-ins aignet))
           (ins-length aignet))
       (<= (lnfix (num-outs aignet))
           (outs-length aignet))
       (<= (lnfix (num-regs aignet))
           (regs-length aignet))
       ;; (< (max-fanin aignet)
       ;;    (num-nodes aignet))
       (<= (* 2 (lnfix (num-nodes aignet)))
           (nodes-length aignet))))

(defsection executable-node-accessors

  ;; Executable accessors.  These come in various levels of granularity for
  ;; convenience.

  ;; get one of the two slots of an node by ID
  (definline id->slot (id slot aignet)
    (declare (type (integer 0 *) id)
             (type bit slot)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (b* ((id (lnfix id))
         (slot (acl2::lbfix slot)))
      ;; NOTE: In CCL, binding (lnfix id) to id above instead of doing it inside, as
      ;; (lnfix (nodesi (+ slot (* 2 (lnfix id))) aignet)),
      ;; solves a problem where the inner call otherwise isn't inlined.
      (lnfix (nodesi (+ slot (* 2 id)) aignet))))

  (definlined set-snode->regid (regin slot0)
    (declare (type (integer 0 *) slot0)
             (type (integer 0 *) regin))
    (logior (ash (lnfix regin) 2)
            (logand 3 (lnfix slot0))))

  ;; get a particular field by ID
  (definline id->type (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->type (id->slot id 0 aignet)))

  (definline id->phase (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->phase (id->slot id 1 aignet)))

  (definline id->regp (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->regp (id->slot id 1 aignet)))

  (definline id->ionum (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->ionum (id->slot id 1 aignet)))

  (definline id->fanin0 (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->fanin (id->slot id 0 aignet)))

  (definline id->fanin1 (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->fanin (id->slot id 1 aignet)))

  (definline reg-id->nxst (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->regid (id->slot id 0 aignet)))

  (definline nxst-id->reg (id aignet)
    (declare (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (snode->regid (id->slot id 1 aignet)))

  (define update-nodesi-ec-call (idx val aignet)
    :enabled t
    (ec-call (update-nodesi idx val aignet)))

  (definline update-node-slot (id slot val aignet)
    (declare (type (integer 0 *) id)
             (type (integer 0 *) val)
             (type bit slot)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< id (num-nodes aignet)))))
    (mbe :logic (update-nodesi (+ (bfix slot) (* 2 (lnfix id)))
                              (nfix val) aignet)
         :exec (b* ((idx (+ slot (* 2 (lnfix id)))))
                 (if (< val (expt 2 32))
                     (update-nodesi idx val aignet)
                   (update-nodesi-ec-call idx val aignet))))))




(defsection maybe-grow-arrays
  ;; Reallocate the array if there isn't room to add an node.
  (definlined maybe-grow-nodes (aignet)
    (declare (xargs :stobjs aignet))
    (let ((target (+ 2 (* 2 (lnfix (num-nodes aignet))))))
      (if (< (nodes-length aignet) target)
          (resize-nodes (max 16 (* 2 target)) aignet)
        aignet)))

  (definlined maybe-grow-ins (aignet)
    (declare (xargs :stobjs aignet))
    (let ((target (+ 1 (lnfix (num-ins aignet)))))
      (if (< (ins-length aignet) target)
          (resize-ins (max 16 (* 2 target)) aignet)
        aignet)))

  (definlined maybe-grow-regs (aignet)
    (declare (xargs :stobjs aignet))
    (let ((target (+ 1 (lnfix (num-regs aignet)))))
      (if (< (regs-length aignet) target)
          (resize-regs (max 16 (* 2 target)) aignet)
        aignet)))

  (definlined maybe-grow-outs (aignet)
    (declare (xargs :stobjs aignet))
    (let ((target (+ 1 (lnfix (num-outs aignet)))))
      (if (< (outs-length aignet) target)
          (resize-outs (max 16 (* 2 target)) aignet)
        aignet))))

;; (define regs-in-bounds ((n natp) aignet)
;;   :guard (and (aignet-sizes-ok aignet)
;;               (<= n (num-regs aignet)))
;;   (if (zp n)
;;       t
;;     (and (< (id-val (regsi (1- n) aignet)) (lnfix (num-nodes aignet)))
;;          (regs-in-bounds (1- n) aignet))))

;; (define aignet-regs-in-bounds (aignet)
;;   :guard (aignet-sizes-ok aignet)
;;   (regs-in-bounds (num-regs aignet) aignet))

(defsection io-accessors/updaters
  (define update-insi-ec-call (n id aignet)
    :enabled t
    (ec-call (update-insi n id aignet)))

  (define update-regsi-ec-call (n id aignet)
    :enabled t
    (ec-call (update-regsi n id aignet)))

  (define update-outsi-ec-call (n id aignet)
    :enabled t
    (ec-call (update-outsi n id aignet)))

  (definline set-innum->id (n id aignet)
    (declare (type (integer 0 *) n)
             (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< n (num-ins aignet)))))
    (mbe :logic (non-exec
                 (update-nth *insi*
                             (update-nth n id (nth *insi* aignet))
                             aignet))
         :exec (if (< id (expt 2 32))
                   (update-insi n id aignet)
                 (update-insi-ec-call n id aignet))))


  (definline innum->id (n aignet)
    (declare (type (integer 0 *) n)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< n (num-ins aignet)))))
    (lnfix (insi n aignet)))

  (definline set-regnum->id (n id aignet)
    (declare (type (integer 0 *) n)
             (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< n (num-regs aignet)))))
    (mbe :logic (non-exec
                 (update-nth *regsi*
                             (update-nth n id (nth *regsi* aignet))
                             aignet))
         :exec (if (< id (expt 2 32))
                   (update-regsi n id aignet)
                 (update-regsi-ec-call n id aignet))))


  (definline set-outnum->id (n id aignet)
    (declare (type (integer 0 *) n)
             (type (integer 0 *) id)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< n (num-outs aignet)))))
    (mbe :logic (non-exec
                 (update-nth *outsi*
                             (update-nth n id (nth *outsi* aignet))
                             aignet))
         :exec (if (< id (expt 2 32))
                   (update-outsi n id aignet)
                 (update-outsi-ec-call n id aignet))))

  (definline outnum->id (n aignet)
    (declare (type (integer 0 *) n)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (< n (num-outs aignet)))))
    (lnfix (outsi n aignet)))


  ;; (definline regnum->ri (n aignet)
  ;;   (declare (type (integer 0 *) n)
  ;;            (xargs :stobjs aignet
  ;;                   :guard (and (aignet-sizes-ok aignet)
  ;;                               (aignet-regs-in-bounds aignet)
  ;;                               (< n (num-regs aignet)))))
  ;;   (b* ((id (lnfix (regsi n aignet))))
  ;;     (if (int= (id->type id aignet) (in-type))
  ;;         (reg-id->nxst id aignet)
  ;;       id)))

  (definline regnum->id (n aignet)
    (declare (type (integer 0 *) n)
             (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                ;; (aignet-regs-in-bounds aignet)
                                (< n (num-regs aignet)))))
    (lnfix (regsi n aignet))))

(definline lit->phase (lit aignet)
  (declare (type (integer 0 *) lit)
           (xargs :stobjs aignet
                  :guard (and (aignet-sizes-ok aignet)
                              (litp lit)
                              (< (lit-id lit)
                                 (num-nodes aignet)))))
  (b-xor (id->phase (lit-id lit) aignet)
         (lit-neg lit)))


(define fanin-litp ((lit litp) aignet)
  :inline t
  :guard (aignet-sizes-ok aignet)
  :enabled t
  (declare (type (integer 0 *) lit))
  (let ((id (lit-id lit)))
    (and (< id (lnfix (num-nodes aignet)))
         (not (int= (id->type id aignet) (out-type))))))


(defsection add-nodes


    (define add-node (aignet)
      :inline t
      (declare (xargs :stobjs aignet
                      :guard (aignet-sizes-ok aignet)))
      (b* ((aignet (maybe-grow-nodes aignet))
           (nodes  (lnfix (num-nodes aignet))))
        (update-num-nodes (+ 1 nodes) aignet)))

    (define add-in (aignet)
      :inline t
      (declare (xargs :stobjs aignet
                      :guard (aignet-sizes-ok aignet)))
      (b* ((aignet (maybe-grow-ins aignet))
           (ins  (lnfix (num-ins aignet))))
        (update-num-ins (+ 1 ins) aignet)))

    (define add-out (aignet)
      :inline t
      (declare (xargs :stobjs aignet
                      :guard (aignet-sizes-ok aignet)))
      (b* ((aignet (maybe-grow-outs aignet))
           (outs  (lnfix (num-outs aignet))))
        (update-num-outs (+ 1 outs) aignet)))

    (define add-reg (aignet)
      :inline t
      (declare (xargs :stobjs aignet
                      :guard (aignet-sizes-ok aignet)))
      (b* ((aignet (maybe-grow-regs aignet))
           (regs  (lnfix (num-regs aignet))))
        (update-num-regs (+ 1 regs) aignet)))

  (defund aignet-add-in (aignet)
    (declare (xargs :stobjs aignet
                    :guard (aignet-sizes-ok aignet)))
    (b* ((pi-num (lnfix (num-ins aignet)))
         (nodes  (lnfix (num-nodes aignet)))
         (aignet (add-node aignet))
         (aignet (add-in aignet))
         (aignet (update-max-fanin nodes aignet))
         (aignet (set-innum->id pi-num nodes aignet))
         ((mv slot0 slot1)
          (mk-snode (in-type) 0 0 0 pi-num))
         (aignet (update-node-slot nodes 0 slot0 aignet))
         (aignet (update-node-slot nodes 1 slot1 aignet)))
      aignet))

  (defund aignet-add-reg (aignet)
    (declare (xargs :stobjs aignet
                    :guard (aignet-sizes-ok aignet)))
    (b* ((ro-num (lnfix (num-regs aignet)))
         (nodes  (lnfix (num-nodes aignet)))
         (aignet (add-reg aignet))
         (aignet (add-node aignet))
         (aignet (update-max-fanin nodes aignet))
         (aignet (set-regnum->id ro-num nodes aignet))
         ((mv slot0 slot1)
          (mk-snode (in-type) 1 0 nodes ro-num))
         (aignet (update-node-slot nodes 0 slot0 aignet))
         (aignet (update-node-slot nodes 1 slot1 aignet)))
      aignet))

  (defund aignet-add-gate (f0 f1 aignet)
    (declare (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (litp f0) (litp f1)
                                (< (lit-id f0)
                                   (num-nodes aignet))
                                (not (int= (id->type (lit-id f0) aignet)
                                           (out-type)))
                                (< (lit-id f1)
                                   (num-nodes aignet))
                                (not (int= (id->type (lit-id f1) aignet)
                                           (out-type))))
                    :guard-hints (("goal" :in-theory (e/d (add-node)
                                                          (len-update-nth-linear))))))
    (b* ((nodes  (lnfix (num-nodes aignet)))
         (aignet (add-node aignet))
         (aignet (update-max-fanin nodes aignet))         
         (phase (b-and (lit->phase f0 aignet)
                       (lit->phase f1 aignet)))
         ((mv slot0 slot1)
          (mk-snode (gate-type) 0 phase (lit-fix f0) (lit-fix f1)))
         (aignet (update-node-slot nodes 0 slot0 aignet))
         (aignet (update-node-slot nodes 1 slot1 aignet)))
      aignet))

  (defund aignet-add-out (f aignet)
    (declare (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (litp f)
                                (< (lit-id f)
                                   (num-nodes aignet))
                                (not (int= (id->type (lit-id f) aignet)
                                           (out-type))))
                    :guard-hints (("goal" :in-theory (enable add-node
                                                             add-out)))))
    (b* ((nodes  (num-nodes aignet))
         (po-num (num-outs aignet))
         (aignet (add-node aignet))
         (aignet (add-out aignet))
         (phase  (lit->phase f aignet))
         (aignet (set-outnum->id po-num nodes aignet))
         ((mv slot0 slot1)
          (mk-snode (out-type) 0 phase (lit-fix f) po-num))
         (aignet (update-node-slot nodes 0 slot0 aignet))
         (aignet (update-node-slot nodes 1 slot1 aignet)))
      aignet))

  (defund aignet-set-nxst (f regid aignet)
    (declare (xargs :stobjs aignet
                    :guard (and (aignet-sizes-ok aignet)
                                (litp f)
                                (< (lit-id f)
                                   (num-nodes aignet))
                                (not (int= (id->type (lit-id f) aignet)
                                           (out-type)))
                                (natp regid)
                                (< regid (num-nodes aignet))
                                (int= (id->type regid aignet)
                                      (in-type))
                                (int= (id->regp regid aignet) 1))
                    :guard-hints ((and stable-under-simplificationp
                                       '(:use aignet-sizes-ok
                                         :in-theory (disable aignet-sizes-ok))))))
    (b* ((nodes  (num-nodes aignet))
         (aignet (add-node aignet))
         (aignet (update-num-nxsts (+ 1 (lnfix (num-nxsts aignet))) aignet))
         (slot0 (id->slot regid 0 aignet))
         (new-slot0 (set-snode->regid nodes slot0))
         (aignet (update-node-slot regid 0 new-slot0 aignet))
         (phase  (lit->phase f aignet))
         ((mv slot0 slot1)
          (mk-snode (out-type) 1 phase (lit-fix f) (lnfix regid)))
         (aignet (update-node-slot nodes 0 slot0 aignet))
         (aignet (update-node-slot nodes 1 slot1 aignet)))
      aignet)))



(define count-nodes ((n natp) (type natp) (regp bitp) aignet)
  :guard (and (aignet-sizes-ok aignet)
              (<= n (num-nodes aignet)))
  :measure (nfix (- (nfix (num-nodes aignet)) (nfix n)))
  :returns (count natp :rule-classes :type-prescription)
  (b* (((when (zp (- (nfix (num-nodes aignet)) (nfix n))))
        0)
       (n-type (id->type n aignet))
       (n-regp (id->regp n aignet)))
    (+ (if (and (eql n-type type)
                (eql n-regp regp))
           1
         0)
       (count-nodes (+ 1 (lnfix n)) type regp aignet))))

(define aignet-counts-accurate (aignet)
  :guard (aignet-sizes-ok aignet)
  (and (eql (nfix (num-ins aignet)) (count-nodes 0 (in-type) 0 aignet))
       (eql (nfix (num-regs aignet)) (count-nodes 0 (in-type) 1 aignet))
       (eql (nfix (num-outs aignet)) (count-nodes 0 (out-type) 0 aignet))
       (eql (nfix (num-nxsts aignet)) (count-nodes 0 (out-type) 1 aignet))))

(defun-sk aignet-nodes-nonconst (aignet)
  (forall idx 
          (implies (and (posp idx)
                        (< idx (nfix (num-nodes aignet))))
                   (not (equal (snode->type (id->slot idx 0 aignet))
                               (const-type)))))
  :rewrite :direct)

;; (defun-sk aignet-max-fanin-sufficient (aignet)
;;   (forall idx
;;           (implies (and (< (nfix (max-fanin aignet)) (nfix idx))
;;                         (< (nfix idx) (nfix (num-nodes aignet))))
;;                    (equal (snode->type (id->slot idx 0 aignet))
;;                           (out-type))))
;;   :rewrite :direct)

;; (define aignet-max-fanin-correct (aignet)
;;   :guard (aignet-sizes-ok aignet)
;;   (and (< (lnfix (max-fanin aignet)) (lnfix (num-nodes aignet)))
;;        (not (equal (id->type (max-fanin aignet) aignet) (out-type)))
;;        (ec-call (aignet-max-fanin-sufficient aignet))))

(define aignet-no-nxstsp ((n natp) aignet)
  ;; Checks no nextstates in the nodes above n.
  :guard (and (aignet-sizes-ok aignet)
              (< n (num-nodes aignet)))
  :measure (nfix (- (nfix (num-nodes aignet)) (+ 1 (nfix n))))
  (b* (((when (mbe :logic (zp (- (nfix (num-nodes aignet)) (+ 1 (nfix n))))
                   :exec (eql (+ 1 n) (num-nodes aignet))))
        t))
    (and (not (and (int= (id->type (+ 1 (lnfix n)) aignet) (out-type))
                   (int= (id->regp (+ 1 (lnfix n)) aignet) 1)))
         (aignet-no-nxstsp (+ 1 (lnfix n)) aignet))))

(define aignet-find-max-fanin ((n natp) aignet)
    :guard (and (aignet-sizes-ok aignet)
                (< n (num-nodes aignet))
                (equal (id->type 0 aignet) (const-type)))
    :measure (nfix n)
    :returns (max-fanin natp :rule-classes :type-prescription)
    (b* (((unless (and (int= (id->type n aignet) (out-type))
                       (mbt (not (zp n)))))
          (lnfix n)))
      (aignet-find-max-fanin (1- (lnfix n)) aignet)))

(defsection aignet-rollback


  (define aignet-rollback-one (aignet)
    :guard (and (aignet-sizes-ok aignet)
                (< 1 (num-nodes aignet))
                (ec-call (aignet-counts-accurate aignet))
                (ec-call (aignet-nodes-nonconst aignet))
                (not (and (equal (id->type (+ -1 (num-nodes aignet)) aignet) (out-type))
                          (equal (id->regp (+ -1 (num-nodes aignet)) aignet) 1))))
    :returns (new-aignet)
    (b* ((n (+ -1 (lnfix (num-nodes aignet))))
         (type (id->type n aignet))
         ((when (eql type (gate-type)))
          (update-num-nodes n aignet))
         ((when (eql type (out-type)))
          ;; We can't handle nxst nodes without doing something more
          ;; complicated, so we'll just guard against them in the logic
          ;; version.
          (b* ((aignet (update-num-outs (1- (lnfix (num-outs aignet))) aignet)))
            (update-num-nodes n aignet)))
         (regp (id->regp n aignet))
         (aignet (if (int= regp 1)
                     (update-num-regs (1- (lnfix (num-regs aignet))) aignet)
                   (update-num-ins (1- (lnfix (num-ins aignet))) aignet))))
      (update-num-nodes n aignet)))

  (define aignet-rollback-aux ((n natp) aignet)
    :guard (and (aignet-sizes-ok aignet)
                (< (nfix n) (num-nodes aignet))
                (aignet-counts-accurate aignet)
                (ec-call (aignet-nodes-nonconst aignet))
                (aignet-no-nxstsp n aignet))
    :measure (nfix (- (nfix (num-nodes aignet)) (+ 1 (nfix n))))
    :returns (new-aignet)
    (b* (((when (mbe :logic (zp (- (nfix (num-nodes aignet)) (+ 1 (nfix n))))
                     :exec (int= (num-nodes aignet) (+ 1 n))))
          aignet)
         (aignet (aignet-rollback-one aignet)))
      (aignet-rollback-aux n aignet)))

  (define aignet-rollback ((n natp) aignet)
    :guard (and (aignet-sizes-ok aignet)
                (< (nfix n) (num-nodes aignet))
                (aignet-counts-accurate aignet)
                (ec-call (aignet-nodes-nonconst aignet))
                (aignet-no-nxstsp n aignet)
                (equal (id->type 0 aignet) (const-type)))
    :returns (new-aignet)
    (b* ((aignet (aignet-rollback-aux n aignet))
         (nodes (lnfix (num-nodes aignet))))
      (if (< (lnfix (max-fanin aignet)) nodes)
          aignet
        (update-max-fanin
         (aignet-find-max-fanin (1- nodes) aignet)
         aignet)))))
      
         
          
          
         
    



(defsection aignet-init
  ;; Clears the aignet without resizing, unless the node array is size 0.
  (defun aignet-clear (aignet)
    (declare (xargs :stobjs aignet
                    :guard-debug t))
    (b* ((aignet (update-num-ins 0 aignet))
         (aignet (update-num-regs 0 aignet))
         (aignet (update-max-fanin 0 aignet))
         (aignet (update-num-nxsts 0 aignet))
         (aignet (update-num-outs 0 aignet))
         (aignet (update-num-nodes 1 aignet))
         (aignet (if (< 1 (nodes-length aignet))
                  aignet
                ;; arbitrary
                (resize-nodes 10 aignet)))
         ;; set up the constant node
         (aignet (update-nodesi 0 0 aignet))
         (aignet (update-nodesi 1 0 aignet)))
      aignet))


  (defun aignet-init (max-outs max-regs max-ins max-nodes aignet)
    (declare (type (integer 0 *) max-outs max-regs max-ins)
             (type (integer 1 *) max-nodes)
             (xargs :stobjs aignet))
    (b* ((max-nodes (mbe :logic (if (< 0 (nfix max-nodes))
                                   max-nodes
                                 1)
                        :exec max-nodes))
         (aignet (resize-nodes (* 2 max-nodes) aignet))
         (aignet (resize-ins (lnfix max-ins) aignet))
         (aignet (resize-outs (lnfix max-outs) aignet))
         (aignet (resize-regs (lnfix max-regs) aignet)))
      (aignet-clear aignet))))


(definline id-existsp (id aignet)
  (declare (xargs :stobjs aignet
                  :guard (natp id)))
  (< (lnfix id) (lnfix (num-nodes aignet))))
