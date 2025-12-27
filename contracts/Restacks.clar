;; Restacks NFT Contract
;; Standard: SIP-009

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token restacks uint)

;; --- Constants & Variables ---
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MINT-PRICE u1000000) ;; 1 STX (in micro-STX)
(define-constant MAX-SUPPLY u1000)
(define-constant METADATA-URI "ipfs://bafybeicbejs625gobsqax4ubb36utzc7qtxr24so3vtt3ssivrlg4glbm4/metadata.json")

(define-data-var last-token-id uint u0)

;; --- Error Codes ---
(define-constant ERR-SOLD-OUT (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-NOT-AUTHORIZED (err u102))

;; --- Public Functions ---

;; Claim function for users to mint an NFT for 1 STX
(define-public (claim)
    (let (
        (target-id (+ (var-get last-token-id) u1))
    )
        ;; Check if supply is available
        (asserts! (<= target-id MAX-SUPPLY) ERR-SOLD-OUT)
        
        ;; Transfer 1 STX payment to contract owner
        (try! (stx-transfer? MINT-PRICE tx-sender CONTRACT-OWNER))
        
        ;; Mint the NFT to the caller
        (try! (nft-mint? restacks target-id tx-sender))
        
        ;; Increment last token ID
        (var-set last-token-id target-id)
        (ok target-id)
    )
)

;; --- SIP-009 Standard Read-Only Functions ---

(define-read-only (get-last-token-id)
    (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint))
    (ok (some METADATA-URI))
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? restacks id))
)

;; Transfer function
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (nft-transfer? restacks id sender recipient)
    )
)