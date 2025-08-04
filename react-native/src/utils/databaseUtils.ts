import { databaseService } from '../services/database';
import { Alert } from 'react-native';

export const resetDatabase = async () => {
  try {
    await databaseService.clearAllData();
    Alert.alert('Success', 'Database has been cleared');
  } catch (error) {
    Alert.alert('Error', 'Failed to clear database');
  }
};

export const getDatabaseInfo = async () => {
  try {
    const decks = await databaseService.getDecks();
    const totalCards = decks.reduce((sum, deck) => sum + (deck.flashcardCount || 0), 0);
    
    return {
      deckCount: decks.length,
      totalCards,
      decks: decks.map(deck => ({
        name: deck.name,
        cardCount: deck.flashcardCount || 0,
      })),
    };
  } catch (error) {
    return null;
  }
};

export const runDatabaseBenchmark = async () => {
  try {
    await databaseService.benchmarkDatabase();
  } catch (error) {
    Alert.alert('Error', 'Failed to run database benchmark');
  }
}; 