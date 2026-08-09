import 'package:go_router/go_router.dart';

import 'features/about/about_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/contact/contact_screen.dart';
import 'features/news/news_detail_screen.dart';
import 'features/services/services_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/technology/technology_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const AppShell()),
    GoRoute(path: '/services', builder: (context, state) => const ServicesScreen()),
    GoRoute(path: '/technology', builder: (context, state) => const TechnologyScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    GoRoute(path: '/contact', builder: (context, state) => const ContactScreen()),
    GoRoute(
      path: '/news/:id',
      builder: (context, state) => NewsDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  ],
);
