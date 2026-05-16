# Brief: Aplikace pro správu členství v samoobslužné posilovně

**Verze:** 2.0 (synchronizace s Claude Design projektem BýtFit Klub)
**Datum:** 16. května 2026
**Autor:** Martin Tellinger
**Pro:** Claude design / Lovable.dev / vývojový tým

---

## 1. Kontext a cíl

Kamarád provozuje **samoobslužnou posilovnu** s fyzickými klíči (žádná recepce, otevřeno 24/7 pro členy s klíčem). Aktuálně eviduje členy v Excelu — jméno, datum platby, částka. Manuální kontrola, kdo zaplatil a kdo ne, manuální upomínky telefonem/SMS.

**Cíl projektu:** Nahradit Excel mobilní aplikací, která:

1. Automatizuje upomínky o končícím členství.
2. Umožní platbu QR kódem (CZ QR / Spayd).
3. Dá správci přehled o stavu plateb a vydaných klíčích.
4. Umožní hromadnou komunikaci se členy.

**Cílová platforma:** Nativní mobilní aplikace (iOS + Android) pro členy. Správcovské rozhraní řešeno jako rozšířený view ve stejné aplikaci pod správcovským účtem (jeden codebase, role-based UI).

**Doporučená realizace:** Flutter (jeden codebase, oba store), backend Supabase (auth, postgres, edge functions, push přes FCM/APNs).

---

## 2. Personas

### Člen — Pavel, 34 let

Chodí 3× týdně po práci. Platí měsíc 850 Kč, někdy 3 měsíce 2250 Kč. Dřív mu majitel volal, že má zaplatit — vždycky na to zapomínal. Klíč nosí na klíčence od auta. Chce: nezapomenout zaplatit, mít doklad, vědět co se v posilovně děje.

### Student — Tereza, 22 let

VŠ studentka, platí studentské 750 / 1950 Kč. Občas si dá pauzu přes prázdniny. Aktivní na telefonu, ocení digitální kartu v Apple Wallet.

### Správce / majitel — Honza

Provozuje posilovnu jako vedlejší činnost (OSVČ). Excel je pro něj limit — neví, kdo přesně dluží, kdo má klíč a nevrátil ho, kdo už 2 měsíce nepřišel. Chce: méně manuální práce, jasný přehled, automatické připomínky bez vlastního zásahu.

---

## 3. Členské tarify (data)

| Tarif | Doba | Cena | Cena/měsíc |
|---|---|---|---|
| Standard měsíční | 30 dní | 850 Kč | 850 Kč |
| Standard 3 měsíce | 90 dní | 2 250 Kč | 750 Kč |
| Student měsíční | 30 dní | 750 Kč | 750 Kč |
| Student 3 měsíce | 90 dní | 1 950 Kč | 650 Kč |

> **Poznámka k 6měsíčnímu tarifu:** Claude Design ukazuje variantu Standard 6m za 4 250 Kč. Olda ji **zatím nepotvrdil** — v MVP **se nezavádí**. Protože tabulka `tariffs` je konfigurovatelná, může si tarif Olda kdykoliv přidat sám v UI „Více > Tarify a ceny" bez zásahu vývojáře. **UI obrazovky 05 (QR Payment) se ale staví tak, aby zvládla libovolný počet tarifů** (gridem, ne pevně 3 dlaždice) — viz sekce 6.

**Tarify musí být konfigurovatelné v nastavení správce**, ne hardcoded v kódu. Kamarád v únoru 2026 přecenil a doběhové staré tarify (roční permice rozpočítaná na měsíce, staré čtvrtletní ceny) existují u některých členů ještě dnes. Při dalším zdražování / přidání nového tarifu musí být schopen to udělat sám bez zásahu vývojáře.

Datový model: tabulka `tariffs` s poli `name`, `duration_days`, `price`, `is_student`, `is_active` (deaktivované tarify zůstávají historicky uložené u plateb, ale nejde je vybrat při nové platbě).

**Klíč:** vratná kauce **100 Kč** při vydání, vrací se při ukončení členství a odevzdání klíče. **Pokud člen klíč nevrátí do 30 dnů od konce posledního platného členství (expirace bez prodloužení), kauce propadá** a klíč je veden jako "nevrácený, kauce propadla". Po této lhůtě se předpokládá, že klíč nebude vrácen — správce může zvážit výměnu zámku, pokud je to bezpečnostní riziko.

**Pravidla:**
- Studentský tarif vyžaduje ověření statusu (správce schvaluje při registraci nebo nahráním ISIC fotky).
- Členství se neobnovuje automaticky — člen platí ručně, app posílá připomínku.
- **Každý člen má vlastní "den platby v měsíci" (billing_day_of_month)** — den, ke kterému mu vyprší členství a k němuž má platit další platbu. Pokud člen začal platit 11. v měsíci, jeho měsíční členství končí vždy 11. následujícího měsíce. Pokud není den zadán, použije se default 1. dne měsíce.
- Platba se počítá od data zaplacení (ne kalendářní měsíc), kvůli prodlužování přesně o 30 / 90 dní.
- Při zaplacení během platného členství se nová doba **přičte** ke stávající expiraci, ne k dnešnímu datu — billing_day zůstává zachován.

---

## 4. Klíčové uživatelské toky

### 4.1 Registrace nového člena

1. Stáhne app, otevře.
2. Zadá: jméno, příjmení, e-mail, telefon, výběr tarifu (standard / student).
3. Pokud student → upload fotky ISIC nebo studentského potvrzení.
4. Vytvoří heslo, potvrdí GDPR souhlas.
5. **Stav účtu: "Čeká na schválení."** Vidí prázdný dashboard s textem "Jakmile správce ověří tvou registraci a předá ti klíč, dostaneš notifikaci."
6. Správci přijde push + e-mail "Nová registrace: Pavel Novák".
7. Správce v app schválí (případně zamítne s důvodem). U schválení vyplní:
   - Datum vydání klíče
   - Číslo klíče (volitelně, pokud má číslované)
   - Přijatá kauce 100 Kč: ✓
   - Volitelně: rovnou zaeviduje první platbu členství, pokud člen platil cash při vyzvednutí klíče.
8. Členovi přijde push "Tvůj účet byl aktivován. Vyzvedni si klíč u majitele." nebo (pokud už klíč má) "Účet aktivní, můžeš platit a chodit cvičit."

### 4.2 Platba členství (člen)

1. Na dashboardu vidí: "Členství platí do 23. 5. 2026 — zbývá 8 dní."
2. Klikne "Prodloužit členství".
3. Vybere tarif (1 měsíc / 3 měsíce).
4. App vygeneruje **CZ QR platbu (Spayd)** s:
   - Číslem účtu posilovny
   - Částkou
   - Variabilním symbolem (interní ID člena, např. 240001)
   - Zprávou pro příjemce: "Členství — Pavel Novák"
5. Člen zaplatí ze své banky (Revolut, KB, ČS — všichni umí Spayd).
6. **Potvrzení platby správcem:** Účet kamaráda není uspořádaný pro automatické párování (různé typy plateb, smíšený osobní/posilovenský provoz). Správce dostane push **"Pavel Novák oznámil platbu 2 250 Kč — potvrď přijetí"** a po kontrole ve své bance jednoduše klikne **"Potvrdit přijato"** (nebo "Odmítnout" s důvodem).
7. Po potvrzení: člen dostane push "Platba přijata. Členství prodlouženo do 23. 6. 2026."
8. Daňový doklad / účtenka ke stažení v PDF přímo v app.

**Po odeslání QR má člen v app tlačítko "Zaplatil jsem"** — kliknutím signalizuje správci, že platba je v bance. Bez tohoto signálu by správce musel proaktivně kontrolovat účet, takhle dostane upozornění až když je co kontrolovat.

**Fallback:** pokud člen zaplatí cash nebo jiným způsobem, správce ručně přidá platbu v detailu člena ("Přidat platbu" → částka, datum, tarif).

### 4.3 Automatické připomínky

Trigger podle počtu dní do expirace:

| Den | Akce | Kanál |
|---|---|---|
| –14 | Mírná připomínka "Tvé členství končí za 14 dní. Můžeš prodloužit kdykoliv." | Push |
| –3 | Připomínka s QR "Členství končí za 3 dny. Naskenuj QR pro prodloužení." | Push + e-mail |
| 0 | Den expirace "Dnes končí tvé členství. Zaplať pro pokračování." | Push + e-mail |
| +1 | "Členství vypršelo. Prosím vrať klíč nebo prodluž." | Push + e-mail (zvýrazněno) |
| +7 | "Členství vypršelo před týdnem. Kontaktuj majitele." | Push + správci interní upozornění |
| +30 | "Klíč nevrácen do 30 dnů od expirace — kauce 100 Kč propadla." | Push členovi + správci interní upozornění |

Po +14 dnech bez reakce → automaticky **suspended** stav, správce vidí v dashboardu "K řešení: 3 členové po lhůtě, vyžadují kontakt".

Po +30 dnech bez vrácení klíče → automatická akce: kauce označena jako `forfeited` (propadla), klíč zůstává v evidenci jako "ztracený / nevrácený", člen přechází do stavu `inactive`. Správce dostane upozornění, ať zváží výměnu zámku.

### 4.4 Komunikace mezi majitelem a členy

Systém zpráv má **dvě vrstvy**:

**A) Broadcast (hromadné zprávy)** — od majitele všem nebo segmentu

1. V "Více" → "Hromadná zpráva všem" nebo z konkrétního filtrovaného seznamu.
2. Výběr příjemců:
   - Všichni aktivní členové
   - Aktivní + suspended
   - Pouze tarif (standard / student)
   - Tag (např. "VIP", "firma")
   - Konkrétní lidé (multi-select)
3. Zadá titulek a text. Volitelně přiloží obrázek.
4. Náhled. Odešle.
5. Členové dostanou push + zpráva se uloží do "Nástěnka" v jejich app jako post typu `info` (viz 4.6).

Šablony: "Mimořádně zavřeno", "Nový stroj", "Změna otevírací doby", "Vánoční pauza".

**B) Konverzace 1:1 (chat majitel ↔ člen)** — obousměrný kanál

- **Inbox vláken (admin):** seznam všech konverzací seřazený podle posledního příspěvku. Badge nepřečtených, vyhledávání podle jména, "Nová zpráva" pro založení vlákna.
- **Vlákno:** klasické bubliny (já vs. druhý), seskupení po dnech, header s kontextem člena (tarif, expirace) a odkaz na detail.
- **Šablony odpovědí dynamicky podle stavu člena:**
  - State `error` (po lhůtě) → "Připomínka platby {X} Kč. Pošlu QR."
  - State `warn` (končí za pár dní) → "Ahoj {jméno}, končí ti za pár dní. Chceš prodloužit?"
  - Vždy: "Stavím se zítra v Klubu.", "Díky, mám."
- **Z čeho vznikne vlákno:**
  - Člen napíše majiteli ze svého profilu ("Napsat Oldovi")
  - Člen nahlásí závadu z dashboardu (viz 4.7) — text se uloží jako první zpráva ve vlákně
  - Majitel založí vlákno z detailu člena
- Push notifikace o nepřečtených zprávách (s respektem k nastavení v profilu — viz 4.8).

### 4.5 Správa klíčů (správce)

V detailu člena:
- **Klíč vydán:** ✓ datum, číslo klíče (volitelně)
- **Kauce 100 Kč přijata:** ✓
- **Klíč vrácen:** datum (po ukončení členství)
- **Kauce vrácena / propadla:** ✓ vrácena | ⚠ propadla (datum)

Dashboard "Klíče":
- Celkem v oběhu
- U koho (seznam)
- Po expiraci členství, ale klíč nevrácen (kritické — riziko neoprávněného přístupu)
- **Propadlé kauce** — seznam členů, kterým kauce propadla (klíč v nenávratnu), s datem propadnutí. Z účetního pohledu se kauce stává příjmem posilovny.

### 4.6 Nástěnka klubu (BoardScreen)

Hlavní komunikační prostor klubu — místo statického "Oznámení" je nástěnka s typovanými příspěvky a filtry. Pátá položka v member bottom navu.

**Typy příspěvků (post types):**

| Typ | Label | Barva | Použití |
|---|---|---|---|
| `pinned` | Připnuto | akcent | Aktuálně důležité, zobrazuje se nahoře |
| `outage` | Mimo provoz | červená | "Bench č. 2 mimo provoz" |
| `warning` | Pozor | žlutá | "Neházejte klíče za dveře" |
| `promo` | Akce | zelená | "Doporuč kamaráda, dostaneš měsíc zdarma" |
| `event` | Událost | modrá | "Společné běhání · pondělky 18:00" |
| `fixed` | Opraveno | zelená | "Sprcha č. 3 opravena" |
| `info` | Info | šedá | Broadcasty z 4.4 A |

**Funkce:**
- Filtry chips nahoře: Vše, Výpadky, Pozor, Akce, Události.
- Připnuté příspěvky vždy nahoře, ostatní podle data.
- Indikátor "otevřeno" / "zavřeno" v hlavičce (podle aktuálního času a otevírací doby — viz sekce 13).
- **Členové můžou taky psát** — ne všechny typy. Členský post jde jako `event` (návrh společné aktivity) nebo `info` a vyžaduje schválení majitele před zveřejněním (anti-spam, anti-konflikt).
- Komentáře pod příspěvky **nejsou v MVP** (přidaná komplexita, moderace). Diskuze přes 1:1 zprávy.

**Datový model:** tabulka `board_posts` s poli `id`, `author_id`, `type`, `title`, `body`, `is_pinned`, `cta_label` (volitelně, např. "Sdílet pozvánku"), `published_at`, `approved_by` (nullable — null = od majitele, vyplněno = od člena schváleného Oldou).

### 4.7 Hlášení závady (FaultReport)

Bottom sheet otevírající se z member dashboardu sekundárním tlačítkem ("Nahlásit závadu").

**Tok:**
1. Člen klikne na "Nahlásit závadu".
2. Bottom sheet s textovým polem a uploadem fotek (multi-upload, libovolný počet).
3. Po odeslání:
   - Vznikne nové vlákno 1:1 (nebo se přidá zpráva do existujícího) s prefixem "🔧 Závada: {text}" a přiloženými fotkami.
   - Majitel dostane push.
   - Volitelně (fáze 2): závada automaticky vytvoří draft post typu `outage` na nástěnce, který majitel jedním klikem zveřejní.

**Datový model:** zprávy v `messages` mají flag `is_fault_report` a array `attachment_urls`.

### 4.8 Notifikační preference (Profil)

Člen v profilu nastavuje, co dostává jako push:

- **Push notifikace** (master toggle) — konec členství, schválení žádostí. Zapnuto výchozí.
- **Výpadky a zavírací doba** — když je v Klubu něco mimo provoz. Zapnuto výchozí.
- **Akce a slevy** — promo posty na nástěnce. Vypnuto výchozí (anti-spam).

Plus globální:
- **Téma**: Tmavé / Systém / Světlé (segmented control).
- **Jazyk**: CS / EN (segmented control). EN je placeholder v MVP, lokalizace přijde s expanzí.

**Datový model:** tabulka `notification_preferences` per člen, sloupce `push_master`, `push_outages`, `push_promos`, `theme`, `language`.

### 4.9 Export dat pro účetnictví (AdminMore)

I když plnohodnotné účetnictví / faktury nejsou v MVP, **CSV export plateb** je užitečný pro případ, kdy se Olda rozhodne data poslat účetní:

- Z AdminMore → Data → "Export plateb (CSV)"
- Filtrovatelné období (posledních 12 měsíců default)
- Sloupce: datum, jméno člena, tarif, částka, metoda (QR/cash/manuální), stav, VS
- **Záloha databáze** — automatická noční záloha, manuální spuštění z UI, zobrazuje "poslední záloha · {datum}".

---

## 5. Datový model (zjednodušený)

```
members
├── id (uuid)
├── first_name, last_name, email, phone
├── role: 'member' | 'admin'
├── status: 'pending' | 'active' | 'suspended' | 'inactive'
├── tariff_type: 'standard' | 'student'
├── student_proof_url (nullable)
├── variable_symbol (int, unikátní — pro orientaci ve výpisu banky)
├── membership_expires_at (date, nullable)
├── billing_day_of_month (int 1-31, nullable — den v měsíci, kdy je splatná další platba; null = platí od 1. dne měsíce)
├── key_issued (bool)
├── key_number (string, nullable)
├── key_issued_at (date, nullable)
├── key_returned_at (date, nullable)
├── deposit_paid (bool)
├── deposit_returned (bool)
├── deposit_status: 'paid' | 'returned' | 'forfeited' (default 'paid' po přijetí)
├── deposit_forfeited_at (timestamp, nullable — vyplní automatika po 30 dnech od expirace bez vrácení klíče)
├── notes (text, jen pro správce)
├── created_at, approved_at, approved_by
└── tags (array)

payments
├── id
├── member_id (FK)
├── amount (int, Kč)
├── tariff: '1m_standard' | '3m_standard' | '1m_student' | '3m_student' | 'deposit' | 'historical' | 'other'
├── tariff_id (FK na tabulku tariffs, nullable pro historical/deposit)
├── paid_at (timestamp)
├── method: 'qr_bank' | 'cash' | 'manual' | 'imported'
├── variable_symbol
├── extends_membership_by_days (int: 30 nebo 90, u historických libovolné)
├── matched_automatically (bool)
├── is_historical (bool, default false — true pro platby naimportované z Excelu)
└── invoice_pdf_url (nullable)

notifications_sent
├── id
├── member_id (FK)
├── type: 'expiry_warning_14d' | 'expiry_warning_3d' | ... | 'broadcast'
├── channel: 'push' | 'email'
├── sent_at
└── content_snapshot

broadcasts
├── id
├── created_by (admin id)
├── title, body, image_url
├── target_filter (json: tariff, status, tags, member_ids)
├── sent_at
└── recipients_count

audit_log
├── id
├── actor_id, action, target_type, target_id
├── metadata (json)
└── created_at

tariffs
├── id
├── name (string, např. "Standard 3 měsíce")
├── duration_days (int: 30, 90, 180)
├── price (int, Kč)
├── is_student (bool)
├── is_active (bool — deaktivované zůstávají u historických plateb, nejde vybrat při nové)
├── sort_order (int)
└── created_at

opening_hours
├── id
├── weekday (int 0–6, 0 = pondělí)
├── open_time (time, nullable — null = zavřeno)
├── close_time (time, nullable)
├── note (string, nullable — např. "do 14:00 jen pro členy")
└── updated_at
-- (jedna řádka per den; 7 řádků total, editovatelné z AdminMore)
-- pro mimořádné události (jednorázové zavření na revizi atd.) se používá nástěnka, typ `outage`

board_posts
├── id
├── author_id (FK členové, typicky majitel)
├── type: 'pinned' | 'outage' | 'warning' | 'promo' | 'event' | 'fixed' | 'info'
├── title (string)
├── body (text)
├── is_pinned (bool)
├── cta_label (string, nullable — např. "Sdílet pozvánku")
├── cta_action (string, nullable — např. "share_referral")
├── attachment_urls (array)
├── approved_by (FK admin, nullable — null = od majitele, vyplněno = od člena schváleného Oldou)
├── published_at (timestamp)
└── created_at

threads
├── id
├── member_id (FK)
├── created_at
└── updated_at (= timestamp poslední zprávy, pro řazení inboxu)

messages
├── id
├── thread_id (FK)
├── from_role: 'admin' | 'member'
├── body (text)
├── attachment_urls (array)
├── is_fault_report (bool, default false)
├── read_at (timestamp, nullable)
└── created_at

broadcasts
├── id
├── created_by (admin id)
├── title, body, image_url
├── target_filter (json: tariff, status, tags, member_ids)
├── sent_at
└── recipients_count

notification_preferences
├── member_id (FK, PK)
├── push_master (bool, default true)
├── push_outages (bool, default true)
├── push_promos (bool, default false)
├── theme: 'dark' | 'system' | 'light' (default 'dark')
├── language: 'cs' | 'en' (default 'cs')
└── updated_at
```

---

## 6. Obrazovky — minimální seznam

Číslování odpovídá Claude Design projektu **BýtFit Klub** (interní čísla obrazovek 01–13).

### Pro člena
1. **01 Splash + Onboarding** — uvítací obrazovka, login (e-mail + heslo), odkaz na registraci.
2. **02 Registrace** — formulář: jméno, příjmení, e-mail, telefon, výběr tarifu, upload ISIC pokud student, heslo, GDPR.
3. **03 Čekání na schválení** — neutrální obrazovka po registraci, instrukce.
4. **04 Member Dashboard** — pozdrav, velký stav členství ("Do posilovny můžeš ještě **23 dní**"), datum expirace, primární CTA "Prodloužit členství", sekundární "Nahlásit závadu" (otevírá bottom sheet 4.7), indikátor nepřečtených postů na nástěnce.
5. **05 QR Payment** — výběr tarifu z konfigurované tabulky `tariffs` (v MVP 4 tarify, ale **grid se přizpůsobí libovolnému počtu** — 2 sloupce pro 4 tarify, 3 sloupce pokud Olda přidá 6m / 12m varianty), velký QR, detaily platby, tlačítko "Zaplatil jsem".
6. **06 History** — historie aktivit, ne jen plateb. Typy: `pay` (platba), `key` (vydání/vrácení), `signup` (schválení registrace). Filtry chips, group by month, mini stats nahoře ("Zaplaceno celkem", "Člen od").
7. **07 Board (Nástěnka)** — viz sekce 4.6.
8. **08 Profile** — viz sekce 4.8 (notifikace, téma, jazyk, kontakt, členství, klíč, pomoc, odhlášení).
9. **09 Member Card** — fullscreen členská karta se jménem, stavem, datem, číslem klíče. Tlačítko Apple/Google Wallet (fáze 2).

**Member bottom nav (5 položek):** Domů (04) · Karta (09) · Historie (06) · Nástěnka (07) · Profil (08).

### Pro majitele (admin)
10. **10 Admin Dashboard** — top stats, "Vyžaduje pozornost" (čekající platby, registrace, propadlé kauce, končící), quick actions, graf příjmu.
11. **11 Member List** — filtrovatelný a vyhledávatelný seznam, barevné indikátory stavu, řazení.
12. **12 Member Detail** — všechny údaje, edit, sekce klíč + kauce, sekce platby, sekce komunikace (poslední vlákno), manuální platba, suspend, smazání.
13. **13 Approval Queue (Schvalování)** — fronta nových žadatelů. Karta: foto ISIC pokud student, data, tlačítka Schválit / Zamítnout.
14. **AdminPayments** — měsíční souhrn nahoře (aktuální měsíc + YTD), filtry stavu (Vše / Přijato / Čeká / Po lhůtě), vyhledávání, seznam plateb. Tlačítka přidat platbu (manuální) a export.
15. **AdminMessages** — inbox vláken 1:1 (viz 4.4 B). Nepřečtené nahoře, vyhledávání, FAB pro novou zprávu.
16. **AdminThread** — jedna konverzace, bubliny, kontextový header, šablony odpovědí podle stavu člena.
17. **AdminMore (Více)** — sekce Aktivita (schvalování, nástěnka, hromadná zpráva), Klub (tarify, otevírací doba, klíče, pravidla), Data (export CSV, záloha), Účet.
18. **AddMember** — manuální přidání člena majitelem (mimo standardní registraci přes app).
19. **Broadcast Composer** — výběr příjemců, editor, náhled, odeslat (vyvolá se z AdminMore nebo MemberList).
20. **Statistiky** (fáze 2 v plné formě) — měsíční příjem chart, počet aktivních v čase, retence, projekce.
21. **Excel Import Wizard** — viz sekce 8.

**Admin bottom nav (5 položek):** Domů (10) · Členové (11) · Platby (14) · Zprávy (15) · Více (17).

---

## 7. MVP scope vs. fáze 2

### MVP (musí být v první verzi)

- Registrace + schvalování členů (ApprovalQueue)
- Členské tarify (5 variant, konfigurovatelné v `tariffs`)
- QR platby (Spayd, CZ QR Platba) — 1m / 3m / 6m s indikací úspory
- Manuální potvrzení platby správcem (po notifikaci od člena "Zaplatil jsem")
- Stavy plateb: `pending` / `ok` / `overdue` + měsíční souhrn s YTD
- Automatické notifikace (–14, –3, 0, +1, +7, +30 dní)
- Push (FCM + APNs) s respektem k notification_preferences
- **Konverzace 1:1 majitel ↔ člen** (vlákna, šablony, vyhledávání) + **broadcast** všem
- **Nástěnka klubu (BoardScreen)** s typovanými posty (pinned, outage, warning, promo, event, fixed, info)
- **Hlášení závady** z member dashboardu (text + fotky → vlákno)
- **Notifikační preference** v profilu (push master, výpadky, promo, téma, jazyk)
- Členská karta (fullscreen)
- Správa klíčů a kaucí (kauce propadá po 30 dnech od neaktivity)
- Member List s filtry, vyhledáváním, řazením
- Member Detail s manuální platbou
- AddMember (manuální přidání člena majitelem)
- AdminMore s nastavením klubu (tarify, otevírací doba, pravidla)
- **Export plateb jako CSV** (i když Olda účetnictví neřeší — uvolnit data, kdyby je účetní vyžádala)
- Migrace z Excelu (jednorázový wizard) + průběžný re-import / kontrola dat
- Záloha databáze (denní automatická + manuální spuštění z UI)
- GDPR (souhlas, export, smazání)

### Fáze 2 (po validaci MVP)

- Automatické bankovní párování (až si Olda udělá v účtu pořádek nebo zařídí samostatný účet)
- Apple/Google Wallet karta (UI tlačítko už v MVP, ale neaktivní)
- **Referral program** — kód kamaráda, po jeho 3měsíční platbě +30 dní pro pozvavšího (post typu `promo` na nástěnce už existuje v MVP, ale share flow až tady)
- Tagy a slevové kódy
- Frozen membership (pauza)
- QR check-in pro evidenci docházky (statistiky vytíženosti)
- Daňový doklad / účtenka jako PDF (pokud někdo bude chtít)
- Stripe/GoPay pro kartové platby
- **Komentáře pod posty na nástěnce** (vyžaduje moderaci)
- **Auto-draft postů z hlášení závad** (FaultReport → návrh outage postu, který majitel zveřejní)
- Plné statistiky (chart příjmu 6m, retence, projekce)
- EN lokalizace

### Vyloučeno

- Sociální feed mezi členy (kromě nástěnky)
- AI trenér / tréninkové plány / motivační prvky
- Apple Health / wearables
- Rezervace strojů
- Online lekce / streaming
- Multi-tenant (více poboček)

---

## 8. Migrace z Excelu

**Aktuální stav:** Excel má 34 aktivních členů (k 15. 5. 2026), sloupce: **jméno (volný text), období (volný text, např. "KVĚTEN", "ČERVENEC-ČERVENEC", "SRPEN-červenec roční"), částka.**

**Specifika reálného Excelu:**

- Jména jsou v různém formátu: "Jméno Příjmení", "Příjmení Jméno", někdy s číslem na konci (např. "Smyčka 11.").
- **Číslo na konci jména = den v měsíci, ke kterému má člen platit další platbu** (vlastní billing_day). Pokud číslo chybí, člen platí od 1. dne měsíce.
- Z 34 členů má 13 vlastní billing_day (různá čísla 2–23), 19 platí od prvního.
- Období je nestrukturovaný text — značí měsíce, do kterých má člen zaplaceno. Někdy jeden měsíc ("KVĚTEN"), někdy rozsah ("ČERVENEC-ČERVENEC"), někdy slovní označení ("SRPEN-červenec roční" = doběh staré roční permice). Jednou se objevuje datum přímo v období ("červenec 26.") místo u jména.
- **Částky 1200, 1300, 1500, 1700 Kč** jsou doběhy starých tarifů (roční permice rozpočítaná po měsících, staré čtvrtletní ceny před přeceněním v únoru 2026). V nové aplikaci tyto tarify **nepoužívat** — postupně doběhnou a všichni přejdou na aktuální ceník.
- **Jeden záznam ("Kyselý") je speciální případ a do importu nepatří** — vyloučit ručně.

**Plán migrace:**

1. Správce v app otevře **wizard "Migrace dat z Excelu"** (one-time setup).
2. Nahraje Excel/CSV.
3. **Automatická pre-parsing fáze** — importér detekuje:
   - Jméno a příjmení (split z volného textu).
   - Číslo na konci jména → návrh `billing_day_of_month`.
   - Měsíc/období → návrh data expirace (poslední den uvedeného měsíce, kombinovaného s billing_day pokud existuje).
4. App ukáže každý řádek a požádá správce o **ruční potvrzení čtyř věcí**:
   - **Jméno + příjmení** (předvyplněno, správce upraví).
   - **Den platby v měsíci** (předvyplněno z čísla, nebo prázdné = od 1.).
   - **Datum expirace členství** (datepicker, předvyplněno na základě měsíce v Excelu a billing_day).
   - **Tarif této poslední platby** (dropdown: aktuální tarify + "Historický (doběh starého ceníku)" pro částky 1200/1300/1500/1700).
5. Pro každý potvrzený řádek se vytvoří:
   - `member` se statusem `inactive` (zatím bez e-mailu — historický záznam, e-mail si vyplní sám při registraci).
   - `payment` s historickou částkou, datem (přibližně, k 1. dni měsíce platby), označeno `is_historical = true`.
   - `membership_expires_at` = potvrzené datum, `billing_day_of_month` = potvrzený den.
   - `key_issued = true`, `deposit_paid = true` (předpoklad — všichni stávající členové mají klíč a zaplacenou kauci; správce může upravit u jednotlivců).
6. Po importu má kamarád **databázi 34 členů s nastavenými expiracemi a billing_day**. Postupně každého oslovuje (osobně, e-mailem) a vyzývá k registraci v app.
7. Při registraci nového účtu v app se podle jména a příjmení **navrhne spárování** s existujícím historickým záznamem. Správce schválí.
8. Po spárování člen vidí v historii svou poslední platbu (i historickou) a může pokračovat platit přes app.

**Časový odhad migrace:** pro 34 členů ~20–30 minut ručního průchodu wizardem. Jednorázová akce.

**Pole "is_historical" na platbě** je důležité kvůli statistikám — historické platby s necelými částkami by zkreslovaly měsíční reporty příjmů. V dashboardu se filtruje na "Pouze platby přes app" pro skutečný cash flow.

---

## 9. Vizuální systém (synchronizováno s Claude Design)

- **Charakter:** sebevědomá utilita, ne fitness-influencer estetika. Tmavé pozadí, kontrastní akcent, velká typografie pro stav členství.
- **Reference:** Revolut (jasnost dat), Fakturoid (klid, čeština jako prvotřídní občan), Linear (typografická čistota), Apple Wallet (vzor pro členskou kartu).
- **Tokeny (přesné, z `shared.jsx`):**
  - Pozadí: `#0F0F10`, surface `#1A1A1C`, surface2 `#232326`, border `#2A2A2D`, divider `#2A2A2D`
  - Text primární: `#F5F5F7`, sekundární `#8E8E93`, terciární `#5E5E63`
  - Akcent: `#FF4D2E` (CSS proměnná `--bf-accent`, tweakovatelné)
  - Stavy: `ok` `#34C759`, `warn` `#FFCC00`, `error` `#FF3B30`, `muted` šedá
  - Soft varianty: `okSoft`, `warnSoft`, `errorSoft`, `accentSoft` (14% alpha)
- **Typografie:**
  - **Inter** pro UI (váhy 400/500/600/700) — výborná čeština
  - **JetBrains Mono** pro čísla, datumy, kódy, variabilní symboly, identifikátory
  - Bez Roboto / SF Pro / Fraunces
- **Ikony:** Lucide-styled SVG (stroke 1.6, 24px viewBox). Žádné emoji v UI, ani v copy.
- **Tón komunikace:** Tykání, krátké věty, žádné korporátní formulace.
  - „Platí ti to ještě 8 dní." ne „Platnost vašeho členství vyprší za 8 dní."
  - „Můžeš ještě 23 dní" ne „Zbývá 23 dní"
  - Místo "uživatel" → **člen**. Místo "admin" → **majitel** nebo **Olda**.
- **Čísla a formátování:** Čísla a peníze česky: `2 250 Kč` (mezera jako oddělovač tisíců), datum `23. 6. 2026`.
- **Hit targety:** min. 44 px, text na mobilu min. 13 px, hlavičky 22–28 px, hero čísla 32–64 px.

---

## 10. Technický stack (doporučení)

- **Frontend:** Flutter (iOS + Android z jednoho codebase)
- **Backend:** Supabase (Postgres, Auth, Edge Functions, Realtime, Storage)
- **Push:** Firebase Cloud Messaging + APNs (přes Supabase Edge Function)
- **Hosting:** Supabase Cloud (EU region kvůli GDPR)
- **Monitoring:** Sentry pro chyby, Posthog pro produktovou analytiku (volitelné)

---

## 11. Rozhodnutí a omezení (vyplynulé z diskuze a designového procesu)

| Téma | Rozhodnutí |
|---|---|
| **Název aplikace** | **BýtFit Klub** (potvrzeno v designovém procesu). |
| **Majitel** | Pracovně "Olda" (Oldřich Klub) — v UI textech tykání, "napiš Oldovi". |
| **Bankovní párování** | Neřešit v MVP. Kamarád má účet "v bordelu" (smíšený osobní/posilovenský provoz). Místo toho: člen po platbě klikne "Zaplatil jsem", správce v app potvrdí přijetí ručně po kontrole ve své bance. Stavy plateb: `pending` / `ok` / `overdue`. |
| **Číslování klíčů** | Klíče nejsou číslované. Pole `key_number` v data modelu je volitelné (nullable), ale UI ho nevyžaduje. Evidence je per-člen "má klíč ano/ne". |
| **Účetnictví, faktury, účtenky** | Neřešíme jako primární funkci, ale **CSV export plateb je v MVP** (kdyby si o data jednorázově řekla účetní). Daňové doklady / Fakturoid integrace = případně fáze 2. |
| **Studentské ověření** | Stačí **jednorázové** při registraci (upload ISIC nebo studentského potvrzení). Neobnovuje se každý semestr. |
| **Multi-pobočka** | **Neřešíme.** Jedna posilovna, jednoduchá architektura bez tenant ID. |
| **App Store / Play Store** | Vyřešíme později. Pro MVP development lze testovat přes TestFlight (iOS) a internal testing track (Android). |
| **Excel po migraci** | Excel **zůstává v provozu jako pomocný nástroj** pro import a kontrolu dat. Kamarád ho lehce upraví — přidá sloupec s datem expirace — a tento upravený Excel slouží jako zdroj pravdy pro počáteční import a pro průběžnou kontrolu. **App musí podporovat re-import a porovnání s aktuálním stavem v databázi.** |
| **Komunikace** | Hybrid: **broadcast od majitele** + **1:1 konverzace** mezi majitelem a členem. Členové můžou taky psát majiteli (přes "Napsat Oldovi" v profilu nebo přes "Nahlásit závadu"). |
| **Nástěnka** | Centrální informační prostor klubu, 7 typů postů. Členové můžou navrhovat posty (typy `event`, `info`), majitel schvaluje před zveřejněním. |
| **Notifikace** | Granularita: master / výpadky / promo. Promo vypnuté výchozí (anti-spam). |
| **Otevírací doba** | Klub je samoobslužný **24/7 s fyzickým klíčem** pro členy. Editovatelné nastavení v AdminMore > Klub > Otevírací doba slouží jako **informace pro členy** (např. "kdy je Olda obvykle v Klubu", "kdy je doporučená doba bez návalu") a jako **vstup pro indikátor "otevřeno / zavřeno"** na nástěnce. Olda si nastaví sám, formát: po-ne s rozsahem od-do, případně "zavřeno". Změny logují do audit_logu. |
| **Vizuální systém** | Tmavé téma primární (#0F0F10), akcent #FF4D2E, Inter pro UI + JetBrains Mono pro čísla. |

## 11a. Re-import a kontrola dat z Excelu

Kamarád chce Excel používat i nadále jako "kontrolní vrstvu" — zapsat tam platbu rukou, importovat do app, porovnat.

**Požadavek:** v admin sekci "Migrace dat" musí být kromě úvodního importu i **opakovaný import** s těmito vlastnostmi:

1. Správce nahraje upravený Excel.
2. App spáruje řádky s existujícími členy (podle jména) — fuzzy match s ručním potvrzením u nejasných.
3. App ukáže **diff view**:
   - "V Excelu je platba, kterou app nezná" → návrh přidat
   - "App má platbu, kterou Excel nezná" → upozornění (možná správce zapomněl zapsat do Excelu)
   - "Datum expirace se liší" → návrh upravit
4. Správce schválí jednotlivé změny (checkbox u každého rozdílu) nebo "Schválit vše".
5. Audit log zaznamenává každý re-import.

**Praktický dopad:** během prvních měsíců provozu kamarád pravděpodobně bude pracovat paralelně v Excelu i v app. Re-import je můstek, aby se data nerozpadla. Po čase, až si zvykne, může Excel opustit.

---

## 12. Otevřené otázky k potvrzení s Oldou před implementací

1. **Akcentní barva** — návrh #FF4D2E (oranžovo-červená). Olda souhlasí, nebo má vlastní preferenci? Pokud má v Klubu nějakou výraznou barvu (cedule, dres, logo), použije se ta.

*Ostatní otázky vyřešeny:*
- ✅ 6měsíční tarif: zatím se nezavádí, ale UI je připravené na libovolný počet tarifů konfigurovaných v `tariffs`
- ✅ Student 3 měsíce: zůstává **1 950 Kč** (1 500 Kč v designu byla chyba designera)
- ✅ Otevírací doba: **editovatelná v AdminMore** (Olda si nastaví sám), klub je 24/7 pro členy s klíčem

---

## 13. Časový odhad (orientační)

- **MVP development:** 10–14 týdnů (rozšířeno o 2 týdny oproti původnímu odhadu kvůli přidaným funkcím: nástěnka, 1:1 chat, hlášení závad, notifikační preference)
- **Beta testing s kamarádem + 5–10 členy:** 2–4 týdny
- **Public launch:** ~4–5 měsíců od startu

Designová vrstva je z velké části hotová v Claude Design projektu — což ušetří ~2–3 týdny Figma práce.