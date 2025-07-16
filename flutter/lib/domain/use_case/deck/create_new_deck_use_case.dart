import 'package:flashcard/domain/repository/flashcard_repository.dart';

import '../../entities/deck.dart';
import '../../repository/deck_repository.dart';

class CreateNewDeckUseCase {
  final DeckRepository _deckRepository;

  CreateNewDeckUseCase(this._deckRepository);

  Future<int> call(Deck deck) async {
    return await _deckRepository.addDeck(deck);
  }
}