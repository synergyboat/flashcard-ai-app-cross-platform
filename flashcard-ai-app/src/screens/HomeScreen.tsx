import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { Deck } from '../types';
import { databaseService } from '../services/database';

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Home'>;

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const [decks, setDecks] = useState<Deck[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDecks();
  }, []);

  const loadDecks = async () => {
    try {
      await databaseService.init();
      const loadedDecks = await databaseService.getDecks();
      setDecks(loadedDecks);
    } catch (error) {
      console.error('Error loading decks:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderDeckCard = ({ item }: { item: Deck }) => (
    <TouchableOpacity
      style={styles.deckCard}
      onPress={() => navigation.navigate('DeckDetails', {
        deckId: item.id,
        deckName: item.name,
      })}
      activeOpacity={0.8}
    >
      <Text style={styles.deckName}>{item.name}</Text>
      <Text style={styles.deckCount}>
        {item.flashcardCount || 0} cards
      </Text>
      {item.description && (
        <Text style={styles.deckDescription} numberOfLines={2}>
          {item.description}
        </Text>
      )}
    </TouchableOpacity>
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Ionicons name="library-outline" size={64} color="#ccc" />
      <Text style={styles.emptyStateTitle}>Welcome to Flashcard AI!</Text>
      <Text style={styles.emptyStateSubtitle}>
        Tap the AI button below to generate your first deck of flashcards
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <FlatList
        data={decks}
        renderItem={renderDeckCard}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContainer}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={!loading ? renderEmptyState : null}
        numColumns={2}
        columnWrapperStyle={styles.row}
      />

      {/* AI Generation FAB */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => navigation.navigate('AIGenerate')}
        activeOpacity={0.8}
      >
        <Ionicons name="sparkles" size={24} color="white" />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  listContainer: {
    padding: 16,
    paddingBottom: 100, // Space for FAB
  },
  row: {
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  deckCard: {
    width: (width - 48) / 2,
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    minHeight: 120,
  },
  deckName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  deckCount: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  deckDescription: {
    fontSize: 12,
    color: '#999',
    lineHeight: 16,
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#666',
    marginTop: 16,
    marginBottom: 8,
  },
  emptyStateSubtitle: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  fab: {
    position: 'absolute',
    bottom: 24,
    right: 24,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#4A90E2',
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
}); 