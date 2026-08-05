uniffi::setup_scaffolding!();

#[derive(uniffi::Object)]
pub struct RustSigner {}

#[uniffi::export]
impl RustSigner {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self {}
    }

    pub fn process_transaction_data(&self, data: Vec<u8>) -> Vec<u8> {
        // High-performance transaction processing/hashing using Rust 'ring' crate
        use ring::digest;
        let actual_hash = digest::digest(&digest::SHA256, &data);
        actual_hash.as_ref().to_vec()
    }

    pub fn verify_signature(&self, public_key: Vec<u8>, message: Vec<u8>, signature: Vec<u8>) -> bool {
        // Verify ECDSA P-256 signature (secp256r1) as used by Secure Enclave / StrongBox
        use ring::signature;

        let peer_public_key = signature::UnparsedPublicKey::new(
            &signature::ECDSA_P256_SHA256_FIXED,
            public_key
        );

        peer_public_key.verify(&message, &signature).is_ok()
    }
}
