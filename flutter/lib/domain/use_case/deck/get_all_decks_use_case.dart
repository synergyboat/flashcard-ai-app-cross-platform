import '../../entities/deck.dart';
import '../../repository/deck_repository.dart';

class GetAllDecksUseCase {
  final DeckRepository _deckRepository;

  GetAllDecksUseCase(this._deckRepository);

  Future<List<Deck>> call() async {
    return await _deckRepository.getAllDecksWithFlashcards();
  }
}