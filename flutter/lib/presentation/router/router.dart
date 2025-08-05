import 'package:flashcard/presentation/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ...routes,
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    );
  },
);