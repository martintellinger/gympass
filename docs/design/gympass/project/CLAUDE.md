# GymPass · BýtFit Klub

Mobilní app na správu členství malé soukromé posilovny (~34 členů, majitel Olda).
**Není to fitness app** — žádné tréninky, coaching, statistiky síly, "motivační" prvky.
Je to **utilita na členství**: kdo platí, kdo končí, kdo má klíč, co se dnes děje v Klubu.

Flutter, iOS + Android. Dark mode jako primární téma.

## Jazyk a tón

- Vše **česky**, **tykání** ("ahoj Pavle", "můžeš ještě 23 dní").
- Krátké, lidské věty. Žádný korporát ("Vážený uživateli"), žádné emoji.
- Čísla a peníze česky: `2 250 Kč` (mezera jako oddělovač tisíců), datum `23. 6. 2026`.
- Místo "uživatel" → **člen**. Místo "admin" → **majitel** nebo Olda.

## Vizuální systém

Tokeny v `screens/shared.jsx` (objekt `T`):

- Pozadí: `#0F0F10` (bg), surface `#1A1A1C`, surface2 `#232326`, border `#2A2A2D`
- Text: `#F5F5F7` / `#8E8E93` / `#5E5E63`
- Akcent: CSS proměnná `var(--bf-accent, #FF4D2E)` (orange-red, tweakovatelné)
- Status: `ok` zelená `#34C759`, `warn` žlutá `#FFCC00`, `error` červená `#FF3B30`, `muted` šedá
- Soft variants: `okSoft`, `warnSoft`, `errorSoft`, `accentSoft` (14% alpha)

Typografie:
- **Inter** pro UI (400/500/600/700)
- **JetBrains Mono** pro čísla, datumy, kódy, VS, identifikátory
- Žádné Roboto / system-ui / Fraunces / SF Pro

Hit targety min. 44px, text na mobilu min. 13px, hlavičky 22–28px, hero čísla 32–64px.

## Struktura projektu

```
BýtFit Klub.html              — design canvas (všechny obrazovky vedle sebe)
BýtFit Klub - Prototyp.html   — klikatelný prototyp (telefon + persona switcher)
screens/
  shared.jsx                  — tokens, ikony, primitivy
  MemberDashboard.jsx         — 04 hlavní obrazovka člena
  QRPayment.jsx               — 05 prodloužení s QR (3 tarify)
  HistoryScreen.jsx           — 06 historie aktivit
  BoardScreen.jsx             — 07 nástěnka klubu
  ProfileScreen.jsx           — 08 profil
  MemberCard.jsx              — 09 členská karta
  AdminDashboard.jsx          — 10 přehled majitele
  MemberList.jsx              — 11 seznam členů
  MemberDetail.jsx            — 12 detail člena
  ApprovalQueue.jsx           — 13 schvalování registrací
assets/                       — loga, statické obrázky
uploads/                      — uživatelské uploady
design-canvas.jsx · ios-frame.jsx · tweaks-panel.jsx — starter komponenty
```

## Sdílené primitivy (`screens/shared.jsx`)

Exportované přes `Object.assign(window, …)`:

- `T`, `FontUI`, `FontMono` — design tokens
- `Icons` — Lucide-styled SVG (stroke 1.6, 24px viewBox), např. `Icons.home`, `Icons.key`, `Icons.board`
- `StatusBar` — vlastní dark iOS-like statusbar
- `BottomNav({ items, active, onItemClick })` — obecný spodní nav
- `MemberBottomNav({ active, onNav })` — nav specifický pro člena (Domů · Karta · Historie · Nástěnka · Profil), routy v `MEMBER_NAV_ROUTES`
- `Card`, `Btn` (variants: `primary`/`ghost`/`secondary`/`danger`)
- `StatusPill`, `StatusDot` — `state="ok|warn|error|muted"`
- `QRCode({ size, seed })` — pseudo-QR placeholder, `seed` mění vzor
- `Avatar({ name, size })` — iniciály na tinted background

## Konvence pro nové obrazovky

1. **Funkce přijímá `onNav`** s no-op defaultem: `function MyScreen({ onNav = () => {} }) { … }`
2. **Navigace** přes `onNav('routeKey')` nebo `onNav('routeKey', { toast: 'Hotovo' })`
3. **Export** na konci souboru: `Object.assign(window, { MyScreen });`
4. **Registrace v prototypu** — `BýtFit Klub - Prototyp.html`:
   - přidat řádek do `SCREENS` (persona, title, num, comp)
   - přidat klíč do `FLOW.member` / `FLOW.admin`
   - přidat hotspot hints do `HOTSPOT_HINTS`
   - načíst soubor přes `<script type="text/babel" src="…">`
5. **Registrace v canvasu** — `BýtFit Klub.html`: nový `<DCArtboard>` v příslušné sekci, šířka 360, výška podle obsahu
6. **Spodní nav** u členských obrazovek vždy `MemberBottomNav` s `active={index}`
7. **Member screen scroll** — obsah uvnitř, `padding-bottom: 110px` aby spodní nav nepřekrýval poslední item

## Telefon bezel (prototyp)

- 376px šířka (8px padding kolem 360px obrazovky), 48px corner radius
- Dynamic island absolute na top center
- Screen-swap animace přes `@keyframes screenIn`
- Bez bottom safe-area (řeší si každá obrazovka sama přes `paddingBottom: 28`)

## Tweaky

Tweak panel (`tweaks-panel.jsx`) drží akcentní barvu v `TWEAK_DEFAULTS` mezi `EDITMODE-BEGIN/END` markery v `BýtFit Klub - Prototyp.html`. Akcent se aplikuje přes CSS proměnnou `--bf-accent` na `<html>`. **Nepřidávat tweaky bez explicitního požadavku.**

## Klávesové zkratky v prototypu

- `1` → persona Člen
- `2` → persona Majitel
- `Esc` → zpět v historii

## Co nikdy nedělat

- ❌ Žádné emoji v UI (ani v copy, ani v ikonách)
- ❌ Žádné svaly / fitness ikonografie nad rámec `Icons.dumbbell` v logu/akcentu
- ❌ Žádné AI features, žádné "smart suggestions", žádné motivační hlášky
- ❌ Žádné gradient duhové pozadí, žádné neonové glow efekty
- ❌ Žádné anglické UI texty (ani v placeholderech)
- ❌ Nepřejmenovávat existující obrazovky bez důvodu — interní čísla `04`–`13` jsou ze zadání

## Co dělat opatrně

- **Změny v `shared.jsx`** se propisují do všech obrazovek — ověř že nic nerozbiješ
- **Spodní nav** v jednotlivých obrazovkách musí být konzistentní (`MemberBottomNav` ne ručně psaný)
- Když přidáváš novou obrazovku, **přidej ji do canvasu i do prototypu** současně
