import 'package:flashcard/domain/use_case/ai/generate_deck_with_ai_use_case.dart';
import 'package:flashcard/presentation/components/bars/flashcard_app_bar.dart';
import 'package:flashcard/presentation/components/buttons/gradient_button.dart';
import 'package:flashcard/presentation/components/inputs/text_input_field.dart';
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
  int _numberOfCards = 10;
  final GenerateDeckWithAIUseCase _generateDeckWithAIUseCase = getIt<GenerateDeckWithAIUseCase>();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FlashcardAppBar(
          title: "Generate Deck with AI",
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        Center(
                          child: Text("Enter a prompt to generate a deck of flashcards. The AI will create a deck based on your input.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.black87,),
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
                                    color: Colors.white.withValues(alpha: 0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        TextInputField(
                                          value: _promptText,
                                          onValueChanged: (value){
                                            setState(() {
                                              _promptText = value;
                                            });
                                          },
                                          hint: "Enter your prompt here",
                                        ),
                                        const SizedBox(height: 16.0),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Select maximum number of cards",
                                                style: TextStyle(fontSize: 12, color: Colors.black54),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Container(
                                                decoration: BoxDecoration(
                                                  // Add rounded border
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  border: Border.all(
                                                    color: Colors.black.withValues(alpha: 0.4), // Use withValues for
                                                    width: 1.0,
                                                  )
                                                ),
                                                child: DropdownButton<int>(
                                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                                  underline: Container(
                                                    height: 0,
                                                    color: Colors.black.withValues(alpha: 0.4),
                                                  ),
                                                  icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                                                  iconSize: 24,
                                                  dropdownColor: Colors.white,
                                                  focusColor:  Colors.white,
                                                  alignment: Alignment.center,
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  style: TextStyle(fontSize: 18, color: Colors.black87),
                                                  value: _numberOfCards,
                                                  items: [5, 10, 15, 20].map((int value) {
                                                    return DropdownMenuItem<int>(
                                                      value: value,
                                                      child: Text(value.toString()),
                                                    );
                                                  }).toList(),
                                                  onChanged: (int? newValue) {
                                                    setState(() {
                                                      _numberOfCards = newValue ?? 10;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 48.0),
                                Opacity(
                                  opacity: _isGenerating ? 0.5 : 1.0,
                                  child: GradientButton(
                                      text: "Generate Deck",
                                      icon: Icon(CupertinoIcons.sparkles, color: Colors.white),
                                      onPressed: () async {
                                        if (_promptText.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.redAccent,
                                              content: Text("Please enter a prompt to generate the deck."),
                                              duration: Duration(seconds: 2),
                                            )
                                          );
                                          return;
                                        }
                                        if (_isGenerating){
                                          return;
                                        }
                                        setState(() {
                                          _isGenerating = true;
                                        });
                                        Deck deck = await _generateDeckWithAIUseCase(
                                            prompt: _promptText, count: _numberOfCards
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
                                ),

                                const SizedBox(height: 48.0),
                              ],
                            ),
                          ),
                        )
                      ],),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: Colors.black38,
                            size: 24.0,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                              child: Text(
                                "The AI will generate a deck based on your prompt. "
                                    "The generated deck will contain a maximum of $_numberOfCards cards. "
                                    "Please note that language models may not always produce accurate or relevant results, so review the generated cards before using them.",
                                style: TextStyle(fontSize: 10, color: Colors.black54),
                                textAlign: TextAlign.start,
                              )
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    )
                  ],
                )
            )
        )
    );
  }
}