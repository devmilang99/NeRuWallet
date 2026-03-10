import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/permission_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires firebase_options.dart for Web/Desktop)
  try {
    // Note: To use Firebase, run:
    // /home/milan/.pub-cache/bin/flutterfire configure
    // to generate firebase_options.dart, then pass the options here.
    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp();
    } else {
      // For Linux/Web, initializeApp requires options.
      // We skip it for now to allow the app to run without crashing.
      debugPrint("Skipping Firebase initialization on this platform (missing firebase_options.dart)");
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Check initial permissions
  await PermissionUtils.checkInitialPermissions();

  runApp(
    const ProviderScope(
      child: NeRuWalletApp(),
    ),
  );
}

class NeRuWalletApp extends StatelessWidget {
  const NeRuWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeRuWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
