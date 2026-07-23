import 'package:go_router/go_router.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/plans/create_plan_screen.dart';
import '../../screens/plans/plan_detail_screen.dart';
import '../../screens/plans/plan_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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
