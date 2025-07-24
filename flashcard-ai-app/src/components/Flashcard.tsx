import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Dimensions,
  Animated,
} from 'react-native';

interface FlashcardProps {
  question: string;
  answer: string;
  cardNumber?: number;
  totalCards?: number;
  onSwipe?: (direction: 'left' | 'right') => void;
}

const { width } = Dimensions.get('window');

export default function Flashcard({
  question,
  answer,
  cardNumber,
  totalCards,
  onSwipe,
}: FlashcardProps) {
  const [isFlipped, setIsFlipped] = useState(false);
  const [flipAnimation] = useState(new Animated.Value(0));

  const handleFlip = () => {
    const toValue = isFlipped ? 0 : 1;
    Animated.spring(flipAnimation, {
      toValue,
      useNativeDriver: true,
      tension: 10,
      friction: 8,
    }).start();
    setIsFlipped(!isFlipped);
  };

  const frontInterpolate = flipAnimation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '180deg'],
  });

  const backInterpolate = flipAnimation.interpolate({
    inputRange: [0, 1],
    outputRange: ['180deg', '360deg'],
  });

  const frontAnimatedStyle = {
    transform: [{ rotateY: frontInterpolate }],
  };

  const backAnimatedStyle = {
    transform: [{ rotateY: backInterpolate }],
  };

  return (
    <View style={styles.container}>
      <View style={styles.cardContainer}>
        <TouchableOpacity onPress={handleFlip} activeOpacity={0.9}>
          <Animated.View style={[styles.card, styles.frontCard, frontAnimatedStyle]}>
            <Text style={styles.question}>{question}</Text>
            <Text style={styles.tapHint}>Tap to reveal answer</Text>
          </Animated.View>
        </TouchableOpacity>

        <TouchableOpacity onPress={handleFlip} activeOpacity={0.9}>
          <Animated.View style={[styles.card, styles.backCard, backAnimatedStyle]}>
            <Text style={styles.answer}>{answer}</Text>
            <Text style={styles.tapHint}>Tap to see question</Text>
          </Animated.View>
        </TouchableOpacity>
      </View>

      {cardNumber && totalCards && (
        <Text style={styles.progress}>
          Card {cardNumber} of {totalCards}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  cardContainer: {
    width: width - 40,
    height: 400,
    position: 'relative',
  },
  card: {
    width: '100%',
    height: '100%',
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    backfaceVisibility: 'hidden',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  frontCard: {
    backgroundColor: 'white',
  },
  backCard: {
    backgroundColor: '#f8f9fa',
  },
  question: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#333',
    marginBottom: 20,
    lineHeight: 28,
  },
  answer: {
    fontSize: 18,
    textAlign: 'center',
    color: '#555',
    lineHeight: 26,
  },
  tapHint: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    marginTop: 20,
    fontStyle: 'italic',
  },
  progress: {
    fontSize: 14,
    color: '#666',
    marginTop: 20,
  },
}); 