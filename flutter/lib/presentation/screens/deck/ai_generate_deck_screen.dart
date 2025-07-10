import 'package:flashcard/presentation/components/bars/flashcard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../core/config/di/config_di.dart';

class AIGenerateDeckScreen extends StatefulWidget {
  const AIGenerateDeckScreen({super.key});

  @override
  State<AIGenerateDeckScreen> createState() => _AIGenerateDeckScreenState();

}

class _AIGenerateDeckScreenState extends State<AIGenerateDeckScreen> {
  final Logger _logger = getIt<Logger>();
  String _promptText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FlashcardAppBar(
          title: "AI Generate Deck",
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                children: [
                  const SizedBox(height: 32.0),
                  Center(
                    child: Text("Generate Deck with AI",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600, height: 0.9,),
                    ),
                  ),
              ],
            )
            )
        )
    );
  }
}