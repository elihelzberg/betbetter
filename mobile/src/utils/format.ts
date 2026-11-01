export const money = (v: number | null) => v == null ? 'Not applicable' : `$${v.toFixed(2)}`;
export const percent = (v: number | null) => v == null ? 'Not applicable' : `${(v * 100).toFixed(2)}%`;
export const change = (v: number | null) => v == null ? 'Not applicable' : `${v > 0 ? '+' : ''}${(v * 100).toFixed(2)} pp`;
export const boost = (v: number | null) => v == null ? 'No launch profit prizes' : `${v > 0 ? '+' : ''}${percent(v)}`;
export const odds = (v: number | null) => v == null ? 'Not applicable' : v === 0 ? 'No prizes left' : `1 in ${Math.round(1 / v).toLocaleString()}`;
