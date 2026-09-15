(declare-const i0_d Bool)
(declare-const i0_a Bool)
(declare-const i1_d Bool)
(declare-const i1_a Bool)
(declare-const i2_d Bool)
(declare-const i2_a Bool)
(declare-const i3_d Bool)
(declare-const i3_a Bool)
(declare-const i4_d Bool)
(declare-const i4_a Bool)
(define-fun xor5/i0 ((t Int)) Bool (ite (< t 0) i0_d i0_a))
(define-fun xor5/i0C () Bool i0_d)
(define-fun xor5/w0R ((t Int)) Bool
  (xor5/i0 (- t 32))
)
(define-fun xor5/w0F ((t Int)) Bool
  (xor5/i0 (- t 14))
)
(define-fun xor5/w0C () Bool
  xor5/i0C
)
(define-fun xor5/w00D ((t Int)) Bool
  (xor5/i0 t)
)
(define-fun-rec xor5/w0 ((t Int)) Bool
  (ite (<= t 0)
    xor5/w0C
    (ite (not (or (xor5/w00D t) (xor5/w0F t) ))
      false
      (ite (and (xor5/w00D t) (xor5/w0R t) )
        true
        (xor5/w0 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/i2 ((t Int)) Bool (ite (< t 0) i2_d i2_a))
(define-fun xor5/i2C () Bool i2_d)
(define-fun xor5/w1R ((t Int)) Bool
  (xor5/i2 (- t 29))
)
(define-fun xor5/w1F ((t Int)) Bool
  (xor5/i2 (- t 13))
)
(define-fun xor5/w1C () Bool
  xor5/i2C
)
(define-fun xor5/w10D ((t Int)) Bool
  (xor5/i2 t)
)
(define-fun-rec xor5/w1 ((t Int)) Bool
  (ite (<= t 0)
    xor5/w1C
    (ite (not (or (xor5/w10D t) (xor5/w1F t) ))
      false
      (ite (and (xor5/w10D t) (xor5/w1R t) )
        true
        (xor5/w1 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/_3_/o0R ((t Int)) Bool
  ( or ( and (xor5/w0 (- t 157)) ( not (xor5/w1 (- t 168)) ) ) ( and ( not (xor5/w0 (- t 157)) ) (xor5/w1 (- t 168)) ) )
)
(define-fun xor5/_3_/o0F ((t Int)) Bool
  ( or ( and (xor5/w0 (- t 170)) ( not (xor5/w1 (- t 144)) ) ) ( and ( not (xor5/w0 (- t 170)) ) (xor5/w1 (- t 144)) ) )
)
(define-fun xor5/_3_/o0C () Bool
  ( or ( and xor5/w0C ( not xor5/w1C ) ) ( and ( not xor5/w0C ) xor5/w1C ) )
)
(define-fun xor5/_3_/o00D ((t Int)) Bool
  ( or ( and (xor5/w0 t) ( not (xor5/w1 t) ) ) ( and ( not (xor5/w0 t) ) (xor5/w1 t) ) )
)
(define-fun-rec xor5/_3_/o0 ((t Int)) Bool
  (ite (<= t 0)
    xor5/_3_/o0C
    (ite (not (or (xor5/_3_/o00D t) (xor5/_3_/o0F t) ))
      false
      (ite (and (xor5/_3_/o00D t) (xor5/_3_/o0R t) )
        true
        (xor5/_3_/o0 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/w6C () Bool
  xor5/_3_/o0C
)
(define-fun xor5/w60D ((t Int)) Bool
  (xor5/_3_/o0 t)
)
(define-fun xor5/w6 ((t Int)) Bool
  (xor5/w60D t)
)
(define-fun xor5/i4 ((t Int)) Bool (ite (< t 0) i4_d i4_a))
(define-fun xor5/i4C () Bool i4_d)
(define-fun xor5/w4R ((t Int)) Bool
  (xor5/i4 (- t 31))
)
(define-fun xor5/w4F ((t Int)) Bool
  (xor5/i4 (- t 13))
)
(define-fun xor5/w4C () Bool
  xor5/i4C
)
(define-fun xor5/w40D ((t Int)) Bool
  (xor5/i4 t)
)
(define-fun-rec xor5/w4 ((t Int)) Bool
  (ite (<= t 0)
    xor5/w4C
    (ite (not (or (xor5/w40D t) (xor5/w4F t) ))
      false
      (ite (and (xor5/w40D t) (xor5/w4R t) )
        true
        (xor5/w4 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/i1 ((t Int)) Bool (ite (< t 0) i1_d i1_a))
(define-fun xor5/i1C () Bool i1_d)
(define-fun xor5/w2R ((t Int)) Bool
  (xor5/i1 (- t 32))
)
(define-fun xor5/w2F ((t Int)) Bool
  (xor5/i1 (- t 14))
)
(define-fun xor5/w2C () Bool
  xor5/i1C
)
(define-fun xor5/w20D ((t Int)) Bool
  (xor5/i1 t)
)
(define-fun-rec xor5/w2 ((t Int)) Bool
  (ite (<= t 0)
    xor5/w2C
    (ite (not (or (xor5/w20D t) (xor5/w2F t) ))
      false
      (ite (and (xor5/w20D t) (xor5/w2R t) )
        true
        (xor5/w2 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/i3 ((t Int)) Bool (ite (< t 0) i3_d i3_a))
(define-fun xor5/i3C () Bool i3_d)
(define-fun xor5/w3R ((t Int)) Bool
  (xor5/i3 (- t 29))
)
(define-fun xor5/w3F ((t Int)) Bool
  (xor5/i3 (- t 13))
)
(define-fun xor5/w3C () Bool
  xor5/i3C
)
(define-fun xor5/w30D ((t Int)) Bool
  (xor5/i3 t)
)
(define-fun-rec xor5/w3 ((t Int)) Bool
  (ite (<= t 0)
    xor5/w3C
    (ite (not (or (xor5/w30D t) (xor5/w3F t) ))
      false
      (ite (and (xor5/w30D t) (xor5/w3R t) )
        true
        (xor5/w3 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/_4_/o0R ((t Int)) Bool
  ( or ( and (xor5/w2 (- t 152)) ( not (xor5/w3 (- t 163)) ) ) ( and ( not (xor5/w2 (- t 152)) ) (xor5/w3 (- t 163)) ) )
)
(define-fun xor5/_4_/o0F ((t Int)) Bool
  ( or ( and (xor5/w2 (- t 170)) ( not (xor5/w3 (- t 143)) ) ) ( and ( not (xor5/w2 (- t 170)) ) (xor5/w3 (- t 143)) ) )
)
(define-fun xor5/_4_/o0C () Bool
  ( or ( and xor5/w2C ( not xor5/w3C ) ) ( and ( not xor5/w2C ) xor5/w3C ) )
)
(define-fun xor5/_4_/o00D ((t Int)) Bool
  ( or ( and (xor5/w2 t) ( not (xor5/w3 t) ) ) ( and ( not (xor5/w2 t) ) (xor5/w3 t) ) )
)
(define-fun-rec xor5/_4_/o0 ((t Int)) Bool
  (ite (<= t 0)
    xor5/_4_/o0C
    (ite (not (or (xor5/_4_/o00D t) (xor5/_4_/o0F t) ))
      false
      (ite (and (xor5/_4_/o00D t) (xor5/_4_/o0R t) )
        true
        (xor5/_4_/o0 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/w5C () Bool
  xor5/_4_/o0C
)
(define-fun xor5/w50D ((t Int)) Bool
  (xor5/_4_/o0 t)
)
(define-fun xor5/w5 ((t Int)) Bool
  (xor5/w50D t)
)
(define-fun xor5/_5_/o0R ((t Int)) Bool
  ( or ( and ( not (xor5/w4 (- t 172)) ) ( not (xor5/w5 (- t 158)) ) ) ( and (xor5/w4 (- t 172)) (xor5/w5 (- t 158)) ) )
)
(define-fun xor5/_5_/o0F ((t Int)) Bool
  ( or ( and ( not (xor5/w4 (- t 77)) ) ( not (xor5/w5 (- t 90)) ) ) ( and (xor5/w4 (- t 77)) (xor5/w5 (- t 90)) ) )
)
(define-fun xor5/_5_/o0C () Bool
  ( or ( and ( not xor5/w4C ) ( not xor5/w5C ) ) ( and xor5/w4C xor5/w5C ) )
)
(define-fun xor5/_5_/o00D ((t Int)) Bool
  ( or ( and ( not (xor5/w4 t) ) ( not (xor5/w5 t) ) ) ( and (xor5/w4 t) (xor5/w5 t) ) )
)
(define-fun-rec xor5/_5_/o0 ((t Int)) Bool
  (ite (<= t 0)
    xor5/_5_/o0C
    (ite (not (or (xor5/_5_/o00D t) (xor5/_5_/o0F t) ))
      false
      (ite (and (xor5/_5_/o00D t) (xor5/_5_/o0R t) )
        true
        (xor5/_5_/o0 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/w7C () Bool
  xor5/_5_/o0C
)
(define-fun xor5/w70D ((t Int)) Bool
  (xor5/_5_/o0 t)
)
(define-fun xor5/w7 ((t Int)) Bool
  (xor5/w70D t)
)
(define-fun xor5/_6_/o0R ((t Int)) Bool
  ( or ( and ( not (xor5/w6 (- t 392)) ) ( not (xor5/w7 (- t 370)) ) ) ( and (xor5/w6 (- t 392)) (xor5/w7 (- t 370)) ) )
)
(define-fun xor5/_6_/o0F ((t Int)) Bool
  ( or ( and ( not (xor5/w6 (- t 184)) ) ( not (xor5/w7 (- t 164)) ) ) ( and (xor5/w6 (- t 184)) (xor5/w7 (- t 164)) ) )
)
(define-fun xor5/_6_/o0C () Bool
  ( or ( and ( not xor5/w6C ) ( not xor5/w7C ) ) ( and xor5/w6C xor5/w7C ) )
)
(define-fun xor5/_6_/o00D ((t Int)) Bool
  ( or ( and ( not (xor5/w6 t) ) ( not (xor5/w7 t) ) ) ( and (xor5/w6 t) (xor5/w7 t) ) )
)
(define-fun-rec xor5/_6_/o0 ((t Int)) Bool
  (ite (<= t 0)
    xor5/_6_/o0C
    (ite (not (or (xor5/_6_/o00D t) (xor5/_6_/o0F t) ))
      false
      (ite (and (xor5/_6_/o00D t) (xor5/_6_/o0R t) )
        true
        (xor5/_6_/o0 (- t 77)) ; not an ideal resolution, speeds up calculations with inertial delay
      )
    )
  )
)
(define-fun xor5/w8C () Bool
  xor5/_6_/o0C
)
(define-fun xor5/w80D ((t Int)) Bool
  (xor5/_6_/o0 t)
)
(define-fun xor5/w8 ((t Int)) Bool
  (xor5/w80D t)
)
(define-fun xor5/o0 ((t Int)) Bool (xor5/w8 t))
