import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let secureEnclaveProvider = SecureEnclaveProvider()
    private lazy var rustSigner = RustSigner()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let securityChannel = FlutterMethodChannel(name: "com.example.neruwallet/security",
                                                  binaryMessenger: controller.binaryMessenger)

        securityChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

            switch call.method {
            case "generateKey":
                if self?.secureEnclaveProvider.generateSecureKey() == true {
                    result(true)
                } else {
                    result(FlutterError(code: "KEY_GEN_FAILED",
                                       message: "Failed to generate Secure Enclave key",
                                       details: nil))
                }

            case "signData":
                guard let args = call.arguments as? [String: Any],
                      let dataToSign = args["data"] as? FlutterStandardTypedData else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                       message: "Data is missing",
                                       details: nil))
                    return
                }

                self?.secureEnclaveProvider.signData(data: dataToSign.data) { signature, error in
                    if let signature = signature {
                        result(FlutterStandardTypedData(bytes: signature))
                    } else {
                        result(FlutterError(code: "SIGNING_FAILED",
                                           message: error,
                                           details: nil))
                    }
                }

            case "isKeyGenerated":
                result(self?.secureEnclaveProvider.isKeyGenerated() ?? false)

            case "getPublicKey":
                if let publicKey = self?.secureEnclaveProvider.getPublicKey() {
                    result(publicKey)
                } else {
                    result(FlutterError(code: "KEY_NOT_FOUND",
                                       message: "Public key not found",
                                       details: nil))
                }

            case "isScreenRecording":
                result(UIScreen.main.isCaptured)

            case "processTransactionData":
                guard let args = call.arguments as? [String: Any],
                      let data = args["data"] as? FlutterStandardTypedData else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                       message: "Data is missing",
                                       details: nil))
                    return
                }
                let processed = self?.rustSigner.processTransactionData(data: [UInt8](data.data))
                result(FlutterStandardTypedData(bytes: Data(processed ?? [])))

            case "verifyRustSignature":
                guard let args = call.arguments as? [String: Any],
                      let pubKey = args["publicKey"] as? FlutterStandardTypedData,
                      let msg = args["message"] as? FlutterStandardTypedData,
                      let sig = args["signature"] as? FlutterStandardTypedData else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                       message: "Missing arguments for verification",
                                       details: nil))
                    return
                }
                let isValid = self?.rustSigner.verifySignature(publicKey: [UInt8](pubKey.data),
                                                               message: [UInt8](msg.data),
                                                               signature: [UInt8](sig.data))
                result(isValid)

            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
