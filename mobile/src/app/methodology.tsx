import { ScrollView, Text } from 'react-native';
import { styles } from '../components/UI';
export default function Methodology() {
  return <ScrollView style={styles.page} contentContainerStyle={styles.content}>
    <Text style={styles.title}>Assumptions stay visible.</Text>
    <Text style={styles.text}>Official Michigan Lottery data. All scratch-off games are collected and cached for six hours. If refresh fails, the last successful collection stays available; check observation dates in game details. Pull-to-refresh reloads the shared cache; it does not force a new collection. EV and probabilities use estimated ticket inventory from common low-value prize retention. These are model estimates, not verified current odds.</Text>
    <Text style={styles.text}>Total gross EV = Σ(prize × remaining count) / estimated remaining tickets</Text>
    <Text style={styles.text}>Net EV excluding jackpot sums every smaller prize payout, divides by the same estimated ticket inventory, and subtracts the full ticket price. Jackpot odds use the remaining count of the largest prize divided by estimated remaining tickets.</Text>
    <Text style={styles.text}>Net EV subtracts the ticket price. Profit means a prize strictly larger than the ticket cost. Gross EV includes the ticket stake; below $1 means an expected loss per dollar. EV change is the difference in gross return per dollar, shown in percentage points. Changes compare estimated current probabilities with launch probabilities.</Text>
    <Text style={styles.text}>Unclaimed prizes can include already-sold tickets. Even a published unsold-ticket count does not fix that mismatch. Launch inventory is estimated from starting winning tickets × advertised odds. Remaining inventory uses the pooled retention of prizes up to twice the ticket price, falling back to the lowest tiers. The pool is bounded to fit all remaining winners.</Text>
    <Text style={styles.text}>Jackpot enrichment compares the fraction of top prizes left with the fraction of tickets left. An enrichment above 1 does not by itself imply a profitable game. Prize claim delays can create apparent boosts; small differences may reflect model error.</Text>
    <Text style={styles.text}>Built with Jac · Deterministic analysis · Official Michigan Lottery data · No outcome guarantees</Text>
  </ScrollView>;
}
