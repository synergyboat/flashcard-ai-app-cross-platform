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
import { databaseORMService } from '../services/database-orm';
import GradientBackground from '../components/GradientBackground';
import { SCREEN_NAMES, COLORS, UI_CONFIG, SHADOWS } from '../config';

type HomeScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.HOME>;

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
      await databaseORMService.init();
      const loadedDecks = await databaseORMService.getDecks();
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
      onPress={() => item.id && navigation.navigate(SCREEN_NAMES.DECK_DETAILS, {
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
    <GradientBackground>
      <View style={styles.container}>
        <FlatList
          data={decks}
          renderItem={renderDeckCard}
          keyExtractor={(item) => item.id?.toString() || ''}
          contentContainerStyle={styles.listContainer}
          showsVerticalScrollIndicator={false}
          ListEmptyComponent={!loading ? renderEmptyState : null}
          numColumns={2}
          columnWrapperStyle={styles.row}
        />

        {/* AI Generation FAB */}
        <TouchableOpacity
          style={styles.fab}
          onPress={() => navigation.navigate(SCREEN_NAMES.AI_GENERATE)}
          activeOpacity={0.8}
        >
          <Ionicons name="sparkles" size={24} color="white" />
        </TouchableOpacity>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
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
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: UI_CONFIG.BORDER_RADIUS.LARGE,
    borderWidth: 0.5,
    borderColor: COLORS.BORDER.MEDIUM,
    padding: UI_CONFIG.SPACING.CONTAINER_PADDING,
    ...SHADOWS.CARD,
    minHeight: 120,
  },
  deckName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.TEXT.PRIMARY,
    marginBottom: 8,
  },
  deckCount: {
    fontSize: 14,
    color: COLORS.TEXT.PRIMARY,
    marginBottom: 8,
  },
  deckDescription: {
    fontSize: 12,
    color: COLORS.TEXT.SECONDARY,
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
    color: COLORS.TEXT.PRIMARY,
    marginTop: 16,
    marginBottom: 8,
  },
  emptyStateSubtitle: {
    fontSize: 14,
    color: COLORS.TEXT.SECONDARY,
    textAlign: 'center',
    paddingHorizontal: 40,
  },
  fab: {
    position: 'absolute',
    bottom: UI_CONFIG.SPACING.BUTTON_MARGIN,
    right: UI_CONFIG.SPACING.BUTTON_MARGIN,
    width: UI_CONFIG.DIMENSIONS.FAB_SIZE,
    height: UI_CONFIG.DIMENSIONS.FAB_SIZE,
    borderRadius: UI_CONFIG.DIMENSIONS.FAB_SIZE / 2,
    backgroundColor: COLORS.PRIMARY,
    alignItems: 'center',
    justifyContent: 'center',
    ...SHADOWS.FAB,
  },
}); 