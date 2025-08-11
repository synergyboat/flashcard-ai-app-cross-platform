import React, { useState, useRef, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  TouchableOpacity,
  PanResponder,
  Animated,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Flashcard } from '../types';
import { APP_CONFIG } from '../config';

const { width, height } = Dimensions.get('window');
const SWIPE_THRESHOLD = width * APP_CONFIG.ANIMATIONS.SWIPE_THRESHOLD_FACTOR;

interface CardStackProps {
  flashcards: Flashcard[];
  currentIndex: number;
  onSwipeLeft: () => void;
  isPreview?: boolean;
}

export default function CardStack({
  flashcards,
  currentIndex,
  onSwipeLeft,
  isPreview = false,
}: CardStackProps) {
  const [isFlipped, setIsFlipped] = useState(false);
  const [isDragging, setIsDragging] = useState(false);

  React.useEffect(() => {
    setIsFlipped(false);
  }, [currentIndex]);

  const pan = useRef(new Animated.ValueXY()).current;
  const rotate = useRef(new Animated.Value(0)).current;

  const currentCard = flashcards[currentIndex];
  const nextCard = flashcards[currentIndex + 1];
  const nextNextCard = flashcards[currentIndex + 2];

  // Generate pastel-like colors similar to Flutter RandomGradientGenerator
  const pastelPalette = useMemo(
    () => [
      'rgba(255, 205, 210, 0.22)', // red100
      'rgba(248, 187, 208, 0.22)', // pink100/200
      'rgba(225, 190, 231, 0.22)', // purple100
      'rgba(209, 196, 233, 0.22)', // deepPurple100
      'rgba(197, 202, 233, 0.22)', // indigo100
      'rgba(187, 222, 251, 0.22)', // blue100
      'rgba(179, 229, 252, 0.22)', // lightBlue100
      'rgba(178, 235, 242, 0.22)', // cyan100
      'rgba(178, 223, 219, 0.22)', // teal100
      'rgba(200, 230, 201, 0.22)', // green100
      'rgba(220, 237, 200, 0.22)', // lightGreen100
      'rgba(240, 244, 195, 0.22)', // lime100
      'rgba(255, 249, 196, 0.22)', // yellow100
      'rgba(255, 236, 179, 0.22)', // amber100
      'rgba(255, 224, 178, 0.22)', // orange100
      'rgba(255, 204, 188, 0.22)', // deepOrange100
    ],
    []
  );

  const pickRandomColors = (count: number) => {
    const result: string[] = [];
    for (let i = 0; i < count; i += 1) {
      result.push(pastelPalette[Math.floor(Math.random() * pastelPalette.length)]);
    }
    return result;
  };

  // Recompute gradients when the top card index changes to keep them stable per card
  const topGradient1 = useMemo(() => {
    return [...pickRandomColors(2), 'rgba(255,255,255,0.10)', 'rgba(255,255,255,0.40)', 'rgba(255,255,255,0.40)'];
  }, [currentIndex]);
  const topGradient2 = useMemo(() => {
    return [...pickRandomColors(3), 'rgba(255,255,255,0.10)', 'rgba(255,255,255,0.10)', 'rgba(255,255,255,0.10)'];
  }, [currentIndex]);

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => false,
      onMoveShouldSetPanResponder: (_, gesture) => {
        const { dx, dy } = gesture;
        return Math.abs(dx) > 10 && Math.abs(dx) > Math.abs(dy);
      },
      onPanResponderGrant: () => {
        setIsDragging(true);
        pan.setOffset({ x: (pan.x as any)._value, y: (pan.y as any)._value });
      },
      onPanResponderMove: (_, gesture) => {
        pan.setValue({ x: gesture.dx, y: gesture.dy });
        const r = gesture.dx / width;
        rotate.setValue(r);
      },
      onPanResponderRelease: (_, gesture) => {
        setIsDragging(false);
        pan.flattenOffset();
        const { dx, vx } = gesture;
        const shouldSwipe = Math.abs(dx) > SWIPE_THRESHOLD || Math.abs(vx) > 0.5;
        if (shouldSwipe) {
          animateSwipe(dx > 0 ? 'right' : 'left');
        } else {
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
        duration: APP_CONFIG.ANIMATIONS.SWIPE_DURATION,
        useNativeDriver: false,
      }),
      Animated.timing(rotate, {
        toValue: direction === 'right' ? 1 : -1,
        duration: APP_CONFIG.ANIMATIONS.SWIPE_DURATION,
        useNativeDriver: false,
      }),
    ]).start(() => {
      onSwipeLeft();
      resetPosition();
      setIsFlipped(false);
    });
  };

  const resetPosition = () => {
    pan.setValue({ x: 0, y: 0 });
    rotate.setValue(0);
  };

  const handleFlip = () => {
    if (!isDragging) setIsFlipped(prev => !prev);
  };

  // Height tuned to resemble Flutter screen proportion
  const computedCardHeight = Math.min(height * (isPreview ? 0.50 : 0.56), 520);

  // Second card scale grows slightly as you drag the top card
  const scaleBump = pan.x.interpolate({
    inputRange: [-150, 0, 150],
    outputRange: [0.02, 0, 0.02],
    extrapolate: 'clamp',
  });
  const secondBaseScale = new Animated.Value(0.96);
  const secondScale = Animated.add(secondBaseScale, scaleBump);

  // Layer renderer (bottom to top to mimic a deck shadow)
  const renderLayer = (
    card: Flashcard,
    layerIndex: number,
    isTop: boolean
  ) => {
    const baseScale = layerIndex === 0 ? 1 : layerIndex === 1.4 ? secondScale : 0.94;
    const translateY = layerIndex * 12; // small vertical offset like Flutter stack

    const animatedStyle = isTop
      ? {
        transform: [
          { translateX: pan.x },
          { translateY: pan.y },
          {
            rotate: rotate.interpolate({
              inputRange: [-1, 0, 1],
              outputRange: ['-12deg', '0deg', '12deg'],
            }),
          },
          { scale: baseScale as any },
        ],
      }
      : {
        transform: [
          { translateY },
          { scale: baseScale as any },
        ],
      };

    return (
      <Animated.View
        key={`${card.id}-${layerIndex}`}
        style={[styles.card, { height: computedCardHeight }, animatedStyle]}
        {...(isTop ? panResponder.panHandlers : {})}
      >
        {/* Gradient layers to mimic Flutter radial gradients */}
        <LinearGradient
          pointerEvents="none"
          colors={topGradient1 as [string, string, ...string[]]}
          start={{ x: 1, y: 0 }}
          end={{ x: 0.2, y: 0.8 }}
          style={styles.gradientLayer}
        />
        <LinearGradient
          pointerEvents="none"
          colors={topGradient2 as [string, string, ...string[]]}
          start={{ x: 0, y: 0 }}
          end={{ x: 0.8, y: 0.8 }}
          style={styles.gradientLayer}
        />
        <View pointerEvents="none" style={styles.cardBorder} />

        <TouchableOpacity
          onPress={isTop ? handleFlip : undefined}
          activeOpacity={isTop ? 0.9 : 1}
          style={styles.cardContent}
        >
          <Text style={styles.cardText}>
            {isFlipped ? card.answer : card.question}
          </Text>
          {isTop && (
            <Text style={styles.cardProgress}>Card {currentIndex + 1} of {flashcards.length}</Text>
          )}
        </TouchableOpacity>
      </Animated.View>
    );
  };

  return (
    <View style={styles.container}>
      <View style={[styles.stackBox, { width: width - 40, height: computedCardHeight + 24 }]}>
        {/* Render bottom to top: third, second, first */}
        {nextNextCard && renderLayer(nextNextCard, 2, false)}
        {nextCard && renderLayer(nextCard, 1, false)}
        {currentCard && renderLayer(currentCard, 0, true)}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 20,
  },
  stackBox: {
    position: 'relative',
    alignItems: 'center',
    justifyContent: 'center',
  },
  card: {
    position: 'absolute',
    width: '100%',
    backgroundColor: 'white',
    borderRadius: 64,
    padding: 24,
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 10,
  },
  gradientLayer: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 64,
  },
  cardBorder: {
    ...StyleSheet.absoluteFillObject,
    borderRadius: 64,
    borderWidth: 1,
    borderColor: '#E0E0E0',
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
  cardProgress: {
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
    marginTop: 40,
  },
}); 