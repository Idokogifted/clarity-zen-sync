;; ZenSync Achievements NFT Contract

;; Constants
(define-constant err-invalid-hours (err u200))
(define-constant err-invalid-type (err u201))

;; Achievement Types
(define-constant achievement-types (list 
  "beginner-mind"
  "master-meditator"
  "zen-warrior"
  "enlightened-one"
))

;; Define NFT
(define-non-fungible-token zen-achievement uint)

;; Data vars
(define-data-var achievement-counter uint u0)

;; Maps
(define-map achievement-metadata uint {
  meditation-hours: uint,
  achievement-type: (string-utf8 24),
  timestamp: uint
})

;; Public functions
(define-public (mint-achievement (meditation-hours uint) (achievement-type (string-utf8 24)))
  (let (
    (achievement-id (+ (var-get achievement-counter) u1))
  )
    ;; Validate achievement type
    (asserts! (is-some (index-of achievement-types achievement-type)) err-invalid-type)
    ;; Validate meditation hours
    (asserts! (> meditation-hours u0) err-invalid-hours)
    
    (try! (nft-mint? zen-achievement achievement-id tx-sender))
    (map-set achievement-metadata achievement-id {
      meditation-hours: meditation-hours,
      achievement-type: achievement-type,
      timestamp: block-height
    })
    (var-set achievement-counter achievement-id)
    (ok achievement-id)
  )
)

;; Read only functions
(define-read-only (get-achievement-owner (achievement-id uint))
  (nft-get-owner? zen-achievement achievement-id)
)

(define-read-only (get-achievement-metadata (achievement-id uint))
  (map-get? achievement-metadata achievement-id)
)
