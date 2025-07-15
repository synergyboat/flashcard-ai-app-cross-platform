import '../../entities/deck.dart';
import '../../repository/deck_repository.dart';

class CreateNewDeckUseCase {
  final DeckRepository _deckRepository;

  CreateNewDeckUseCase(this._deckRepository);

  Future<void> call(Deck deck) async {
    await _deckRepository.addDeck(deck);
  }
}