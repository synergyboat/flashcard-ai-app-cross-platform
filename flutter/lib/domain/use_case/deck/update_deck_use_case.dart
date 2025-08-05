import 'package:flashcard/domain/repository/deck_repository.dart';

import '../../entities/deck.dart';

class UpdateDeckUseCase {
  final DeckRepository _deckRepository;

  UpdateDeckUseCase(this._deckRepository);

  Future<void> call(Deck updatedDeck) async {
    await _deckRepository.updateDeck(updatedDeck);
  }
}