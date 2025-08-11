import React, { useEffect, useRef, useState } from 'react';
import { TouchableOpacity, Text, StyleSheet, ViewStyle, TextStyle, View, Animated, LayoutChangeEvent } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { COLORS, TYPOGRAPHY, SHADOWS } from '../config/theme.config';

interface GradientButtonProps {
  title: string;
  onPress: () => void;
  style?: ViewStyle;
  textStyle?: TextStyle;
  disabled?: boolean;
  colors?: string[];
  shadowColor?: string;
  icon?: React.ReactNode;
  timer?: number; // milliseconds after which the text fades and button morphs to circle
}

const AnimatedTouchable = Animated.createAnimatedComponent(TouchableOpacity);

export default function GradientButton({
  title,
  onPress,
  style,
  textStyle,
  disabled = false,
  colors = [COLORS.PRIMARY, '#6fbfff'],
  icon,
  timer = 0,
}: GradientButtonProps) {
  const [hideText, setHideText] = useState(false);
  const [measured, setMeasured] = useState<{ width: number; height: number }>({ width: 0, height: 0 });

  // 0 = expanded, 1 = circle
  const collapse = useRef(new Animated.Value(0)).current;

  const onButtonLayout = (e: LayoutChangeEvent) => {
    const { width, height } = e.nativeEvent.layout;
    if (width !== measured.width || height !== measured.height) {
      setMeasured({ width, height });
    }
  };


  const animatedWidth = collapse.interpolate({
    inputRange: [0, 1],
    outputRange: [measured.width || 160, measured.height || 54],
  });
  const animatedRadius = collapse.interpolate({
    inputRange: [0, 1],
    outputRange: [32, (measured.height || 54) / 2],
  });
  const textOpacity = collapse.interpolate({ inputRange: [0, 0.5, 1], outputRange: [1, 0, 0] });

  useEffect(() => {
    if (timer && timer > 0) {
      const id = setTimeout(() => {
        Animated.timing(collapse, {
          toValue: 1,
          duration: 350,
          useNativeDriver: false,
        }).start(() => setHideText(true));
      }, timer);
      return () => clearTimeout(id);
    }
  }, [timer, collapse]);

  return (
    <View style={styles.container}>
      <AnimatedTouchable
        onLayout={onButtonLayout}
        style={[
          styles.button,
          style,
          { borderRadius: animatedRadius, width: animatedWidth },
        ]}
        onPress={onPress}
        disabled={disabled}
        activeOpacity={0.8}
      >
        <LinearGradient
          colors={colors as [string, string, ...string[]]}
          style={styles.gradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          <View style={styles.contentContainer}>
            {icon && <View >{icon}</View>}
            {!hideText && (
              <Animated.Text style={[styles.text, textStyle, { opacity: textOpacity }]}>
                {title}
              </Animated.Text>
            )}
          </View>
        </LinearGradient>
      </AnimatedTouchable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    shadowColor: COLORS.PRIMARY,
    shadowOffset: { width: 0, height: 5 },
    shadowOpacity: 0.55,
    shadowRadius: 18,
    // elevation: 10,
  },
  button: {
    borderRadius: 32,
    overflow: 'hidden',
    ...SHADOWS.BUTTON,
  },
  gradient: {
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 54,
  },
  contentContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  // iconContainer: {
  //   marginRight: 8,
  // },
  text: {
    color: COLORS.TEXT.WHITE,
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    fontWeight: TYPOGRAPHY.WEIGHTS.MEDIUM,
    textAlign: 'center',
  },
  disabled: {
    opacity: 0.6,
  },
  disabledText: {
    color: COLORS.TEXT.LIGHT,
  },
}); 