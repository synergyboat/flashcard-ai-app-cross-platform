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
import { databaseORMService } from '../services/database-orm';
import CardStack from '../components/CardStack';
import GradientButton from '../components/GradientButton';
import GradientBackground from '../components/GradientBackground';
import { SCREEN_NAMES } from '../config';

type StudyScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.STUDY>;
type StudyScreenRouteProp = RouteProp<RootStackParamList, typeof SCREEN_NAMES.STUDY>;

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
      const cards = await databaseORMService.getFlashcards(deckId);
      setFlashcards(cards);
    } catch (error) {
      console.error('Error loading flashcards:', error);
      Alert.alert('Error', 'Failed to load flashcards');
    } finally {
      setLoading(false);
    }
  };

  const handleSwipeLeft = async () => {

    // Mark as reviewed and move to next
    if (currentIndex < flashcards.length) {
      if (flashcards[currentIndex].id) {
        await databaseORMService.updateFlashcardReview(flashcards[currentIndex].id);
      }
    }

    if (currentIndex < flashcards.length - 1) {
      const newIndex = currentIndex + 1;
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
    handleSwipeLeft();
  };

  const handleCardPress = () => {

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
      <GradientBackground>
        <View style={styles.loadingContainer}>
          <Text>Loading flashcards...</Text>
        </View>
      </GradientBackground>
    );
  }

  if (flashcards.length === 0) {
    return (
      <GradientBackground>
        <View style={styles.emptyContainer}>
          <Ionicons name="document-outline" size={64} color="#ccc" />
          <Text style={styles.emptyText}>No flashcards to study</Text>
          <GradientButton
            title="Go Back"
            onPress={() => navigation.goBack()}
            style={styles.backButton}
          />
        </View>
      </GradientBackground>
    );
  }

  const currentCard = flashcards[currentIndex];

  return (
    <GradientBackground>
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.deckName}>{deckName}</Text>
          <TouchableOpacity
            style={styles.closeButton}
            onPress={handleClose}
          >
            <Ionicons name="close" size={24} color="#666" />
          </TouchableOpacity>
        </View>

        <CardStack
          key={`card-${currentIndex}`}
          flashcards={flashcards}
          currentIndex={currentIndex}
          onSwipeLeft={handleSwipeLeft}
        />
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
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  emptyText: {
    fontSize: 18,
    color: '#666666',
    marginTop: 16,
    marginBottom: 32,
  },
  backButton: {
    width: 200,
  },
  header: {
    backgroundColor: '#FEF8FF',
    padding: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#333333',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  deckName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333333',
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#333333',
    alignItems: 'center',
    justifyContent: 'center',
  },
}); 