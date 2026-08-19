pub mod frb_generated; /* AUTO INJECTED BY flutter_rust_bridge. This line may not be accurate, and you can change it according to your needs. */
pub mod api;

#[cfg(test)]
mod tests {
    use super::api::*;

    #[test]
    fn test_hashing() {
        let signer = RustSigner::new();
        let data = vec![1, 2, 3];
        let hash = signer.process_transaction_data(data);
        assert_eq!(hash.len(), 32);
    }

    #[test]
    fn test_signature_verification_failure() {
        let signer = RustSigner::new();
        let pub_key = vec![0; 65];
        let msg = vec![1, 2, 3];
        let sig = vec![0; 64];
        let is_valid = signer.verify_signature(pub_key, msg, sig);
        assert!(!is_valid);
    }
}
