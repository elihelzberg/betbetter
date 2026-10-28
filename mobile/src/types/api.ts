// mobile/src/types/api.ts

export interface PrizeTier {
  amount: number;
  original: number;
  remaining: number;
}

export interface GameSnapshot {
  game_id: string;
  name: string;
  state: string;
  ticket_price: number;
  prizes: PrizeTier[];
  original_tickets: number | null;
  remaining_tickets: number | null;
  observed_at: string;
  launch_date: string;
  advertised_odds: number;
  inventory_method: string;
  source_url: string;
  status: string;
}

export interface Metrics {
  launch_ev_per_dollar: number | null;
  top_prizes_remaining: number;
  gross_ev: number | null;
  net_ev: number | null;
  non_jackpot_net_ev: number | null;
  ev_per_dollar: number | null;
  any_probability: number | null;
  profit_probability: number | null;
  jackpot_probability: number | null;
  ev_change: number | null;
  jackpot_boost: number | null;
  any_boost: number | null;
  profit_boost: number | null;
}

export interface RankedGame {
  game: GameSnapshot;
  metrics: Metrics;
}

export interface Query {
  state?: string;
  min_price?: number;
  max_price?: number;
  sort_by?: string;
  search?: string;
  limit?: number;
}

export interface Answer {
  message: string;
  games: RankedGame[];
  mode: string;
}