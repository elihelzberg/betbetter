import React from 'react';
import { Pressable, StyleSheet, Text, TextInput, TextInputProps, View } from 'react-native';
export const styles = StyleSheet.create({
  page: { flex: 1, backgroundColor: '#0b0f19' },
  content: { padding: 16, gap: 12 },
  panel: { padding: 16, borderRadius: 12, backgroundColor: '#1e293b', gap: 12 },
  title: { color: '#f8fafc', fontSize: 22, fontWeight: 'bold' },
  text: { color: '#cbd5e1', fontSize: 14, lineHeight: 21 },
  error: { color: '#fda4af', fontSize: 14 },
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 8 },
  button: { padding: 12, borderRadius: 8, backgroundColor: '#075985' },
  input: { color: '#f8fafc', backgroundColor: '#0f172a', borderWidth: 1, borderColor: '#64748b', borderRadius: 8, padding: 12 },
});
export function Action({ title, onPress, disabled = false, selected }: { title: string; onPress: () => void; disabled?: boolean; selected?: boolean }) {
  return <Pressable accessibilityRole="button" accessibilityState={{ disabled, selected }} disabled={disabled} onPress={onPress} style={[styles.button, selected && { backgroundColor: '#0e7490' }, disabled && { opacity: 0.5 }]}><Text style={styles.text}>{title}</Text></Pressable>;
}
export function Field({ label, ...props }: TextInputProps & { label: string }) {
  return <View style={{ gap: 6 }}><Text style={styles.text}>{label}</Text><TextInput accessibilityLabel={label} placeholderTextColor="#94a3b8" style={styles.input} {...props} /></View>;
}
export function Stat({ label, value }: { label: string; value: string }) {
  return <View style={{ width: '48%', gap: 4 }}><Text style={styles.text}>{label}</Text><Text style={[styles.text, { color: '#7dd3fc', fontWeight: 'bold' }]}>{value}</Text></View>;
}
