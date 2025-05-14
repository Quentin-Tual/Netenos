; circ_f51m, Xor22640_i1, o6
; Variable Declarations
(declare-const i0_d Bool)
(declare-const i1_d Bool)
(declare-const i2_d Bool)
(declare-const i3_d Bool)
(declare-const i4_d Bool)
(declare-const i5_d Bool)
(declare-const i6_d Bool)
(declare-const i7_d Bool)
(declare-const i0_a Bool)
(declare-const i1_a Bool)
(declare-const i2_a Bool)
(declare-const i3_a Bool)
(declare-const i4_a Bool)
(declare-const i5_a Bool)
(declare-const i6_a Bool)
(declare-const i7_a Bool)
(declare-const t_a Int)
 
; Function Definitions
(define-fun i0 ((t Int)) Bool
	(ite (< t 0) i0_d i0_a))
(define-fun i1 ((t Int)) Bool
	(ite (< t 0) i1_d i1_a))
(define-fun i2 ((t Int)) Bool
	(ite (< t 0) i2_d i2_a))
(define-fun i3 ((t Int)) Bool
	(ite (< t 0) i3_d i3_a))
(define-fun i4 ((t Int)) Bool
	(ite (< t 0) i4_d i4_a))
(define-fun i5 ((t Int)) Bool
	(ite (< t 0) i5_d i5_a))
(define-fun i6 ((t Int)) Bool
	(ite (< t 0) i6_d i6_a))
(define-fun i7 ((t Int)) Bool
	(ite (< t 0) i7_d i7_a))
(define-fun y ((t Int)) Bool (xor(i7 (- t 1)) (i6 (- t 1)) ))
(define-fun yp ((t Int)) Bool (xor(i7 (- t 1)) (i6 (- t 2))  ))
 
; Forbidden Vectors Constraints

 
; Assertions

(assert (> t_a 0))
(assert (= (y t_a) (not (yp t_a))))
 
; Solve
(check-sat)
(get-model)
