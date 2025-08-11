import { Entity, PrimaryKey, Column, DateColumn } from '../decorators';
import { BaseEntity } from '../base-entity';
import { Deck } from '../../types';

@Entity('deck')
export class DeckEntity extends BaseEntity {
  @PrimaryKey(true)
  id?: number;

  @Column({ type: 'TEXT NOT NULL' })
  name?: string;

  @Column({ type: 'TEXT NOT NULL' })
  description?: string;

  @DateColumn()
  createdAt?: Date;

  @DateColumn()
  updatedAt?: Date;

  constructor(data?: Partial<DeckEntity>) {
    super();
    if (data) {
      Object.assign(this, data);
    }
  }

  static fromDeck(deck: Deck): DeckEntity {
    return new DeckEntity({
      id: deck.id,
      name: deck.name || '',
      description: deck.description || '',
      createdAt: deck.createdAt,
      updatedAt: deck.updatedAt,
    });
  }

  toDeck(): Deck {
    return {
      id: this.id,
      name: this.name,
      description: this.description,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      flashcards: [],
    };
  }


  setTimestamps(): void {
    const now = new Date();
    if (!this.createdAt) {
      this.createdAt = now;
    }
    this.updatedAt = now;
  }

  static fromRow(row: Record<string, any>): DeckEntity {
    return new DeckEntity({
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt ? new Date(row.createdAt) : undefined,
      updatedAt: row.updatedAt ? new Date(row.updatedAt) : undefined,
    });
  }

  toRow(): Record<string, any> {
    return {
      id: this.id,
      name: this.name,
      description: this.description,
      createdAt: this.createdAt?.toISOString(),
      updatedAt: this.updatedAt?.toISOString(),
    };
  }
}