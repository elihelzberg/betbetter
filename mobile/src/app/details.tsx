import React, { useEffect, useState } from 'react';
import { ActivityIndicator, Linking, ScrollView, Text, View } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { api } from '../services/api';
import { Action, Stat, styles } from '../components/UI';
import { boost, change, money, odds, percent } from '../utils/format';
import { loadGameDetails, type DetailsState } from '../services/details';
export default function Details() {
  const { gameId, state } = useLocalSearchParams<{ gameId: string; state?: string }>();
  const [retry, setRetry] = useState(0);
  return <DetailsContent key={`${state}-${gameId}-${retry}`} gameId={gameId} state={state} onRetry={() => setRetry(retry + 1)} />;
}
function DetailsContent({ gameId, state, onRetry }: { gameId: string; state?: string; onRetry: () => void }) {
  const [{ item, history, loading, error }, setDetails] = useState<DetailsState>({ item: null, history: [], loading: true, error: '' });
  const [sourceError, setSourceError] = useState('');
  useEffect(() => loadGameDetails(api, gameId, state || 'MI', setDetails), [gameId, state]);
  const g = item?.game, m = item?.metrics;
  return <ScrollView style={styles.page} contentContainerStyle={styles.content}>
    {loading && <ActivityIndicator color="#38bdf8" />}
    {!!(error || sourceError) && <><Text accessibilityRole="alert" style={styles.error}>{error || sourceError}</Text><Action title="Retry" onPress={onRetry} /></>}
    {g && m && <>
      <Text style={styles.title}>{g.name}</Text><Text style={styles.text}>{g.game_id} · {g.state} · {money(g.ticket_price)} ticket</Text>
      <View style={[styles.panel, styles.row]}>
        <Stat label="Est. gross payout / ticket" value={money(m.gross_ev)} /><Stat label="Est. net EV / ticket" value={money(m.net_ev)} />
        <Stat label="Est. net EV excluding jackpot" value={money(m.non_jackpot_net_ev)} /><Stat label="Est. jackpot odds" value={odds(m.jackpot_probability)} />
        <Stat label="Est. jackpot enrichment" value={m.jackpot_enrichment == null ? 'Not applicable' : `${m.jackpot_enrichment.toFixed(2)}×`} />
      </View>
      <Text style={styles.text}>Net EV excluding jackpot omits the largest prize payout and subtracts the ticket cost. All tickets remain in the denominator. Jackpot odds refer to the largest prize tier.</Text>
      <Text style={styles.text}>{g.inventory_note}</Text>
      <Text style={styles.text}>Inventory: {g.inventory_method}. Launched {g.launch_date}. Source updated {g.source_updated_at || 'Not published'}. Collected {g.observed_at}.</Text>
      <Text style={styles.text}>Estimated launch tickets: {g.original_tickets?.toLocaleString() ?? 'Not published'} · Estimated remaining tickets: {g.remaining_tickets?.toLocaleString() ?? 'Not published'} · Advertised odds: 1 in {g.advertised_odds}</Text>
      {g.source_url ? <Action title="Official source" onPress={() => { void Linking.openURL(g.source_url).catch(() => setSourceError('Could not open the official source.')); }} /> : <Text style={styles.text}>Fictional fixture — no official source.</Text>}
      <Text style={styles.text}>Estimated changes vs launch: any prize {boost(m.any_boost)} · profit {boost(m.profit_boost)} · jackpot {boost(m.jackpot_boost)}</Text>
      <Text style={styles.title}>Prize tiers</Text>
      {g.prizes.map(p => <View key={p.amount} style={styles.panel}><Text style={styles.text}>{money(p.amount)} prize</Text><Text style={styles.text}>Original: {p.original} · Remaining: {p.remaining} · Claimed / removed: {p.original - p.remaining}</Text></View>)}
      <Text style={styles.title}>Snapshot history</Text>
      {!loading && !error && history.length === 0 && <Text style={styles.text}>No snapshots available.</Text>}
      {history.map(h => <View key={h.game.observed_at} style={styles.panel}><Text style={styles.text}>Observation (UTC): {h.game.observed_at}</Text><Text style={styles.text}>Est. gross EV / $1: {money(h.metrics.ev_per_dollar)} · Change vs launch: {change(h.metrics.ev_change)} · Top prizes left: {percent(h.metrics.top_prizes_remaining)}</Text></View>)}
    </>}
  </ScrollView>;
}
