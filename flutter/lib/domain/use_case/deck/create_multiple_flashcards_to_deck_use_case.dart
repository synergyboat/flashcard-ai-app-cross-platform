import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:flashcard/domain/repository/flashcard_repository.dart';

import '../../entities/flashcard.dart';
import '../../repository/deck_repository.dart';

class CreateMultipleFlashcardsToDeckUseCase {
  final FlashcardRepository _flashcardRepository;

  CreateMultipleFlashcardsToDeckUseCase(this._flashcardRepository);

  Future<void> call(int deckId, List<Flashcard> flashcards) async {
    if (flashcards.isEmpty) {
      throw ArgumentError('Flashcards cannot be empty');
    }
    await _flashcardRepository.addMultipleFlashcardsToDeck(deckId, flashcards);
  }
}