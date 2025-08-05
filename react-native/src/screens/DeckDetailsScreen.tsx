import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { Deck, Flashcard } from '../types';
import { databaseORMService } from '../services/database-orm';
import GradientButton from '../components/GradientButton';
import GradientBackground from '../components/GradientBackground';
import { SCREEN_NAMES } from '../config';

type DeckDetailsScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.DECK_DETAILS>;
type DeckDetailsScreenRouteProp = RouteProp<RootStackParamList, typeof SCREEN_NAMES.DECK_DETAILS>;

export default function DeckDetailsScreen() {
  const navigation = useNavigation<DeckDetailsScreenNavigationProp>();
  const route = useRoute<DeckDetailsScreenRouteProp>();
  const { deckId, deckName } = route.params;

  const [deck, setDeck] = useState<Deck | null>(null);
  const [flashcards, setFlashcards] = useState<Flashcard[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDeckData();
  }, [deckId]);

  const loadDeckData = async () => {
    try {
      const [deckData, cards] = await Promise.all([
        databaseORMService.getDeck(deckId),
        databaseORMService.getFlashcards(deckId),
      ]);
      
      setDeck(deckData);
      setFlashcards(cards);
    } catch (error) {
      console.error('Error loading deck data:', error);
      Alert.alert('Error', 'Failed to load deck data');
    } finally {
      setLoading(false);
    }
  };

  const handleStartStudy = () => {
    if (flashcards.length === 0) {
      Alert.alert('No Cards', 'This deck has no flashcards to study.');
      return;
    }
    navigation.navigate(SCREEN_NAMES.STUDY, { deckId, deckName });
  };

  const handleDeleteDeck = () => {
    Alert.alert(
      'Delete Deck',
      'Are you sure you want to delete this deck? This action cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await databaseORMService.deleteDeck(deckId);
              navigation.goBack();
            } catch (error) {
              console.error('Error deleting deck:', error);
              Alert.alert('Error', 'Failed to delete deck');
            }
          },
        },
      ]
    );
  };

  const renderFlashcard = ({ item, index }: { item: Flashcard; index: number }) => (
    <View style={styles.flashcardItem}>
      <View style={styles.cardNumber}>
        <Text style={styles.cardNumberText}>{index + 1}</Text>
      </View>
      <View style={styles.cardContent}>
        <Text style={styles.question} numberOfLines={2}>
          {item.question}
        </Text>
        <Text style={styles.answer} numberOfLines={1}>
          {item.answer}
        </Text>
      </View>
    </View>
  );

  if (loading) {
    return (
      <GradientBackground>
        <View style={styles.loadingContainer}>
          <Text>Loading...</Text>
        </View>
      </GradientBackground>
    );
  }

  return (
    <GradientBackground>
      <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.deckName}>{deckName}</Text>
        <Text style={styles.cardCount}>
          {flashcards.length} card{flashcards.length !== 1 ? 's' : ''}
        </Text>
        {deck?.description && (
          <Text style={styles.description}>{deck.description}</Text>
        )}
      </View>

      <FlatList
        data={flashcards}
        renderItem={renderFlashcard}
        keyExtractor={(item) => item.id?.toString() || ''}
        contentContainerStyle={styles.listContainer}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View style={styles.emptyState}>
            <Ionicons name="document-outline" size={48} color="#ccc" />
            <Text style={styles.emptyStateText}>No flashcards in this deck</Text>
          </View>
        }
      />

      <View style={styles.buttonContainer}>
        <GradientButton
          title="Start Study Session"
          onPress={handleStartStudy}
          disabled={flashcards.length === 0}
          style={styles.studyButton}
        />
      </View>

      <TouchableOpacity
        style={styles.deleteButton}
        onPress={handleDeleteDeck}
      >
        <Ionicons name="trash-outline" size={20} color="#ff4444" />
        <Text style={styles.deleteButtonText}>Delete Deck</Text>
      </TouchableOpacity>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    backgroundColor: '#FEF8FF',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  deckName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333333',
    marginBottom: 8,
  },
  cardCount: {
    fontSize: 16,
    color: '#666666',
    marginBottom: 8,
  },
  description: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 20,
  },
  listContainer: {
    padding: 16,
    paddingBottom: 120, // Space for buttons
  },
  flashcardItem: {
    backgroundColor: '#ffffff',
    borderRadius: 32,
    borderWidth: 0.5,
    borderColor: '#9E9E9E',
    padding: 16,
    marginBottom: 12,
    flexDirection: 'row',
    alignItems: 'center',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  cardNumber: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#0c7fff',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 16,
  },
  cardNumberText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
  cardContent: {
    flex: 1,
  },
  question: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 4,
  },
  answer: {
    fontSize: 14,
    color: '#212121',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyStateText: {
    fontSize: 16,
    color: '#666666',
    marginTop: 12,
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 60,
    left: 20,
    right: 20,
  },
  studyButton: {
    width: '100%',
  },
  deleteButton: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
  },
  deleteButtonText: {
    color: '#ff4444',
    fontSize: 16,
    marginLeft: 8,
  },
}); 