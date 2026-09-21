-- Basic per-IP rate limiting for the OpenAI-backed edge functions (chat,
-- transcribe, tts). These are public endpoints (verify_jwt = false) fronted
-- only by the publishable key, which ships inside the app and can be
-- extracted — without this, anyone could run up unlimited OpenAI cost.
-- Not a defense against a determined/distributed attacker, just a cheap
-- backstop against a single leaked key or a runaway client.
create table if not exists public.rate_limits (
  key text primary key,
  window_start timestamptz not null,
  count int not null default 0
);

-- Atomically checks and increments the counter for `p_key` in the current
-- `p_window_seconds` window, returning false once `p_limit` is hit.
-- security definer so it can be called by the service-role client without
-- needing table grants; execute is restricted to service_role below so an
-- anon caller can't hit it directly over PostgREST and forge its own count.
create or replace function public.check_rate_limit(p_key text, p_limit int, p_window_seconds int)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_window_start timestamptz;
  v_count int;
begin
  select window_start, count into v_window_start, v_count
  from public.rate_limits where key = p_key
  for update;

  if not found or v_window_start < now() - make_interval(secs => p_window_seconds) then
    insert into public.rate_limits (key, window_start, count)
    values (p_key, now(), 1)
    on conflict (key) do update set window_start = excluded.window_start, count = 1;
    return true;
  end if;

  if v_count >= p_limit then
    return false;
  end if;

  update public.rate_limits set count = count + 1 where key = p_key;
  return true;
end;
$$;

revoke all on function public.check_rate_limit(text, int, int) from public, anon, authenticated;
grant execute on function public.check_rate_limit(text, int, int) to service_role;

alter table public.rate_limits enable row level security;
-- No policies granted: only the service-role client (which bypasses RLS)
-- touches this table, via the function above.
