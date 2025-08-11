import React, { useEffect, useMemo, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  Platform,
  ToastAndroid,
} from 'react-native';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { Deck, Flashcard } from '../types';
import { databaseORMService } from '../services/database-orm';
import GradientButton from '../components/GradientButton';
import GradientBackground from '../components/GradientBackground';
import EditFlashcardModal from '../components/EditFlashcardModal';
import CardStack from '../components/CardStack';
import { SCREEN_NAMES, COLORS, TYPOGRAPHY } from '../config';

type DeckDetailsScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.DECK_DETAILS>;
type DeckDetailsScreenRouteProp = RouteProp<RootStackParamList, typeof SCREEN_NAMES.DECK_DETAILS>;

export default function DeckDetailsScreen() {
  const navigation = useNavigation<DeckDetailsScreenNavigationProp>();
  const route = useRoute<DeckDetailsScreenRouteProp>();
  const { deckId, deckName, previewDeck } = route.params ?? ({} as any);

  const isPreview = !!previewDeck && !deckId;

  const [deck, setDeck] = useState<Deck | null>(null);
  const [flashcards, setFlashcards] = useState<Flashcard[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [iosToastVisible, setIosToastVisible] = useState(false);
  const [completionVisible, setCompletionVisible] = useState(false);

  useEffect(() => {
    loadDeckData();
  }, [deckId, isPreview]);

  const loadDeckData = async () => {
    try {
      await databaseORMService.init();

      if (isPreview && previewDeck) {
        setDeck({ name: previewDeck.name, description: previewDeck.description });
        setFlashcards(previewDeck.flashcards as Flashcard[]);
        setLoading(false);
        return;
      }

      if (!deckId) {
        setLoading(false);
        return;
      }

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

  const handleSwipeLeft = () => {
    setCurrentIndex(prev => {
      const next = prev + 1;
      if (next >= flashcards.length) {
        setCompletionVisible(true);
      }
      return next;
    });
  };

  const showCreatedToastAndGoHome = (name: string) => {
    if (Platform.OS === 'android') {
      ToastAndroid.show('Deck created.', ToastAndroid.SHORT);
      navigation.navigate(SCREEN_NAMES.HOME as never);
    } else {
      setIosToastVisible(true);
      // Navigate immediately (same as Flutter code does after showing SnackBar)
      navigation.navigate(SCREEN_NAMES.HOME as never);
    }
  };

  const handleSaveDeck = async () => {
    try {
      if (!isPreview || !previewDeck) return;
      await databaseORMService.createDeckWithFlashcards(
        { name: previewDeck.name, description: previewDeck.description },
        previewDeck.flashcards
      );
      showCreatedToastAndGoHome(previewDeck.name);
    } catch (e) {
      console.error(e);
      Alert.alert('Error', 'Failed to save deck');
    }
  };

  if (loading || flashcards.length === 0) {
    return (
      <GradientBackground>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>
            {loading ? 'Loading...' : 'No flashcards in this deck'}
          </Text>
        </View>
      </GradientBackground>
    );
  }

  return (
    <GradientBackground>
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
            <Ionicons name="chevron-back" size={24} color={COLORS.TEXT.PRIMARY} />
          </TouchableOpacity>
          <Text style={styles.deckName}>{deckName || previewDeck?.name || 'Deck Details'}</Text>
          <Text style={styles.editButtonText} onPress={() => setEditModalVisible(true)}>Edit</Text>
        </View>

        {(deck?.description) && !isPreview && (
          <Text style={styles.description}>{deck?.description || previewDeck?.description}</Text>
        )}

        <View style={styles.cardContainer}>
          <CardStack
            key={`card-${currentIndex}`}
            flashcards={flashcards}
            currentIndex={currentIndex}
            onSwipeLeft={handleSwipeLeft}
            isPreview={isPreview}
          />
        </View>

        <View style={styles.buttonContainer}>
          {isPreview ? (
            <GradientButton title="Save Deck" onPress={handleSaveDeck} style={styles.closeButton} />
          ) : (
            <GradientButton title="Close" onPress={() => navigation.goBack()} style={styles.closeButton} />
          )}
        </View>

        {iosToastVisible && (
          <View style={styles.toast} pointerEvents="none">
            <Ionicons name="checkmark" size={18} color="#fff" />
            <Text style={styles.toastText}>Deck created.</Text>
          </View>
        )}
        {completionVisible && (
          <View style={styles.completionOverlay}>
            <View style={styles.completionContent}>
              <Text style={styles.completionTitle}>You're done!</Text>
              <Text style={styles.completionText}>You've reached the end of this deck.</Text>
              <View style={styles.completionButtons}>
                <GradientButton
                  title="Restart"
                  onPress={() => {
                    setCompletionVisible(false);
                    setCurrentIndex(0);
                  }}
                  style={{ flex: 1, marginRight: 8 }}
                />
                <GradientButton
                  title="Close"
                  onPress={() => {
                    setCompletionVisible(false);
                    navigation.goBack();
                  }}
                  style={{ flex: 1, marginLeft: 8 }}
                />
              </View>
            </View>
          </View>
        )}
      </View>

      <EditFlashcardModal
        visible={editModalVisible}
        flashcard={flashcards[currentIndex] || null}
        onClose={() => setEditModalVisible(false)}
        onSave={() => { }}
        onDelete={() => { }}
      />
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 22,
    paddingVertical: 22,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.SECONDARY,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 16,
    paddingTop: 50,
  },
  backButton: {
    padding: 4,
  },
  deckName: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    flex: 1,
    textAlign: 'center',
  },
  editButton: {
    padding: 4,
  },
  editButtonText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.PRIMARY,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
  },
  description: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.SECONDARY,
    textAlign: 'center',
    paddingHorizontal: 16,
  },
  cardContainer: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'center',
    marginBottom: 20,
  },
  buttonContainer: {
    paddingBottom: 20,
  },
  closeButton: {
    width: '100%',
  },
  toast: {
    position: 'absolute',
    left: 16,
    right: 16,
    bottom: 40,
    backgroundColor: '#2ecc71',
    borderRadius: 12,
    paddingVertical: 12,
    paddingHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 2 },
    elevation: 5,
  },
  toastText: {
    color: '#fff',
    marginLeft: 8,
    fontSize: 14,
    fontWeight: '600',
  },
  completionOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0,0,0,0.35)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  completionContent: {
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: 16,
    padding: 20,
    width: '88%',
  },
  completionTitle: {
    fontSize: TYPOGRAPHY.SIZES.XLARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.BOLD,
    color: COLORS.TEXT.PRIMARY,
    textAlign: 'center',
    marginBottom: 8,
  },
  completionText: {
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.SECONDARY,
    textAlign: 'center',
    marginBottom: 16,
  },
  completionButtons: {
    flexDirection: 'row',
  },
}); 