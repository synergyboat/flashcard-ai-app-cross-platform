import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Dimensions,
  Alert,
} from 'react-native';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { Deck } from '../types';
import { databaseORMService } from '../services/database-orm';
import GradientBackground from '../components/GradientBackground';
import DeckCard from '../components/DeckCard';
import GradientButton from '../components/GradientButton';
import { SCREEN_NAMES, COLORS, UI_CONFIG, SHADOWS, TYPOGRAPHY } from '../config';

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.HOME>;

const { width } = Dimensions.get('window');

export default function HomeScreen() {
  const navigation = useNavigation<HomeScreenNavigationProp>();
  const [decks, setDecks] = useState<Deck[]>([]);
  const [loading, setLoading] = useState(true);
  const [isShaking, setIsShaking] = useState(false);
  const [showText, setShowText] = useState(false);

  useFocusEffect(
    React.useCallback(() => {
      loadDecks();
    }, [])
  );

  useEffect(() => {
    if (decks.length === 0) {
      setShowText(true);
      const timer = setTimeout(() => setShowText(false), 5000);
      return () => clearTimeout(timer);
    }
  }, [decks.length]);

  const loadDecks = async () => {
    try {
      await databaseORMService.init();
      await databaseORMService.seedSampleData();
      const loadedDecks = await databaseORMService.getDecks();
      setDecks(loadedDecks);
    } catch (error) {
      console.error('Error loading decks:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeckPress = (deck: Deck) => {
    if (deck.id) {
      navigation.navigate(SCREEN_NAMES.DECK_DETAILS, {
        deckId: deck.id,
        deckName: deck.name || 'Unnamed Deck',
      });
    }
  };

  const handleLongPress = () => {
    setIsShaking(!isShaking);
  };

  const handleEditDeck = async (updatedDeck: Deck) => {
    try {
      if (updatedDeck.id) {
        await databaseORMService.updateDeck(updatedDeck.id, {
          name: updatedDeck.name,
          description: updatedDeck.description,
        });
        loadDecks();
      }
    } catch (error) {
      console.error('Error updating deck:', error);
      Alert.alert('Error', 'Failed to update deck');
    }
  };

  const handleDeleteDeck = async (deckId: number) => {
    try {
      await databaseORMService.deleteDeck(deckId);
      loadDecks();
    } catch (error) {
      console.error('Error deleting deck:', error);
      Alert.alert('Error', 'Failed to delete deck');
    }
  };

  const renderDeckCard = ({ item }: { item: Deck }) => (
    <DeckCard
      deck={item}
      onPress={handleDeckPress}
      onLongPress={handleLongPress}
      onEdit={handleEditDeck}
      onDelete={handleDeleteDeck}
      isShaking={isShaking}
    />
  );

  const renderEmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyStateTitle}>
        No decks found.{"\n"}Create a new deck to get started.
      </Text>
      <View style={styles.emptyStateButton}>
        <GradientButton
          title={showText ? "✨ Generate with AI" : "✨"}
          onPress={() => navigation.navigate(SCREEN_NAMES.AI_GENERATE)}
          style={styles.aiButton}
        />
      </View>
    </View>
  );

  return (
    <GradientBackground>
      <TouchableOpacity
        style={styles.container}
        activeOpacity={1}
        onPress={() => setIsShaking(false)}
      >
        <Text style={styles.appTitle}>Flashcard AI</Text>

        <View style={styles.contentContainer}>
          {decks.length === 0 ? (
            renderEmptyState()
          ) : (
            <View style={styles.gridContainer}>
              <FlatList
                data={decks}
                renderItem={renderDeckCard}
                keyExtractor={(item) => item.id?.toString() || ''}
                contentContainerStyle={styles.listContainer}
                showsVerticalScrollIndicator={false}
                  numColumns={2}
                  columnWrapperStyle={styles.row}
                />
            </View>
          )}
        </View>

        {/* AI Generation Button for non-empty state */}
        {decks.length > 0 && (
          <View style={styles.bottomButtonContainer}>
            <GradientButton
              timer={5000}
              title={"Generate with AI"}
              icon={<Ionicons name="sparkles" size={20} color={COLORS.TEXT.WHITE} />}
              onPress={() => navigation.navigate(SCREEN_NAMES.AI_GENERATE)}
              style={styles.bottomAiButton}
            />
          </View>
        )}
      </TouchableOpacity>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingVertical: 24,
  },
  appTitle: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    textAlign: 'center',
    paddingTop: 50,
    paddingBottom: 16,
  },
  contentContainer: {
    flex: 1,
    paddingHorizontal: 16,
  },
  gridContainer: {
    flex: 1,
  },
  listContainer: {
    gap: 16,
    paddingTop: 8,
    paddingBottom: 100,
    paddingHorizontal: 16,
  },
  row: {
    justifyContent: 'space-between',
  },
  emptyState: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyStateTitle: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.SECONDARY,
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: TYPOGRAPHY.LINE_HEIGHTS.NORMAL,
  },
  emptyStateButton: {
    alignSelf: 'center',
  },
  aiButton: {
    alignSelf: 'center',
  },
  bottomButtonContainer: {
    position: 'absolute',
    bottom: 40,
    right: 30,
  },
  bottomAiButton: {
    alignSelf: 'center',
  },
}); 