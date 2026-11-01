import React from 'react';
import { Pressable, Text, View } from 'react-native';
import { RankedGame } from '../types/api';
import { boost, change, money, odds, percent } from '../utils/format';
import { Stat, styles } from './UI';
export function GameCard({ item: { game: g, metrics: m }, onPress }: { item: RankedGame; onPress: () => void }) {
  return <Pressable accessibilityRole="button" accessibilityLabel={`View ${g.name} details`} onPress={onPress} style={[styles.panel, { marginBottom: 12 }]}>
    <Text style={styles.title}>{g.name}</Text><Text style={styles.text}>{money(g.ticket_price)} · {g.state} · {g.inventory_method}</Text>
    <View style={styles.row}>
      <Stat label="Est. gross EV / $1" value={money(m.ev_per_dollar)} />
      <Stat label="Est. jackpot odds" value={odds(m.jackpot_probability)} />
      <Stat label="Est. net EV excluding jackpot" value={money(m.non_jackpot_net_ev)} />
      <Stat label="Top prizes left" value={percent(m.top_prizes_remaining)} />
      <Stat label="Est. any prize" value={percent(m.any_probability)} />
      <Stat label="Est. profit" value={percent(m.profit_probability)} />
      <Stat label="Est. EV vs launch" value={change(m.ev_change)} />
      <Stat label="Est. jackpot change" value={boost(m.jackpot_boost)} />
      <Stat label="Est. profit change" value={boost(m.profit_boost)} />
    </View><Text style={styles.text}>View prize tiers and history →</Text>
  </Pressable>;
}
