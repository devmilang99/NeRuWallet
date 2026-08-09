uniffi::include_scaffolding!("rust_signer");

pub struct RustSigner {}

impl RustSigner {
    pub fn new() -> Self {
        Self {}
    }

    pub fn process_transaction_data(&self, data: Vec<u8>) -> Vec<u8> {
        use ring::digest;
        let actual_hash = digest::digest(&digest::SHA256, &data);
        actual_hash.as_ref().to_vec()
    }

    pub fn verify_signature(&self, public_key: Vec<u8>, message: Vec<u8>, signature: Vec<u8>) -> bool {
        use ring::signature;

        let peer_public_key = signature::UnparsedPublicKey::new(
            &signature::ECDSA_P256_SHA256_FIXED,
            public_key
        );

        peer_public_key.verify(&message, &signature).is_ok()
    }
}

// Global functions as defined in UDL
pub fn process_transaction_data(data: Vec<u8>) -> Vec<u8> {
    let signer = RustSigner::new();
    signer.process_transaction_data(data)
}

pub fn verify_signature(public_key: Vec<u8>, message: Vec<u8>, signature: Vec<u8>) -> bool {
    let signer = RustSigner::new();
    signer.verify_signature(public_key, message, signature)
}

#[cfg(test)]
mod tests {
    use super::*;

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
