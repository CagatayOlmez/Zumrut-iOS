-- Dua and "Günün Bilgisi" content, editable by the admin (you) through the
-- Supabase Studio table editor instead of an app release. Read-only for the
-- app (anon role); writes only happen via Studio / the service role.

create table if not exists public.duas (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  arabic text not null,
  source text not null,
  category text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.info_cards (
  id text primary key,
  category text not null check (category in ('HADİS', 'AYET')),
  text text not null,
  source text not null,
  created_at timestamptz not null default now()
);

alter table public.duas enable row level security;
alter table public.info_cards enable row level security;

grant select on public.duas to anon, authenticated;
grant select on public.info_cards to anon, authenticated;

create policy "Public read access" on public.duas
  for select to anon, authenticated using (true);

create policy "Public read access" on public.info_cards
  for select to anon, authenticated using (true);

-- Public-read bucket for cached dua recitation audio (mp3s written by the
-- `tts` edge function via the service role, which bypasses RLS on write).
insert into storage.buckets (id, name, public)
values ('dua-audio', 'dua-audio', true)
on conflict (id) do nothing;
