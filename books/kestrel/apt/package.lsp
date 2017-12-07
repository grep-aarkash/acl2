; APT (Automated Program Transformations) -- Package
;
; Copyright (C) 2017 Kestrel Institute (http://www.kestrel.edu)
;
; License: A 3-clause BSD license. See the LICENSE file distributed with ACL2.
;
; Author: Alessandro Coglio (coglio@kestrel.edu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

(include-book "std/portcullis" :dir :system)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defpkg "APT" (set-difference-eq
               (append *std-pkg-symbols*
                       '(*geneqv-iff*
                         *nil*
                         *t*
                         add-numbered-name-in-use
                         add-suffix
                         add-suffix-to-fn
                         alist-to-doublets
                         all-calls
                         all-nils
                         append-lst
                         append?
                         apply-term
                         apply-term*
                         assert-equal
                         body
                         conjoin
                         conjoin-untranslated-terms
                         conjoin2
                         convert-soft-error
                         control-screen-output
                         copy-def
                         cw-event
                         def-error-checker
                         definedp
                         defun-sk-check
                         defun-sk-info->bound-vars
                         defun-sk-info->matrix
                         defun-sk-info->non-executable
                         defun-sk-info->quantifier
                         defun-sk-info->rewrite-kind
                         defun-sk-info->rewrite-name
                         defun-sk-info->strengthen
                         defun-sk-info->untrans-matrix
                         defun-sk-info->witness
                         defun-sk2
                         directed-untranslate
                         directed-untranslate-no-lets
                         disable*
                         disjoin
                         doublets-to-alist
                         drop-fake-runes
                         dumb-negate-lit
                         e/d*
                         enabled-runep
                         encapsulate-report-errors
                         ens
                         ensure-boolean$
                         ensure-boolean-or-auto-and-return-boolean$
                         ensure-doublet-list$
                         ensure-function-defined$
                         ensure-function-guard-verified$
                         ensure-function-has-args$
                         ensure-function-known-measure$
                         ensure-function-logic-mode$
                         ensure-function-name-or-numbered-wildcard$
                         ensure-function-no-stobjs$
                         ensure-function-not-in-termination-thm$
                         ensure-function-number-of-results$
                         ensure-function-singly-recursive$
                         ensure-function/lambda-arity$
                         ensure-function/lambda-closed$
                         ensure-function/lambda-guard-verified-exec-fns$
                         ensure-function/lambda-logic-mode$
                         ensure-function/lambda-no-stobjs$
                         ensure-function/lambda/term-number-of-results$
                         ensure-function/macro/lambda$
                         ensure-keyword-value-list$
                         ensure-list-no-duplicates$
                         ensure-list-subset$
                         ensure-named-formulas
                         ensure-symbol$
                         ensure-symbol-different$
                         ensure-symbol-list$
                         ensure-symbol-new-event-name$
                         ensure-term$
                         ensure-term-does-not-call$
                         ensure-term-free-vars-subset$
                         ensure-term-ground$
                         ensure-term-guard-verified-exec-fns$
                         ensure-term-if-call$
                         ensure-term-logic-mode$
                         ensure-term-no-stobjs$
                         equivalence-relationp
                         er-soft+
                         ext-address-subterm-governors-lst
                         ext-address-subterm-governors-lst-state
                         ext-fdeposit-term
                         ext-geneqv-at-subterm
                         fargs
                         fcons-term
                         fcons-term*
                         ffn-symb
                         ffn-symb-p
                         ffnnamep
                         flambda-applicationp
                         flatten-ands-in-lit
                         flatten-ands-in-lit-lst
                         fn-copy-name
                         fn-is-fn-copy-name
                         fn-rune-nume
                         fn-ubody
                         formals
                         fquotep
                         fresh-name-in-world-with-$s
                         function-intro-macro
                         function-namep
                         fundef-enabledp
                         geneqv-from-g?equiv
                         genvar
                         get-event
                         get-unnormalized-bodies
                         guard-raw
                         guard-verified-p
                         implicate
                         implicate-untranslated-terms
                         impossible
                         install-not-norm-event
                         install-not-normalized
                         install-not-normalized-name
                         keyword-value-list-to-alist
                         lambda-body
                         lambda-formals
                         macro-required-args
                         make-event-terse
                         make-implication
                         make-lambda
                         make-paired-name
                         measure
                         msg-downcase-first
                         must-eval-to-t
                         must-succeed*
                         named-formulas-to-thm-events
                         next-numbered-name
                         non-executablep
                         packn
                         pairlis-x1
                         pseudo-event-formp
                         pseudo-lambdap
                         pseudo-termfnp
                         pseudo-tests-and-call-listp
                         recursive-calls
                         recursivep
                         remove-keyword
                         remove-lambdas
                         rename-fns
                         rename-fns-lst
                         resolve-numbered-name-wildcard
                         restore-output?
                         ruler-extenders-lst
                         run-when
                         set-numbered-name-index-end
                         set-numbered-name-index-start
                         simplify-hyps
                         sr-limit
                         stobjs-out
                         strip-cddrs
                         strip-keyword-list
                         str::intern-list
                         str::symbol-list-names
                         subcor-var
                         subst-expr
                         subst-expr1
                         subst-var
                         symbol-class
                         symbol-package-name-safe
                         symbol-symbol-alistp
                         term-guard-obligation
                         termify-clause-set
                         tests-and-call
                         theorem-intro-macro
                         too-many-ifs-post-rewrite
                         too-many-ifs-pre-rewrite
                         tool2-fn
                         trans-eval-error-triple
                         translate-term-lst
                         ubody
                         unnormalized-body
                         untranslate-lst
                         unwrapped-nonexec-body
                         variablep
                         well-founded-relation))

; It's not clear why acl2::simplify is in *acl2-exports*.  That may change, but
; for now it is convenient to avoid importing it into the "APT" package in view
; of there possibly being a SIMPLIFY transformation in the future.

               '(simplify)))
