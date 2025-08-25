import 'package:flashcard/domain/entities/deck.dart';
import 'package:flashcard/presentation/screens/ai_generator/deck_preview_screen.dart';
import 'package:flashcard/presentation/screens/benchmark/list_render_benchmark_screen.dart';
import 'package:flashcard/presentation/screens/deck/deck_details_screen.dart';
import 'package:flashcard/presentation/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

import '../screens/ai_generator/ai_generate_deck_screen.dart';

final List<GoRoute> routes = [
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
        return DeckDetailsScreen(deck: deckId);
    }),
  GoRoute(
      name: 'deck_preview',
      path: '/deck_preview',
      builder: (context, state) {
        final Deck deckId = state.extra as Deck;
        return DeckPreviewScreen(deck: deckId);
    }),
  GoRoute(
    name: 'benchmark',
    path: '/benchmark',
    builder: (context, state) => const ListRenderBenchmarkScreen(
      itemCount: 100, benchmarkType: BenchmarkType.scrollPerformance, iterations: 3,
    )
  )
];