import { useEffect, useState } from 'react';
import { ActivityIndicator, Button, ScrollView, StyleSheet, Text, View } from 'react-native';
import { Stack, useLocalSearchParams } from 'expo-router';
import { api } from '../services/api';
import { RankedGame } from '../types/api';

const money = (value: number | null) => value == null ? 'N/A' : `$${value.toFixed(2)}`;
const odds = (value: number | null) => value != null && value > 0
  ? `1 in ${Math.round(1 / value).toLocaleString()}` : 'N/A';

export function DetailsScreen() {
  const { gameId, name, state = 'MI' } = useLocalSearchParams<{
    gameId: string; name?: string; state?: string;
  }>();
  return <GameDetails key={`${state}:${gameId}`} gameId={gameId} name={name} state={state} />;
}

function GameDetails({ gameId, name, state }: { gameId: string; name?: string; state: string }) {
  const [history, setHistory] = useState<RankedGame[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let active = true;
    api.getGameHistory(gameId, state)
      .then(data => { if (active) setHistory(data); })
      .catch(() => { if (active) setError('Could not load game details. Check your connection and try again.'); })
      .finally(() => { if (active) setLoading(false); });
    return () => { active = false; };
  }, [gameId, state, attempt]);

  const latest = history[history.length - 1];
  return (
    <>
      <Stack.Screen options={{ title: latest?.game.name || name || 'Game details' }} />
      {loading ? (
        <View style={styles.centered}><ActivityIndicator size="large" color="#38bdf8" accessibilityLabel="Loading game details" /></View>
      ) : error ? (
        <View style={styles.centered}>
          <Text style={styles.text} accessibilityRole="alert">{error}</Text>
          <Button title="Try again" onPress={() => {
            setLoading(true);
            setError(null);
            setAttempt(value => value + 1);
          }} />
        </View>
      ) : !latest ? (
        <View style={styles.centered}><Text style={styles.text}>No snapshots found for this game.</Text></View>
      ) : (
        <ScrollView contentContainerStyle={styles.content}>
          <Text style={styles.title}>{latest.game.name}</Text>
          <Text style={styles.muted}>Game {latest.game.game_id} · {latest.game.state} · Ticket {money(latest.game.ticket_price)}</Text>
          <View style={styles.panel}>
            <Text style={styles.text}>Est. gross EV / $1: {money(latest.metrics.ev_per_dollar)}</Text>
            <Text style={styles.text}>Est. net EV / ticket: {money(latest.metrics.net_ev)}</Text>
            <Text style={styles.text}>Est. net EV excluding jackpot: {money(latest.metrics.non_jackpot_net_ev)}</Text>
            <Text style={styles.text}>Est. jackpot odds: {odds(latest.metrics.jackpot_probability)}</Text>
          </View>
          <Text style={styles.muted}>Inventory: {latest.game.inventory_method}. Odds and EV use modeled ticket counts. Unclaimed prizes may belong to tickets already sold.</Text>
          <Text style={styles.muted}>Collected: {latest.game.observed_at}</Text>
          <Text style={styles.heading}>Prize breakdown</Text>
          <View style={styles.panel}>
            <View style={styles.row}>
              <Text style={styles.cell}>Prize</Text><Text style={styles.cell}>Original</Text><Text style={styles.cell}>Remaining</Text>
            </View>
            {latest.game.prizes.map(prize => (
              <View key={prize.amount} style={styles.row}>
                <Text style={styles.cell}>{money(prize.amount)}</Text>
                <Text style={styles.cell}>{prize.original.toLocaleString()}</Text>
                <Text style={styles.cell}>{prize.remaining.toLocaleString()}</Text>
              </View>
            ))}
          </View>
          <Text style={styles.heading}>Snapshot history</Text>
          <Text style={styles.muted}>Latest {Math.min(history.length, 20)} of {history.length.toLocaleString()} snapshots</Text>
          {history.slice(-20).reverse().map(snapshot => (
            <View key={snapshot.game.observed_at} style={styles.panel}>
              <Text style={styles.text}>{snapshot.game.observed_at}</Text>
              <Text style={styles.muted}>Est. gross EV / $1: {money(snapshot.metrics.ev_per_dollar)}</Text>
            </View>
          ))}
        </ScrollView>
      )}
    </>
  );
}

const styles = StyleSheet.create({
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 24, gap: 16 },
  content: { padding: 16, paddingBottom: 40, gap: 12 },
  title: { color: '#f8fafc', fontSize: 24, fontWeight: 'bold' },
  heading: { color: '#f8fafc', fontSize: 18, fontWeight: 'bold', marginTop: 8 },
  text: { color: '#e2e8f0', fontSize: 15 },
  muted: { color: '#94a3b8', fontSize: 13, lineHeight: 20 },
  panel: { backgroundColor: '#1e293b', padding: 14, borderRadius: 10, gap: 10 },
  row: { flexDirection: 'row', gap: 8 },
  cell: { flex: 1, color: '#e2e8f0', fontSize: 13 },
});
