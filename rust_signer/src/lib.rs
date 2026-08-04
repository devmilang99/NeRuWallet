uniffi::setup_scaffolding!();

#[derive(uniffi::Object)]
pub struct RustSigner {}

#[uniffi::export]
impl RustSigner {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self {}
    }

    pub fun process_transaction_data(&self, data: Vec<u8>) -> Vec<u8> {
        // High-performance transaction processing/hashing using Rust 'ring' crate
        use ring::digest;
        let actual_hash = digest::digest(&digest::SHA256, &data);
        actual_hash.as_ref().to_vec()
    }
}
