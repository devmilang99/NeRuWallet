// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neruwallet/core/providers/init_provider.dart';
import 'package:neruwallet/main.dart';

void main() {
  testWidgets('app boots with provider scope', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appInitProvider.overrideWithValue(Future.value())],
        child: const NeRuWalletApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Pump for a duration to bypass the splash screen branding delay
    // Using multiple pumps instead of pumpAndSettle to avoid infinite animation timeout
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
