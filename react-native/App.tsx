import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import 'react-native-gesture-handler';
import HomeScreen from './src/screens/HomeScreen';
import AIGenerateScreen from './src/screens/AIGenerateScreen';
import DeckDetailsScreen from './src/screens/DeckDetailsScreen';
import StudyScreen from './src/screens/StudyScreen';
import { SCREEN_NAMES, SCREEN_TITLES, COLORS } from './src/config';
import ListRenderBenchmarkScreen from './src/screens/ListRenderBenchmarkScreen';

// Screens

export type RootStackParamList = {
  [SCREEN_NAMES.HOME]: undefined;
  [SCREEN_NAMES.AI_GENERATE]: undefined;
  [SCREEN_NAMES.DECK_DETAILS]: {
    deckId?: number;
    deckName?: string;
    previewDeck?: {
      name: string;
      description?: string;
      flashcards: { question: string; answer: string }[];
    };
  };
  [SCREEN_NAMES.STUDY]: { deckId: number; deckName: string };
};

const Stack = createStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <StatusBar style="auto" />
        {/*<ListRenderBenchmarkScreen/>*/}
        <Stack.Navigator
          initialRouteName={SCREEN_NAMES.HOME}
          screenOptions={{
            headerShown: false,
          }}
        >
          <Stack.Screen
            name={SCREEN_NAMES.HOME}
            component={HomeScreen}
          />
          <Stack.Screen
            name={SCREEN_NAMES.AI_GENERATE}
            component={AIGenerateScreen}
          />
          <Stack.Screen
            name={SCREEN_NAMES.DECK_DETAILS}
            component={DeckDetailsScreen}
          />
          <Stack.Screen
            name={SCREEN_NAMES.STUDY}
            component={StudyScreen}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
