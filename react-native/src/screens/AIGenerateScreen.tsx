import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  Alert,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../../App';
import { AIGenerationRequest } from '../types';
import { databaseORMService } from '../services/database-orm';
import { aiService } from '../services/ai';
import GradientButton from '../components/GradientButton';
import GradientBackground from '../components/GradientBackground';
import { SCREEN_NAMES, APP_CONFIG } from '../config';

type AIGenerateScreenNavigationProp = StackNavigationProp<RootStackParamList, typeof SCREEN_NAMES.AI_GENERATE>;

export default function AIGenerateScreen() {
  const navigation = useNavigation<AIGenerateScreenNavigationProp>();
  const [topic, setTopic] = useState('');
  const [cardCount, setCardCount] = useState(APP_CONFIG.CARD_LIMITS.DEFAULT.toString());
  const [loading, setLoading] = useState(false);

  const handleGenerate = async () => {
    if (!topic.trim()) {
      Alert.alert('Error', 'Please enter a topic');
      return;
    }

    const count = parseInt(cardCount);
    if (isNaN(count) || count < APP_CONFIG.CARD_LIMITS.MIN || count > APP_CONFIG.CARD_LIMITS.MAX) {
      Alert.alert('Error', `Please enter a valid number of cards (${APP_CONFIG.CARD_LIMITS.MIN}-${APP_CONFIG.CARD_LIMITS.MAX})`);
      return;
    }

    setLoading(true);

    try {
      const request: AIGenerationRequest = {
        topic: topic.trim(),
        cardCount: count,
      };

      const response = await aiService.generateFlashcards(request);

      // Create the deck with flashcards using ORM
      const deckId = await databaseORMService.createDeckWithFlashcards(
        {
          name: response.deck.name,
          description: response.deck.description,
        },
        response.flashcards
      );

      Alert.alert(
        'Success!',
        `Generated ${response.flashcards.length} flashcards about "${topic}"`,
        [
          {
            text: 'View Deck',
            onPress: () => navigation.navigate(SCREEN_NAMES.DECK_DETAILS, {
              deckId,
              deckName: response.deck.name,
            }),
          },
          {
            text: 'Generate Another',
            onPress: () => {
              setTopic('');
              setCardCount(APP_CONFIG.CARD_LIMITS.DEFAULT.toString());
            },
          },
        ]
      );
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      Alert.alert('Error', `Failed to generate flashcards: ${errorMessage}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <GradientBackground>
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.title}>Generate Deck with AI</Text>
      
      <View style={styles.inputContainer}>
        <Text style={styles.label}>Topic</Text>
        <TextInput
          style={styles.input}
          value={topic}
          onChangeText={setTopic}
          placeholder="Enter your prompt here"
          placeholderTextColor="#999"
          multiline
          numberOfLines={3}
          textAlignVertical="top"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Number of Cards</Text>
        <TextInput
          style={styles.input}
          value={cardCount}
          onChangeText={setCardCount}
          placeholder="5"
          placeholderTextColor="#999"
          keyboardType="numeric"
          maxLength={2}
        />
      </View>

      <View style={styles.buttonContainer}>
        <GradientButton
          title={loading ? 'Generating...' : 'Generate Deck'}
          onPress={handleGenerate}
          disabled={loading}
          style={styles.generateButton}
        />
      </View>

      {loading && (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#4A90E2" />
          <Text style={styles.loadingText}>Creating your flashcards...</Text>
        </View>
      )}

      <View style={styles.infoContainer}>
        <Text style={styles.infoTitle}>How it works:</Text>
        <Text style={styles.infoText}>
          • Enter any topic you want to study{'\n'}
          • Choose how many flashcards to generate{'\n'}
          • AI will create educational questions and answers{'\n'}
          • Your new deck will be saved automatically
        </Text>
        
      </View>
      </ScrollView>
    </GradientBackground>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    padding: 20,
    paddingBottom: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333333',
    textAlign: 'center',
    marginBottom: 32,
  },
  inputContainer: {
    marginBottom: 24,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333333',
    marginBottom: 8,
  },
  input: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    fontSize: 16,
    color: '#333',
    borderWidth: 1,
    borderColor: '#e1e5e9',
    minHeight: 50,
  },
  buttonContainer: {
    marginTop: 16,
    marginBottom: 32,
  },
  generateButton: {
    width: '100%',
  },
  loadingContainer: {
    alignItems: 'center',
    marginVertical: 20,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#666',
  },
  infoContainer: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 20,
    borderWidth: 1,
    borderColor: '#e1e5e9',
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  aiStatusContainer: {
    marginTop: 20,
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: '#e1e5e9',
  },
  aiStatusTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  aiStatusText: {
    fontSize: 14,
    color: '#4A90E2',
    fontWeight: '600',
    marginBottom: 4,
  },
  aiStatusNote: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
  },
}); 