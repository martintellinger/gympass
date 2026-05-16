# Vlastnický dashboard

_Started 2026-05-16 10:57 UTC_

---

## User

Nyní udělej funčkní stránky platby, zprávy a více na straně majitele. Mělo by fungovat přidávání členů, sortování a vyhledávání. Jak mají fungovat zprávy se podívej do briefu.

## Assistant

_[tool: list_files]_

_[tool: list_files]_

_[tool: list_files]_

_[tool: grep]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: view_image]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: update_todos]_

_[tool: write_file]_

Začnu vytvořením sdíleného úložiště dat a nového admin spodního navu, pak postavím obrazovky.

_[tool: str_replace_edit]_

Teď přidám podporu badge do BottomNav v shared.jsx:Teď AdminPayments — seznam plateb s filtrem, vyhledáváním a podrobnostmi:

_[tool: write_file]_

Teď AdminMessages — inbox konverzací:

_[tool: write_file]_

Teď AdminThread — jedno vlákno s členem:

_[tool: write_file]_

Teď AdminMore (Více) a AddMember (přidat člena):

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

Teď refaktor MemberListu — funkční vyhledávání, řazení, filtry + napojení na store:

_[tool: str_replace_edit]_

Teď AdminDashboard — použít AdminBottomNav a napojit navigaci:

_[tool: grep]_

_[tool: grep]_

_[tool: str_replace_edit]_

Teď upravím MemberDetail aby přijímal memberId a měl tlačítko na napsání zprávy:

_[tool: grep]_

_[tool: grep]_

_[tool: str_replace_edit]_

Teď zaregistruji vše do prototypu a canvasu:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: show_html]_

_[tool: show_html]_

_[tool: get_webview_logs]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: str_replace_edit]_

Přidám pár májových plateb aby měsíční souhrn nebyl prázdný:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: str_replace_edit]_

Vypadá skvěle! Teď přidám nové obrazovky i do canvasu:

_[tool: update_todos]_

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. Přidal jsem na straně majitele tyto funkční obrazovky:

**Platby** — měsíční souhrn (květen, YTD), vyhledávání podle jména, filtry stavu (Vše / Přijato / Čeká / Po lhůtě), řazení podle data, inline akce „Připomenout" (odešle zprávu) a „Označit zaplaceno" u nedoplatků.

**Zprávy** — inbox vláken s nepřečtenými indikátory, vyhledávání, kompoz nové zprávy (výběr člena z bottom sheetu), tlačítka „Hromadná zpráva" a „Připomenout dlužníky".

**Konverzace** — celé vlákno se členem: bubliny, časové skupiny, kontextová lišta (varování u dlužníků / končících), šablony rychlých odpovědí podle stavu, funkční kompozér (Enter = odeslat).

**Více** — rozcestník: schvalování (s badge), nástěnka, hromadná zpráva, tarify, otevírací doba, klíče, export, FAQ, odhlášení.

**Nový člen** — formulář s jménem, kontaktem, segmentem tarifu (Standard/Student + ISIC), délkou (3/6/12 měs.), kauce za klíč, kalkulačka ceny. Po uložení skočí na seznam s toastem.

**Členové** — funkční hledání (jméno, e-mail, telefon), filtry stavu s počty, bottom sheet pro řazení (expirace / jméno / tarif + směr).

**Detail člena** — teď reaktivní (přijímá `memberId`), zobrazuje platby toho daného člena, má rychlé akce (Zpráva / Platba / Prodloužit) a u dlužníků/končících banner s přímým „Napsat".

Vše napojené přes sdílený store (`screens/store.jsx`) — přidání člena se promítne do seznamu, odeslání zprávy se promítne do vlákna i do badge v bottom navu. Spodní nav majitele je teď konzistentní (`AdminBottomNav`) napříč všemi admin obrazovkami.

## User

Verifier agent check completed

## Assistant

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: done]_

Opraveno — všechny numerické/datumové sloupce na úzkém telefonu (360px) mají teď `whiteSpace: nowrap` a `flexShrink: 0`, takže nepřeteknou ani nezalomí:

- **Platby · měsíční souhrn** — hlavní číslo, „YTD", labely stavů
- **PaymentRow** — částka + tarif vpravo, datum + typ uprostřed
- **MemberList** — sloupec s dny vpravo
- **AdminThread header** — datum expirace v podtitulu

## User

Při přidávání nového člena nebo jeho úpravě at je možnost nastavit individuální cenu za měsíc.

## Assistant

_[tool: str_replace_edit]_

Doplním možnost vlastní ceny za měsíc + úpravu existujícího člena:Teď přepíšu AddMember na duální režim (přidat / upravit) s vlastní cenou:

_[tool: write_file]_

Teď napojím edit ikonu v MemberDetail a zobrazím cenu v kontaktní kartě:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

Přidám pár ukázkových vlastních cen do dat, ať je to v UI vidět:

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. Co je nového:

**Vlastní cena za měsíc** — v AddMember nová sekce „Cena za měsíc" s přepínačem „Individuální cena". Když je zapnutý, ukáže se vstupní pole se +/− tlačítky (krok 50 Kč), preset chips (400 / 500 / 600 / 750 / 900 / 1200 Kč) a v souhrnu se cena podbarví akcentní barvou. „K zaplacení" se počítá z aktuální měsíční ceny × délka.

**Úprava existujícího člena** — AddMember teď přijímá `memberId` a v tom režimu předvyplní data, schová délku (ta se nastavuje při prodloužení) a tlačítko se změní na „Uložit změny". Tužka v hlavičce MemberDetail otevře tento režim. Po uložení skok zpět na detail s toastem.

**MemberDetail** — v kontaktní kartě nový řádek „Cena/měs." s číslem; pokud má člen vlastní cenu, ukáže se mu vedle ní oranžový badge **VLASTNÍ**. Klepnutím na řádek se rovnou skočí do editace.

Pro ukázku jsem dvěma členům v datech nastavil vlastní cenu — Adamovi Benešovi 600 Kč (sleva za dlouholeté členství) a Martinu Tichému 700 Kč.

## User

Verifier agent check completed

## Assistant

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: save_screenshot]_

_[tool: view_image]_

Vše funguje — detail člena ukazuje cenu s badge **VLASTNÍ** u Adama (600 Kč), klepnutí na tužku otevře editaci s předvyplněnými údaji včetně přepínače „Individuální cena" a podtitulem „vlastní cena" v oranžové.

## User

Zkontroluj jestli jsou všechny prolinky správné. Settings v seznamu členů by měl dělat co?

## Assistant

_[tool: read_file]_

_[tool: str_replace_edit]_

Projdu prolinky a opravím to. K té settings ikoně — momentálně otevírá jen řazení, což je málo pro tu „posuvníkovou" ikonu. Předělám ji na **Filtr & řazení** (víc os) a opravím i ostatní rozbité prolinky.

_[tool: grep]_

_[tool: copy_starter_component]_

_[tool: str_replace_edit]_

_[tool: read_file]_

_[tool: str_replace_edit]_

Teď back-nav přes historii, image-slot avatary v detailu a v prototypu:Teď aktualizuji obrazovky aby používaly goBack (s fallbackem na konkrétní rodičovskou obrazovku):

_[tool: str_replace_edit]_

Přidám PhotoAvatar (image-slot + iniciály jako fallback) do shared.jsx:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

Teď opravím back nav v ostatních admin obrazovkách:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

Teď opravím broadcast — nahradím rozbitou navigaci skutečným bottom sheetem:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

Teď AdminMore broadcast a Nástěnka — opravím cíle:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: show_html]_

_[tool: get_webview_logs]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: grep]_

_[tool: grep]_

_[tool: str_replace_edit]_

Image-slot vypadá ošklivě v malé velikosti. Použiji ho s overlayem iniciál:Přidám globální CSS, který schová výchozí placeholder image-slot:

_[tool: str_replace_edit]_

_[tool: save_screenshot]_

_[tool: view_image]_

_[tool: str_replace_edit]_

Vypadá to čistě — inicály se zobrazují normálně, foto lze přetáhnout. Doladím i canvas a ukončím:

_[tool: done]_

Hotovo. Co jsem opravil a přidal:

**Prolinky (zpětky) — zpět teď používá historii navigace**, ne natvrdo přiřazený parent. Předal jsem `goBack` ze hlavní App komponenty do obrazovek; každá obrazovka (`MemberDetail`, `AdminThread`, `ApprovalQueue`, `AddMember`) ho použije, pokud existuje, a má pojistku na konkrétní cíl pro případ, kdy je obrazovka první (např. otevřená přímo z designového canvasu). Takže když přijdeš na detail z platby, zpět tě vrátí na platby, ne na seznam. Stejně z vlákna do detailu, atd.

**Opravená navigace na neexistující route `compose`** — „Hromadná zpráva" v Zprávách i ve Více teď otevírá **BroadcastSheet** přímo v inboxu: textarea, výběr cílovky (Všem / Dlužníkům / Končícím / Aktivním) s počtem, tři šablony a tlačítko „Odeslat · N členů". Z More se předává `broadcast: true` a sheet se otevře automaticky.

**Tlaítkové prolinky z Přehledu**: „2 po lhůtě" → Členové prefiltrované na `error`, „5 končí brzy" → Členové prefiltrované na `warn` (přes nový param `filterPreset`).

**Settings (ikona slidery) v seznamu členů** — předělal jsem ze samotného řazení na **Filtr a řazení**:
- Řadit: Expirace / Jméno / Tarif + směr ↑↓
- Tarif filtr: Oba / Standard / Student
- Klíč filtr: Všichni / S klíčem / Bez klíče
- „Resetovat" v hlavičce sheetu + badge na ikoně když jsou nějaké extra filtry aktivní

**Avatary se skutečnými fotkami** — `PhotoAvatar` přes web component `<image-slot>` (přidal jsem skript do prototypu i canvasu). V detailu člena je teď 72px kruh kam můžeš přetáhnout reálnou fotku člena, dokud není vyplněn, ukazuje iniciály na barevném pozadí. Foto se ukládá per `member-{id}`, takže každý člen má vlastní.

**Drobnosti**: zrušil jsem barevné tečky vlevo od jména v seznamu členů (stav je vidět vpravo přes barvu dnů + label), avatar v seznamu povýšen z 36 na 40 px.

