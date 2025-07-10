import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../components/backgrounds/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBackground(
            child: Center(
              child: Text('Flashcard',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            )
        )
    );
  }
}