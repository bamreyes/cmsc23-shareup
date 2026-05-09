import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/features/feed/screens/request_item_screen.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

// ── IMPORT YOUR WIDGETS/SCREENS HERE ───────────────────────
import 'core/widgets/buttons/primary_button.dart';
import 'core/widgets/buttons/secondary_button.dart';
import 'package:project/features/auth/providers/auth_provider.dart';

import 'package:project/core/models/post_model.dart';

// PLAYGROUND GUIDE:
// 1. To test a FULL SCREEN:
//    Go to line 45 and swap 'PlaygroundHome()' with your screen (e.g. 'LandingScreen()').
// 2. To test INDIVIDUAL WIDGETS:
//    Keep 'PlaygroundHome()' and add your widgets to the 'children' list on line 75.
// 3. Run this file specifically:
//    `flutter run lib/playground.dart`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  // Uncomment to add your providers
  runApp(
    MultiProvider(
      providers: [
        // Add your global providers here if needed for testing
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const PlaygroundApp(),
    ),
  );
  // runApp(PlaygroundApp());
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mockPost = PostModel(
      userId: 'user_12345',
      name: 'Fresh Tomatoes',
      description:
          'Freshly picked tomatoes from my backyard garden. Perfect for salads or cooking!',
      image:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=800&q=80',
      expirationDate: DateTime.now().add(const Duration(days: 4)),
      dietaryTags: ['Vegan', 'Fresh Fruits', 'Raw Ingredient'],
      latitude: 14.1648,
      longitude: 121.2413,
      locationName: 'UPLB Gate',
      status: PostStatus.available,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now(),
    );
    return MaterialApp(
      title: 'ShareUP Playground',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── TEST TARGET ─────────────────────────────────────────
      // FOR SCREENS: Replace PlaygroundHome() with your screen
      // FOR WIDGETS: Use PlaygroundHome()
      // home: FeedItemScreen(post: mockPost),
      home: RequestItemScreen(post: mockPost),
      // ────────────────────────────────────────────────────────
    );
  }
}

/// Note: Do NOT use this for testing full screens (Scaffolds) as it will nest them.
class PlaygroundHome extends StatelessWidget {
  const PlaygroundHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Playground'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ADD THE COMPONENT YOU WANT TO SEE BELOW ──────
            SecondaryButton(text: 'SecondaryButton', onPressed: () {}),
            PrimaryButton(text: 'Testing Primary Button', onPressed: () {}),
            const SizedBox(height: 16),
            // Add more widgets here...
            // ──────────────────────────────────────────────────
          ],
        ),
      ),
    );
  }
}
