import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:project/core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

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
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShareUP',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: true,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
