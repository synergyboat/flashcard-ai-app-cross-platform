import { databaseService } from '../services/database';

export class DatabaseInitializer {
    static async initialize(): Promise<void> {
        try {
            await databaseService.init();

            if (__DEV__) {
                console.log('Database initialized successfully');

                // Uncomment the line below to run benchmark on app startup
                // await this.benchmarkDatabase();
            }
        } catch (error) {
            if (__DEV__) {
                console.error('Error initializing database:', error);
            }
            throw error;
        }
    }

    static async benchmarkDatabase(): Promise<void> {
        try {
            console.log('🚀 Starting database benchmark...');
            await databaseService.benchmarkDatabase();
            console.log('✅ Database benchmark completed successfully');
        } catch (error) {
            console.error('❌ Error running database benchmark:', error);
            throw error;
        }
    }

    // Optional: Add sample data for testing (similar to Flutter implementation)
    static async addSampleData(): Promise<void> {
        try {
            const existingDecks = await databaseService.getDecks();

            if (existingDecks.length === 0) {
                const sampleDeck = {
                    name: 'Sample Deck',
                    description: 'A sample deck with basic flashcards',
                };

                const deckId = await databaseService.createDeck(sampleDeck);

                const sampleFlashcards = [
                    {
                        deckId,
                        question: 'What is the capital of France?',
                        answer: 'Paris',
                    },
                    {
                        deckId,
                        question: 'What is 2 + 2?',
                        answer: '4',
                    },
                ];

                await databaseService.createFlashcards(sampleFlashcards);

                if (__DEV__) {
                    console.log('Sample data added successfully');
                }
            }
        } catch (error) {
            if (__DEV__) {
                console.error('Error adding sample data:', error);
            }
        }
    }
} 