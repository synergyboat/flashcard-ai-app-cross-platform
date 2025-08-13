import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  Alert,
  ScrollView,
  ActivityIndicator,
  TouchableOpacity,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { Ionicons } from '@expo/vector-icons';
import { RootStackParamList } from '../../App';
import { AIGenerationRequest } from '../types';
import { databaseORMService } from '../services/database-orm';
import { aiService } from '../services/ai';
import GradientButton from '../components/GradientButton';
import GradientBackground from '../components/GradientBackground';
import { SCREEN_NAMES, COLORS, TYPOGRAPHY } from '../config';
import { Dropdown } from 'react-native-element-dropdown';

type AIGenerateScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.AI_GENERATE>;

export default function AIGenerateScreen() {
  const navigation = useNavigation<AIGenerateScreenNavigationProp>();
  const [topic, setTopic] = useState('');
  const [cardCount, setCardCount] = useState(10);
  const [loading, setLoading] = useState(false);

  const dropdownData = [5, 10, 15, 20].map(v => ({ label: String(v), value: v }));

  const handleGenerate = async () => {
    if (!topic.trim()) {
      Alert.alert('Error', 'Please enter a topic');
      return;
    }

    const count = cardCount;

    setLoading(true);

    try {
      // Ensure database is initialized
      await databaseORMService.init();

      const request: AIGenerationRequest = {
        topic: topic.trim(),
        cardCount: count,
      };

      const response = await aiService.generateFlashcards(request);

      // Navigate to Deck Details in preview mode; user will save from there
      navigation.navigate(SCREEN_NAMES.DECK_DETAILS, {
        previewDeck: {
          name: response.deck.name,
          description: response.deck.description,
          flashcards: response.flashcards,
        },
        deckName: response.deck.name,
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      Alert.alert('Error', `Failed to generate flashcards: ${errorMessage}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <GradientBackground>
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backButton}>
            <Ionicons name="chevron-back" size={24} color={COLORS.TEXT.PRIMARY} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Generate Deck with AI</Text>
          <View style={styles.backButton} />
        </View>

      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
          <View>
            <Text style={styles.subtitle}>
              Provide a topic or concept below. The AI will generate a flashcard deck based on your input.
            </Text>

            <View style={styles.formContainer}>
              <View style={styles.inputContainer}>
                <TextInput
                  style={styles.textInput}
                  value={topic}
                  onChangeText={setTopic}
                  placeholder="Enter a topic for the deck"
                  placeholderTextColor={COLORS.TEXT.LIGHT}
                  multiline={false}
                />
              </View>

              <View style={styles.dropdownContainer}>
                <Text style={styles.dropdownLabel}>Max number of cards</Text>
                <Dropdown
                  data={dropdownData}
                  style={styles.dropdown}
                  containerStyle={styles.dropdownMenu}
                  placeholderStyle={styles.dropdownPlaceholder}
                  selectedTextStyle={styles.dropdownSelectedText}
                  labelField="label"
                  valueField="value"
                  value={cardCount}
                  placeholder="Select"
                  onChange={(item: { label: string; value: number }) => setCardCount(item.value)}
                  renderRightIcon={() => (
                    <Ionicons name="chevron-down" size={18} color={COLORS.TEXT.SECONDARY} />
                  )}
                  maxHeight={220}
                />
              </View>
            </View>

            <View style={styles.buttonContainer}>
              <GradientButton
                title={loading ? 'Generating...' : 'Generate Deck'}
                onPress={handleGenerate}
                disabled={loading || !topic.trim()}
                style={styles.generateButton}
                icon={<Ionicons name="sparkles" size={20} color={COLORS.TEXT.WHITE} />}
              />
            </View>

            {loading && (
              <View style={styles.loadingContainer}>
                <ActivityIndicator size="large" color={COLORS.PRIMARY} />
                <Text style={styles.loadingText}>Creating your flashcards...</Text>
              </View>
            )}
          </View>

          <View style={styles.infoContainer}>
            <Ionicons name="information-circle-outline" size={24} color={COLORS.TEXT.LIGHT} />
            <Text style={styles.infoText}>
              The AI will generate a deck based on your prompt. The generated deck will contain a maximum of {cardCount} cards. Please note that language models may not always produce accurate or relevant results, so review the generated cards before using them.
            </Text>
          </View>
      </ScrollView>
      </View>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
    paddingTop: 50,
  },
  backButton: {
    padding: 4,
    width: 32,
  },
  headerTitle: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    flex: 1,
    textAlign: 'center',
  },
  container: {
    flex: 1,
    paddingTop: 24,
  },
  content: {
    padding: 16,
    paddingBottom: 40,
    justifyContent: 'space-between',
    height: '100%',
  },
  title: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.PRIMARY,
    textAlign: 'center',
    marginBottom: 32,
    paddingHorizontal: 8,
  },
  formContainer: {
    backgroundColor: 'rgba(255, 255, 255, 0)',
    borderRadius: 8,
    padding: 8,
    marginBottom: 48,
    marginTop: 32,
  },
  inputContainer: {
    marginBottom: 16,
  },
  textInput: {
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: `${COLORS.TEXT.PRIMARY}66`,
    padding: 16,
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    minHeight: 50,
  },
  dropdownContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  dropdownLabel: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.SECONDARY,
  },
  dropdown: {
    // flex: 1,
    width: 72,
    backgroundColor: COLORS.BACKGROUND.TRANSPARENT,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: `${COLORS.TEXT.PRIMARY}66`,
    paddingHorizontal: 12,
    paddingVertical: 16,
    minHeight: 44,
    marginLeft: 12,
  },
  dropdownMenu: {
    borderRadius: 8,
  },
  dropdownPlaceholder: {
    color: COLORS.TEXT.SECONDARY,
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
  },
  dropdownSelectedText: {
    color: COLORS.TEXT.PRIMARY,
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
  },
  buttonContainer: {
    marginBottom: 32,
  },
  generateButton: {

  },
  loadingContainer: {
    alignItems: 'center',
    marginVertical: 20,
  },
  loadingText: {
    marginTop: 12,
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.SECONDARY,
  },
  infoContainer: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingHorizontal: 8,
  },
  infoText: {
    fontSize: TYPOGRAPHY.SIZES.TINY,
    color: COLORS.TEXT.SECONDARY,
    lineHeight: TYPOGRAPHY.LINE_HEIGHTS.TIGHT,
    marginLeft: 8,
    flex: 1,
    textAlign: 'justify',
  },
}); 