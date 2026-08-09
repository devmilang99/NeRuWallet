import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neruwallet/core/services/rust_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RustService rustService;
  const channel = MethodChannel('com.example.neruwallet/security');

  setUp(() {
    rustService = RustService();
  });

  group('RustService', () {
    test('processTransactionData calls the correct method channel', () async {
      final testData = Uint8List.fromList([1, 2, 3]);
      final expectedHash = Uint8List.fromList(List.generate(32, (i) => i));

      // Mocking the MethodChannel response
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'processTransactionData') {
              return expectedHash;
            }
            return null;
          });

      final result = await rustService.processTransactionData(testData);

      expect(result, isNotNull);
      expect(result, equals(expectedHash));
    });

    test(
      'verifySignature returns true when native side returns true',
      () async {
        final pubKey = Uint8List(65);
        final msg = Uint8List.fromList([1, 2, 3]);
        final sig = Uint8List(64);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'verifyRustSignature') {
                return true;
              }
              return false;
            });

        final isValid = await rustService.verifySignature(
          publicKey: pubKey,
          message: msg,
          signature: sig,
        );

        expect(isValid, isTrue);
      },
    );

    test('returns null when platform channel throws exception', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            throw PlatformException(code: 'ERROR');
          });

      final result = await rustService.processTransactionData(Uint8List(0));
      expect(result, isNull);
    });
  });
}
