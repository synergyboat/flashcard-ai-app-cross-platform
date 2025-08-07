import 'dart:math';
import 'package:flashcard/core/utils/navigation_helper.dart';
import 'package:flashcard/domain/entities/deck.dart';
import 'package:flashcard/domain/use_case/deck/get_all_decks_use_case.dart';
import 'package:flashcard/presentation/components/bars/flashcard_bottom_action_bar.dart';
import 'package:flashcard/presentation/components/buttons/ai_button.dart';
import 'package:flashcard/presentation/components/containers/deck_collection_grid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../core/config/di/config_di.dart';
import '../../../domain/use_case/deck/delete_deck_use_case.dart';
import '../../../domain/use_case/deck/update_deck_use_case.dart';
import '../../components/bars/flashcard_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetAllDecksUseCase _getAllDecksUseCase = getIt<GetAllDecksUseCase>();
  final DeleteDeckUseCase _deleteDeckUseCase = getIt<DeleteDeckUseCase>();
  final UpdateDeckUseCase _updateDeckUseCase = getIt<UpdateDeckUseCase>();
  final Logger _logger = getIt<Logger>();
  bool showText = false;
  List<Deck> decks = [];

  void _toggleShowText(){
    setState(() {
      showText = true;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (showText) {
        setState(() {
          showText = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _toggleShowText();
  }


  void _refresh(){
    if (kDebugMode){
      _logger.i("Refreshing decks");
    }
    _getAllDecksUseCase().then((value) {
      setState(() {
        decks = value;
        showText = decks.isEmpty;
        _toggleShowText();
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
        trailing:(decks.isEmpty)? null
            :AIButton(
          showText: showText,
            onPressed: () {
              _logger.i("AI button pressed");
              context.push("/ai_generate_deck");
            }
        ),
      ),
      appBar: FlashcardAppBar(),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: (decks.isEmpty)?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "No decks found. \nCreate a new deck to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      AIButton(
                          showText: true,
                          onPressed: () {
                            _logger.i("AI button pressed");
                            context.push("/ai_generate_deck");
                          }
                      )
                    ],
                  ),
                )
            :
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: DeckCollectionGrid(
                      decks: decks,
                      deleteDeckUseCase: _deleteDeckUseCase,
                      updateDeckUseCase: _updateDeckUseCase,
                      refreshDecks: _refresh,
                      onDeckSelected: (Deck deck)=>{
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