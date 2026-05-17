-- BýtFit Klub — Postgres / Supabase schema (DRAFT for review).
--
-- Source of truth: docs/gym-app-brief.md §5 "Datový model" + CLAUDE.md
-- business rules. This is a starting point to review with the owner, not a
-- final migration. Money/expiry semantics live in the app's tested domain
-- layer (lib/core/domain/) — the DB stores raw facts only.
--
-- Conventions: snake_case, uuid PKs, timestamptz, soft enums via CHECK so
-- the owner can extend tariffs/states without a migration where the brief
-- says they're configurable (§ tariffs).

create extension if not exists "pgcrypto";

-- ── members ─────────────────────────────────────────────────────────────
create table members (
  id                   uuid primary key default gen_random_uuid(),
  -- Links to Supabase Auth once auth is decided (email/OTP vs phone). Null
  -- for imported members who haven't registered yet (§8 migration).
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
  -- Member self-pause (CLAUDE.md §self-pause). Frozen membership; expiry &
  -- deposit clock don't advance while set.
  paused_at            timestamptz,
  pause_reason         text check (pause_reason in ('holiday','illness','other')),
  notes                text,                       -- admin-only
  tags                 text[] not null default '{}',
  created_at           timestamptz not null default now(),
  approved_at          timestamptz,
  approved_by          uuid references members (id)
);

-- ── tariffs (configurable — §3, no enum in code) ────────────────────────
create table tariffs (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,                     -- "Standard 3 měsíce"
  duration_days integer not null,                  -- 30 | 90 | 180 …
  price         integer not null,                  -- Kč
  is_student    boolean not null default false,
  is_active     boolean not null default true,     -- inactive stay on history
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now()
);

-- ── payments ────────────────────────────────────────────────────────────
create table payments (
  id                        uuid primary key default gen_random_uuid(),
  member_id                 uuid not null references members (id) on delete cascade,
  amount                    integer not null,      -- Kč
  tariff                    text not null,         -- snapshot label
  tariff_id                 uuid references tariffs (id),  -- null: historical/deposit
  paid_at                   timestamptz not null default now(),
  method                    text not null default 'manual'
                              check (method in ('qr_bank','cash','manual','imported')),
  variable_symbol           integer,
  extends_membership_by_days integer not null default 0,
  -- No automatic bank matching in MVP (§6) — always false for now.
  matched_automatically     boolean not null default false,
  -- Excel imports: excluded from real cash-flow stats (§9, domain/revenue).
  is_historical             boolean not null default false,
  invoice_pdf_url           text,
  created_at                timestamptz not null default now()
);
create index on payments (member_id, paid_at desc);

-- ── threads / messages (owner ↔ member) ─────────────────────────────────
create table threads (
  id         uuid primary key default gen_random_uuid(),
  member_id  uuid not null unique references members (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()   -- = last message, inbox sort
);

create table messages (
  id              uuid primary key default gen_random_uuid(),
  thread_id       uuid not null references threads (id) on delete cascade,
  from_role       text not null check (from_role in ('admin','member')),
  body            text not null,
  attachment_urls text[] not null default '{}',
  is_fault_report boolean not null default false,  -- §4.7
  read_at         timestamptz,
  created_at      timestamptz not null default now()
);
create index on messages (thread_id, created_at);

-- ── peer threads (member ↔ member — CLAUDE.md §11) ──────────────────────
-- Not in the brief's §5 list but in MVP scope per CLAUDE.md §11. Two member
-- participants, order-independent (mirrors store.dart pairKey).
create table peer_threads (
  id         uuid primary key default gen_random_uuid(),
  member_a   uuid not null references members (id) on delete cascade,
  member_b   uuid not null references members (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (member_a < member_b),
  unique (member_a, member_b)
);

create table peer_messages (
  id          uuid primary key default gen_random_uuid(),
  thread_id   uuid not null references peer_threads (id) on delete cascade,
  sender_id   uuid not null references members (id) on delete cascade,
  body        text not null,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);
create index on peer_messages (thread_id, created_at);

-- ── board posts (nástěnka — §4.6, 7 types) ──────────────────────────────
create table board_posts (
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
  -- null = from the owner; set = member post approved by this admin (§4.6).
  approved_by     uuid references members (id),
  published_at    timestamptz,
  created_at      timestamptz not null default now()
);

-- ── opening hours (info indicator — §14/§15, 7 rows) ────────────────────
create table opening_hours (
  weekday    integer primary key check (weekday between 0 and 6), -- 0 = Mon
  open_time  time,                                -- null = closed
  close_time time,
  note       text,
  updated_at timestamptz not null default now()
);

-- ── notification_preferences (1:1 with member — §4.8) ───────────────────
create table notification_preferences (
  member_id    uuid primary key references members (id) on delete cascade,
  push_master  boolean not null default true,
  push_outages boolean not null default true,
  push_promos  boolean not null default false,
  theme        text not null default 'dark'
                 check (theme in ('dark','system','light')),
  language     text not null default 'cs' check (language in ('cs','en')),
  updated_at   timestamptz not null default now()
);

-- ── notifications_sent (audit of reminders — §4.3) ──────────────────────
create table notifications_sent (
  id               uuid primary key default gen_random_uuid(),
  member_id        uuid not null references members (id) on delete cascade,
  type             text not null,   -- expiry_warning_14d … broadcast
  channel          text not null check (channel in ('push','email')),
  sent_at          timestamptz not null default now(),
  content_snapshot text
);

-- ── broadcasts (§4.4) ───────────────────────────────────────────────────
create table broadcasts (
  id               uuid primary key default gen_random_uuid(),
  created_by       uuid not null references members (id),
  title            text not null,
  body             text not null,
  image_url        text,
  target_filter    jsonb,
  sent_at          timestamptz,
  recipients_count integer not null default 0
);

-- ── audit_log ───────────────────────────────────────────────────────────
create table audit_log (
  id          uuid primary key default gen_random_uuid(),
  actor_id    uuid references members (id),
  action      text not null,
  target_type text,
  target_id   uuid,
  metadata    jsonb,
  created_at  timestamptz not null default now()
);
