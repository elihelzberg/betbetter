import type { Query, RankedGame, Answer } from '../types/api';

export function resolveApiUrl(override?: string, hostUri?: string | null): string {
  if (override?.trim()) return override.trim().replace(/\/+$/, '');
  const host = new URL(hostUri?.includes('://') ? hostUri : `http://${hostUri || 'localhost'}`).hostname;
  return `http://${host}:8000/api`;
}

export function createApi(baseUrl: string, fetcher: typeof fetch = fetch) {
  async function request<T>(path: string, body?: unknown): Promise<T> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000);
    try {
      const res = await fetcher(`${baseUrl}${path}`, {
        method: body === undefined ? 'GET' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        ...(body === undefined ? {} : { body: JSON.stringify(body) }),
        signal: controller.signal,
      });
      const payload = await res.json().catch(() => { throw new Error('The game service returned an unexpected response. Check the API address.'); });
      if (!res.ok || payload?.ok === false) throw new Error(payload?.error?.message || `Game service error (${res.status}).`);
      return payload as T;
    } catch (error) {
      if (error instanceof Error && error.name === 'AbortError') throw new Error('The game service timed out. Please retry.');
      if (error instanceof TypeError) throw new Error('Cannot reach the game service. Keep your phone and computer on the same Wi-Fi and start the betBetter server.');
      throw error;
    } finally { clearTimeout(timeout); }
  }
  async function games(path: string, body?: unknown): Promise<RankedGame[]> {
    const data = await request<RankedGame[]>(path, body);
    if (!Array.isArray(data)) throw new Error('The game service returned an unexpected games response.');
    return data;
  }
  return {
    getGames(query: Query = {}) {
      return games('/games', {
        state: query.state ?? 'MI', min_price: query.min_price ?? 0, max_price: query.max_price ?? 100,
        sort_by: query.sort_by ?? 'jackpot_boost', search: query.search ?? '', limit: query.limit ?? 1000,
      });
    },
    getGameHistory(gameId: string, state = 'MI') {
      return games(`/games/${encodeURIComponent(gameId)}/history?state=${encodeURIComponent(state)}`);
    },
    askQuestion(question: string) { return request<Answer>('/ask', { question }); },
  };
}
