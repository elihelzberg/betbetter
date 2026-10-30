// mobile/src/services/api.ts
import { Query, RankedGame, Answer } from '../types/api';
import Constants from 'expo-constants';

// Dynamically grab the IP address of the Mac running the Expo bundler
const debuggerHost = Constants.expoConfig?.hostUri;
const localhost = debuggerHost ? debuggerHost.split(':')[0] : 'localhost';

export const API_BASE_URL = `http://${localhost}:8000/api`;

export const api = {
  async getGames(query: Query = {}): Promise<RankedGame[]> {
    const res = await fetch(`${API_BASE_URL}/games`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        state: query.state || 'MI',
        min_price: query.min_price ?? 0.0,
        max_price: query.max_price ?? 100.0,
        sort_by: query.sort_by || 'jackpot_boost',
        search: query.search || '',
        limit: query.limit || 1000,
      }),
    });
    if (!res.ok) throw new Error('Failed to fetch games');
    return res.json();
  },

  async getGameHistory(gameId: string, state: string = 'MI'): Promise<RankedGame[]> {
    const res = await fetch(`${API_BASE_URL}/games/${gameId}/history?state=${state}`);
    if (!res.ok) throw new Error('Failed to fetch history');
    return res.json();
  },

  async askQuestion(question: string): Promise<Answer> {
    const res = await fetch(`${API_BASE_URL}/ask`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question }),
    });
    if (!res.ok) throw new Error('Failed to get answer');
    return res.json();
  },
};