import { createClient, type SupabaseClient } from '@supabase/supabase-js';
let instance: SupabaseClient | null = null;
export function configured() {
  return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
}
export function db(): SupabaseClient {
  if (!configured()) throw new Error('กรุณาตั้งค่า Supabase Environment Variables ก่อน');
  if (!instance) instance = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!, { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } });
  return instance;
}
export type Station = {
  id: string; name: string; brand: string | null; address: string | null;
  province: string | null; latitude: number; longitude: number;
  fuel_type: string; status: 'pending'|'approved'|'rejected';
  last_verified_at: string | null; created_at: string; photo_path: string | null;
};
