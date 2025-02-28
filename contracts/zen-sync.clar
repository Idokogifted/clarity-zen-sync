;; ZenSync Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-duration (err u101))
(define-constant err-already-meditating (err u102))

;; Data vars
(define-data-var min-session-duration uint u300) ;; 5 minutes
(define-data-var total-meditation-time uint u0)

;; Maps
(define-map meditation-sessions principal
  {
    start-time: uint,
    duration: uint,
    meditation-type: (string-utf8 24)
  }
)

(define-map user-statistics principal
  {
    total-sessions: uint,
    total-time: uint,
    longest-session: uint
  }
)

;; Define token for rewards
(define-fungible-token zen-token)

;; Events
(define-data-var last-event-id uint u0)
(define-map events uint
  {
    event-type: (string-utf8 12),
    user: principal,
    data: (string-utf8 256)
  }
)

;; Private functions
(define-private (emit-event (event-type (string-utf8 12)) (data (string-utf8 256)))
  (let ((event-id (+ (var-get last-event-id) u1)))
    (map-set events event-id
      {
        event-type: event-type,
        user: tx-sender,
        data: data
      }
    )
    (var-set last-event-id event-id)
    (ok event-id)
  )
)

(define-private (update-statistics (duration uint))
  (let (
    (current-stats (default-to
      {
        total-sessions: u0,
        total-time: u0,
        longest-session: u0
      }
      (map-get? user-statistics tx-sender)
    ))
  )
    (map-set user-statistics tx-sender
      {
        total-sessions: (+ (get total-sessions current-stats) u1),
        total-time: (+ (get total-time current-stats) duration),
        longest-session: (max duration (get longest-session current-stats))
      }
    )
  )
)

;; Public functions
(define-public (start-session (meditation-type (string-utf8 24)))
  (let ((current-time (get-block-time)))
    (asserts! (is-none (map-get? meditation-sessions tx-sender))
      err-already-meditating)
    (try! (emit-event "session-start" meditation-type))
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
    (var-set total-meditation-time (+ (var-get total-meditation-time) duration))
    (update-statistics duration)
    (try! (emit-event "session-end" (concat "Duration: " (to-string duration))))
    (mint-reward tx-sender duration)
  )
)

(define-private (mint-reward (user principal) (duration uint))
  (let (
    (base-reward (/ duration u60))
    (bonus (if (>= duration u3600) u10 u0))
    (reward-amount (+ base-reward bonus))
  )
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

(define-read-only (get-user-statistics (user principal))
  (map-get? user-statistics user)
)

(define-read-only (get-total-meditation-time)
  (ok (var-get total-meditation-time))
)
