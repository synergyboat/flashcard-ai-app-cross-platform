import '../../entities/flashcard.dart';
import '../../repository/flashcard_repository.dart';

class UpdateFlashcardUseCase {
  final FlashcardRepository _flashcardRepository;

  UpdateFlashcardUseCase(this._flashcardRepository);

  Future<void> call(Flashcard updatedFlashcard) async {
    await _flashcardRepository.updateFlashcard(updatedFlashcard);
  }
}