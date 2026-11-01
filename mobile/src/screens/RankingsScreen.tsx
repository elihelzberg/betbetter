import React, { useEffect, useRef, useState } from 'react';
import { View, FlatList, ActivityIndicator, Text } from 'react-native';
import { router } from 'expo-router';
import { api } from '../services/api';
import { Query, RankedGame } from '../types/api';
import { GameCard } from '../components/GameCard';
import { Action, Field, styles } from '../components/UI';
const sorts = [
  ['non_jackpot_net_ev', 'Est. net EV excluding jackpot'], ['jackpot_boost', 'Est. jackpot change vs launch'],
  ['profit_boost', 'Est. profit change vs launch'], ['any_boost', 'Est. any-prize change vs launch'],
  ['ev_per_dollar', 'Est. gross EV per dollar'], ['any_probability', 'Est. any prize probability'],
  ['profit_probability', 'Est. profit probability'], ['jackpot_probability', 'Est. jackpot probability'],
  ['top_prizes_remaining', 'Top prizes remaining'], ['ev_change', 'Est. EV change since launch'],
  ['jackpot_enrichment', 'Est. jackpot enrichment'],
];
export function RankingsScreen() {
  const [games, setGames] = useState<RankedGame[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [minimum, setMinimum] = useState('0');
  const [maximum, setMaximum] = useState('100');
  const [search, setSearch] = useState('');
  const [sort, setSort] = useState('jackpot_boost');
  const [showSorts, setShowSorts] = useState(false);
  const applied = useRef<Query>({ sort_by: 'jackpot_boost' });
  const request = useRef({ id: 0 });
  async function load(query: Query) {
    const id = ++request.current.id;
    setLoading(true); setError('');
    try { const data = await api.getGames(query); if (id === request.current.id) { setGames(data); applied.current = query; } }
    catch (err) { if (id === request.current.id) setError(err instanceof Error ? err.message : 'Could not load games. Please retry.'); }
    finally { if (id === request.current.id) setLoading(false); }
  }
  useEffect(() => { const pending = request.current; void load(applied.current); return () => { pending.id++; }; }, []);
  function apply() {
    const min = Number(minimum || '0'), max = Number(maximum || '100');
    if (!Number.isFinite(min) || !Number.isFinite(max) || min < 0 || max < min) { setError('Enter a valid price range: minimum must be nonnegative and maximum at least minimum.'); return; }
    void load({ min_price: min, max_price: max, search, sort_by: sort });
  }
  return <View style={styles.page}><FlatList data={games} keyExtractor={i => `${i.game.state}-${i.game.game_id}`} contentContainerStyle={styles.content}
    refreshing={loading} onRefresh={() => { void load(applied.current); }} keyboardShouldPersistTaps="handled"
    ListHeaderComponent={<View style={{ gap: 12, marginBottom: 12 }}>
      <Text style={styles.title}>Scratch-off rankings</Text><Text style={styles.text}>Michigan · Official Michigan Lottery data · Model estimates, not verified current odds.</Text>
      <View style={styles.row}><Action title="Ask the data" onPress={() => router.push('/ask')} /><Action title="Assumptions & data" onPress={() => router.push('/methodology')} /></View>
      <View style={styles.panel}><Text style={styles.text}>State: Michigan</Text>
        <Field label="Minimum ticket price ($)" value={minimum} onChangeText={setMinimum} keyboardType="decimal-pad" />
        <Field label="Maximum ticket price ($)" value={maximum} onChangeText={setMaximum} keyboardType="decimal-pad" />
        <Field label="Find a game" placeholder="Name or game ID" value={search} onChangeText={setSearch} />
        <Action title={`Rank by: ${sorts.find(s => s[0] === sort)?.[1]}`} onPress={() => setShowSorts(!showSorts)} />
        {showSorts && sorts.map(([value, label]) => <Action key={value} title={label} selected={sort === value} onPress={() => { setSort(value); setShowSorts(false); }} />)}
        <Action title={loading ? 'Loading…' : 'Apply filters'} disabled={loading} onPress={apply} />
      </View>
      {!!error && <><Text accessibilityRole="alert" style={styles.error}>{error}</Text><Action title="Retry last search" disabled={loading} onPress={() => { void load(applied.current); }} /></>}
      {loading && <ActivityIndicator color="#38bdf8" />}
      <Text style={styles.text}>{games.length} results · higher ranks first. Select a game for prize tiers and history.</Text>
    </View>}
    ListEmptyComponent={!loading && !error ? <Text style={styles.text}>No games match these filters. Try a wider price range or another search.</Text> : undefined}
    renderItem={({ item }) => <GameCard item={item} onPress={() => router.push({ pathname: '/details', params: { gameId: item.game.game_id, state: item.game.state } })} />}
  /></View>;
}
