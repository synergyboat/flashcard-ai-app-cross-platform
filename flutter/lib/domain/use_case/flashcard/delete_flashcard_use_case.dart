import 'package:flashcard/domain/entities/flashcard.dart';

import '../../repository/flashcard_repository.dart';

class DeleteFlashcardUseCase {
  final FlashcardRepository _flashcardRepository;

  DeleteFlashcardUseCase(this._flashcardRepository);

  Future<void> call(Flashcard flashcard) async {
    await _flashcardRepository.deleteFlashcard(flashcard);
  }
}