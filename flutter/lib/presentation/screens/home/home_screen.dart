import 'dart:math';
import 'package:flashcard/presentation/components/bars/flashcard_bottom_action_bar.dart';
import 'package:flashcard/presentation/components/buttons/add_button.dart';
import 'package:flashcard/presentation/components/buttons/ai_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../core/config/di/config_di.dart';
import '../../components/bars/flashcard_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final Logger _logger = getIt<Logger>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FlashcardBottomActionBar(
          leading: AIButton(
            onPressed: () {
              _logger.i("AI button pressed");
             context.push("/ai_generate_deck");
            }
          ),
        trailing: AddButton(
          onPressed: () {
            _logger.i("AI button pressed");
            context.push("/ai_generate_deck");
          })
      ),
      appBar: FlashcardAppBar(),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Your deck collection is empty.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: [
                                Text(
                                  "Generate using AI",
                                  style: TextStyle(fontSize: 14, color: Colors.black38),
                                ),
                                const SizedBox(height: 16),
                                Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateZ(pi / 2.5),
                                  child: Column(
                                    children: [
                                      Opacity(
                                        opacity: 0.25,
                                        child: SvgPicture.asset(
                                          'assets/svg/curved-arrow.svg',
                                          height: 80,
                                          semanticsLabel: 'Squiggly Arrow',
                                        ),
                                      ),
                                    ],
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              children: [
                                Text(
                                  "Create deck manually",
                                  style: TextStyle(fontSize: 14, color: Colors.black38),
                                ),
                                const SizedBox(height: 16),
                                Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..scale(-1.0, 1.0)
                                      ..rotateZ(pi / 2.5),
                                    child: Opacity(
                                      opacity: 0.25,
                                      child: SvgPicture.asset(
                                        'assets/svg/curved-arrow.svg',
                                        height: 80,
                                        semanticsLabel: 'Squiggly Arrow',
                                      ),
                                    )
                                )
                              ],
                            ),
                          ),
                        ),
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