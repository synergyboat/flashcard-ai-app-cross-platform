import 'dart:math';
import 'package:flashcard/core/utils/navigation_helper.dart';
import 'package:flashcard/domain/entities/deck.dart';
import 'package:flashcard/domain/use_case/deck/get_all_decks_use_case.dart';
import 'package:flashcard/presentation/components/bars/flashcard_bottom_action_bar.dart';
import 'package:flashcard/presentation/components/buttons/add_button.dart';
import 'package:flashcard/presentation/components/buttons/ai_button.dart';
import 'package:flashcard/presentation/components/containers/deck_collection_grid.dart';
import 'package:flutter/foundation.dart';
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
  final GetAllDecksUseCase _getAllDecksUseCase = getIt<GetAllDecksUseCase>();
  final Logger _logger = getIt<Logger>();
  List<Deck> decks = [];

  void _refresh(){
    if (kDebugMode){
      _logger.i("Refreshing decks");
    }
    _getAllDecksUseCase().then((value) {
      setState(() {
        decks = value;
      });
    }).catchError((error) {
      _logger.e("Error fetching decks: $error");
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // This runs when the widget is first created
  //   _refresh();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when the route changes
    final currentRoute = getCurrentRouteName(context);
    if (currentRoute == 'home') {
      _refresh();
    }
  }


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
            child: (decks.isEmpty)?
                Stack(
            children: [
              Center(
                child: Text(
                  "No decks found. Create a new deck to get started.",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
            ]
                )
            :
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: DeckCollectionGrid(decks: decks, onDeckSelected: (Deck deck)=>{
                    context.pushNamed("deck", extra: deck)
                  }),
                ),
              ],
            )
          )
      )
    );
  }
}