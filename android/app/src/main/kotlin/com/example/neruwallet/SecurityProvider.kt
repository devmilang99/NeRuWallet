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

class SecurityProvider(private val context: Context) {

    private val keyStoreAlias = "neru_wallet_signing_key"
    private val providerName = "AndroidKeyStore"

    fun generateHardwareBackedKey(): Boolean {
        return try {
            generateKey(true) // Try StrongBox
            true
        } catch (e: Exception) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && e is StrongBoxUnavailableException) {
                // Fallback to TEE
                try {
                    generateKey(false)
                    true
                } catch (inner: Exception) {
                    false
                }
            } else {
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
