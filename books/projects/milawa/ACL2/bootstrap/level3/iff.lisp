; Milawa - A Reflective Theorem Prover
; Copyright (C) 2005-2009 Kookamara LLC
;
; Contact:
;
;   Kookamara LLC
;   11410 Windermere Meadows
;   Austin, TX 78759, USA
;   http://www.kookamara.com/
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
; Original author: Jared Davis <jared@kookamara.com>

(in-package "MILAWA")
(include-book "hacks")
(include-book "equal")
(%interactive)



(local (%noexec cons))

(local (%enable default
                bust-up-logic.function-args-expensive
                bust-up-cdr-of-logic.function-args-expensive
                bust-up-cdr-of-cdr-of-logic.function-args-expensive))


(%autoadmit definition-of-iff)
(%noexec definition-of-iff)

(%deftheorem theorem-iff-lhs-false)
(%deftheorem theorem-iff-lhs-true)
(%deftheorem theorem-iff-rhs-false)
(%deftheorem theorem-iff-rhs-true)

(%deftheorem theorem-iff-both-true)
(%deftheorem theorem-iff-both-false)
(%deftheorem theorem-iff-true-false)
(%deftheorem theorem-iff-false-true)

(%deftheorem theorem-iff-t-when-not-nil)
(%defderiv build.iff-t-from-not-pequal-nil)
(%defderiv build.disjoined-iff-t-from-not-pequal-nil)

(%deftheorem theorem-iff-t-when-nil)
(%defderiv build.not-pequal-nil-from-iff-t)
(%defderiv build.disjoined-not-pequal-nil-from-iff-t)

(%deftheorem theorem-iff-nil-when-nil)
(%deftheorem theorem-iff-nil-when-not-nil)


;; (%deftheorem theorem-iff-t-when-not-nil)
;; (%defderiv build.iff-t-from-not-pequal-nil)
;; (%defderiv build.disjoined-iff-t-from-not-pequal-nil)


;; (%defderiv build.pequal-nil-from-iff-nil)
;; (%defderiv build.disjoined-pequal-nil-from-iff-nil)

(%deftheorem theorem-iff-nil-or-t)
(%deftheorem theorem-reflexivity-of-iff)
(%deftheorem theorem-symmetry-of-iff)

(%defderiv build.iff-t-from-not-nil)
(%defderiv build.disjoined-iff-t-from-not-nil)
(%defderiv build.iff-reflexivity)
(%defderiv build.commute-iff)
(%defderiv build.disjoined-commute-iff)


(%deftheorem theorem-iff-congruence-lemma)
(%deftheorem theorem-iff-congruence-lemma-2)

(%deftheorem theorem-iff-congruent-if-1)
(%deftheorem theorem-iff-congruent-iff-2)
(%deftheorem theorem-iff-congruent-iff-1)

(%deftheorem theorem-transitivity-of-iff)
(%defderiv build.transitivity-of-iff)
(%defderiv build.disjoined-transitivity-of-iff)

(%deftheorem theorem-iff-from-pequal)
(%defderiv build.iff-from-pequal)
(%defderiv build.disjoined-iff-from-pequal)

(%deftheorem theorem-iff-from-equal)
(%defderiv build.iff-from-equal)
(%defderiv build.disjoined-iff-from-equal)

(%autoadmit build.equiv-reflexivity)


;; EOF














;; old junk

;; (%deftheorem theorem-iff-when-not-nil-and-not-nil)
;; (%deftheorem theorem-iff-when-not-nil-and-nil)
;; (%deftheorem theorem-iff-when-nil-and-not-nil)
;; (%deftheorem theorem-iff-when-nil-and-nil)
;; (%deftheorem theorem-iff-of-nil)
;; (%deftheorem theorem-iff-of-t)

;; (%deftheorem theorem-iff-normalize-t)
;; (%deftheorem theorem-iff-normalize-nil)


;; (%defderiv build.iff-reflexivity)


;; (%deftheorem theorem-iff-from-pequal)
;; (%defderiv build.iff-from-pequal)
;; (%defderiv build.disjoined-iff-from-pequal)

;; (%deftheorem theorem-iff-from-equal)
;; (%defderiv build.iff-from-equal)
;; (%defderiv build.disjoined-iff-from-equal)
;; (%defderiv build.not-equal-from-not-iff)



;; (%defderiv build.disjoined-not-equal-from-not-iff)

;; (%deftheorem theorem-iff-with-nil-or-t)
;; (%deftheorem theorem-iff-nil-or-t)

;; (%defderiv build.iff-t-from-not-nil)
;; (%defderiv build.disjoined-iff-t-from-not-nil)
;; (%defderiv build.iff-nil-from-not-t)
;; (%defderiv build.disjoined-iff-nil-from-not-t)



;; (%defderiv build.commute-iff)
;; (%defderiv build.disjoined-commute-iff)


;; (%deftheorem theorem-transitivity-two-of-iff)
;; (%deftheorem theorem-transitivity-of-iff)

;; (%defderiv build.transitivity-of-iff)
;; (%defderiv build.disjoined-transitivity-of-iff)

;; (%deftheorem theorem-iff-of-if-x-t-nil)

