import 'package:flashcard/domain/entities/deck.dart';
import 'package:flashcard/presentation/screens/ai_generator/deck_preview_screen.dart';
import 'package:flashcard/presentation/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/ai_generator/ai_generate_deck_screen.dart';
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
  GoRoute(
    name: 'ai_generate_deck',
    path: '/ai_generate_deck',
    builder: (context, state) => const AIGenerateDeckScreen()),
  GoRoute(
      name: 'deck',
      path: '/deck',
      builder: (context, state) {
        final Deck deckId = state.extra as Deck;
        return DeckPreviewScreen(deck: deckId);
    }),
];