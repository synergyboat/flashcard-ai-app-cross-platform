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
  deckId?: number;

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

  static fromRow(row: Record<string, any>): FlashcardEntity {
    return new FlashcardEntity({
      id: row.id,
      deckId: row.deckId,
      question: row.question,
      answer: row.answer,
      createdAt: row.createdAt ? new Date(row.createdAt) : undefined,
      updatedAt: row.updatedAt ? new Date(row.updatedAt) : undefined,
      lastReviewed: row.lastReviewed ? new Date(row.lastReviewed) : undefined,
    });
  }

  toRow(): Record<string, any> {
    return {
      id: this.id,
      deckId: this.deckId,
      question: this.question,
      answer: this.answer,
      createdAt: this.createdAt?.toISOString(),
      updatedAt: this.updatedAt?.toISOString(),
      lastReviewed: this.lastReviewed?.toISOString(),
    };
  }
}