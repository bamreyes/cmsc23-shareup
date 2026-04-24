import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:project/features/auth/screens/sign_up_screen.dart';
import 'package:project/features/auth/screens/login_screen.dart';
import 'package:project/features/home/screens/not_found_screen.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/core/widgets/navigation/main_navigation_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: authProvider,
  redirect: (context, state) {
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoggingIn =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exchanges',
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const NotFoundScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
