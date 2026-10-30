// mobile/App.tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { RankingsScreen } from './src/screens/RankingsScreen';
import { StatusBar } from 'expo-status-bar';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="light" />
      <Stack.Navigator
        screenOptions={{
          headerStyle: { backgroundColor: '#0b0f19' },
          headerTintColor: '#f8fafc',
          headerTitleStyle: { fontWeight: 'bold' },
        }}
      >
        <Stack.Screen name="Rankings" component={RankingsScreen} options={{ title: 'betBetter · Scratch-offs' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}