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
  int _numberOfCards = 10;
  final GenerateDeckWithAIUseCase _generateDeckWithAIUseCase = getIt<GenerateDeckWithAIUseCase>();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FlashcardAppBar(
          title: "",
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                  children: [
                    Center(
                      child: Text("Generate Deck with AI",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.w600,),
                      ),
                    ),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 2,
                                    blurRadius: 32,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    TextField(
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
                                          borderSide: BorderSide.none, // Disable default border
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            width: 1.0,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            style: BorderStyle.solid,
                                            color: Colors.black.withValues(alpha: 0.4), // Preferred over withValues
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            width: 1.0,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            style: BorderStyle.solid,
                                            color: Colors.black.withValues(alpha: 0.4),
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            width: 1.0,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            style: BorderStyle.solid,
                                            color: Colors.black.withValues(alpha: 0),
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            width: 1.0,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            style: BorderStyle.solid,
                                            color: Colors.redAccent.withValues(alpha: 0.4), // Or use Colors.red for errors
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                            width: 1.0,
                                            strokeAlign: BorderSide.strokeAlignInside,
                                            style: BorderStyle.solid,
                                            color:Colors.redAccent.withValues(alpha: 0.4), // Or use Colors.red
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Select number of cards",
                                            style: TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                          const SizedBox(width: 8.0),
                                          DropdownButton<int>(
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
                                        ],
                                      ),
                                    )
                                  ],
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
                            )
                          ],
                        ),
                      ),
                    )
                                ],
                              ),
                )
            )
        )
    );
  }
}