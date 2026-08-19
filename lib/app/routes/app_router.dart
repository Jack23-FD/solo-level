import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/plans/create_plan_screen.dart';
import '../../screens/plans/plan_detail_screen.dart';
import '../../screens/plans/plan_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../services/audio_service.dart';

class PageSoundObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute != null) {
      AudioService.playPageChange();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      AudioService.playPageChange();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AudioService.playPageChange();
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    observers: [PageSoundObserver()],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/plans',
        builder: (context, state) => const PlanListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePlanScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final planId = state.pathParameters['id'] ?? '';
              return PlanDetailScreen(planId: planId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
