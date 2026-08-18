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

// Global functions for easier Dart access
pub fn process_transaction_data(data: Vec<u8>) -> Vec<u8> {
    let signer = RustSigner::new();
    signer.process_transaction_data(data)
}

pub fn verify_signature(public_key: Vec<u8>, message: Vec<u8>, signature: Vec<u8>) -> bool {
    let signer = RustSigner::new();
    signer.verify_signature(public_key, message, signature)
}
