import 'package:flashcard/presentation/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';

final List<GoRoute> routes = [
  GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) => const SplashScreen()),
  GoRoute(
    name: 'home',
    path: '/home',
    builder: (context, state) => const HomeScreen()),
];