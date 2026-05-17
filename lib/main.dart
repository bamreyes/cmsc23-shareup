import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/theme/app_theme.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'firebase_options.dart';
import 'package:project/core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/features/feed/providers/feed_provider.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/home/providers/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('App starting: Widgets initialized');

  try {
    debugPrint('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Firebase initialization timed out after 10s');
        throw Exception('Firebase initialization timeout');
      },
    );
    debugPrint('Firebase initialization successful');

    debugPrint('Loading environment variables...');
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded');
  } catch (e) {
    debugPrint('Initialization failed: $e');
  }

  debugPrint('Calling runApp...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: feedProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => ExchangeProvider()),
        ChangeNotifierProvider.value(value: homeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final appMode = profile.currentUser?.appMode ?? AppMode.system;

    return MaterialApp.router(
      title: 'ShareUP',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: true,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(appMode),
    );
  }

  ThemeMode _getThemeMode(AppMode mode) {
    switch (mode) {
      case AppMode.light:
        return ThemeMode.light;
      case AppMode.dark:
        return ThemeMode.dark;
      case AppMode.system:
        return ThemeMode.system;
    }
  }
}
