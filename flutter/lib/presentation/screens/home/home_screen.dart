import 'package:flashcard/domain/use_case/ai/generate_deck_with_ai_use_case.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../core/config/di/config_di.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final Logger _logger = getIt<Logger>();
  String _promptText = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children:[
                TextField(
                  onChanged: (text){
                    setState(() {
                      _promptText = text;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: "Enter search term",
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(onPressed: ()=>{
                  getIt<GenerateDeckWithAIUseCase>().call(prompt: _promptText)
                      .then((value) => _logger.d(value.toString()))
                      .catchError((error) => _logger.e(error))
                }, child: Text("Generate with AI")),
                TextButton(onPressed: ()=>{}, child: Text("Add manually")),
              ],
            ),
          )
      )
    );
  }
}