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

// Screens





export type RootStackParamList = {
  Home: undefined;
  AIGenerate: undefined;
  DeckDetails: { deckId: string; deckName: string };
  Study: { deckId: string; deckName: string };
};

const Stack = createStackNavigator<RootStackParamList>();

export default function App() {
  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <StatusBar style="auto" />
        <Stack.Navigator
          initialRouteName="Home"
          screenOptions={{
            headerStyle: {
              backgroundColor: '#f8f9fa',
            },
            headerTintColor: '#333',
            headerTitleStyle: {
              fontWeight: 'bold',
            },
          }}
        >
          <Stack.Screen 
            name="Home" 
            component={HomeScreen} 
            options={{ title: 'Flashcard AI' }}
          />
          <Stack.Screen 
            name="AIGenerate" 
            component={AIGenerateScreen} 
            options={{ title: 'AI Generate Deck' }}
          />
          <Stack.Screen 
            name="DeckDetails" 
            component={DeckDetailsScreen} 
            options={{ title: 'Deck Details' }}
          />
          <Stack.Screen 
            name="Study" 
            component={StudyScreen} 
            options={{ title: 'Study' }}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
