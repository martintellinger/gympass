-- ============================================================================
-- BýtFit Klub — ONE-PASTE Supabase setup
-- ============================================================================
-- Paste this whole file into the Supabase SQL editor and press "Run".
-- Project: yktounljghdypfhbdxws  (the one the app ships with by default).
--
-- It is idempotent enough to re-run during setup (drops/creates the trigger,
-- `on conflict do nothing` on seed). It bundles, in order:
--   1. schema   (= docs/backend/schema.sql)
--   2. roster-gated registration — norm_txt + roster_find_match RPC +
--      handle_new_user (claims an imported roster row by name)
--   3. RLS      (= docs/backend/rls.sql)
--   4. storage bucket for student proofs (ISIC)
--   5. seed: tariffs + 7 opening-hours rows
--   6. ADMIN BOOTSTRAP (read the comment at the very bottom!)
--
-- After running this, the Flutter app's login + registration work against
-- this project with no further code changes.
-- ============================================================================

create extension if not exists "pgcrypto";

-- ── 1. SCHEMA ───────────────────────────────────────────────────────────────

create table if not exists members (
  id                   uuid primary key default gen_random_uuid(),
  auth_user_id         uuid unique references auth.users (id) on delete set null,
  first_name           text not null,
  last_name            text not null,
  email                text,
  phone                text,
  role                 text not null default 'member'
                         check (role in ('member','admin')),
  status               text not null default 'pending'
                         check (status in ('pending','active','suspended','inactive')),
  tariff_type          text not null default 'standard'
                         check (tariff_type in ('standard','student')),
  student_proof_url    text,
  variable_symbol      integer unique,
  membership_expires_at date,
  billing_day_of_month integer check (billing_day_of_month between 1 and 31),
  key_issued           boolean not null default false,
  key_number           text,
  key_issued_at        date,
  key_returned_at      date,
  deposit_paid         boolean not null default false,
  deposit_returned     boolean not null default false,
  deposit_status       text not null default 'paid'
                         check (deposit_status in ('paid','returned','forfeited')),
  deposit_forfeited_at timestamptz,
  paused_at            timestamptz,
  pause_reason         text check (pause_reason in ('holiday','illness','other')),
  notes                text,
  tags                 text[] not null default '{}',
  created_at           timestamptz not null default now(),
  approved_at          timestamptz,
  approved_by          uuid references members (id)
);

create table if not exists tariffs (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  duration_days integer not null,
  price         integer not null,
  is_student    boolean not null default false,
  is_active     boolean not null default true,
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now()
);

create table if not exists payments (
  id                        uuid primary key default gen_random_uuid(),
  member_id                 uuid not null references members (id) on delete cascade,
  amount                    integer not null,
  tariff                    text not null,
  tariff_id                 uuid references tariffs (id),
  paid_at                   timestamptz not null default now(),
  method                    text not null default 'manual'
                              check (method in ('qr_bank','cash','manual','imported')),
  variable_symbol           integer,
  extends_membership_by_days integer not null default 0,
  matched_automatically     boolean not null default false,
  is_historical             boolean not null default false,
  invoice_pdf_url           text,
  created_at                timestamptz not null default now()
);
create index if not exists payments_member_paid_idx
  on payments (member_id, paid_at desc);

create table if not exists threads (
  id         uuid primary key default gen_random_uuid(),
  member_id  uuid not null unique references members (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists messages (
  id              uuid primary key default gen_random_uuid(),
  thread_id       uuid not null references threads (id) on delete cascade,
  from_role       text not null check (from_role in ('admin','member')),
  body            text not null,
  attachment_urls text[] not null default '{}',
  is_fault_report boolean not null default false,
  read_at         timestamptz,
  created_at      timestamptz not null default now()
);
create index if not exists messages_thread_idx on messages (thread_id, created_at);

create table if not exists peer_threads (
  id         uuid primary key default gen_random_uuid(),
  member_a   uuid not null references members (id) on delete cascade,
  member_b   uuid not null references members (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (member_a < member_b),
  unique (member_a, member_b)
);

create table if not exists peer_messages (
  id          uuid primary key default gen_random_uuid(),
  thread_id   uuid not null references peer_threads (id) on delete cascade,
  sender_id   uuid not null references members (id) on delete cascade,
  body        text not null,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);
create index if not exists peer_messages_thread_idx
  on peer_messages (thread_id, created_at);

create table if not exists board_posts (
  id              uuid primary key default gen_random_uuid(),
  author_id       uuid not null references members (id),
  type            text not null
                    check (type in ('pinned','outage','warning','promo','event','fixed','info')),
  title           text not null,
  body            text not null,
  is_pinned       boolean not null default false,
  cta_label       text,
  cta_action      text,
  attachment_urls text[] not null default '{}',
  approved_by     uuid references members (id),
  published_at    timestamptz,
  created_at      timestamptz not null default now()
);

create table if not exists opening_hours (
  weekday    integer primary key check (weekday between 0 and 6),
  open_time  time,
  close_time time,
  note       text,
  updated_at timestamptz not null default now()
);

create table if not exists notification_preferences (
  member_id    uuid primary key references members (id) on delete cascade,
  push_master  boolean not null default true,
  push_outages boolean not null default true,
  push_promos  boolean not null default false,
  theme        text not null default 'dark'
                 check (theme in ('dark','system','light')),
  language     text not null default 'cs' check (language in ('cs','en')),
  updated_at   timestamptz not null default now()
);

create table if not exists notifications_sent (
  id               uuid primary key default gen_random_uuid(),
  member_id        uuid not null references members (id) on delete cascade,
  type             text not null,
  channel          text not null check (channel in ('push','email')),
  sent_at          timestamptz not null default now(),
  content_snapshot text
);

create table if not exists broadcasts (
  id               uuid primary key default gen_random_uuid(),
  created_by       uuid not null references members (id),
  title            text not null,
  body             text not null,
  image_url        text,
  target_filter    jsonb,
  sent_at          timestamptz,
  recipients_count integer not null default 0
);

create table if not exists audit_log (
  id          uuid primary key default gen_random_uuid(),
  actor_id    uuid references members (id),
  action      text not null,
  target_type text,
  target_id   uuid,
  metadata    jsonb,
  created_at  timestamptz not null default now()
);

-- ── 2. ROSTER-GATED REGISTRATION (/goal) ────────────────────────────────────
-- Members are pre-imported as a roster (status 'inactive', no auth_user_id,
-- only name + expiry — contacts are collected at registration). A new signup
-- may only proceed if the name matches an unclaimed roster row. The trigger
-- then CLAIMS that row (links the auth user, fills e-mail/phone, sets
-- status='pending' for Olda to confirm key/deposit, brief §4.1). Matching is
-- case-, diacritics- and order-insensitive.

create extension if not exists unaccent;

create or replace function public.norm_txt(p text)
returns text language sql immutable as $$
  select regexp_replace(lower(unaccent(coalesce(p,''))), '\s+', ' ', 'g')
$$;

-- Anon-callable yes/no gate for registration step 1 (no PII leaves the DB).
create or replace function public.roster_find_match(p_first text, p_last text)
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from members m
    where m.auth_user_id is null
      and (
        (norm_txt(m.first_name) = norm_txt(p_first) and norm_txt(m.last_name) = norm_txt(p_last))
        or
        (norm_txt(m.first_name) = norm_txt(p_last)  and norm_txt(m.last_name) = norm_txt(p_first))
      )
  )
$$;
revoke all on function public.roster_find_match(text,text) from public;
grant execute on function public.roster_find_match(text,text) to anon, authenticated;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_first text := coalesce(new.raw_user_meta_data->>'first_name','');
  v_last  text := coalesce(new.raw_user_meta_data->>'last_name','');
  v_phone text := nullif(new.raw_user_meta_data->>'phone','');
  v_id uuid;
begin
  -- Claim an unclaimed roster row (either name order).
  with cand as (
    select id from members m
    where m.auth_user_id is null
      and (
        (norm_txt(m.first_name) = norm_txt(v_first) and norm_txt(m.last_name) = norm_txt(v_last))
        or
        (norm_txt(m.first_name) = norm_txt(v_last)  and norm_txt(m.last_name) = norm_txt(v_first))
      )
    order by m.created_at
    limit 1
  )
  update members m
     set auth_user_id = new.id,
         email        = new.email,
         phone        = coalesce(v_phone, m.phone),
         status       = 'pending'
    from cand
   where m.id = cand.id
  returning m.id into v_id;

  -- No roster match → fresh pending member (defence-in-depth: a direct API
  -- signup still lands in Olda's approval queue, never auto-active).
  if v_id is null then
    insert into public.members
      (auth_user_id, first_name, last_name, email, phone, role, status)
    values
      (new.id, v_first, v_last, new.email, v_phone, 'member', 'pending')
    returning id into v_id;
  end if;

  insert into public.notification_preferences (member_id)
  values (v_id) on conflict (member_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── 3. ROW-LEVEL SECURITY ───────────────────────────────────────────────────
-- The web bundle ships a publishable key, so RLS *is* the boundary.

create or replace function current_member_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from members where auth_user_id = auth.uid()
$$;

create or replace function is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from members
    where auth_user_id = auth.uid() and role = 'admin'
  )
$$;

alter table members                   enable row level security;
alter table tariffs                   enable row level security;
alter table payments                  enable row level security;
alter table threads                   enable row level security;
alter table messages                  enable row level security;
alter table peer_threads              enable row level security;
alter table peer_messages             enable row level security;
alter table board_posts               enable row level security;
alter table opening_hours             enable row level security;
alter table notification_preferences  enable row level security;
alter table notifications_sent        enable row level security;
alter table broadcasts                enable row level security;
alter table audit_log                 enable row level security;

drop policy if exists members_self_or_admin_read on members;
create policy members_self_or_admin_read on members for select
  using (is_admin() or id = current_member_id());
drop policy if exists members_self_update on members;
create policy members_self_update on members for update
  using (id = current_member_id()) with check (id = current_member_id());
drop policy if exists members_admin_write on members;
create policy members_admin_write on members for all
  using (is_admin()) with check (is_admin());

-- Column guard: `members_self_update` is row-scoped only, so without this a
-- member could PATCH their own row to role='admin' and bypass approval.
-- Non-admins keep name/phone/email/pause edits; everything owner-managed
-- (role, status, tariff, expiry, key, deposit, approval) is reverted to OLD.
create or replace function public.guard_member_self_update()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  -- Skip for trusted server context (no auth.uid()) — e.g. the roster-claim
  -- trigger — and for admins. Anon/system updates only reach members via
  -- SECURITY DEFINER funcs; real member PostgREST updates carry auth.uid().
  if auth.uid() is null or is_admin() then return new; end if;
  new.role                  := old.role;
  new.status                := old.status;
  new.tariff_type           := old.tariff_type;
  new.membership_expires_at := old.membership_expires_at;
  new.billing_day_of_month  := old.billing_day_of_month;
  new.key_issued            := old.key_issued;
  new.key_number            := old.key_number;
  new.deposit_paid          := old.deposit_paid;
  new.deposit_status        := old.deposit_status;
  new.variable_symbol       := old.variable_symbol;
  new.approved_at           := old.approved_at;
  new.approved_by           := old.approved_by;
  return new;
end $$;
drop trigger if exists members_guard_self_update on public.members;
create trigger members_guard_self_update before update on public.members
  for each row execute function public.guard_member_self_update();

drop policy if exists tariffs_read on tariffs;
create policy tariffs_read on tariffs for select using (true);
drop policy if exists tariffs_admin_write on tariffs;
create policy tariffs_admin_write on tariffs for all
  using (is_admin()) with check (is_admin());

drop policy if exists payments_self_read on payments;
create policy payments_self_read on payments for select
  using (is_admin() or member_id = current_member_id());
drop policy if exists payments_admin_write on payments;
create policy payments_admin_write on payments for all
  using (is_admin()) with check (is_admin());

drop policy if exists threads_self_read on threads;
create policy threads_self_read on threads for select
  using (is_admin() or member_id = current_member_id());
drop policy if exists threads_admin_write on threads;
create policy threads_admin_write on threads for all
  using (is_admin()) with check (is_admin());

drop policy if exists messages_participant_read on messages;
create policy messages_participant_read on messages for select
  using (is_admin() or exists (
    select 1 from threads t
    where t.id = messages.thread_id and t.member_id = current_member_id()));
drop policy if exists messages_participant_insert on messages;
create policy messages_participant_insert on messages for insert
  with check (is_admin() or exists (
    select 1 from threads t
    where t.id = messages.thread_id and t.member_id = current_member_id()));

drop policy if exists peer_threads_participant on peer_threads;
create policy peer_threads_participant on peer_threads for all
  using (member_a = current_member_id() or member_b = current_member_id()
         or is_admin())
  with check (member_a = current_member_id() or member_b = current_member_id());

drop policy if exists peer_messages_participant on peer_messages;
create policy peer_messages_participant on peer_messages for all
  using (is_admin() or exists (
    select 1 from peer_threads pt
    where pt.id = peer_messages.thread_id
      and (pt.member_a = current_member_id()
           or pt.member_b = current_member_id())))
  with check (sender_id = current_member_id());

drop policy if exists board_read on board_posts;
create policy board_read on board_posts for select
  using (is_admin() or approved_by is not null or exists (
    select 1 from members m
    where m.id = board_posts.author_id and m.role = 'admin'));
drop policy if exists board_member_insert on board_posts;
create policy board_member_insert on board_posts for insert
  with check (author_id = current_member_id());
drop policy if exists board_admin_write on board_posts;
create policy board_admin_write on board_posts for all
  using (is_admin()) with check (is_admin());

drop policy if exists hours_read on opening_hours;
create policy hours_read on opening_hours for select using (true);
drop policy if exists hours_admin_write on opening_hours;
create policy hours_admin_write on opening_hours for all
  using (is_admin()) with check (is_admin());

drop policy if exists prefs_self on notification_preferences;
create policy prefs_self on notification_preferences for all
  using (is_admin() or member_id = current_member_id())
  with check (member_id = current_member_id());

drop policy if exists notif_sent_admin on notifications_sent;
create policy notif_sent_admin on notifications_sent for all
  using (is_admin()) with check (is_admin());
drop policy if exists broadcasts_admin on broadcasts;
create policy broadcasts_admin on broadcasts for all
  using (is_admin()) with check (is_admin());
drop policy if exists audit_admin_read on audit_log;
create policy audit_admin_read on audit_log for select using (is_admin());

-- ── 4. STORAGE: student proofs (ISIC) ───────────────────────────────────────
-- Public bucket so the app's getPublicUrl works. Upload happens during
-- registration (before there is a session) so anon may insert.

insert into storage.buckets (id, name, public)
values ('student-proofs', 'student-proofs', true)
on conflict (id) do nothing;

drop policy if exists student_proofs_insert on storage.objects;
create policy student_proofs_insert on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'student-proofs');
drop policy if exists student_proofs_read on storage.objects;
create policy student_proofs_read on storage.objects for select
  using (bucket_id = 'student-proofs');

-- ── 5. SEED ─────────────────────────────────────────────────────────────────
-- Tariffs per CLAUDE.md: Standard 850/2 250, Student 750/1 950 (1m/3m).
insert into tariffs (name, duration_days, price, is_student, sort_order)
select * from (values
  ('Standard 1 měsíc', 30,  850, false, 1),
  ('Standard 3 měsíce', 90, 2250, false, 2),
  ('Student 1 měsíc',  30,  750, true,  3),
  ('Student 3 měsíce', 90, 1950, true,  4)
) as v(name, duration_days, price, is_student, sort_order)
where not exists (select 1 from tariffs);

-- Opening hours: informational only (24/7 for key holders, §14/§15). Example
-- defaults — the owner edits these in-app. weekday 0 = Monday.
insert into opening_hours (weekday, open_time, close_time, note) values
  (0, '06:00', '22:00', null),
  (1, '06:00', '22:00', null),
  (2, '06:00', '22:00', null),
  (3, '06:00', '22:00', null),
  (4, '06:00', '22:00', null),
  (5, '08:00', '20:00', null),
  (6, '08:00', '20:00', null)
on conflict (weekday) do nothing;

-- ── 6. ADMIN BOOTSTRAP ──────────────────────────────────────────────────────
-- There is no admin yet. Olda must register once through the app (creating a
-- `pending` member). THEN run the line below with his e-mail to promote him:
--
--   update members set role = 'admin', status = 'active'
--   where email = 'olda@example.com';
--
-- Optional, for the smoothest demo: in Supabase → Authentication → Providers
-- → Email, turn OFF "Confirm email". Approval is manual anyway (brief §4.1),
-- so e-mail confirmation is just extra friction for the club's ~34 members.
-- ============================================================================
