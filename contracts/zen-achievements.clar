;; ZenSync Achievements NFT Contract

;; Define NFT
(define-non-fungible-token zen-achievement uint)

;; Data vars
(define-data-var achievement-counter uint u0)

;; Public functions
(define-public (mint-achievement (meditation-hours uint) (achievement-type (string-utf8 24)))
  (let (
    (achievement-id (+ (var-get achievement-counter) u1))
  )
    (try! (nft-mint? zen-achievement achievement-id tx-sender))
    (var-set achievement-counter achievement-id)
    (ok achievement-id)
  )
)

;; Read only functions
(define-read-only (get-achievement-owner (achievement-id uint))
  (nft-get-owner? zen-achievement achievement-id)
)
