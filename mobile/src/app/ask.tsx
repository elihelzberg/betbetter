import React, { useRef, useEffect, useState } from 'react';
import { ScrollView, Text, View } from 'react-native';
import { router } from 'expo-router';
import { Action, Field, styles } from '../components/UI';
import { api } from '../services/api';
import { Answer, RankedGame } from '../types/api';
import { change, money, percent } from '../utils/format';
function metric(r: RankedGame, sort: string) {
  if (sort === 'jackpot_probability') return `${percent(r.metrics.jackpot_probability)} jackpot probability`;
  if (sort === 'profit_probability') return `${percent(r.metrics.profit_probability)} profit probability`;
  if (sort === 'any_probability') return `${percent(r.metrics.any_probability)} any-prize probability`;
  if (sort === 'ev_change') return `${change(r.metrics.ev_change)} EV change`;
  return `${money(r.metrics.ev_per_dollar)} gross EV / $1`;
}
export default function Ask() {
  const [question, setQuestion] = useState('What are the five best $10–$20 scratchers in Michigan?');
  const [answer, setAnswer] = useState<Answer | null>(null);
  const [asking, setAsking] = useState(false);
  const [error, setError] = useState('');
  const active = useRef(true);
  useEffect(() => { active.current = true; return () => { active.current = false; }; }, []);
  async function ask() {
    if (asking || !question.trim()) return;
    setAsking(true); setError(''); setAnswer(null);
    try { const result = await api.askQuestion(question.trim()); if (active.current) setAnswer(result); }
    catch { if (active.current) setError('Could not answer. Check your connection and use a valid price range and a result count from 1 to 100.'); }
    finally { if (active.current) setAsking(false); }
  }
  return <ScrollView keyboardShouldPersistTaps="handled" style={styles.page} contentContainerStyle={styles.content}>
    <Text style={styles.title}>Find what you’re looking for.</Text><Text style={styles.text}>Rankings calculated using Michigan Lottery data. The current question service uses a limited rule-based parser.</Text>
    <View style={styles.panel}><Text style={styles.title}>AI & Gambling Disclaimer</Text><Text style={styles.text}>This research interface may produce inaccurate or incomplete information. Lottery odds, rankings, and expected returns are estimates, not guarantees. This information is for educational purposes only and does not constitute financial or gambling advice. Gambling involves financial risk. Please play responsibly.</Text></View>
    <Field label="Ask about games" value={question} onChangeText={setQuestion} maxLength={500} multiline />
    <Action title={asking ? 'Working…' : 'Ask'} disabled={asking || !question.trim()} onPress={() => { void ask(); }} />
    {!!error && <Text accessibilityRole="alert" style={styles.error}>{error}</Text>}
    {answer && <View style={styles.panel} accessibilityLiveRegion="polite"><Text style={styles.text}>{answer.message}</Text>{answer.games.map((r, i) => <Action key={`${r.game.state}-${r.game.game_id}`} title={`${i + 1}. ${r.game.name} · ${money(r.game.ticket_price)} ticket · ${metric(r, answer.sort_by)}`} onPress={() => router.push({ pathname: '/details', params: { gameId: r.game.game_id, state: r.game.state } })} />)}</View>}
  </ScrollView>;
}
