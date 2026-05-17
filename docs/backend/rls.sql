-- BýtFit Klub — Row-Level Security (DRAFT for review).
--
-- Web is a PUBLIC static bundle shipping the anon key, so RLS *is* the
-- security boundary (not key secrecy). Two roles: a member sees only their
-- own data; an admin (the owner) sees everything. Helper functions resolve
-- the caller's member row from the Supabase Auth uid.

-- Caller's member id (null if not linked yet).
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

-- Enable RLS everywhere.
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

-- ── members ─────────────────────────────────────────────────────────────
create policy members_self_or_admin_read on members for select
  using (is_admin() or id = current_member_id());
-- Members may edit a narrow set of their own fields; the app must still
-- restrict columns (status/tariff/expiry stay owner-managed per the brief).
create policy members_self_update on members for update
  using (id = current_member_id()) with check (id = current_member_id());
create policy members_admin_write on members for all
  using (is_admin()) with check (is_admin());

-- ── tariffs (everyone reads active; admin manages) ──────────────────────
create policy tariffs_read on tariffs for select using (true);
create policy tariffs_admin_write on tariffs for all
  using (is_admin()) with check (is_admin());

-- ── payments (own history; admin all) ───────────────────────────────────
create policy payments_self_read on payments for select
  using (is_admin() or member_id = current_member_id());
create policy payments_admin_write on payments for all
  using (is_admin()) with check (is_admin());

-- ── owner ↔ member threads/messages ─────────────────────────────────────
create policy threads_self_read on threads for select
  using (is_admin() or member_id = current_member_id());
create policy threads_admin_write on threads for all
  using (is_admin()) with check (is_admin());

create policy messages_participant_read on messages for select
  using (is_admin() or exists (
    select 1 from threads t
    where t.id = messages.thread_id and t.member_id = current_member_id()));
create policy messages_participant_insert on messages for insert
  with check (is_admin() or exists (
    select 1 from threads t
    where t.id = messages.thread_id and t.member_id = current_member_id()));

-- ── peer threads/messages (only the two participants) ───────────────────
create policy peer_threads_participant on peer_threads for all
  using (member_a = current_member_id() or member_b = current_member_id()
         or is_admin())
  with check (member_a = current_member_id() or member_b = current_member_id());

create policy peer_messages_participant on peer_messages for all
  using (is_admin() or exists (
    select 1 from peer_threads pt
    where pt.id = peer_messages.thread_id
      and (pt.member_a = current_member_id()
           or pt.member_b = current_member_id())))
  with check (sender_id = current_member_id());

-- ── board / hours / prefs ───────────────────────────────────────────────
-- Members see owner posts and approved member posts; admin sees all.
create policy board_read on board_posts for select
  using (is_admin() or approved_by is not null or exists (
    select 1 from members m
    where m.id = board_posts.author_id and m.role = 'admin'));
create policy board_member_insert on board_posts for insert
  with check (author_id = current_member_id());     -- needs admin approval
create policy board_admin_write on board_posts for all
  using (is_admin()) with check (is_admin());

create policy hours_read on opening_hours for select using (true);
create policy hours_admin_write on opening_hours for all
  using (is_admin()) with check (is_admin());

create policy prefs_self on notification_preferences for all
  using (is_admin() or member_id = current_member_id())
  with check (member_id = current_member_id());

-- ── admin-only tables ───────────────────────────────────────────────────
create policy notif_sent_admin on notifications_sent for all
  using (is_admin()) with check (is_admin());
create policy broadcasts_admin on broadcasts for all
  using (is_admin()) with check (is_admin());
create policy audit_admin_read on audit_log for select using (is_admin());
