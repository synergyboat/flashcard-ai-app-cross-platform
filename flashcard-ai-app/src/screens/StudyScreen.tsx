import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  Dimensions,
} from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { Flashcard } from '../types';
import { databaseService } from '../services/database';
import CardStack from '../components/CardStack';
import GradientButton from '../components/GradientButton';

type StudyScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Study'>;
type StudyScreenRouteProp = RouteProp<RootStackParamList, 'Study'>;

const { width } = Dimensions.get('window');

export default function StudyScreen() {
  const navigation = useNavigation<StudyScreenNavigationProp>();
  const route = useRoute<StudyScreenRouteProp>();
  const { deckId, deckName } = route.params;

  const [flashcards, setFlashcards] = useState<Flashcard[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFlashcards();
  }, [deckId]);

  const loadFlashcards = async () => {
    try {
      const cards = await databaseService.getFlashcards(deckId);
      setFlashcards(cards);
    } catch (error) {
      console.error('Error loading flashcards:', error);
      Alert.alert('Error', 'Failed to load flashcards');
    } finally {
      setLoading(false);
    }
  };

  const handleSwipeLeft = async () => {
    console.log('Swipe left - current index:', currentIndex, 'total cards:', flashcards.length);
    
    // Mark as reviewed and move to next
    if (currentIndex < flashcards.length) {
      await databaseService.updateFlashcardReview(flashcards[currentIndex].id);
    }
    
    if (currentIndex < flashcards.length - 1) {
      const newIndex = currentIndex + 1;
      console.log('Moving to index:', newIndex);
      setCurrentIndex(newIndex);
    } else {
      // End of study session
      Alert.alert(
        'Study Session Complete!',
        `You've reviewed all ${flashcards.length} cards in this deck.`,
        [
          {
            text: 'Study Again',
            onPress: () => setCurrentIndex(0),
          },
          {
            text: 'Finish',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    }
  };

  const handleSwipeRight = async () => {
    console.log('Swipe right - current index:', currentIndex, 'total cards:', flashcards.length);
    
    // Mark as reviewed and move to next (same as left for now)
    if (currentIndex < flashcards.length) {
      await databaseService.updateFlashcardReview(flashcards[currentIndex].id);
    }
    
    if (currentIndex < flashcards.length - 1) {
      const newIndex = currentIndex + 1;
      console.log('Moving to index:', newIndex);
      setCurrentIndex(newIndex);
    } else {
      // End of study session
      Alert.alert(
        'Study Session Complete!',
        `You've reviewed all ${flashcards.length} cards in this deck.`,
        [
          {
            text: 'Study Again',
            onPress: () => setCurrentIndex(0),
          },
          {
            text: 'Finish',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    }
  };

  const handleCardPress = () => {
    // This will be handled by the CardStack component for flipping
  };

  const handleClose = () => {
    Alert.alert(
      'End Study Session',
      'Are you sure you want to end this study session?',
      [
        { text: 'Continue Studying', style: 'cancel' },
        { text: 'End Session', onPress: () => navigation.goBack() },
      ]
    );
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Loading flashcards...</Text>
      </View>
    );
  }

  if (flashcards.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Ionicons name="document-outline" size={64} color="#ccc" />
        <Text style={styles.emptyText}>No flashcards to study</Text>
        <GradientButton
          title="Go Back"
          onPress={() => navigation.goBack()}
          style={styles.backButton}
        />
      </View>
    );
  }

  const currentCard = flashcards[currentIndex];

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.deckName}>{deckName}</Text>
        <TouchableOpacity
          style={styles.closeButton}
          onPress={handleClose}
        >
          <Ionicons name="close" size={24} color="#666" />
        </TouchableOpacity>
      </View>

      {/* Card Stack */}
      <CardStack
        key={`card-${currentIndex}`}
        flashcards={flashcards}
        currentIndex={currentIndex}
        onSwipeLeft={handleSwipeLeft}
        onSwipeRight={handleSwipeRight}
        onCardPress={handleCardPress}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8f9fa',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 18,
    color: '#666',
    marginTop: 16,
    marginBottom: 32,
  },
  backButton: {
    width: 200,
  },
  header: {
    backgroundColor: 'white',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e1e5e9',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  deckName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#f8f9fa',
    alignItems: 'center',
    justifyContent: 'center',
  },
}); 