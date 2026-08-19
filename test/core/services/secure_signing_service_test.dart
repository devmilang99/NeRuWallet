import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_testrt 'package:neruwallet/src/rust/api.dart';
import 'package:neruwallet/src/rust/frb_generated.dart';

class MockRustLibApi extends RustLibApi {
  Uint8List? processTransactionDataResult;

  @override
  Future<Uint8List> crateApiProcessTransactionData({
    required List<int> data,
  }) async {
    return processTransactionDataResult ?? Uint8List(0);
  }

  @override
  Future<bool> crateApiVerifySignature({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  }) async => true;

  @override
  Future<RustSigner> crateApiRustSignerNew() async => const RustSigner();

  @override
  Future<Uint8List> crateApiRustSignerProcessTransactionData({
    required RustSigner that,
    required List<int> data,
  }) async => Uint8List(0);

  @override
  Future<bool> crateApiRustSignerVerifySignature({
    required RustSigner that,
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  }) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockRustLibApi mockApi;
  const channel = MethodChannel('com.example.neruwallet/security');

  setUpAll(() {
    mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    container = ProviderContainer();
    mockApi.processTransactionDataResult = null;
  });

  tearDown(() {
    container.dispose();
  });

  group('SecureSigningService', () {
    test('signData calls platform channel', () async {
      final testData = Uint8List.fromList([1, 2, 3]);
      final expectedSignature = Uint8List.fromList([4, 5, 6]);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            if (methodCall.method == 'signData') {
              return expectedSignature;
            }
            return null;
          });

      final signingService = container.read(secureSigningServiceProvider);
      final result = await signingService.signData(testData);

      expect(result, equals(expectedSignature));
    });

    test(
      'signDataWithRustHash hashes with Rust then signs with Hardware',
      () async {
        final rawData = Uint8List.fromList([1, 2, 3]);
        final hashedData = Uint8List.fromList([10, 20, 30]);
        final finalSignature = Uint8List.fromList([100, 200]);

        mockApi.processTransactionDataResult = hashedData;

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'signData') {
                // Ensure it's signing the HASHED data, not the raw data
                final dataArg = methodCall.arguments['data'] as Uint8List;
                if (listEquals(dataArg, hashedData)) {
                  return finalSignature;
                }
              }
              return null;
            });

        final signingService = container.read(secureSigningServiceProvider);
        final result = await signingService.signDataWithRustHash(rawData);

        expect(result, equals(finalSignature));
      },
    );
  });
}
