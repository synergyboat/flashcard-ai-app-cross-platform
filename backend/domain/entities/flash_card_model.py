from pydantic import BaseModel


class FlashCardModel(BaseModel):
    """
    FlashCardModel represents a flashcard with a question and answer.
    """
    id: str
    user_id: str
    media_id: str
    question: str
    answer: str

    class Config:
        orm_mode = True

    def __str__(self):
        return f"FlashCard(id={self.id}, question={self.question}, answer={self.answer})"