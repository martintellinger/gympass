# Wallet integrace omezení

_Started 2026-05-15 14:04 UTC_

---

## User

<system-info comment="Only acknowledge these if relevant">
Project title is now "GymPass"
Current date is now May 15, 2026
</system-info>

<default aesthetic>
If no references, art direction or design systems were provided, use this default professional modern, minimal aesthetic as a base. Declare your choice out loud so you stick to it. Guidance:
- Choose a type pairing from web-safe set or Google Fonts. Helvetica is a good choice. Avoid hard-to-read or overly stylized fonts. Use 1-3 fonts only.
- Foreground and background: choose a color tone (warm, cool, neutral, something in-between). Use subtly-toned whites and blacks; avoid saturations above 0.02 for whites.
- Accents: choose 0-2 additional accent colors using oklch. All accents should share same chroma and lightness; vary hue.
- NEVER write out an SVG yourself that's more complicated than a square, circle, diamond, etc.
- For imagery, never hand-draw SVGs; use subtly-striped SVG placeholders instead with monospace explainers for what should be dropped there (e.g. “product shot”)

CRITICAL: ignore default aesthetic entirely if given other aesthetic instructions like reference images, design systems or guidance, or if there are files in the project already.
</default aesthetic>

<attached_files>
- uploads/CleanShot 2026-05-15 at 16.04.33@2x.jpg
</attached_files>

<pasted_text name="Pasted text (269 lines)">
# Design brief — Aplikace pro správu členství v posilovně

**Pro:** Claude Design
**Od:** Martin Tellinger
**Datum:** květen 2026
**Deliverable:** Figma návrh klíčových obrazovek mobilní aplikace (iOS + Android), v češtině

---

## 1. Co designuješ

Mobilní aplikaci pro **samoobslužnou posilovnu** s 34 členy. Nahradí Excel, ve kterém majitel teď vede platby a expirace členství.

**Dva typy uživatele v jedné aplikaci:**
- **Člen** — vidí svoje členství, platí QR kódem, dostává oznámení.
- **Majitel (admin)** — vidí všechny členy, schvaluje registrace, posílá hromadné zprávy, řeší klíče a kauce. Stejná app, jiná role po přihlášení.

Platformy: iOS + Android (jeden codebase, Flutter).

---

## 2. Vibe & tón

**Není to fitness app.** Žádné svaly, žádné motivační citáty, žádné gradient overlay přes fotku vzpěrače. Je to **utilita na správu členství** — bližší Revolutu / Fakturoidu než Strava nebo Nike Run Club.

Charakter: **klidný, sebejistý, česky.** Tykání, krátké věty, žádné korporátní formulace.

> Místo: „Platnost vašeho členství vyprší za 8 dní."
> Použij: „Platí ti to ještě 8 dní."

> Místo: „Proveďte úhradu členského příspěvku."
> Použij: „Zaplať a pokračuj cvičit."

**Reference, kterými se inspiruj:**
- **Revolut** — jasnost dat, velká primární akce, žádný balast
- **Fakturoid** — čeština jako prvotřídní jazyk, ne přeložená angličtina
- **Linear** — typografická čistota, hustota informací bez chaosu
- **Apple Wallet** — vzor pro členskou kartu

**Čemu se vyhni:**
- Stock fotky lidí ve fitku
- Žluto-černé „motivační" estetiky
- Heavy gradienty, glow efekty, 3D ikony
- Emoji jako designový prvek
- Anglicismy v UI textech

---

## 3. Barevný systém

**Tmavé téma jako primární** (lidi se na to dívají v posilovně i pozdě večer, OLED šetří baterii).

| Role | Barva | Použití |
|---|---|---|
| Pozadí | #0F0F10 | Hlavní pozadí (ne čistá černá) |
| Surface | #1A1A1C | Karty, sekce |
| Border / divider | #2A2A2D | Jemné oddělení |
| Text primární | #F5F5F7 | Hlavní text |
| Text sekundární | #8E8E93 | Popisky, metadata |
| Akcent | **#FF4D2E** (oranžovo-červená) — návrh, k diskuzi | Primární CTA, indikátory aktivního stavu |
| Stav OK | #34C759 | Členství aktivní, platba prošla |
| Stav warning | #FFCC00 | Členství brzy končí (≤7 dní) |
| Stav error | #FF3B30 | Expirováno, neplaceno, propadlá kauce |

Světlé téma připrav jako variantu, ale primární návrh je dark.

---

## 4. Typografie

**Inter** (volně dostupný, výborná čeština vč. háčků a čárek).

| Styl | Velikost | Váha | Použití |
|---|---|---|---|
| Display | 48 px | Bold | Velký stav členství na dashboardu („Platí ti to 23 dní") |
| Title 1 | 28 px | Semibold | Hlavičky obrazovek |
| Title 2 | 22 px | Semibold | Sekce |
| Body | 17 px | Regular | Hlavní text |
| Caption | 13 px | Regular | Metadata, datumy |
| Mono | 15 px | Medium | Variabilní symbol, čísla účtu |

---

## 5. Obrazovky k navržení (priority MVP)

### A. Pro člena

1. **Onboarding / login** — uvítací obrazovka, login (e-mail + heslo) + odkaz na registraci.
2. **Registrace** — formulář: jméno, příjmení, e-mail, telefon, výběr tarifu (standard / student), upload ISIC pokud student, heslo, GDPR souhlas.
3. **Čekání na schválení** — neutrální obrazovka po registraci, vysvětlení dalšího kroku, instrukce „vyzvedni si klíč u majitele."
4. **Dashboard (hlavní obrazovka člena)** — viz detail níže.
5. **Prodloužení členství** — výběr tarifu (1m / 3m), zobrazení QR kódu k platbě s instrukcemi a stavem (čeká / přijato).
6. **Historie plateb** — chronologický seznam, každá platba s PDF dokladem ke stažení.
7. **Oznámení** — feed zpráv od majitele (mimořádné zavření, novinky).
8. **Profil** — osobní údaje, jazyk, GDPR export, smazání účtu, odhlášení.
9. **Členská karta** — fullscreen view se jménem, stavem (zelená/žlutá/červená), datem expirace. Tlačítko „Přidat do Apple/Google Wallet".

### B. Pro majitele

10. **Dashboard admina** — viz detail níže.
11. **Seznam členů** — filtrovatelný (stav, tarif), řadit (expirace, abeceda), vyhledat. Barevné indikátory u každého řádku.
12. **Detail člena** — všechny údaje, edit, sekce klíč + kauce, sekce platby, manuální platba, suspend, smazání.
13. **Schvalování registrací** — fronta nových žadatelů. Karta s daty + ISIC fotkou (pokud student) + tlačítka Schválit / Zamítnout.
14. **Hromadná zpráva** — výběr cílové skupiny, editor titulku a textu, náhled, odeslat.
15. **Statistiky** — měsíční příjem (chart), počet aktivních v čase, projekce příjmu na další měsíc.
16. **Migrace z Excelu** — wizard pro jednorázový import. Tabulkový view s 34 řádky, pro každý řádek pole: jméno, billing_day, datum expirace, tarif. Potvrď / Přeskoč.

**Priorita pro první iteraci:** 4, 5, 9, 10, 11, 12, 13. Zbytek druhá iterace.

---

## 6. Dashboard člena — detail

Nejdůležitější obrazovka v aplikaci. Otevírá ji člen, aby zjistil dvě věci: **kolik mu zbývá** a **kdy musí znovu zaplatit**.

**Hierarchie shora dolů:**

1. **Pozdrav** — „Ahoj, Pavle." (16 px, sekundární barva)
2. **Velký stav** — display typografie:
   - Pokud aktivní: „Platí ti to **23 dní**" (číslo akcentně, zbytek bílé)
   - Pokud ≤ 7 dní: „Platí ti to **3 dny**" (číslo žluté)
   - Pokud expirováno: „Členství vypršelo **před 2 dny**" (červené)
3. **Datum expirace** (menší, sekundární) — „do 23. 6. 2026"
4. **Primární tlačítko** — „Prodloužit členství" (full-width, akcentní barva). Pokud zbývá hodně dní, lze ho zmenšit / udělat sekundární.
5. **Karta „Tvoje karta"** — náhled členské karty (jméno, stav, číslo klíče), tap → fullscreen.
6. **Sekce „Poslední aktivity"** — 2–3 poslední platby s datem a částkou.
7. **Sekce „Oznámení"** — pokud je nepřečtené, badge + nejnovější.

**Bottom navigation:**
- Domů (dashboard)
- Karta
- Historie
- Oznámení
- Profil

---

## 7. Dashboard majitele — detail

Otevírá ho denně a chce vědět: **kdo dluží, kdo končí, je něco urgentního.**

**Hierarchie shora dolů:**

1. **Top stats — 4 dlaždice v gridu 2×2:**
   - Aktivních členů: **34**
   - Končí do 7 dní: **5** (žlutě)
   - Po lhůtě: **2** (červeně)
   - Příjem tento měsíc: **28 950 Kč**
2. **Sekce „Vyžaduje pozornost"** — actionable seznam:
   - 2 čekající registrace → tap vede na schvalování
   - 2 propadlé kauce → tap vede na detail
   - 5 končí brzy → tap vede na filtrovaný seznam
3. **Quick actions** — 3 ikony v řadě:
   - „Poslat zprávu" (hromadná komunikace)
   - „Přidat platbu" (manuální evidence cash platby)
   - „Přidat člena" (manuální registrace)
4. **Graf příjmu** — sloupcový chart, posledních 6 měsíců.

**Bottom navigation pro admina:**
- Dashboard
- Členové
- Platby
- Zprávy
- Více (statistiky, nastavení, migrace)

---

## 8. Stavy členství — vizuální systém

Přes celou app musí být **konzistentní vizuální language** pro 4 stavy:

| Stav | Barva | Label | Význam |
|---|---|---|---|
| Aktivní | Zelená #34C759 | „Aktivní" | Platí, zbývá > 7 dní |
| Brzy končí | Žlutá #FFCC00 | „Končí za X dní" | Platí, zbývá ≤ 7 dní |
| Expirováno | Červená #FF3B30 | „Vypršelo" | 0–30 dní po expiraci |
| Suspended | Šedá #8E8E93 | „Pozastaveno" | 30+ dní po expiraci, vč. propadlé kauce |

**Použití:** tečka / pill / badge u jména v seznamu, barva display textu na dashboardu, ikona u karty.

---

## 9. QR platba — speciální obrazovka

Klíčový moment v celé aplikaci. Člen sem dojde, naskenuje QR ze své banky, zaplatí.

**Layout:**

1. Headline: „Naskenuj QR ve své bance"
2. **QR kód** — velký, vystředěný, na bílém pozadí (i v dark módu — banka potřebuje kontrast pro skener).
3. **Detaily platby** pod QR:
   - Částka: **2 250 Kč**
   - Účet: 1234567890/0100
   - VS: 240001
   - Zpráva: Členství Pavel Novák
4. **Sekundární akce:** „Zkopírovat údaje" pro lidi, co QR neumí.
5. **Stav v reálném čase** — „⏳ Čekáme na platbu…" → po spárování animace + „✓ Platba přijata. Členství prodlouženo do 23. 7. 2026."

QR kód obsahuje **CZ QR Platba formát (Spayd)** — fungují všechny české banky včetně Revolutu.

---

## 10. Klíčové detaily, na které se nesmí zapomenout

- **Apple Wallet / Google Wallet tlačítko** na obrazovce karty (fáze 2, ale připrav UI prvek).
- **Pull-to-refresh** všude, kde je seznam.
- **Empty states** — když nemá oznámení, nemá platby. Krátký, lehce vtipný copy.
- **Loading states** — skeleton, ne spinner.
- **Error states** — žádné „Něco se pokazilo." Konkrétně: „Nepodařilo se načíst členy. Zkontroluj internet a zkus znovu."
- **Toasts pro feedback** — po každé akci (uloženo, odesláno, smazáno).
- **Confirmation modaly** jen u nevratných akcí (smazat člena, propadnout kauci).
- **Haptic feedback** na primární akce (Flutter podporuje).

---

## 11. Klíče a kauce — speciální UI patterns

V detailu člena pro admina musí být **jasný panel „Klíč"**:

- Stav: **Vydán** (datum) / **Vrácen** (datum) / **Nevrácen po lhůtě**
- Číslo klíče (volitelně, pokud má číslované)
- Stav kauce: **Přijata** (100 Kč) / **Vrácena** (datum) / **Propadla** (datum)
- Tlačítka kontextově:
  - Pokud vydán, členství končí → „Označit jako vrácený + vrátit kauci"
  - Pokud 30+ dní po expiraci → „Propadnout kauci" (s confirmation)

V seznamu členů použij **ikonu klíče** s barevným indikátorem jako sekundární info — admin na první pohled vidí, kdo má klíč doma a komu by neměl chodit.

---

## 12. Co nedělat (deliverable scope)

V první iteraci **nenavrhuj:**

- Sociální features mezi členy (chat, profily, friend list)
- Tréninkové plány nebo cvičení
- Rezervace strojů
- Online lekce
- Wearables integrace
- Multi-jazyk (zatím jen čeština)
- Onboarding tutoriály

---

## 13. Deliverable formát

- **Figma file** se sekcemi: Foundations (barvy, typo, komponenty), Member screens, Admin screens, Flows (registrace → schválení, expirace → platba).
- **Prototyp** pro klíčové flow: registrace, prodloužení s QR, schvalování v adminovi.
- **Light verze** komponentů jako alternativa.
- **Iconography** — používej Lucide nebo Phosphor (open-source, konzistentní).

---

## 14. Otevřené otázky pro design

1. **Akcentní barva** — návrh #FF4D2E je první iterace. Stojí za to vygenerovat 3 varianty (oranžová, fialová, žlutá) a Martin vybere.
2. **Logo / název aplikace** — zatím není. Pracovní název „Klubovna" nebo „GymPass" — k diskuzi.
3. **Onboarding tour** — krátký 3-screen swipe nebo žádný? Doporučení: žádný, app je dost jednoduchá.
4. **Ilustrace** — empty states a onboarding bez ilustrací (jen typografie), nebo s minimální monoline?

---

## Kontext, který bys mohl chtít

- Celkem 34 členů (k 5/2026), suma měsíčního příjmu ~28 950 Kč.
- Tarify: 850 Kč/měsíc, 2 250 Kč/3 měsíce, studenti 750 / 1 950.
- Kauce za klíč 100 Kč, propadá po 30 dnech od neaktivity.
- Každý člen má vlastní „billing day" (den v měsíci splatnosti).
- Pro plnou produktovou specifikaci viz samostatný dokument `gym-app-brief.md` (architektura, data model, technický stack).
</pasted_text>

<!-- The user explicitly selected the following skills for this project, as attachments to their message. These are not optional context — they define how you work. Use them. -->
<attached-skill name="Hi-fi design">
Create a high-fidelity, polished design. Follow the instructions about design in your system prompt, particularly the 'How to do design work' section. Use the design_canvas starter component, or make a full-bleed prototype and offer options via Tweaks.
</attached-skill>

<attached-skill name="Interactive prototype">
Create a fully interactive prototype with realistic state management and transitions. Use React useState/useEffect for dynamic behavior. Include hover states, click interactions, form validation, animated transitions, and multi-step navigation flows. It should feel like a real working app, not a static mockup.
</attached-skill>


<system-reminder>Auto-injected reminder (ignore if not relevant): do not recreate copyrighted or branded UI unless the user's email domain matches that company. Create original designs instead.</system-reminder>

## Assistant

_[tool: view_image]_

_[tool: update_todos]_

Mám detailní brief, jdu rovnou stavět. Návrh designu:

- **Vizuální systém:** dark theme #0F0F10 / surface #1A1A1C / akcent #FF4D2E (s tweaks variantou žluté a fialové), Inter pro UI, JetBrains Mono pro čísla
- **Brand:** "BýtFit Klub" podle dodaného loga
- **Layout:** design canvas s iOS frame, sedm priority obrazovek (4, 5, 9, 10, 11, 12, 13)
- **Mikro-detaily:** klidná typografie ve stylu Linear, krátké české věty, žádné motivační vibe
- **Tweaks:** akcentní barva (3 varianty), light/dark theme, hustota

_[tool: copy_starter_component]_

_[tool: copy_starter_component]_

_[tool: copy_starter_component]_

_[tool: copy_files]_

_[tool: grep]_

_[tool: grep]_

_[tool: read_file]_

_[tool: write_file]_

Teď napíšu shared tokens a ikony — pak postupně každou obrazovku.

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

_[tool: grep]_

_[tool: str_replace_edit]_

_[tool: done]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. **7 priority obrazovek MVP** na design canvasu:

**Pro člena (4 · 5 · 9):** Dashboard se status countdown · QR platba (SPAYD) s live čekáním · Plnoobrazovková karta s Apple/Google Wallet CTA.

**Pro majitele (10 · 11 · 12 · 13):** Přehled s 2×2 statama a sloupcovým grafem · Seznam členů (12 fiktivních, barevné dots + ISIC tagy + ikony klíče) · Detail člena s panelem klíč/kauce · Schvalování s ISIC náhledem a sticky action barem.

**Vizuální systém:** dark #0F0F10 jako základ, Inter pro UI, JetBrains Mono pro čísla a kódy, status dots/pills použité konzistentně přes celou app. Žádné svaly, žádné motivační citáty.

**Tweaks → Akcentní barva:** 4 varianty (oranžovo-červená podle briefu, žlutá, fialová, zelená) — uloží se napříč obrazovkami.

**Co můžeš chtít dál:** zbývající obrazovky druhé iterace (registrace, historie plateb, hromadná zpráva, statistiky, migrace z Excelu), light theme variantu, nebo flow prototyp (registrace → schválení).

## User

přidávání do apple wallet nebo google wallet nedělej. Klíče číslovat nebudeme.

Místo textu platí ti to ještě dáme: Do posilovny můžeš ještě.

Prodloužení QR nebude žádný status čekáme na platbu, to nemáme jak zjistit.

## Assistant

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: done]_

Hotovo. Změny:

- **Wallet tlačítka** pryč z karty (zůstal jen tip o jasu obrazovky)
- **Klíče bez čísel** — všude jen ikona klíče + „klíč u tebe" / „u člena" / „bez klíče"
- **Dashboard:** „Do posilovny můžeš ještě **23** dní"
- **QR platba** — žádný live status, jen QR + údaje + tlačítko zkopírovat

## User

Přidej možnost QR kod si stáhnout do mobilu

## Assistant

_[tool: read_file]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: done]_

Hotovo. Pod QR jsou teď dvě tlačítka vedle sebe — **Uložit QR** (do Fotek) a **Zkopírovat** údaje — a pod tím malá nápověda, jak ho v bance otevřít přes „Naskenovat ze souboru".

## User

no a potrebuju vidět cely screen obrazovek nejenom ty kousky co se vlezou na viewport

## Assistant

_[tool: str_replace_edit]_

Jasně — uvolním rámeček telefonu, ať každá obrazovka vyroste do plné výšky obsahu.

_[tool: run_script]_

_[tool: str_replace_edit]_

_[tool: done]_

_[tool: fork_verifier_agent]_

Telefony teď nemají vlastní scroll — každá obrazovka vyrostla na svou plnou výšku, takže vidíš celý obsah najednou (status bar nahoře, bottom nav / action bar dole).

## User

Verifier agent check completed

## Assistant

Verifier potvrdil — všechno v pořádku. ✓

## User

Potrebuju z toho udelat klikaci aplikaci, prototyp.

## User

Udelas?

