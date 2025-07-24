import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
  PanResponder,
  Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Flashcard } from '../types';

const { width, height } = Dimensions.get('window');
const CARD_HEIGHT = height * 0.6;
const SWIPE_THRESHOLD = width * 0.25;

interface CardStackProps {
  flashcards: Flashcard[];
  currentIndex: number;
  onSwipeLeft: () => void;
  onSwipeRight: () => void;
  onCardPress: () => void;
}

export default function CardStack({
  flashcards,
  currentIndex,
  onSwipeLeft,
  onSwipeRight,
  onCardPress,
}: CardStackProps) {
  const [isFlipped, setIsFlipped] = useState(false);
  const [isDragging, setIsDragging] = useState(false);

  // Reset flip state when card changes
  React.useEffect(() => {
    setIsFlipped(false);
  }, [currentIndex]);
  
  // Simple pan values without complex transforms
  const pan = useRef(new Animated.ValueXY()).current;
  const rotate = useRef(new Animated.Value(0)).current;

  const currentCard = flashcards[currentIndex];
  const nextCard = flashcards[currentIndex + 1];
  const prevCard = flashcards[currentIndex - 1];

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      
      onPanResponderGrant: () => {
        setIsDragging(true);
        pan.setOffset({
          x: (pan.x as any)._value,
          y: (pan.y as any)._value,
        });
      },
      
      onPanResponderMove: (_, gestureState) => {
        // Simple movement without complex transforms
        pan.setValue({
          x: gestureState.dx,
          y: gestureState.dy,
        });
        
        // Simple rotation based on horizontal movement
        const rotateValue = gestureState.dx / width;
        rotate.setValue(rotateValue);
      },
      
      onPanResponderRelease: (_, gestureState) => {
        setIsDragging(false);
        pan.flattenOffset();
        
        const { dx } = gestureState;
        
        if (Math.abs(dx) > SWIPE_THRESHOLD) {
          // Swipe threshold reached - animate off screen
          const direction = dx > 0 ? 'right' : 'left';
          animateSwipe(direction);
        } else {
          // Return to center
          resetPosition();
        }
      },
    })
  ).current;

  const animateSwipe = (direction: 'left' | 'right') => {
    const toValue = direction === 'right' ? width : -width;
    
    Animated.parallel([
      Animated.timing(pan.x, {
        toValue,
        duration: 250,
        useNativeDriver: false,
      }),
      Animated.timing(rotate, {
        toValue: direction === 'right' ? 1 : -1,
        duration: 250,
        useNativeDriver: false,
      }),
    ]).start(() => {
      // Call the appropriate callback
      if (direction === 'left') {
        onSwipeLeft();
      } else {
        onSwipeRight();
      }
      
      // Reset for next card
      resetPosition();
      setIsFlipped(false);
    });
  };

  const resetPosition = () => {
    pan.setValue({ x: 0, y: 0 });
    rotate.setValue(0);
  };

  const handleFlip = () => {
    if (!isDragging) {
      setIsFlipped(!isFlipped);
    }
  };

  const renderCard = (card: Flashcard, index: number, isCurrent: boolean = false) => {
    const cardStyle = isCurrent ? styles.currentCard : styles.stackCard;
    const zIndex = isCurrent ? 3 : 2 - index;
    const stackScale = isCurrent ? 1 : 0.95 - index * 0.05;

    // Only apply pan and rotate to current card
    const animatedStyle = isCurrent ? {
      transform: [
        { translateX: pan.x },
        { translateY: pan.y },
        { rotate: rotate.interpolate({
          inputRange: [-1, 0, 1],
          outputRange: ['-15deg', '0deg', '15deg'],
        })},
        { scale: stackScale },
      ],
    } : {
      transform: [{ scale: stackScale }],
    };

    return (
      <Animated.View
        key={card.id}
        style={[
          cardStyle,
          { zIndex },
          animatedStyle,
        ]}
        {...(isCurrent ? panResponder.panHandlers : {})}
      >
        <TouchableOpacity
          onPress={isCurrent ? handleFlip : undefined}
          activeOpacity={isCurrent ? 0.9 : 1}
          style={styles.cardContent}
        >
          <Text style={styles.cardText}>
            {isFlipped ? card.answer : card.question}
          </Text>
          {isCurrent && (
            <Text style={styles.tapHint}>
              {isFlipped ? 'Tap to see question' : 'Tap to reveal answer'}
            </Text>
          )}
        </TouchableOpacity>
      </Animated.View>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.cardStack}>
        {/* Render next card in background */}
        {nextCard && renderCard(nextCard, currentIndex + 1)}
        
        {/* Render current card */}
        {currentCard && renderCard(currentCard, currentIndex, true)}
        
        {/* Render previous card in background */}
        {prevCard && renderCard(prevCard, currentIndex - 1)}
      </View>

      {/* Swipe indicators */}
      <View style={styles.swipeIndicators}>
        <TouchableOpacity 
          style={[styles.indicator, styles.leftIndicator]}
          onPress={onSwipeLeft}
        >
          <Ionicons name="arrow-back" size={24} color="#ff6b6b" />
          <Text style={styles.indicatorText}>Skip</Text>
        </TouchableOpacity>
        <TouchableOpacity 
          style={[styles.indicator, styles.rightIndicator]}
          onPress={onSwipeRight}
        >
          <Ionicons name="arrow-forward" size={24} color="#51cf66" />
          <Text style={styles.indicatorText}>Got it</Text>
        </TouchableOpacity>
      </View>

      {/* Progress indicator */}
      <View style={styles.progressContainer}>
        <Text style={styles.progressText}>
          {currentIndex + 1} of {flashcards.length}
        </Text>
      </View>

      {/* Swipe instruction */}
      <View style={styles.instructionContainer}>
        <Text style={styles.instructionText}>
          Swipe left to skip • Swipe right for "got it" • Tap to flip
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardStack: {
    width: width - 40,
    height: CARD_HEIGHT,
    position: 'relative',
  },
  currentCard: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 24,
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  stackCard: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    backgroundColor: '#f8f9fa',
    borderRadius: 20,
    padding: 24,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  cardContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardText: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#333',
    lineHeight: 28,
  },
  tapHint: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    marginTop: 20,
    fontStyle: 'italic',
  },
  swipeIndicators: {
    position: 'absolute',
    top: 20,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 40,
  },
  indicator: {
    alignItems: 'center',
    padding: 8,
    borderRadius: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
  },
  leftIndicator: {
    borderColor: '#ff6b6b',
    borderWidth: 2,
  },
  rightIndicator: {
    borderColor: '#51cf66',
    borderWidth: 2,
  },
  indicatorText: {
    fontSize: 12,
    fontWeight: '600',
    marginTop: 4,
  },
  progressContainer: {
    position: 'absolute',
    bottom: 60,
    alignItems: 'center',
  },
  progressText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '600',
  },
  instructionContainer: {
    position: 'absolute',
    bottom: 20,
    alignItems: 'center',
  },
  instructionText: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
  },
}); 