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

// Screens





export type RootStackParamList = {
  [SCREEN_NAMES.HOME]: undefined;
  [SCREEN_NAMES.AI_GENERATE]: undefined;
  [SCREEN_NAMES.DECK_DETAILS]: { deckId: number; deckName: string };
  [SCREEN_NAMES.STUDY]: { deckId: number; deckName: string };
};

const Stack = createStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <StatusBar style="auto" />
        <Stack.Navigator
          initialRouteName={SCREEN_NAMES.HOME}
          screenOptions={{
            headerStyle: {
              backgroundColor: COLORS.BACKGROUND.HEADER,
            },
            headerTintColor: COLORS.TEXT.PRIMARY,
            headerTitleStyle: {
              fontWeight: 'bold',
              color: COLORS.TEXT.PRIMARY,
            },
          }}
        >
          <Stack.Screen 
            name={SCREEN_NAMES.HOME} 
            component={HomeScreen} 
            options={{ title: SCREEN_TITLES.HOME }}
          />
          <Stack.Screen 
            name={SCREEN_NAMES.AI_GENERATE} 
            component={AIGenerateScreen} 
            options={{ title: SCREEN_TITLES.AI_GENERATE }}
          />
          <Stack.Screen 
            name={SCREEN_NAMES.DECK_DETAILS} 
            component={DeckDetailsScreen} 
            options={{ title: SCREEN_TITLES.DECK_DETAILS }}
          />
          <Stack.Screen 
            name={SCREEN_NAMES.STUDY} 
            component={StudyScreen} 
            options={{ title: SCREEN_TITLES.STUDY }}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
