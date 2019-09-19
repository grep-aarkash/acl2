; Java Library
;
; Copyright (C) 2019 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "natives")

(include-book "../types-for-natives")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Generate Java code for the natively implemented functions, with testing code.

(java::atj characterp
           stringp
           symbolp
           integerp
           rationalp
           complex-rationalp
           consp
           acl2-numberp
           unary--
           unary-/
           binary-*
           binary-+
           char-code
           code-char
           coerce
           intern-in-package-of-symbol
           symbol-package-name
           symbol-name
           pkg-imports
           pkg-witness
           <
           complex
           realpart
           imagpart
           numerator
           denominator
           cons
           car
           cdr
           equal
           if
           :deep nil
           :guards t
           :java-class "NativesShallowGuarded"
           :tests *all-tests*)
