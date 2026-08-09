package com.example.neruwallet

import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor
// Import the generated Rust bindings (will be available after build)
import uniffi.rust_signer.RustSigner

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.example.neruwallet/security"
    private lateinit var securityProvider: SecurityProvider
    private val rustSigner: RustSigner by lazy { RustSigner() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        securityProvider = SecurityProvider(this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "generateKey" -> {
                    if (securityProvider.generateHardwareBackedKey()) {
                        result.success(true)
                    } else {
                        result.error(
                            "KEY_GEN_FAILED",
                            "Failed to generate hardware-backed key",
                            null
                        )
                    }
                }

                "signData" -> {
                    val dataToSign = call.argument<ByteArray>("data")
                    if (dataToSign == null) {
                        result.error("INVALID_ARGUMENT", "Data to sign is null", null)
                        return@setMethodCallHandler
                    }
                    authenticateAndSign(dataToSign, result)
                }

                "isKeyGenerated" -> {
                    result.success(securityProvider.isKeyGenerated())
                }

                "getPublicKey" -> {
                    val publicKey = securityProvider.getPublicKey()
                    if (publicKey != null) {
                        result.success(publicKey)
                    } else {
                        result.error("KEY_NOT_FOUND", "Public key not found", null)
                    }
                }

                "setSecure" -> {
                    val isSecure = call.argument<Boolean>("isSecure") ?: false
                    if (isSecure) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }

                // Rust-backed cryptographic operations
                "processTransactionData" -> {
                    val data = call.argument<ByteArray>("data")
                    if (data != null) {
                        Log.d(
                            "RustSigner",
                            "Kotlin: Initiating Rust hashing for ${data.size} bytes"
                        )
                        try {
                            val startTime = System.currentTimeMillis()
                            val processed =
                                rustSigner.processTransactionData(data.map { it.toUByte() })
                            val endTime = System.currentTimeMillis()
                            Log.d(
                                "RustSigner",
                                "Kotlin: Rust hashing completed in ${endTime - startTime}ms"
                            )
                            result.success(processed.map { it.toByte() }.toByteArray())
                        } catch (e: Exception) {
                            Log.e("RustSigner", "Kotlin: Rust hashing failed: ${e.message}")
                            result.error("RUST_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Data is null", null)
                    }
                }

                "verifyRustSignature" -> {
                    val pubKey = call.argument<ByteArray>("publicKey")
                    val msg = call.argument<ByteArray>("message")
                    val sig = call.argument<ByteArray>("signature")
                    if (pubKey != null && msg != null && sig != null) {
                        Log.d("RustSigner", "Kotlin: Initiating Rust signature verification")
                        try {
                            val startTime = System.currentTimeMillis()
                            val isValid = rustSigner.verifySignature(
                                pubKey.map { it.toUByte() },
                                msg.map { it.toUByte() },
                                sig.map { it.toUByte() }
                            )
                            val endTime = System.currentTimeMillis()
                            Log.d(
                                "RustSigner",
                                "Kotlin: Rust verification completed in ${endTime - startTime}ms. Result: $isValid"
                            )
                            result.success(isValid)
                        } catch (e: Exception) {
                            Log.e("RustSigner", "Kotlin: Rust verification failed: ${e.message}")
                            result.error("RUST_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing arguments for verification", null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun authenticateAndSign(data: ByteArray, result: MethodChannel.Result) {
        val executor: Executor = ContextCompat.getMainExecutor(this)
        val signature = securityProvider.getSignatureObject()

        if (signature == null) {
            result.error("KEY_NOT_FOUND", "Signing key not found. Generate it first.", null)
            return
        }

        val biometricPrompt = BiometricPrompt(
            this, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    result.error("AUTH_ERROR", errString.toString(), null)
                }

                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(authResult)
                    try {
                        val cryptoSignature = authResult.cryptoObject?.signature
                        cryptoSignature?.update(data)
                        val signedData = cryptoSignature?.sign()
                        result.success(signedData)
                    } catch (e: Exception) {
                        result.error("SIGNING_FAILED", e.message, null)
                    }
                }

                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Authentication failed, but user can try again (e.g. wrong finger)
                }
            })

        val promptInfoBuilder = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authorize Transaction")
            .setSubtitle("Sign transaction using hardware-backed key")

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            promptInfoBuilder.setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
        } else {
            promptInfoBuilder.setNegativeButtonText("Cancel")
        }

        biometricPrompt.authenticate(
            promptInfoBuilder.build(),
            BiometricPrompt.CryptoObject(signature)
        )
    }
}

