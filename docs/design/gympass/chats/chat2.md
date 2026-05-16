# Interaktivní prototyp

_Started 2026-05-15 17:56 UTC_

---

## User

Potrebuji z toho udělat klikatelny prototyp

## Assistant

_[tool: list_files]_

_[tool: list_files]_

_[tool: list_files]_

_[tool: list_files]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

_[tool: read_file]_

Skvělé! Mám všechen kontext. Teď vytvořím klikatelný prototyp.

Plán:
- Vytvořím `BýtFit Klub - Prototyp.html` s navigačním systémem (router přes `useState`)
- Dvě sekce: **Člen** (Dashboard → QR platba → Karta) a **Admin** (Přehled → Seznam → Detail / Schvalování)
- Místo Design Canvasu jeden telefon, který přepíná obrazovky s plynulou animací
- Switcher Člen/Admin nahoře vedle telefonu (mimo bezel, aby šel ovládat)
- Klikatelné akce: tlačítka, bottom nav, řádky v seznamech, zpět-tlačítka, schválení/odmítnutí

Nejprve se podívám na zbylé screeny, ať vím, co kde linkovat.

_[tool: str_replace_edit]_

Plán je jasný. Vytvořím samostatný soubor `BýtFit Klub - Prototyp.html` s navigačním systémem, který obrazovky propojí. Existující obrazovky upravím minimálně — přidám prop `onNav` s no-op defaultem, takže původní canvas zůstane funkční.

Začnu úpravami v `shared.jsx` (přidám `onClick` na `Btn` a `onItemClick` na `BottomNav`):Teď upravím jednotlivé obrazovky, aby přijímaly `onNav`:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: write_file]_

Teď vytvořím samotný prototyp:

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. Klikatelný prototyp `BýtFit Klub - Prototyp.html`:

- **Telefon uprostřed** s plynulým přechodem mezi obrazovkami
- **Vlevo persona switcher** Člen / Majitel + seznam obrazovek pro skok kamkoli + reset
- **Vpravo legenda hotspotů** + tlačítko zpět + dráha (breadcrumb)
- **Klikatelné akce** v telefonu:
  - Člen: *Prodloužit členství* → QR · *Tvoje karta* → karta · spodní nav *Karta*
  - QR/Karta: zpět/X → dashboard
  - Admin: *Čekající registrace* → schvalování · *Propadlé kauce / Končí brzy* → seznam · spodní nav *Členové*
  - Seznam: jakýkoliv řádek → detail · spodní nav *Přehled* → admin
  - Schvalování: *Schválit / Zamítnout* → admin s toastem
- **Klávesy**: `1` člen · `2` majitel · `Esc` zpět
- Tweak akcentní barvy zůstal funkční

Existující `BýtFit Klub.html` (design canvas) se nerozbil — obrazovky dostaly volitelný `onNav` prop s no-op defaultem.

## User

Verifier agent check completed

## Assistant

Verifier potvrdil, že prototyp funguje. Můžeš si projít flow přes telefon, persona switcher vlevo nebo skok přímo na obrazovku v seznamu.

## User

Udělej i funkční přepínání tarifu, podle toho se přegeneruje QR kod.

dodělej funkční záložky historie, oznameni a profil.

V menu místo oznámení dáme položku nástěnka, kde budou zprávy z posilovny, co je noveho, co zrovna nefunguje, na co je potřeba dát pozor, akce a slevy, apod

## Assistant

_[tool: str_replace_edit]_

Plán:
1. **QR**: stav tarifu — překreslí QR, částku i VS
2. **Nový screen**: Historie · Nástěnka · Profil
3. **Bottom nav** přepíše "Oznámení" → "Nástěnka", všechny záložky funkční

Začnu úpravami:

_[tool: write_file]_

Teď QRPayment — interaktivní výběr tarifu:Teď MemberDashboard — bottom nav přepojím na router přes `MemberBottomNav`:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: read_file]_

_[tool: str_replace_edit]_

_[tool: read_file]_

_[tool: str_replace_edit]_

Teď tři nové obrazovky:

_[tool: write_file]_

_[tool: write_file]_

_[tool: write_file]_

Teď propojím nové obrazovky do prototypu:

_[tool: str_replace_edit]_

_[tool: grep]_

_[tool: read_file]_

_[tool: str_replace_edit]_

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. Co je nového:

**QR platba** — tři klikatelné tarify (1 / 3 / 6 měsíců). Při přepnutí:
- překreslí se QR (jiný vzor pro každý tarif)
- aktualizuje se Částka, VS a popisek pod QR
- subtle fade animace

**Tři nové obrazovky** napojené přes spodní nav:
- **Historie** — všechny platby/klíč/účet seskupené po měsících, filtr chipsy (Vše, Platby, Klíč, Účet), souhrn nahoře (zaplaceno, člen od)
- **Nástěnka** — zprávy z posilovny: výpadky (Bench mimo provoz), akce (doporuč kamaráda), události (společné běhání), varování, opravy. Připnutý post nahoře (zítra zavřeno do 14:00), filtr podle typu, barevně rozlišené štítky
- **Profil** — kontakt, členství s klíčem, notifikace s funkčními switche, segmenty pro téma/jazyk, FAQ, odhlásit

**Bottom nav** je teď plně funkční pro všechny členské obrazovky (Domů · Karta · Historie · Nástěnka · Profil) a "Oznámení" → "Nástěnka". Na dashboardu místo bell ikony nahoře nástěnka s notification dotem; náhled nejnovějšího pinnutého postu místo bývalého oznámení.

## User

Máš kontext soubor claude.md? Nepotřebuješ ho vytvořit at se ti lepe pracuje?

## Assistant

Dobrý nápad — `CLAUDE.md` načítám automaticky na začátku každého chatu, takže tam mít projektové konvence šetří mi to čas a tobě tokeny (nemusím se v každé úloze rozkoukávat).

Co bych tam pro GymPass dal:

- **Kontext produktu** — malá privátní posilovna (~34 členů), majitel Martin, mobil-first Flutter app na správu členství. Ne fitness app.
- **Jazyk** — všechno česky, tykání, ne "uživatel" ale "ty / člen".
- **Design systém** — tokens v `screens/shared.jsx` (T, Icons, StatusBar, MemberBottomNav, Card, Btn, QRCode, Avatar), dark first, Inter pro UI, JetBrains Mono pro čísla, status: ok/warn/error/muted.
- **Struktura** — `BýtFit Klub.html` = design canvas (všechno vedle sebe), `BýtFit Klub - Prototyp.html` = klikatelný prototyp, obrazovky v `screens/`. Akcent přes CSS var `--bf-accent`.
- **Konvence pro nové obrazovky** — prop `onNav = () => {}`, registrovat v `SCREENS` + `FLOW` v prototypu, případně přidat artboard do canvasu, member screens používají `MemberBottomNav`.
- **Co tam ne** — žádné svaly, žádné fitness coachingové prvky, žádné AI features.

Mám ho vytvořit? Pokud máš preference (jiný tón, jiné no-go, branding rules), napiš a zařadím to.

## User

/init

## Assistant

_[tool: write_file]_

Hotovo. `CLAUDE.md` načtu automaticky při každém novém chatu v tomhle projektu. Obsahuje:

- **Produktový kontext** + tón (česky, tykání, ne fitness app)
- **Vizuální systém** — tokeny, barvy, fonty, hit targety
- **Strukturu projektu** — kde co leží, k čemu slouží
- **Sdílené primitivy** v `shared.jsx`
- **Konvence pro nové obrazovky** — 7 kroků checklist (onNav, registrace v prototypu i canvasu, member nav…)
- **Co nikdy nedělat** — no emoji, no fitness/AI, no anglické copy
- **Co dělat opatrně** — shared.jsx, sync mezi canvasem a prototypem

Pokud chceš něco doplnit (např. konkrétní brand pravidla, jména/role v týmu, specifika z briefu, deadliny pro MVP), klidně mi to napiš a doplním. Stejně tak pokud je něco navíc — vyhoď si to.

## User

Změň jméno správce z Martin na Olda

## Assistant

_[tool: grep]_

_[tool: run_script]_

Přejmenuju všude kromě člena Martin Tichý (to je jiná osoba):

_[tool: grep]_

Přejmenováno všude — autor postů na nástěnce, pozdrav v admin přehledu, tip na členské kartě, kontakt v profilu, historie. Skloňování: vokativ "Oldo", dativ "Oldovi".

`Martin Tichý` v seznamu členů zůstal — to je jiná osoba (člen Klubu).

## User

Přidej funkce na homescreen nahlášení poruchy / závady. Členové tam budou mít formulář přes který můžou napsat, když se něco pokazí nebo nefunguje.

Jednoduchý input text a možnost nahrát fotky. Formulář vyskočí do bottom sheetu.

## Assistant

_[tool: write_file]_

Vytvořím bottom sheet:Teď napojím sheet na dashboard:

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

_[tool: str_replace_edit]_

Také přidám script do canvasu, ať se dashboard tam vykreslí korektně:

_[tool: done]_

_[tool: fork_verifier_agent]_

Hotovo. Pod hlavním CTA na dashboardu je teď tlačítko **"Nahlásit závadu"** s wrench ikonou. Po kliknutí:

- vyjede bottom sheet ze spodu s tmavým backdropem
- **textarea** s helpful placeholderem ("Třeba: bench č. 2 má rozsekané lano...")
- **fotky** — klik na "+ fotka" otevře file picker, lze přidat víc, každá thumbnail má × na odebrání
- **Odeslat** je disabled dokud nezadáš text
- po odeslání: sheet se zavře, toast "Závada nahlášena. Díky! · 2 fotky"
- zavřít: backdrop, ✕ nebo drag handle

Funguje to jak v prototypu, tak v design canvasu (sheet se objeví pozičně k viewport).

## User

Verifier agent check completed

## Assistant

Verifier potvrdil. Bottom sheet pro nahlášení závady je hotový a funguje napříč prototypem i canvasem.

