import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/init_provider.dart';
import 'package:neruwallet/core/providers/theme_provider.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/encryption_service.dart';
import 'package:neruwallet/core/services/error_handler.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/app_router.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/core/widgets/global_error_screen.dart';
import 'package:neruwallet/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Interception
  // For framework-level errors (e.g. build phase)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.e('Flutter Framework Error', details.exception, details.stack);
  };

  // For async errors not caught by try-catch
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e('Uncaught Async Error', error, stack);
    return true; // Error was handled
  };

  // UI for crashes in build methods
  ErrorWidget.builder = (details) =>
      GlobalErrorScreen(error: details.exception, stackTrace: details.stack);

  // Set up edge-to-edge display
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  final initCompleter = Completer<void>();

  try {
    // 1. Load environment variables
    await dotenv.load();

    // 2. Initialize Firebase & Supabase in parallel
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',
        publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      ),
    ]);

    initCompleter.complete();
  } catch (e, stack) {
    AppLogger.e('System Initialization Failed', e, stack);
    if (!initCompleter.isCompleted) initCompleter.complete();
  }

  // 3. Setup Riverpod container with the init future
  final container = ProviderContainer(
    overrides: [appInitProvider.overrideWithValue(initCompleter.future)],
  );

  // 4. Initialize Database & Encryption
  try {
    final encryptionService = container.read(encryptionServiceProvider);
    await encryptionService.init();
    container.read(appDatabaseProvider);
  } catch (e) {
    AppLogger.e('Service Initialization Failed', e);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NeRuWalletApp(),
    ),
  );
}

class NeRuWalletApp extends ConsumerWidget {
  const NeRuWalletApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);
    final messengerKey = ref.watch(scaffoldMessengerKeyProvider);

    return MaterialApp.router(
      title: 'NeRuWallet',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
