import type { RankedGame } from '../types/api';
import type { createApi } from './client';

export type DetailsState = {
  item: RankedGame | null;
  history: RankedGame[];
  loading: boolean;
  error: string;
};

type DetailsApi = Pick<ReturnType<typeof createApi>, 'getGames' | 'getGameHistory'>;

/** One cancellable screen load; late responses cannot publish into another game. */
export function loadGameDetails(
  client: DetailsApi,
  gameId: string,
  state: string,
  onState: (state: DetailsState) => void,
): () => void {
  let active = true;
  let current: DetailsState = { item: null, history: [], loading: true, error: '' };
  function update(change: Partial<DetailsState>) {
    if (!active) return;
    current = { ...current, ...change };
    onState(current);
  }
  update({});
  void (async () => {
    try {
      if (!gameId) throw new Error('Missing game ID');
      const games = await client.getGames({ state, search: gameId });
      if (!active) return;
      const item = games.find(game => game.game.game_id === gameId);
      if (!item) throw new Error('Game unavailable');
      update({ item });
      const history = await client.getGameHistory(gameId, state);
      update({ history });
    } catch {
      update({ error: 'Could not load game details or snapshot history. Please retry.' });
    } finally {
      update({ loading: false });
    }
  })();
  return () => { active = false; };
}
