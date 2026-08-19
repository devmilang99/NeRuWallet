import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:neruwallet/core/services/rust_service.dart';
import 'package:neruwallet/src/rust/api.dart';
import 'package:neruwallet/src/rust/frb_generated.dart';

class MockRustLibApi extends RustLibApi {
  Uint8List? processTransactionDataResult;
  bool? verifySignatureResult;
  Object? errorToThrow;

  @override
  Future<Uint8List> crateApiProcessTransactionData({
    required List<int> data,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return processTransactionDataResult ?? Uint8List(0);
  }

  @override
  Future<bool> crateApiVerifySignature({
    required List<int> publicKey,
    required List<int> message,
    required List<int> signature,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return verifySignatureResult ?? false;
  }

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

  late RustService rustService;
  late MockRustLibApi mockApi;

  setUpAll(() {
    mockApi = MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    // Reset mock state before each test
    mockApi.processTransactionDataResult = null;
    mockApi.verifySignatureResult = null;
    mockApi.errorToThrow = null;
    rustService = RustService();
  });

  group('RustService', () {
    test('processTransactionData calls the correct native method', () async {
      final testData = Uint8List.fromList([1, 2, 3]);
      final expectedHash = Uint8List.fromList(List.generate(32, (i) => i));

      mockApi.processTransactionDataResult = expectedHash;

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

        mockApi.verifySignatureResult = true;

        final isValid = await rustService.verifySignature(
          publicKey: pubKey,
          message: msg,
          signature: sig,
        );

        expect(isValid, isTrue);
      },
    );

    test('returns null when platform side throws exception', () async {
      mockApi.errorToThrow = Exception('Native Error');

      final result = await rustService.processTransactionData(Uint8List(0));
      expect(result, isNull);
    });
  });
}
