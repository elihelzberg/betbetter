import React, { useEffect, useState } from 'react';
import { View, FlatList, ActivityIndicator, StyleSheet, RefreshControl } from 'react-native';
import { router } from 'expo-router';
import { api } from '../services/api';
import { RankedGame } from '../types/api';
import { GameCard } from '../components/GameCard';

export const RankingsScreen = () => {
  const [games, setGames] = useState<RankedGame[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = async () => {
    try {
      const data = await api.getGames({ sort_by: 'jackpot_boost' });
      setGames(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    let active = true;
    api.getGames({ sort_by: 'jackpot_boost' })
      .then(data => { if (active) setGames(data); })
      .catch(console.error)
      .finally(() => { if (active) setLoading(false); });
    return () => { active = false; };
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadData();
  };

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#38bdf8" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={games}
        keyExtractor={(item) => item.game.game_id}
        renderItem={({ item }) => (
          <GameCard
            item={item}
            onPress={() => router.push({
              pathname: '/details/[gameId]',
              params: { gameId: item.game.game_id, name: item.game.name, state: item.game.state },
            })}
          />
        )}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#38bdf8" />}
        contentContainerStyle={{ padding: 12 }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0b0f19' },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#0b0f19' },
});
