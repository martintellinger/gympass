# Supabase napojení — STAV: AUTH ŽIVĚ, zbývá nasadit DB schéma

## ⚡ Co musíš udělat ty (jediný blokující krok)

Projekt `yktounljghdypfhbdxws` je prázdný (žádné tabulky). Kód je hotový a
otestovaný; chybí jen **nasadit databázi**, což vyžaduje přístup do SQL
editoru (anon/publishable klíč na DDL nestačí):

1. Otevři **Supabase → SQL editor**, vlož celý obsah
   [`docs/backend/setup.sql`](setup.sql) a klikni **Run**. (Schéma + trigger
   registrace + RLS + storage bucket + seed tarifů a otevírací doby.)
2. Zaregistruj se jednou v app jako Olda → vznikne `pending` člen. Pak v SQL
   editoru: `update members set role='admin', status='active' where email='…';`
3. (Volitelné, hladší demo) Authentication → Providers → Email → vypni
   „Confirm email" (schvalování je stejně ruční, brief §4.1).

Hotovo. Login i registrace pak fungují bez další změny v kódu.

## Co je ŽIVĚ napojené (ověřeno proti reálnému projektu)

- `Supabase.initialize` v `main.dart` (default creds v `AppEnv`, lze
  přebít přes `--dart-define`).
- **Přihlášení + registrace + čekání na schválení** (obrazovky 01–03,
  `lib/features/auth/`), `go_router` redirect guard řízený auth stavem.
- Registrace volá `signUp` s metadaty (jméno, příjmení, telefon, tarif,
  ISIC url) → DB trigger `handle_new_user` z nich vyrobí `pending` člena.
  Ověřeno: signUp vrací 200 a metadata se ukládají přesně; projekt
  vyžaduje potvrzení e-mailu (UI to řeší obrazovkou „Potvrď e-mail").
- Student: upload ISIC přes `file_picker` do bucketu `student-proofs`
  (best-effort, registraci neblokuje).

## Co zůstává na mocku (záměrně — architektura B, samostatná dávka)

Žádná z 18 obrazovek aplikace ještě nečte z `gymRepositoryProvider` —
běží dál na `storeProvider` (in-memory). `SupabaseGymRepository` je
stále dokumentovaný stub. Přepojování obrazovka-po-obrazovce na
`AsyncValue` providery nad repository je další fáze (viz níže), není
součástí tohoto kroku. Smoke-test guardrail (18 obrazovek) zůstává
zelený, protože widget testy volají `authNotifier.debugUseMock()`.

---

Tahle složka + `lib/core/data/` + `lib/core/env/` byla **příprava**
na backend; auth vrstva ji teď používá. Cílem bylo postavit šev, aby
napojení dat bylo mechanické.

## Co je hotové (v repu)

| Vrstva | Soubor | Role |
|---|---|---|
| Env | `lib/core/env/app_env.dart` | Secrets přes `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`), `AppEnv.hasSupabase` |
| DTO | `lib/core/data/dto/db_rows.dart` | DB-tvar řádků (`MemberRow`, `PaymentRow`, `TariffRow`, `OpeningHoursRow`) + `fromMap` |
| Mapper | `lib/core/data/dto/member_mapper.dart` | DB řádek → view `Member` přes **otestovanou doménovou vrstvu** (expirace, pauza, kauce) |
| Kontrakt | `lib/core/data/gym_repository.dart` | Asynchronní rozhraní = šev |
| Mock impl | `lib/core/data/mock_gym_repository.dart` | Obaluje `GymStore` — šev je živý a testovaný |
| Supabase stub | `lib/core/data/supabase_gym_repository.dart` | `UnimplementedError` + přesná mapovací cesta v každé metodě |
| Výběr | `lib/core/data/gym_repository_provider.dart` | Mock vs Supabase podle `AppEnv.hasSupabase` |
| Schéma | `docs/backend/schema.sql` | Postgres tabulky dle briefu §5 + CLAUDE.md |
| RLS | `docs/backend/rls.sql` | Politiky pro role člen/admin (web je veřejný → RLS = ochrana) |

Klíčový princip: **veškerá datumová/finanční logika zůstává v
`lib/core/domain/`** (otestováno, 46 testů). Supabase implementace jen
parsuje řádky a protáhne je mapperem — nikde se nereimplementuje výpočet
expirace, kauce ani pauzy.

## Co je potřeba rozhodnout (blokující — bez toho nelze wirovat)

1. **Dva Supabase projekty?** Doporučení: oddělený projekt pro veřejné web
   demo (anon key je v JS bundlu) vs. ostrá data. → potřebuju potvrdit.
2. **Auth model.** Obrazovky 01–03 neexistují, router nemá guard. Rozhodnout
   e-mail+OTP / telefon; pak doplnit přihlášení + `go_router` redirect +
   obnovu session. `members.auth_user_id` na to ve schématu čeká.
3. **Revize schématu + RLS** s ohledem na reálná data kamaráda (zvlášť
   `members_self_update` — které sloupce smí člen měnit; brief říká, že
   stav/tarif/expiraci spravuje majitel).
4. **Architektura B** (z plánu): přechod obrazovek z `storeProvider` na
   `AsyncValue` providery nad `gymRepositoryProvider`, feature po feature
   (loading/error/empty stavy dle DoD).

## Sekvence wiringu (až přijdou credentials)

1. `flutter pub add supabase_flutter flutter_secure_storage file_picker excel`
   (viz `pubspec` — balíčky zatím **nepřidané**, ať build nezávisí na síti).
2. `Supabase.initialize(...)` v `main.dart` za `AppEnv.hasSupabase`.
3. Implementovat `SupabaseGymRepository` metodu po metodě podle TODO
   komentářů (parse `*Row.fromMap` → `memberFromRow`).
4. Spustit `schema.sql` + `rls.sql` v Supabase, doplnit seed tarifů a
   7 řádků `opening_hours`.
5. Migrace Excelu (§8): reálný `file_picker`/`excel` parser → existující
   `diffImport` → `importMembers`.
6. Postupně přepínat obrazovky na repository providery.

## Poznámky

- Web preview deploy: anon key se musí předat buildu v
  `.github/workflows/deploy-pages.yml` přes `--dart-define`
  (GitHub Secrets), jinak `AppEnv.hasSupabase=false` a běží mock — preview
  se tím nikdy nerozbije.
- `member↔member` chat (CLAUDE.md §11) není v briefu §5; ve schématu
  přidán jako `peer_threads`/`peer_messages` (k revizi).
- `member_mapper.depositStatusFor` je připravené pro detail člena (§5
  kauce) — view `Member` zatím deposit pole nemá, dopojí se s detailem.
