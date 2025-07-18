import 'package:flashcard/domain/use_case/ai/generate_deck_with_ai_use_case.dart';
import 'package:flashcard/presentation/components/bars/flashcard_app_bar.dart';
import 'package:flashcard/presentation/components/buttons/gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../core/config/di/config_di.dart';
import '../../../domain/entities/deck.dart';

class AIGenerateDeckScreen extends StatefulWidget {
  const AIGenerateDeckScreen({super.key});

  @override
  State<AIGenerateDeckScreen> createState() => _AIGenerateDeckScreenState();

}

class _AIGenerateDeckScreenState extends State<AIGenerateDeckScreen> {
  final Logger _logger = getIt<Logger>();
  String _promptText = "";
  final GenerateDeckWithAIUseCase _generateDeckWithAIUseCase = getIt<GenerateDeckWithAIUseCase>();
  bool _isGenerating = false;

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
                  const SizedBox(height: 64.0),
                  Center(
                    child: Text("Generate Deck with AI",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w600, height: 0.9,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 32.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(width: 1.0, color: Colors.black.withValues(alpha: 0.4)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 2,
                                  blurRadius: 32,
                                  offset: Offset(0, 10), // changes position of shadow
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _promptText = value;
                                });
                              },
                              maxLines: 1,
                              decoration: InputDecoration(
                                hintText: "Enter your prompt here",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 64.0),
                          Opacity(
                            opacity: _isGenerating ? 0.5 : 1.0,
                            child: GradientButton(
                                text: "Generate Deck",
                                icon: Icon(CupertinoIcons.sparkles, color: Colors.white),
                                onPressed: () async {
                                  if (_isGenerating){
                                    return;
                                  }
                                  setState(() {
                                    _isGenerating = true;
                                  });
                                  Deck deck = await _generateDeckWithAIUseCase(
                                      prompt: _promptText
                                  );
                                  setState(() {
                                    _isGenerating = false;
                                  });
                                  _logger.i("Deck generated with prompt: $_promptText");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Deck generated successfully!"),
                                        duration: Duration(seconds: 2),
                                      )
                                  );
                                  if (mounted){
                                    context.pushNamed("deck_preview", extra: deck);
                                  }
                                }),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            )
            )
        )
    );
  }
}