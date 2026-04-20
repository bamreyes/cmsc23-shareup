import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/landing_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
  } catch (e) {
    debugPrint('Firebase initialization failed or caught: $e');
  }

  debugPrint('Calling runApp...');
  // Uncomment for providers
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       // Add your global providers here
  //       // ChangeNotifierProvider(create: (_) => AuthProvider()),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareUP',
      debugShowCheckedModeBanner: true,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}
