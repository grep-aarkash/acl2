; Java Library
;
; Copyright (C) 2020 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "primarrays")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Specialize the input and output types of the tested functions.

(java::def-atj-main-function-type test-boolean-array-read
                                  (:jboolean[] :jint) :jboolean)

(java::def-atj-main-function-type test-char-array-read
                                  (:jchar[] :jint) :jchar)

(java::def-atj-main-function-type test-byte-array-read
                                  (:jbyte[] :jint) :jbyte)

(java::def-atj-main-function-type test-short-array-read
                                  (:jshort[] :jint) :jshort)

(java::def-atj-main-function-type test-int-array-read
                                  (:jint[] :jint) :jint)

(java::def-atj-main-function-type test-long-array-read
                                  (:jlong[] :jint) :jlong)

(java::def-atj-main-function-type test-boolean-array-length (:jboolean[]) :jint)

(java::def-atj-main-function-type test-char-array-length (:jchar[]) :jint)

(java::def-atj-main-function-type test-byte-array-length (:jbyte[]) :jint)

(java::def-atj-main-function-type test-short-array-length (:jshort[]) :jint)

(java::def-atj-main-function-type test-int-array-length (:jint[]) :jint)

(java::def-atj-main-function-type test-long-array-length (:jlong[]) :jint)

(java::def-atj-main-function-type test-boolean-array-of-length
                                  (:jint) :jboolean[])

(java::def-atj-main-function-type test-char-array-of-length
                                  (:jint) :jchar[])

(java::def-atj-main-function-type test-byte-array-of-length
                                  (:jint) :jbyte[])

(java::def-atj-main-function-type test-short-array-of-length
                                  (:jint) :jshort[])

(java::def-atj-main-function-type test-int-array-of-length
                                  (:jint) :jint[])

(java::def-atj-main-function-type test-long-array-of-length
                                  (:jint) :jlong[])

(java::def-atj-main-function-type test-boolean-array-with-comps-0
                                  () :jboolean[])

(java::def-atj-main-function-type test-char-array-with-comps-0
                                  () :jchar[])

(java::def-atj-main-function-type test-byte-array-with-comps-0
                                  () :jbyte[])

(java::def-atj-main-function-type test-short-array-with-comps-0
                                  () :jshort[])

(java::def-atj-main-function-type test-int-array-with-comps-0
                                  () :jint[])

(java::def-atj-main-function-type test-long-array-with-comps-0
                                  () :jlong[])

(java::def-atj-main-function-type test-boolean-array-with-comps-1
                                  (:jboolean) :jboolean[])

(java::def-atj-main-function-type test-char-array-with-comps-1
                                  (:jchar) :jchar[])

(java::def-atj-main-function-type test-byte-array-with-comps-1
                                  (:jbyte) :jbyte[])

(java::def-atj-main-function-type test-short-array-with-comps-1
                                  (:jshort) :jshort[])

(java::def-atj-main-function-type test-int-array-with-comps-1
                                  (:jint) :jint[])

(java::def-atj-main-function-type test-long-array-with-comps-1
                                  (:jlong) :jlong[])

(java::def-atj-main-function-type test-boolean-array-with-comps-2
                                  (:jboolean :jboolean) :jboolean[])

(java::def-atj-main-function-type test-char-array-with-comps-2
                                  (:jchar :jchar) :jchar[])

(java::def-atj-main-function-type test-byte-array-with-comps-2
                                  (:jbyte :jbyte) :jbyte[])

(java::def-atj-main-function-type test-short-array-with-comps-2
                                  (:jshort :jshort) :jshort[])

(java::def-atj-main-function-type test-int-array-with-comps-2
                                  (:jint :jint) :jint[])

(java::def-atj-main-function-type test-long-array-with-comps-2
                                  (:jlong :jlong) :jlong[])

(java::def-atj-main-function-type test-boolean-array-with-comps-3
                                  (:jboolean :jboolean :jboolean) :jboolean[])

(java::def-atj-main-function-type test-char-array-with-comps-3
                                  (:jchar :jchar :jchar) :jchar[])

(java::def-atj-main-function-type test-byte-array-with-comps-3
                                  (:jbyte :jbyte :jbyte) :jbyte[])

(java::def-atj-main-function-type test-short-array-with-comps-3
                                  (:jshort :jshort :jshort) :jshort[])

(java::def-atj-main-function-type test-int-array-with-comps-3
                                  (:jint :jint :jint) :jint[])

(java::def-atj-main-function-type test-long-array-with-comps-3
                                  (:jlong :jlong :jlong) :jlong[])

(java::def-atj-main-function-type f (:jint[] :jint :jint) :jint)

(java::def-atj-main-function-type g (:jbyte[] :jshort[]) :jint)

(java::def-atj-main-function-type h (:jbyte) :jchar[])

(java::def-atj-main-function-type i (:jfloat[] :jdouble[] :jint :jint) :jdouble)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Generate Java code for the tested functions.
; The automatic generation of tests is not supported yet.

(java::atj test-boolean-array-read
           test-char-array-read
           test-byte-array-read
           test-short-array-read
           test-int-array-read
           test-long-array-read
           test-boolean-array-length
           test-char-array-length
           test-byte-array-length
           test-short-array-length
           test-int-array-length
           test-long-array-length
           test-boolean-array-of-length
           test-char-array-of-length
           test-byte-array-of-length
           test-short-array-of-length
           test-int-array-of-length
           test-long-array-of-length
           test-boolean-array-with-comps-0
           test-char-array-with-comps-0
           test-byte-array-with-comps-0
           test-short-array-with-comps-0
           test-int-array-with-comps-0
           test-long-array-with-comps-0
           test-boolean-array-with-comps-1
           test-char-array-with-comps-1
           test-byte-array-with-comps-1
           test-short-array-with-comps-1
           test-int-array-with-comps-1
           test-long-array-with-comps-1
           test-boolean-array-with-comps-2
           test-char-array-with-comps-2
           test-byte-array-with-comps-2
           test-short-array-with-comps-2
           test-int-array-with-comps-2
           test-long-array-with-comps-2
           test-boolean-array-with-comps-3
           test-char-array-with-comps-3
           test-byte-array-with-comps-3
           test-short-array-with-comps-3
           test-int-array-with-comps-3
           test-long-array-with-comps-3
           f
           g
           h
           i
           :deep nil
           :guards t
           :java-class "PrimarraysShallowGuarded"
           :tests *shallow-guarded-tests*)
