import json
import os
import tempfile
import unittest
from unittest.mock import patch
import michigan_live as live


class CollectorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.env = patch.dict(os.environ, MICHIGAN_CACHE_PATH=self.temp.name + '/cache.sqlite3')
        self.env.start()
        live._RETRY_AFTER = 0

    def tearDown(self):
        self.env.stop()
        self.temp.cleanup()

    def test_cache_and_failure_preserve_complete_batch(self):
        games = [{'game_id': str(i)} for i in range(107)]
        with patch.object(live, 'collect', return_value=games) as collect:
            self.assertEqual(live.load_snapshots(), games)
            self.assertEqual(live.load_snapshots(), games)
            collect.assert_called_once()
        with live.database() as db:
            db.execute('UPDATE batches SET fetched=0')
        with patch.object(live, 'collect', side_effect=ValueError('Incomplete source')):
            self.assertEqual(live.load_snapshots(), games)
            self.assertEqual(live.load_snapshots(history=True), games)
            with self.assertRaises(ValueError):
                live.load_snapshots(force=True)
        with live.database() as db:
            self.assertEqual(db.execute('SELECT COUNT(*) FROM batches').fetchone()[0], 1)

    def test_initial_failure_never_returns_demo(self):
        with patch.object(live, 'collect', side_effect=ValueError('offline')):
            with self.assertRaises(ValueError):
                live.load_snapshots()

    def test_normalize_aggregates_counts_without_inventory_estimate(self):
        game = dict(igtId=636, name='Official game', overallOdds='1 in 4.11',
                    displayedTicketPrice='$5.00', dateAdded='2024-01-02T00:00-05:00', identifier='GAME')
        tiers = [dict(prize_amount='100', starting_amount=10, prizes_remaining='3', updatedAt='2026-10-08T07:00:00Z')] * 2
        result = live.normalize(game, tiers, '2026-10-08T08:00:00+00:00')
        self.assertEqual(result['prizes'], [dict(amount=100.0, original=20, remaining=6)])
        self.assertIsNone(result['original_tickets'])
        self.assertIsNone(result['remaining_tickets'])
        self.assertFalse(result['is_demo'])
        tiers[0] = dict(prize_amount='100', starting_amount=1, prizes_remaining='3')
        with self.assertRaises(ValueError):
            live.normalize(game, tiers, '2026-10-08T08:00:00+00:00')

    def test_inventory_model_and_feasibility(self):
        row = dict(ticket_price=10, advertised_odds=4.0, prizes=[
            dict(amount=10, original=100, remaining=60),
            dict(amount=20, original=50, remaining=30),
            dict(amount=1000, original=10, remaining=8)])
        estimated = live.estimate_snapshot(row)
        self.assertEqual(estimated['original_tickets'], 640)
        self.assertEqual(estimated['remaining_tickets'], 384)
        self.assertEqual(estimated['inventory_method'], 'estimate')
        self.assertNotIn('original_tickets', row)
        # Depleted baseline with surviving big prizes must stay feasible.
        row['prizes'][0]['remaining'] = 0
        row['prizes'][1]['remaining'] = 0
        estimated = live.estimate_snapshot(row)
        self.assertEqual(estimated['remaining_tickets'], 8)
        self.assertIn('raised', estimated['inventory_note'])
        for tier in row['prizes']:
            tier['remaining'] = 0
        self.assertEqual(live.estimate_snapshot(row)['remaining_tickets'], 0)

    def test_inventory_fallback_uses_lowest_tiers(self):
        row = dict(ticket_price=1, advertised_odds=4, prizes=[
            dict(amount=5, original=100, remaining=50),
            dict(amount=100, original=10, remaining=8)])
        result = live.estimate_snapshot(row)
        self.assertEqual(result['remaining_tickets'], 220)
        self.assertIn('lowest available', result['inventory_note'])

    def test_discovery_fetches_all_107_in_batches(self):
        games = [dict(igtId=i, gameCategoryIdentifier='RETAIL_INSTANT_GAMES_CATEGORY') for i in range(107)]
        def respond(operations):
            if operations[0]['query'] == live.CATALOG:
                return [{'getCMSGames': games}]
            return [{'getRetailTopPrizesRemainingForGameDetails': [op['variables']['id']]} for op in operations]
        with patch.object(live, 'request', side_effect=respond) as request, patch.object(live, 'normalize', side_effect=lambda g, t, observed: g):
            self.assertEqual(len(live.collect()), 107)
            self.assertEqual(request.call_count, 12)


if __name__ == '__main__':
    unittest.main()
