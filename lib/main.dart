import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neruwallet/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Use a ProviderContainer to access and initialize services before the UI is ready
  final container = ProviderContainer();
  
  try {
    // Initialize notification handling (FCM)
    await container.read(notificationServiceProvider).initialize();
  } catch (e) {
    debugPrint('Notification initialization error: $e');
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
