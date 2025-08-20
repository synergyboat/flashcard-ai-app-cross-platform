// benchmark-db.ts — Flutter-parity benchmark with floating-point timing (2 decimals)
// Operations covered (tags EXACTLY match your request):
// - db_row_size_add_demo_Deck
// - db_write_add_demo_deck
// - db_row_size_add_demo_flashcard
// - db_write_add_demo_flashcard
// - db_read_fetch_demo_deck
// - db_row_size_fetched_demo_deck
// - db_read_fetch_demo_flashcards
// - db_row_size_fetched_demo_flashcards
// - db_read
// - db_read_getAllDecksWithFlashcards
// - db_row_size_getAllDecksWithFlashcards

import { databaseORMService } from './database-orm';
import { Deck, Flashcard } from '../types';
import { logDbRowSize, logTotalDbRowSize } from '../core/benchmark/logDbRowSize';
import { logExecDuration } from '../core/benchmark/logExecDuration';

export interface ILogger {
  debug: (message: string) => void;
  info: (message: string) => void;
  error: (message: string) => void;
}

type Metrics = {
  Iteration: number;
  db_row_size_add_demo_Deck: number;              // bytes
  db_write_add_demo_deck: number;                 // ms (2 decimals)
  db_row_size_add_demo_flashcard: number;         // bytes
  db_write_add_demo_flashcard: number;            // ms (2 decimals)
  db_read_fetch_demo_deck: number;                // ms (2 decimals)
  db_row_size_fetched_demo_deck: number;          // bytes
  db_read_fetch_demo_flashcards: number;          // ms (2 decimals)
  db_row_size_fetched_demo_flashcards: number;    // bytes
  db_read: number;                                 // ms (2 decimals)
  db_read_getAllDecksWithFlashcards: number;       // ms (2 decimals)
  db_row_size_getAllDecksWithFlashcards: number;   // bytes
};

const HEADERS: (keyof Metrics)[] = [
  'Iteration',
  'db_row_size_add_demo_Deck',
  'db_write_add_demo_deck',
  'db_row_size_add_demo_flashcard',
  'db_write_add_demo_flashcard',
  'db_read_fetch_demo_deck',
  'db_row_size_fetched_demo_deck',
  'db_read_fetch_demo_flashcards',
  'db_row_size_fetched_demo_flashcards',
  'db_read',
  'db_read_getAllDecksWithFlashcards',
  'db_row_size_getAllDecksWithFlashcards',
];

// -------- Precision helpers --------
const round2 = (n: number) => Math.round(n * 100) / 100;

function nowMs(): number {
  // Prefer high resolution
  // @ts-ignore
  if (typeof performance !== 'undefined' && typeof performance.now === 'function') {
    return performance.now();
  }
  // Node-like envs (testing)
  // @ts-ignore
  if (typeof process !== 'undefined' && process.hrtime && typeof process.hrtime.bigint === 'function') {
    // nanoseconds -> ms
    // @ts-ignore
    const ns: bigint = process.hrtime.bigint();
    return Number(ns) / 1e6;
  }
  return Date.now();
}

function normalizeRow(obj: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = {};

  // Force all keys from the prototype too, if you know the schema
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const val = (obj as any)[key];
      // Replace undefined with null for consistency
      result[key] = val === undefined ? null : val;
    }
  }

  return result;
}

function sizeBytes(obj: unknown): number {
   try {
    const normalized = typeof obj === 'object' && obj !== null
      ? normalizeRow(obj as Record<string, unknown>)
      : obj;

    const json = JSON.stringify(normalized ?? null);

    if (typeof TextEncoder !== 'undefined') {
      return new TextEncoder().encode(json).length;
    }
    if (typeof Buffer !== 'undefined') {
      return Buffer.byteLength(json, 'utf8');
    }
    return unescape(encodeURIComponent(json)).length;
  } catch {
    return 0;
  }
}

export class DatabaseBenchmark {
  private static instance: DatabaseBenchmark;

  private logger: ILogger = {
    debug: (m) => console.log(`[DEBUG] ${m}`),
    info:  (m) => console.log(`[INFO] ${m}`),
    error: (m) => console.error(`[ERROR] ${m}`),
  };

  private constructor() {}

  public static getInstance(): DatabaseBenchmark {
    if (!DatabaseBenchmark.instance) {
      DatabaseBenchmark.instance = new DatabaseBenchmark();
    }
    return DatabaseBenchmark.instance;
  }

  /** Optional: stream logs to UI */
  public setLogger(logger: ILogger): void {
    this.logger = {
      debug: logger?.debug ?? ((m) => console.log(`[DEBUG] ${m}`)),
      info:  logger?.info  ?? ((m) => console.log(`[INFO] ${m}`)),
      error: logger?.error ?? ((m) => console.error(`[ERROR] ${m}`)),
    };
  }

  /** Run N iterations and pretty-print a table of all results (with 2-decimal ms) */
  public async runBenchmark(iterations = 1): Promise<void> {
    await databaseORMService.init(); // idempotent
    const all: Metrics[] = [];

    for (let i = 1; i <= iterations; i++) {
      this.logger.info(`=== Iteration ${i} ===`);
      const row = await this.benchmarkOnce(i);
      all.push(row);
    }

    this.prettyPrint(all);
  }

  /** One full pass producing all requested metrics/tags */
  private async benchmarkOnce(iteration: number): Promise<Metrics> {
    // 1) Demo Deck
    const demoDeck: Omit<Deck, 'id' | 'createdAt' | 'updatedAt'> = {
      name: 'Benchmark Deck',
      description: 'A deck for benchmarking purposes',
      flashcards: [],
    };

    // Log row size (Dart tag casing: Deck capitalized)
    logDbRowSize(demoDeck as Record<string, unknown>, {
      name: 'Demo Deck',
      tag: 'db_row_size_add_demo_Deck',
    });
    const db_row_size_add_demo_Deck = sizeBytes(demoDeck);

    // Create deck (time; measure around logExecDuration to avoid double exec)
    const tDeckStart = nowMs();
    const deckId = await logExecDuration(
      () => databaseORMService.createDeck(demoDeck),
      { name: 'Adding demo deck to DB', tag: 'db_write_add_demo_deck' }
    );
    const db_write_add_demo_deck = round2(nowMs() - tDeckStart);

    // 2) Demo Flashcard
    const demoFlashcard: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'> = {
      deckId,
      question: 'What is the capital of Germany?',
      answer: 'Berlin',
      lastReviewed: undefined,
    };

    logDbRowSize(demoFlashcard as Record<string, unknown>, {
      name: 'Demo Flashcard',
      tag: 'db_row_size_add_demo_flashcard',
    });
    const db_row_size_add_demo_flashcard = sizeBytes(demoFlashcard);

    const tFcStart = nowMs();
    await logExecDuration(
      () => databaseORMService.createFlashcard(demoFlashcard),
      { name: 'Adding demo flashcard to DB', tag: 'db_write_add_demo_flashcard' }
    );
    const db_write_add_demo_flashcard = round2(nowMs() - tFcStart);

    // 3) Fetch demo deck by id
    const tFetchDeck = nowMs();
    const fetchedDeck = await logExecDuration(
      () => databaseORMService.getDeck(deckId),
      { name: 'Fetching demo deck from DB', tag: 'db_read_fetch_demo_deck' }
    );
    const db_read_fetch_demo_deck = round2(nowMs() - tFetchDeck);

    const deckForSize =
      fetchedDeck ?? { name: 'Not Found', description: 'Not Found', flashcards: [] };

    const db_row_size_fetched_demo_deck = sizeBytes(deckForSize);
    logDbRowSize(deckForSize as Record<string, unknown>, {
      name: 'Fetched Demo Deck',
      tag: 'db_row_size_fetched_demo_deck',
    });

    // 4) Fetch flashcards for deck
    const tFetchFcs = nowMs();
    const fetchedFlashcards = await logExecDuration(
      () => databaseORMService.getFlashcards(deckId),
      { name: 'Fetching flashcards for demo deck', tag: 'db_read_fetch_demo_flashcards' }
    );
    const db_read_fetch_demo_flashcards = round2(nowMs() - tFetchFcs);

    const db_row_size_fetched_demo_flashcards = sizeBytes(fetchedFlashcards ?? []);
    logTotalDbRowSize(
      (fetchedFlashcards as unknown as Record<string, unknown>[]) ?? [],
      { name: 'Fetched Demo Flashcards', tag: 'db_row_size_fetched_demo_flashcards' }
    );

    // 5) General read — align to column "db_read" (all decks)
    const tReadAll = nowMs();
    await logExecDuration(
      () => databaseORMService.getDecks?.() ?? Promise.resolve([]),
      { name: 'General read (all decks)', tag: 'db_read' } as any
    );
    const db_read = round2(nowMs() - tReadAll);

    // 6) Fetch ALL decks WITH flashcards
    const tAllWF = nowMs();
    const allDecksWithFlashcards = await logExecDuration(
      () => (databaseORMService as any).getAllDecksWithFlashcards?.() ?? Promise.resolve([]),
      { name: 'Fetching all decks with flashcards', tag: 'db_read_getAllDecksWithFlashcards' }
    );
    const db_read_getAllDecksWithFlashcards = round2(nowMs() - tAllWF);

    const db_row_size_getAllDecksWithFlashcards = sizeBytes(allDecksWithFlashcards ?? []);
    logTotalDbRowSize(
      (allDecksWithFlashcards as unknown as Record<string, unknown>[]) ?? [],
      { name: 'All Decks With Flashcards', tag: 'db_row_size_getAllDecksWithFlashcards' }
    );

    // Clean up (best effort; cascade expected)
    try {
      await databaseORMService.deleteDeck?.(deckId);
    } catch (e: any) {
      this.logger.debug(`Cleanup deleteDeck ignored: ${e?.message ?? e}`);
    }

    return {
      Iteration: iteration,
      db_row_size_add_demo_Deck,
      db_write_add_demo_deck,
      db_row_size_add_demo_flashcard,
      db_write_add_demo_flashcard,
      db_read_fetch_demo_deck,
      db_row_size_fetched_demo_deck,
      db_read_fetch_demo_flashcards,
      db_row_size_fetched_demo_flashcards,
      db_read,
      db_read_getAllDecksWithFlashcards,
      db_row_size_getAllDecksWithFlashcards,
    };
  }

  /** Pretty print a fixed-width table of all iterations (with units and 2-decimal ms) */
  private prettyPrint(rows: Metrics[]) {
    if (rows.length === 0) return;

    // Build formatted table (string values with units)
    const header = [
      'Iteration',
      'db_row_size_add_demo_Deck',
      'db_write_add_demo_deck',
      'db_row_size_add_demo_flashcard',
      'db_write_add_demo_flashcard',
      'db_read_fetch_demo_deck',
      'db_row_size_fetched_demo_deck',
      'db_read_fetch_demo_flashcards',
      'db_row_size_fetched_demo_flashcards',
      'db_read',
      'db_read_getAllDecksWithFlashcards',
      'db_row_size_getAllDecksWithFlashcards',
    ];

    const rowsStr: string[][] = [
      header,
      ...rows.map((r) => [
        String(r.Iteration),
        `${r.db_row_size_add_demo_Deck} B`,
        `${r.db_write_add_demo_deck.toFixed(2)} ms`,
        `${r.db_row_size_add_demo_flashcard} B`,
        `${r.db_write_add_demo_flashcard.toFixed(2)} ms`,
        `${r.db_read_fetch_demo_deck.toFixed(2)} ms`,
        `${r.db_row_size_fetched_demo_deck} B`,
        `${r.db_read_fetch_demo_flashcards.toFixed(2)} ms`,
        `${r.db_row_size_fetched_demo_flashcards} B`,
        `${r.db_read.toFixed(2)} ms`,
        `${r.db_read_getAllDecksWithFlashcards.toFixed(2)} ms`,
        `${r.db_row_size_getAllDecksWithFlashcards} B`,
      ]),
    ];

    const colWidths = header.map((_, ci) =>
      Math.max(...rowsStr.map((row) => row[ci].length))
    );
    const pad = (s: string, w: number) => s + ' '.repeat(Math.max(0, w - s.length));
    const line = (row: string[]) => row.map((cell, i) => pad(cell, colWidths[i])).join('  ');
    const sepLen = colWidths.reduce((a, b) => a + b, 0) + (header.length - 1) * 2;

    this.logger.info('=== Benchmark Results ===');
    this.logger.info(line(rowsStr[0]));
    this.logger.info('-'.repeat(sepLen));
    for (let i = 1; i < rowsStr.length; i++) {
      this.logger.info(line(rowsStr[i]));
    }
  }
}

// Singleton + helpers
export const databaseBenchmark = DatabaseBenchmark.getInstance();

/** Run N iterations and pretty-print results */
export async function runBenchmark(iterations = 1): Promise<void> {
  await databaseBenchmark.runBenchmark(iterations);
}

/** For one-off quick parity run */
export async function runQuickBenchmark(): Promise<void> {
  await databaseBenchmark.runBenchmark(1);
}