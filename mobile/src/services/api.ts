import Constants from 'expo-constants';
import { createApi, resolveApiUrl } from './client';

// Both clients use the same Jac server; Expo only serves the mobile bundle.
export const API_BASE_URL = resolveApiUrl(process.env.EXPO_PUBLIC_API_URL, Constants.expoConfig?.hostUri);
export const api = createApi(API_BASE_URL);
