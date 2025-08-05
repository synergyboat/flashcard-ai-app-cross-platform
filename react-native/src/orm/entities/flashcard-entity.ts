import { Entity, PrimaryKey, Column, DateColumn, ForeignKey } from '../decorators';
import { BaseEntity } from '../base-entity';
import { Flashcard } from '../../types';

@Entity('flashcard')
export class FlashcardEntity extends BaseEntity {
  @PrimaryKey(true)
  id?: number;

  @ForeignKey({ 
    referencedTable: 'deck', 
    referencedColumn: 'id', 
    onDelete: 'CASCADE' 
  })
  deckId!: number;

  @Column({ type: 'TEXT NOT NULL' })
  question!: string;

  @Column({ type: 'TEXT NOT NULL' })
  answer!: string;

  @DateColumn()
  createdAt?: Date;

  @DateColumn()
  updatedAt?: Date;

  @DateColumn()
  lastReviewed?: Date;

  constructor(data?: Partial<FlashcardEntity>) {
    super();
    if (data) {
      Object.assign(this, data);
    }
  }

  static fromFlashcard(flashcard: Flashcard): FlashcardEntity {
    return new FlashcardEntity({
      id: flashcard.id,
      deckId: flashcard.deckId,
      question: flashcard.question,
      answer: flashcard.answer,
      createdAt: flashcard.createdAt,
      updatedAt: flashcard.updatedAt,
      lastReviewed: flashcard.lastReviewed,
    });
  }

  toFlashcard(): Flashcard {
    return {
      id: this.id,
      deckId: this.deckId,
      question: this.question,
      answer: this.answer,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      lastReviewed: this.lastReviewed,
    };
  }

  setTimestamps(): void {
    const now = new Date();
    if (!this.createdAt) {
      this.createdAt = now;
    }
    this.updatedAt = now;
  }

  markAsReviewed(): void {
    this.lastReviewed = new Date();
    this.updatedAt = new Date();
  }
}