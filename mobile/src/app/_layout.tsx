import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';

export default function RootLayout() {
  return (
    <>
      <StatusBar style="light" />
      <Stack screenOptions={{
        headerStyle: { backgroundColor: '#0b0f19' },
        headerTintColor: '#f8fafc',
        headerTitleStyle: { fontWeight: 'bold' },
        contentStyle: { backgroundColor: '#0b0f19' },
      }}>
        <Stack.Screen name="index" options={{ title: 'betBetter · Scratch-offs' }} />
        <Stack.Screen name="details/[gameId]" options={{ title: 'Game details' }} />
      </Stack>
    </>
  );
}
