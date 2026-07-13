import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/providers/init_provider.dart';
import 'package:neruwallet/core/providers/theme_provider.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/app_router.dart';
import 'package:neruwallet/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final initCompleter = Completer<void>();

  final container = ProviderContainer(
    overrides: [appInitProvider.overrideWithValue(initCompleter.future)],
  );

  // Use Timer.run to push this task to the next event loop iteration
  // allowing the engine to process the initial build and paint of NeRuWalletApp first.
  Timer.run(() async {
    try {
      await dotenv.load(fileName: ".env");
      await Future.wait([
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        Supabase.initialize(
          url: dotenv.env['SUPABASE_URL'] ?? '',
          publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
        ),
      ]);
    } catch (e) {
      debugPrint('System Init Error: $e');
    } finally {
      if (!initCompleter.isCompleted) initCompleter.complete();
    }
  });

  // Database initialization happens after the first frame is rendered
  WidgetsBinding.instance.addPostFrameCallback((_) {
    container.read(appDatabaseProvider);
  });

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

    return MaterialApp.router(
      title: 'NeRuWallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
