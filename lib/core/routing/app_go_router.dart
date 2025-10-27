// File: lib/core/routing/app_go_router.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quan_ly_chi_tieu/features/transactions/presentation/pages/transactions_form_page.dart';
import 'package:quan_ly_chi_tieu/features/transactions/presentation/pages/transactions_list_page.dart';
import 'go_router_refresh_change.dart';
import 'app_routes.dart';
import '../presentation/widget/customer_bottom_nav.dart';
import 'package:quan_ly_chi_tieu/features/home/presentation/pages/home_page.dart';
import 'package:quan_ly_chi_tieu/features/auth/presentation/pages/login_page.dart';
import 'package:quan_ly_chi_tieu/features/auth/presentation/pages/signup_page.dart';
import 'package:quan_ly_chi_tieu/features/splash/presentation/pages/splash_page.dart';

class AppGoRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),

      // Main app shell với bottom nav
      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = _getIndexForLocation(state.matchedLocation);
          return Scaffold(
            body: child,
            bottomNavigationBar: CustomerBottomNav(initialIndex: currentIndex),
          );
        },
        routes: [
          // TẤT CẢ VỀ HOME PAGE
          GoRoute(path: AppRoutes.home, builder: (context, state) => const HomePage()),
          GoRoute(path: AppRoutes.transactions, builder: (context, state) => const TransactionsListPage()),
          GoRoute(path: AppRoutes.addTransaction, builder: (context, state) => const TransactionsFormPage()),
          GoRoute(path: AppRoutes.statistics, builder: (context, state) => const HomePage()),
          GoRoute(path: AppRoutes.profile, builder: (context, state) => const HomePage()),
        ],
      ),
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final atSplash = state.matchedLocation == AppRoutes.splash;
      final loggingIn = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Nếu đang ở splash, không redirect - để splash tự xử lý
      if (atSplash) return null;

      if (!loggedIn && !loggingIn) return AppRoutes.login;
      if (loggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  );

  static int _getIndexForLocation(String path) {
    if (path.startsWith(AppRoutes.home)) return 0;
    else if (path.startsWith(AppRoutes.transactions)) return 1;
    else if (path.startsWith(AppRoutes.addTransaction)) return 2;
    else if (path.startsWith(AppRoutes.statistics)) return 3;
    else if (path.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }
}