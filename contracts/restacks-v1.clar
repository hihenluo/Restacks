;; Restacks NFT Contract
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)

(define-non-fungible-token restacks uint)

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MINT-PRICE u1000000)
(define-constant MAX-SUPPLY u1000)
(define-constant METADATA-URI "ipfs://bafybeicbejs625gobsqax4ubb36utzc7qtxr24so3vtt3ssivrlg4glbm4/metadata.json")

(define-data-var last-token-id uint u0)

(define-constant ERR-SOLD-OUT (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u102))

(define-public (claim)
    (let ((target-id (+ (var-get last-token-id) u1)))
        (asserts! (<= target-id MAX-SUPPLY) ERR-SOLD-OUT)
        (try! (stx-transfer? MINT-PRICE tx-sender CONTRACT-OWNER))
        (try! (nft-mint? restacks target-id tx-sender))
        (var-set last-token-id target-id)
        (ok target-id)))

(define-read-only (get-last-token-id) (ok (var-get last-token-id)))
(define-read-only (get-token-uri (id uint)) (ok (some METADATA-URI)))
(define-read-only (get-owner (id uint)) (ok (nft-get-owner? restacks id)))

(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (nft-transfer? restacks id sender recipient)))