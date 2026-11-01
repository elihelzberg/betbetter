import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
export default function Layout() {
  return <><StatusBar style="light" /><Stack screenOptions={{ headerStyle: { backgroundColor: '#0b0f19' }, headerTintColor: '#f8fafc', contentStyle: { backgroundColor: '#0b0f19' } }}>
    <Stack.Screen name="index" options={{ title: 'betBetter · Scratch-offs' }} />
    <Stack.Screen name="details" options={{ title: 'Game details' }} />
    <Stack.Screen name="ask" options={{ title: 'Ask the data' }} />
    <Stack.Screen name="methodology" options={{ title: 'Assumptions & data' }} />
  </Stack></>;
}
