# CLAUDE.md

Tento dokument je projektový kontext pro Claude Code. Načítá se automaticky při každé session. Drž se ho při všech rozhodnutích.

---

## Co stavíme

Mobilní aplikaci pro **správu členství v samoobslužné posilovně** (~34 členů). Nahrazuje Excel.

**Dvě role v jedné aplikaci:**
- **Člen** — vidí svoje členství, platí QR, dostává oznámení.
- **Admin (majitel)** — vidí všechny členy, schvaluje registrace, potvrzuje platby, posílá zprávy.

**Platformy:** iOS + Android z jednoho codebase (Flutter).

---

## Klíčové dokumenty

Přečti si VŽDY na začátku session:

1. `docs/gym-app-brief.md` — produktová specifikace (data model, flows, MVP scope, fáze 2). **Verze 2.0** — synchronizovaná s designem.
2. `docs/gym-app-design-brief.md` — vizuální specifikace (barvy, typografie, obrazovky, tón).
3. `docs/design/gympass/project/CLAUDE.md` — **design system z Claude Design** (přesné tokeny, konvence pro obrazovky).
4. `docs/design/gympass/project/screens/` — **JSX prototypy všech obrazovek**. Implementuj je pixel-perfect ve Flutteru.
5. `docs/seznam_c_lenu.xlsx` — reálný Excel od kamaráda, vzor dat pro migrační wizard.

**Pokud se rozcházejí, prioritní je `gym-app-brief.md` v2.0.** JSX prototypy jsou pravda o tom, jak má vypadat UI.

**Design bundle** v `docs/design/` obsahuje:
- 17 obrazovek jako JSX (members + admin)
- Tokeny v `screens/shared.jsx`
- In-memory store s mock daty v `screens/store.jsx`
- Tři chat transkripty (`chats/chat1-3.md`) — historie designových rozhodnutí
- Logo BýtFit Klub v `assets/bytfit-logo.jpg`

---

## Stack a knihovny

| Vrstva | Technologie | Poznámka |
|---|---|---|
| Frontend | **Flutter** (latest stable) | iOS + Android jeden codebase |
| State management | **Riverpod** | Doporučená volba 2026, ne Provider ani BLoC |
| Routing | **go_router** | Deklarativní routing |
| Backend | **Supabase** | Auth, Postgres, Storage, Edge Functions, Realtime |
| Push | **FCM** (Android) + **APNs** (iOS) přes Supabase Edge Function | |
| QR generování | **qr_flutter** | CZ QR Platba / Spayd formát |
| Lokalizace | **flutter_localizations + intl** | Primárně CS, EN připravit jako fallback |
| Datepicker | **flutter_native_widgets** | Nativní look |
| HTTP | **dio** + **supabase_flutter** | |
| Logging | **logger** | Strukturované logy |
| Testing | **flutter_test** + **mocktail** | Unit testy minimálně pro business logic (expirace, billing_day, kauce) |

**Nepoužívej:**
- Firebase přímo (kromě FCM přes Supabase) — držíme se Supabase
- Provider / BLoC — Riverpod
- shared_preferences pro citlivá data — flutter_secure_storage

---

## Konvence kódu

### Struktura projektu

```
lib/
├── main.dart
├── app.dart                       # MaterialApp, theme, routing
├── core/
│   ├── theme/                     # Barvy, typografie, dark/light
│   ├── routing/                   # go_router config
│   ├── extensions/                # DateTime, String extensions
│   └── utils/                     # helper funkce
├── features/
│   ├── auth/
│   │   ├── data/                  # Repository, Supabase calls
│   │   ├── domain/                # Models, business logic
│   │   └── presentation/          # Screens, widgets, providers
│   ├── membership/                # Stav, expirace, billing_day
│   ├── payment/                   # QR generování, manuální potvrzení
│   ├── notifications/             # Push, in-app feed
│   ├── admin/
│   │   ├── members_list/
│   │   ├── member_detail/
│   │   ├── approve_registrations/
│   │   ├── confirm_payments/
│   │   ├── broadcast/
│   │   ├── stats/
│   │   └── excel_import/          # Migrační wizard + re-import diff
│   └── profile/
├── shared/
│   ├── widgets/                   # Reusable UI (StatusPill, MembershipCard, …)
│   └── models/                    # Sdílené modely (Member, Payment, Tariff)
└── l10n/                          # Lokalizace
```

### Naming

- Files: `snake_case.dart`
- Classes / Widgets: `PascalCase`
- Variables / functions: `camelCase`
- Constants: `lowerCamelCase` v souboru, `SCREAMING_SNAKE_CASE` v `const`
- Database: `snake_case` (Postgres konvence)

### Stav UI

- Riverpod providers označovat suffixem: `membersListProvider`, `currentMemberProvider`
- Async state: `AsyncValue<T>` s explicitním handlingem loading / error / data
- Nikdy `setState` ve features layer — jen v jednoduchých leaf widgetech

### Chyby

- Custom exceptions v `core/errors/`: `AuthException`, `PaymentException`, `ImportException`
- Zachycuj na hranicích vrstev, prezentuj uživateli jako konkrétní hlášku (česky, viz design brief sekce 10)
- Loguj s kontextem (member_id, action) přes `logger`

---

## Business pravidla (DŮLEŽITÉ — snadno se na to zapomene)

1. **Tarify jsou konfigurovatelné** — tabulka `tariffs` v DB, ne enum v kódu. UI „Více > Tarify a ceny" v adminu. **Aktuální tarify v MVP:** Standard 850 / 2 250 Kč (1m/3m), Student 750 / 1 950 Kč (1m/3m). **6měsíční Standard (4 250 Kč) je v Claude Design prototypu, ale do MVP se nezavádí** — Olda si ho může kdykoliv přidat sám. **Obrazovka 05 (QR Payment) se proto staví flexibilně** — grid zvládne 2–6 tarifů (4 v MVP, ne pevně 3 dlaždice jako v JSX prototypu). Při implementaci ignoruj fixní `TARIFFS = { m1, m3, m6 }` v `QRPayment.jsx` a načítej z DB.
2. **Každý člen má `billing_day_of_month`** (1–31, nullable = 1.). Expirace se počítá k tomuto dni.
3. **Edge case billing_day = 31:** v měsíci, který má jen 30/28/29 dní, použij **poslední den měsíce** (jako Stripe).
4. **Při zaplacení během platného členství:** nová doba se **přičítá k existující expiraci**, ne k dnešnímu datu. Billing_day zachován.
5. **Kauce za klíč 100 Kč:** propadá automaticky **30 dní po expiraci členství** bez vrácení klíče. Stav `deposit_status` přechází z `paid` → `forfeited`.
6. **Manuální potvrzování plateb:** v MVP **není automatické párování s bankou**. Člen klikne „Zaplatil jsem", admin pak ručně potvrdí v sekci „Platby > Čeká". Stavy: `pending` / `ok` / `overdue`.
7. **Studentský tarif:** vyžaduje ISIC/potvrzení nahrané při registraci. **Ověření jen jednou**, neobnovuje se.
8. **Migrace z Excelu:** Excel je **stále v provozu** jako kontrolní vrstva. App musí umět **opakovaný import** s diff view.
9. **Historické platby z Excelu:** mají `is_historical = true`, do statistik příjmů se počítají odděleně.
10. **Notifikace:** trigger -14, -3, 0, +1, +7, +30 dní. Push + in-app. Respektuj `notification_preferences` (push_master, push_outages, push_promos).
11. **Komunikace = broadcast + 1:1 chat (majitel↔člen i člen↔člen).** Broadcast jde do nástěnky jako post typu `info`. Vlákno majitel↔člen vzniká z "Napsat Oldovi" v profilu, z hlášení závady, nebo když admin založí vlákno z detailu člena. **Člen↔člen:** member záložka „Zprávy" (nahradila „Karta"; karta dostupná z dashboardu) — jednotný inbox: konverzace s majitelem (odznak „PROVOZ", vždy přítomná) + vlákna s ostatními členy, "+" zakládá nové. Bez moderace/blokování v MVP (viz brief 4.4 C). Mock: `peerThreads` v `store.dart` klíčované `pairKey(a,b)`, `kCurrentMemberId='pavel'`.
12. **Nástěnka — 7 typů postů:** pinned, outage, warning, promo, event, fixed, info. Posty od členů (event, info) vyžadují schválení majitele.
13. **Hlášení závady** = bottom sheet z member dashboardu → text + fotky → vzniká nebo se přidá do 1:1 vlákna s majitelem.
14. **Indikátor "otevřeno / zavřeno"** v hlavičce nástěnky — výpočet podle aktuálního času a tabulky `opening_hours` (7 řádků, jeden per den, editovatelné z AdminMore). Pokud je dnešní řádek `null/null` (zavřeno), indikátor je červený. Pokud aktuální čas spadá mezi `open_time` a `close_time`, indikátor je zelený. Mimo to žlutý („zavřeno, otevírá se v X").
15. **Klub je 24/7 pro členy s klíčem** — `opening_hours` nepředstavuje fyzický přístup, je to **informační prvek** ("kdy je Olda obvykle v Klubu"). Funkce app jako platby, schvalování atd. fungují bez ohledu na otevírací dobu.

---

## Design system (krátká verze, plné v design briefu)

- **Tmavé téma primární.** Pozadí #0F0F10, surface #1A1A1C, text #F5F5F7.
- **Akcent #FF4D2E** (zatím — Martin potvrdí s kamarádem).
- **Stavy:** zelená #34C759 (aktivní), žlutá #FFCC00 (končí ≤7 dní), červená #FF3B30 (expirováno), šedá #8E8E93 (suspended).
- **Typografie:** Inter, vážná čeština, tykání, krátké věty. **Žádné fitness motivační formulace.**
- **Ikony:** Lucide nebo Phosphor (free, konzistentní).

---

## Co dělat a nedělat (workflow)

### Vždy

- **Začni přečtením `docs/gym-app-brief.md` a `docs/gym-app-design-brief.md`.**
- Před implementací nové feature napiš krátký plán do chatu a počkej na schválení.
- Po každé větší změně spusť `flutter analyze` a `flutter test`.
- Commituj často s konvenčními zprávami: `feat: add member detail screen`, `fix: billing_day edge case for 31`.
- Před push: build pro iOS i Android (`flutter build apk --debug`, `flutter build ios --debug --no-codesign`).

### Nikdy

- **Neimplementuj automatické bankovní párování v MVP.** Je to vyloučené (viz brief sekce 11).
- **Negeneruj daňové doklady / faktury.** Není v MVP scope.
- **Nepřidávej multi-tenant (více poboček).** Jedna posilovna, jednoduchá architektura.
- **Nepoužívej anglické UI texty.** Vše česky, tykání, viz tón v design briefu.
- **Nezahazuj sloupce z importovaného Excelu bez ručního potvrzení adminem.** Diff view, ne overwrite.
- **Neukládej hesla nebo tokeny do `shared_preferences`.** `flutter_secure_storage`.

---

## Definition of Done pro každou feature

- [ ] Funkční happy path (manuální test na simulátoru)
- [ ] Error states pokryty (offline, server error, validace)
- [ ] Loading state (skeleton, ne spinner) tam, kde data trvají >300 ms
- [ ] Empty state s českou hláškou
- [ ] Dark + light theme (oba renderují bez glitchů)
- [ ] Texty v `l10n/`, ne hardcoded
- [ ] `flutter analyze` = 0 warnings
- [ ] Pokud feature obsahuje business logic (expirace, billing_day, kauce) → unit test
- [ ] Krátký commit message

---

## Aktuální stav (Claude Code aktualizuje při práci)

> **Pozn.:** Hotová je **UI vrstva celého prototypu** (18 obrazovek, pixel-faithful
> port JSX → Flutter) běžící na **mock datech** (`lib/core/store/store.dart`,
> port `store.jsx`). Backend (Supabase), auth, l10n, notifikace, migrace a
> data-ops zatím nejsou — vyžadují credentials / produktová rozhodnutí.

- [~] **Fáze 0 — Setup**: ✅ Flutter projekt, theme (z `shared.jsx`), **go_router se `StatefulShellRoute` (perzistentní iOS 26 nav)**, Riverpod, sdílené primitivy, **design tokeny + spacing/radius škála**, **light/dark `ThemeMode` (živý přepínač)**, **l10n (cs/en, ~389 ARB klíčů, všech 18 obrazovek + nav/persona, živé přepínání jazyka i tématu)** · ⬜ Supabase · ✅ l10n: ICU český plural (one/few/other) dokončen (member_list/fault/payments/thread/Excel import); zbývají jen řetězce vázané na mock data (jména, částky, ukázkové posty) — inventář v `.context/handoff-l10n-followup.md` (sekce „Update 2026-05-17"), přeloží se s backend/datovou vrstvou · ✅ **Supabase napojen** (`Supabase.initialize`, default creds v `AppEnv`, šev `gymRepositoryProvider`); data-vrstva 18 obrazovek zůstává na mocku (architektura B = další dávka)
- [~] **Fáze 1 — Auth**: ✅ obrazovky 01–03 (Login / Registrace / Čekání na schválení, `lib/features/auth/`), `go_router` redirect guard řízený Supabase auth stavem, registrace → DB trigger `handle_new_user` → `pending` člen, ISIC upload do storage, ověřeno proti reálnému projektu (signUp 200) · ⚠️ zbývá nasadit `docs/backend/setup.sql` v Supabase SQL editoru + povýšit Oldu na admina (viz `docs/backend/README.md`) · ✅ persona switcher zůstává jako dev fallback když `!AppEnv.hasSupabase`
- [x] **Fáze 2 — Member core**: Dashboard (04), karta (09), historie (06), profil (08) — UI na mock datech
- [x] **Fáze 3 — Payment**: QR Payment (05) flexibilní grid tarifů, „Zaplatil jsem" — UI
- [x] **Fáze 4 — Board & Fault**: Nástěnka (07) 7 typů postů, hlášení závady (FaultReport) — UI
- [x] **Fáze 5 — Admin core**: Dashboard (10), seznam (11), detail (12), schvalování (13) — UI
- [x] **Fáze 6 — Admin advanced**: Platby (14), zprávy 1:1 (15, 16), Více (17), AddMember (18) — UI
- [x] **Fáze 7 — Komunikace**: Broadcast composer (19), notification preferences v profilu — UI
- [~] **Fáze 8 — Migrace**: ✅ Excel import wizard UI (4 kroky) + re-import diff view + unit-tested `diffImport` + `GymStore.importMembers` (idempotentní) — na mock/syntetickém sheetu · ⬜ reálný `file_picker`/`excel` parser + napojení na Supabase (vyžaduje backend)
- [ ] **Fáze 9 — Notifikace**: FCM/APNs setup, scheduled jobs pro -14/-3/0/+1/+7/+30
- [ ] **Fáze 10 — Data ops**: CSV export plateb, záloha databáze, GDPR
- [~] **Fáze 11 — Polish**: ✅ haptika (`core/utils/haptics.dart`, centrálně v AppButton/BottomNav/toast), press+entrance animace, themed toast, empty states sjednoceny (history doplněn), Skeleton primitiv · ⬜ error/offline stavy a skutečný skeleton-loading vznikají s async/Supabase vrstvou
- [ ] **Fáze 12 — Build & TestFlight/Internal track** (Android SDK + CocoaPods nejsou v tomto prostředí; `flutter build web` ✓, `flutter analyze` 0 issues, `flutter test` ✓)

### Testy & doménová logika (2026-05-17)

- **Pauza členství (rozhodnuto 2026-05-17, majitel):**
  - **Pauza:** člen si ji v profilu (08) zapne sám **jen na konci
    předplatného** (`daysNum ≤ 0`); dřívější pauzu (uprostřed období)
    nastaví **Olda** z detailu člena (12). Olda dostane zprávu do 1:1 vlákna.
  - **Obnovení = výhradně Olda** (z detailu člena 12). Člen resume **nemá** —
    v profilu vidí jen locked řádek „Pozastaveno · Obnovení řeší Olda", tap
    ho pošle do vlákna s Oldou. `GymStore.resumeMembership` posílá zprávu
    `from: 'olda'`.
  - **Bez stropu** — pauza je časově neomezená (žádné auto-expire).
  - **Klíč si člen během pauzy nechává** (vědomé riziko — viz handoff).
  - Expirace i 30denní lhůta kauce (§5) zamrznou —
    `domain/membership.dart#expiryAfterPause` (otestováno). Mock:
    `Member.pausedAt/pauseReason`, `GymStore.pauseMembership`
    (člen, `from:'member'`) / `resumeMembership` (Olda, `from:'olda'`).
- **Test suite: 99 testů, zelená** (`flutter test`). Pokrytí:
  - `test/format_test.dart`, `test/store_test.dart` — formátování + mock store.
  - `test/import_diff_test.dart`, `test/wizard_flow_test.dart` — Excel migrace.
  - `test/screens_smoke_test.dart` — všech 18 obrazovek render v cs/en ×
    dark/light na design rámci 402×874 (chytá chybějící l10n / null / crash).
  - `test/domain/*` — 46 testů doménové vrstvy (vč. `expiryAfterPause`).
- **`lib/core/domain/` — čisté, otestované business funkce** (zatím
  NEnapojené na UI/store; napojí se s Supabase — UI dál běží na mock storu):
  `membership.dart` (expirace + billing_day vč. edge 31→poslední den měsíce,
  přičítání platby k expiraci §2–§4), `deposit.dart` (kauce +30 dní §5),
  `notifications.dart` (plán −14/−3/0/+1/+7/+30 §10), `opening_hours.dart`
  (indikátor otevřeno/zavřeno §14–15), `revenue.dart` (oddělení
  is_historical §9). Produktové předpoklady popsány v doc-comments + handoffu.
- **Smoke test odhalil a opravil 8 reálných layout bugů** na 402px (design
  šířka): infinite-height crash na admin dashboardu + 7× horizontal
  overflow (history/board/member_list/thread/wizard/dashboard) — text
  zabalen do Flexible/ellipsis, akční chipy do Wrap.

Claude Code: po dokončení fáze odškrtni checkbox a commitni `chore: complete phase X`.
