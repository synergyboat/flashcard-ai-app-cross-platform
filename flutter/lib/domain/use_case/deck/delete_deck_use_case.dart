import '../../entities/deck.dart';
import '../../repository/deck_repository.dart';

class DeleteDeckUseCase {
  final DeckRepository _deckRepository;

  DeleteDeckUseCase(this._deckRepository);

  Future<void> call(Deck deck) async {
    await _deckRepository.deleteDeck(deck);
  }
}