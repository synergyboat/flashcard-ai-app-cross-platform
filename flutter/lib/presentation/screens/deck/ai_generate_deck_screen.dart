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
        appBar: AppBar(
          title: Text("AI Generate Deck"),
        ),
        body: Text("")
    );
  }
}