import 'package:go_router/go_router.dart';

import 'features/about/about_screen.dart';
import 'features/account/account_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/contact/contact_screen.dart';
import 'features/news/news_detail_screen.dart';
import 'features/news/news_list_screen.dart';
import 'features/onboarding/sector_picker_screen.dart';
import 'features/resources/resources_screen.dart';
import 'features/services/services_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/technology/technology_screen.dart';
import 'features/tools/checklist_screen.dart';
import 'features/tools/goaml_calculator_screen.dart';
import 'features/tools/health_check_screen.dart';
import 'features/tools/risk_rating_screen.dart';
import 'features/tools/service_finder_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) => AppShell(initialTab: int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0),
    ),
    GoRoute(path: '/me', builder: (context, state) => const AccountScreen()),
    GoRoute(path: '/welcome', builder: (context, state) => const SectorPickerScreen()),
    GoRoute(path: '/sector', builder: (context, state) => const SectorPickerScreen(fromSettings: true)),
    GoRoute(path: '/health-check', builder: (context, state) => const HealthCheckScreen()),
    GoRoute(path: '/service-finder', builder: (context, state) => const ServiceFinderScreen()),
    GoRoute(path: '/tools/risk', builder: (context, state) => const RiskRatingScreen()),
    GoRoute(path: '/tools/goaml', builder: (context, state) => const GoamlCalculatorScreen()),
    GoRoute(path: '/tools/checklist', builder: (context, state) => const ChecklistScreen()),
    GoRoute(path: '/resources', builder: (context, state) => const ResourcesScreen()),
    GoRoute(path: '/news', builder: (context, state) => const NewsListScreen()),
    GoRoute(path: '/services', builder: (context, state) => const ServicesScreen()),
    GoRoute(path: '/technology', builder: (context, state) => const TechnologyScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(
      path: '/contact',
      builder: (context, state) => ContactScreen(initialMessage: state.extra is String ? state.extra as String : null),
    ),
    GoRoute(
      path: '/news/:id',
      builder: (context, state) => NewsDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  ],
);
