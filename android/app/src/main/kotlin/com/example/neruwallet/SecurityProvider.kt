package com.example.neruwallet

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.Signature
import java.security.spec.ECGenParameterSpec

import android.util.Log

class SecurityProvider(private val context: Context) {

    private val keyStoreAlias = "neru_wallet_signing_key"
    private val providerName = "AndroidKeyStore"
    private val TAG = "RustSigner"

    fun generateHardwareBackedKey(): Boolean {
        Log.d(TAG, "Kotlin: generateHardwareBackedKey requested")
        return try {
            generateKey(true) // Try StrongBox
            Log.d(TAG, "Kotlin: Key generated successfully with StrongBox")
            true
        } catch (e: Exception) {
            Log.w(TAG, "Kotlin: StrongBox generation failed: ${e.message}. Trying TEE fallback.")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // Fallback to TEE
                try {
                    generateKey(false)
                    Log.d(TAG, "Kotlin: Key generated successfully with TEE")
                    true
                } catch (inner: Exception) {
                    Log.e(TAG, "Kotlin: TEE generation failed: ${inner.message}")
                    false
                }
            } else {
                Log.e(TAG, "Kotlin: OS version too low for fallback logic")
                false
            }
        }
    }

    private fun generateKey(useStrongBox: Boolean) {
        val keyPairGenerator = KeyPairGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_EC, providerName
        )

        val builder = KeyGenParameterSpec.Builder(
            keyStoreAlias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .setUserAuthenticationRequired(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUserAuthenticationParameters(
                0,
                KeyProperties.AUTH_BIOMETRIC_STRONG or KeyProperties.AUTH_DEVICE_CREDENTIAL
            )
        } else {
            // For older versions, this is the standard biometric requirement
            // Note: Device credential fallback for CryptoObject is limited on older APIs
            builder.setInvalidatedByBiometricEnrollment(true)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && useStrongBox) {
            builder.setIsStrongBoxBacked(true)
        }

        keyPairGenerator.initialize(builder.build())
        keyPairGenerator.generateKeyPair()
    }

    fun getSignatureObject(): Signature? {
        val keyStore = KeyStore.getInstance(providerName).apply { load(null) }
        val privateKey =
            keyStore.getKey(keyStoreAlias, null) as? java.security.PrivateKey ?: return null

        return Signature.getInstance("SHA256withECDSA").apply {
            initSign(privateKey)
        }
    }

    fun isKeyGenerated(): Boolean {
        val keyStore = KeyStore.getInstance(providerName).apply { load(null) }
        return keyStore.containsAlias(keyStoreAlias)
    }

    fun getPublicKey(): String? {
        val keyStore = KeyStore.getInstance(providerName).apply { load(null) }
        val certificate = keyStore.getCertificate(keyStoreAlias) ?: return null
        val publicKey = certificate.publicKey ?: return null
        return android.util.Base64.encodeToString(publicKey.encoded, android.util.Base64.NO_WRAP)
    }
}
