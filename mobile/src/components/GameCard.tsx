import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { RankedGame } from '../types/api';

interface GameCardProps {
  item: RankedGame;
  onPress: () => void;
}

export const GameCard: React.FC<GameCardProps> = ({ item, onPress }) => {
  const { game, metrics } = item;

  const fmtMoney = (val: number | null) => (val != null ? `$${val.toFixed(2)}` : 'N/A');
  const fmtPercent = (val: number | null) => (val != null ? `${(val * 100).toFixed(1)}%` : 'N/A');
  const fmtOdds = (prob: number | null) => (prob && prob > 0 ? `1 in ${Math.round(1 / prob).toLocaleString()}` : 'N/A');

  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.header}>
        <View style={{ flex: 1 }}>
          <Text style={styles.title}>{game.name}</Text>
          <Text style={styles.subtitle}>Ticket: {fmtMoney(game.ticket_price)} • {game.inventory_method}</Text>
        </View>
        <Text style={styles.badge}>{game.state}</Text>
      </View>

      <View style={styles.grid}>
        <View style={styles.metric}>
          <Text style={styles.label}>Est. Gross EV / $1</Text>
          <Text style={[styles.value, styles.highlight]}>{fmtMoney(metrics.ev_per_dollar)}</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.label}>Est. Jackpot Odds</Text>
          <Text style={styles.value}>{fmtOdds(metrics.jackpot_probability)}</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.label}>Net EV (ex. Jackpot)</Text>
          <Text style={styles.value}>{fmtMoney(metrics.non_jackpot_net_ev)}</Text>
        </View>
        <View style={styles.metric}>
          <Text style={styles.label}>Top Prizes Remaining</Text>
          <Text style={styles.value}>{fmtPercent(metrics.top_prizes_remaining)}</Text>
        </View>
      </View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: { backgroundColor: '#1e293b', padding: 14, borderRadius: 10, marginBottom: 10, borderWidth: 1, borderColor: '#334155' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 },
  title: { color: '#f8fafc', fontSize: 16, fontWeight: 'bold' },
  subtitle: { color: '#94a3b8', fontSize: 12, marginTop: 2 },
  badge: { color: '#38bdf8', backgroundColor: '#0f172a', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 4, fontSize: 12, fontWeight: 'bold' },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  metric: { width: '48%', backgroundColor: '#0f172a', padding: 8, borderRadius: 6 },
  label: { color: '#64748b', fontSize: 10, textTransform: 'uppercase' },
  value: { color: '#e2e8f0', fontSize: 13, fontWeight: '600', marginTop: 2 },
  highlight: { color: '#38bdf8' },
});