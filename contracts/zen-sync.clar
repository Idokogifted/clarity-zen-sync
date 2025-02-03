;; ZenSync Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-duration (err u101))
(define-constant err-already-meditating (err u102))

;; Data vars
(define-data-var min-session-duration uint u300) ;; 5 minutes
(define-map meditation-sessions principal
  {
    start-time: uint,
    duration: uint,
    meditation-type: (string-utf8 24)
  }
)

;; Define token for rewards
(define-fungible-token zen-token)

;; Public functions
(define-public (start-session (meditation-type (string-utf8 24)))
  (let ((current-time (get-block-time)))
    (asserts! (is-none (map-get? meditation-sessions tx-sender))
      err-already-meditating)
    (ok (map-set meditation-sessions tx-sender
      {
        start-time: current-time,
        duration: u0,
        meditation-type: meditation-type
      }))
  )
)

(define-public (end-session)
  (let (
    (session (unwrap! (map-get? meditation-sessions tx-sender) (err u103)))
    (duration (- (get-block-time) (get start-time session)))
  )
    (asserts! (>= duration (var-get min-session-duration))
      err-invalid-duration)
    (map-delete meditation-sessions tx-sender)
    (mint-reward tx-sender duration)
  )
)

(define-private (mint-reward (user principal) (duration uint))
  (let ((reward-amount (/ duration u60)))
    (ft-mint? zen-token reward-amount user)
  )
)

;; Read only functions
(define-read-only (get-active-session (user principal))
  (map-get? meditation-sessions user)
)

(define-read-only (get-zen-balance (account principal))
  (ok (ft-get-balance zen-token account))
)
