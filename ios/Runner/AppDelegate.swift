import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let secureEnclaveProvider = SecureEnclaveProvider()

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

            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
