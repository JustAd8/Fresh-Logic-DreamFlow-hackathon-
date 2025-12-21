import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fridgeflow/services/user_service.dart';
import 'package:fridgeflow/screens/onboarding_screen.dart';
import 'package:fridgeflow/screens/dashboard_screen.dart';
import 'package:fridgeflow/screens/pantry_screen.dart';
import 'package:fridgeflow/screens/recipes_screen.dart';
import 'package:fridgeflow/screens/shop_screen.dart';
import 'package:fridgeflow/screens/cooking_mode_screen.dart';
import 'package:fridgeflow/screens/main_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) {
      final hasUser = UserService().hasUser;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (!hasUser && !isOnboarding) {
        return AppRoutes.onboarding;
      }

      if (hasUser && isOnboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(
            currentIndex: 0,
            child: DashboardScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.pantry,
        name: 'pantry',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(
            currentIndex: 1,
            child: PantryScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.recipes,
        name: 'recipes',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(
            currentIndex: 2,
            child: RecipesScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.shop,
        name: 'shop',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainShell(
            currentIndex: 3,
            child: ShopScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.cooking}/:recipeId',
        name: 'cooking',
        builder: (context, state) {
          final recipeId = state.pathParameters['recipeId']!;
          return CookingModeScreen(recipeId: recipeId);
        },
      ),
    ],
  );
}

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String pantry = '/pantry';
  static const String recipes = '/recipes';
  static const String shop = '/shop';
  static const String cooking = '/cooking';
}
