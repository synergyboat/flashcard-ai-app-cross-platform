import 'package:flashcard/domain/repository/flashcard_repository.dart';

import '../../entities/deck.dart';
import '../../entities/flashcard.dart';

class GetFlashcardsFromDeckUseCase {
  final FlashcardRepository _flashcardRepository;

  GetFlashcardsFromDeckUseCase(this._flashcardRepository);

  Future<List<Flashcard>> call(Deck deck) async {
    if (deck.id == null) {
      throw Exception("Deck ID is null. Cannot retrieve flashcards.");
    }
    return await _flashcardRepository.getFlashcardsByDeckId(deck.id!);
  }
}