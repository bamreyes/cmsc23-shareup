import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/auth/screens/sign_up_screen.dart';
import 'package:project/features/auth/screens/login_screen.dart';
import 'package:project/features/feed/screens/feed_screen.dart';
import 'package:project/features/feed/screens/feed_item_screen.dart';
import 'package:project/features/feed/screens/request_item_screen.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/features/home/screens/home_screen.dart';
import 'package:project/features/exchanges/screens/exchanges_screen.dart';
import 'package:project/features/exchanges/screens/item_screen.dart';
import 'package:project/features/exchanges/screens/request_details_screen.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/features/profile/screens/profile_screen.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/core/widgets/navigation/main_navigation_shell.dart';
import 'package:project/features/notifications/screens/notification_screen.dart';
import 'package:project/features/exchanges/screens/add_item_screen.dart';
import 'package:project/features/exchanges/screens/scan_qr_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: Listenable.merge([authProvider, profileProvider]),
  redirect: (context, state) {
    final isLoggedIn = authProvider.isLoggedIn;
    final hasProfile =
        profileProvider.userId != null && profileProvider.currentUser != null;

    final isLoggingIn =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    if (isLoggedIn && isLoggingIn && hasProfile) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(path: '/add-item', builder: (context, state) => const AddItem()),
    GoRoute(path: '/scan-qr', builder: (context, state) => const ScanScreen()),
    GoRoute(
      path: '/item-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final post = extra['post'] as PostModel;
        final user = extra['user'] as UserModel?;
        final distance = extra['distance'] as String?;
        return FeedItemScreen(post: post, user: user, distance: distance);
      },
    ),
    GoRoute(
      path: '/request',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final post = extra['post'] as PostModel;
        final user = extra['user'] as UserModel?;
        final distance = extra['distance'] as String?;
        return RequestItemScreen(
          post: post,
          initialUser: user,
          initialDistance: distance,
        );
      },
    ),
    GoRoute(
      path: '/item',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final post = extra['post'] as PostModel;
        final user = extra['user'] as UserModel;
        return ItemScreen(post: post, user: user);
      },
    ),
    GoRoute(
      path: '/request-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final request = extra['request'] as RequestModel;
        final post = extra['post'] as PostModel;
        final postOwner = extra['postOwner'] as UserModel;
        return RequestDetailsScreen(
          request: request,
          post: post,
          postOwner: postOwner,
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exchanges',
              builder: (context, state) => const ExchangesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
