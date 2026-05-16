// shared.jsx — design tokens, icons, mini components used across screens

const T = {
  bg: '#0F0F10',
  surface: '#1A1A1C',
  surface2: '#232326',
  border: '#2A2A2D',
  divider: 'rgba(255,255,255,0.06)',
  text: '#F5F5F7',
  text2: '#8E8E93',
  text3: '#5E5E63',
  accent: 'var(--bf-accent, #FF4D2E)',
  accentSoft: 'var(--bf-accent-soft, rgba(255,77,46,0.14))',
  ok: '#34C759',
  warn: '#FFCC00',
  error: '#FF3B30',
  okSoft: 'rgba(52,199,89,0.14)',
  warnSoft: 'rgba(255,204,0,0.14)',
  errorSoft: 'rgba(255,59,48,0.14)',
};

const FontUI = "'Inter', -apple-system, system-ui, sans-serif";
const FontMono = "'JetBrains Mono', ui-monospace, Menlo, monospace";

// ─── Icons (stroke, 24px viewBox, Lucide-ish) ────────────────────
const Icon = ({ d, size = 20, stroke = 1.6, fill = 'none', color = 'currentColor', children }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0 }}>
    {d ? <path d={d} /> : children}
  </svg>
);

const Icons = {
  home: <Icon><path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z"/></Icon>,
  card: <Icon><rect x="2.5" y="5" width="19" height="14" rx="2.5"/><path d="M2.5 10h19"/></Icon>,
  history: <Icon><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/><path d="M12 7v5l3 2"/></Icon>,
  bell: <Icon><path d="M6 8a6 6 0 0 1 12 0c0 6 3 7 3 7H3s3-1 3-7"/><path d="M10 20a2 2 0 0 0 4 0"/></Icon>,
  user: <Icon><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></Icon>,
  qr: <Icon><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><path d="M14 14h3v3M21 14v3M14 21h3M21 18v3h-4"/></Icon>,
  arrowRight: <Icon><path d="M5 12h14M13 5l7 7-7 7"/></Icon>,
  arrowLeft: <Icon><path d="M19 12H5M11 19l-7-7 7-7"/></Icon>,
  check: <Icon><path d="M20 6 9 17l-5-5"/></Icon>,
  x: <Icon><path d="M18 6 6 18M6 6l12 12"/></Icon>,
  plus: <Icon><path d="M12 5v14M5 12h14"/></Icon>,
  search: <Icon><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></Icon>,
  filter: <Icon><path d="M4 5h16M7 12h10M10 19h4"/></Icon>,
  key: <Icon><circle cx="8" cy="15" r="4"/><path d="m11 12 9-9M16 7l3 3M14 9l3 3"/></Icon>,
  shield: <Icon><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></Icon>,
  alert: <Icon><path d="M12 9v4M12 17h.01"/><path d="M10.3 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></Icon>,
  trend: <Icon><path d="M22 7 13.5 15.5l-5-5L2 17"/><path d="M16 7h6v6"/></Icon>,
  message: <Icon><path d="M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8z"/></Icon>,
  download: <Icon><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3"/></Icon>,
  copy: <Icon><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></Icon>,
  wallet: <Icon><path d="M19 7H5a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-5"/><path d="M3 9V6a2 2 0 0 1 2-2h11v3"/><circle cx="17" cy="14" r="1.2" fill="currentColor"/></Icon>,
  refresh: <Icon><path d="M3 12a9 9 0 0 1 15-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-15 6.7L3 16"/><path d="M8 16H3v5"/></Icon>,
  more: <Icon><circle cx="5" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="19" cy="12" r="1.4" fill="currentColor" stroke="none"/></Icon>,
  chevron: <Icon><path d="m9 18 6-6-6-6"/></Icon>,
  back: <Icon><path d="m15 18-6-6 6-6"/></Icon>,
  dumbbell: <Icon><path d="M6.5 6.5 17.5 17.5"/><path d="M21 14l-3-3"/><path d="M14 21l-3-3M3 10l3 3M10 3l3 3"/><path d="m6.5 13.5-3 3M17.5 6.5l3-3"/></Icon>,
  sliders: <Icon><path d="M4 21v-7M4 10V3M12 21v-9M12 8V3M20 21v-5M20 12V3M1 14h6M9 8h6M17 16h6"/></Icon>,
  edit: <Icon><path d="M17 3a2.85 2.85 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5z"/></Icon>,
  user_check: <Icon><circle cx="9" cy="8" r="4"/><path d="M3 21a6 6 0 0 1 12 0"/><path d="m17 11 2 2 4-4"/></Icon>,
  trash: <Icon><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/></Icon>,
  pause: <Icon><rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/></Icon>,
  cash: <Icon><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/><path d="M6 12h.01M18 12h.01"/></Icon>,
  send: <Icon><path d="M22 2 11 13"/><path d="m22 2-7 20-4-9-9-4z"/></Icon>,
  user_plus: <Icon><circle cx="9" cy="8" r="4"/><path d="M3 21a6 6 0 0 1 12 0"/><path d="M19 8v6M16 11h6"/></Icon>,
  calendar: <Icon><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/></Icon>,
  isic: <Icon><rect x="2.5" y="5" width="19" height="14" rx="2"/><circle cx="8" cy="11" r="2"/><path d="M5 16c.5-1.5 1.7-2 3-2s2.5.5 3 2M14 9h4M14 12h4M14 15h2"/></Icon>,
  board: <Icon><path d="M5 4h14v16a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1z"/><path d="M9 4v3h6V4M8 12h8M8 16h5"/></Icon>,
  megaphone: <Icon><path d="M3 11v2a2 2 0 0 0 2 2h1l4 4V5L6 9H5a2 2 0 0 0-2 2z"/><path d="M14 8a4 4 0 0 1 0 8"/></Icon>,
  spark: <Icon><path d="M12 3v4M12 17v4M3 12h4M17 12h4M6 6l2.5 2.5M15.5 15.5 18 18M6 18l2.5-2.5M15.5 8.5 18 6"/></Icon>,
  globe: <Icon><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18 14 14 0 0 1 0-18"/></Icon>,
  moon: <Icon><path d="M21 12.8A8 8 0 1 1 11.2 3a6 6 0 0 0 9.8 9.8z"/></Icon>,
  help: <Icon><circle cx="12" cy="12" r="9"/><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.7.4-1 1-1 1.7v.5M12 17h.01"/></Icon>,
  logout: <Icon><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/></Icon>,
  pin: <Icon><path d="m12 17 .01 5M7 4h10l-1 4 3 4H5l3-4z"/></Icon>,
  tool: <Icon><path d="M14.7 6.3a4 4 0 0 0-5.4 5.4L3 18l3 3 6.3-6.3a4 4 0 0 0 5.4-5.4l-2.6 2.6-2.4-2.4z"/></Icon>,
  tag: <Icon><path d="M20.6 13.4 13.4 20.6a2 2 0 0 1-2.8 0L3 13V3h10l7.6 7.6a2 2 0 0 1 0 2.8z"/><circle cx="7.5" cy="7.5" r="1.2" fill="currentColor" stroke="none"/></Icon>,
};

// ─── Status pill / dot ───────────────────────────────────────────
function StatusDot({ state, size = 8 }) {
  const c = state === 'ok' ? T.ok : state === 'warn' ? T.warn : state === 'error' ? T.error : T.text3;
  return <span style={{ display: 'inline-block', width: size, height: size, borderRadius: '50%', background: c, flexShrink: 0 }} />;
}

function StatusPill({ state, children }) {
  const map = {
    ok:    { bg: T.okSoft,    fg: T.ok },
    warn:  { bg: T.warnSoft,  fg: T.warn },
    error: { bg: T.errorSoft, fg: T.error },
    muted: { bg: 'rgba(142,142,147,0.16)', fg: T.text2 },
  };
  const c = map[state] || map.muted;
  return (
    <span style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      padding: '4px 8px', borderRadius: 7, background: c.bg, color: c.fg,
      fontSize: 12, fontWeight: 500, letterSpacing: -0.1, lineHeight: 1,
    }}>
      <StatusDot state={state === 'muted' ? null : state} size={6} />
      {children}
    </span>
  );
}

// ─── Status bar (custom dark for our app) ────────────────────────
function StatusBar({ time = '9:41' }) {
  return (
    <div style={{
      height: 54, paddingTop: 14, paddingLeft: 32, paddingRight: 32,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      color: '#fff', fontSize: 17, fontWeight: 600, fontFamily: FontUI,
      position: 'relative', zIndex: 30,
    }}>
      <span style={{ letterSpacing: -0.2 }}>{time}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
        <svg width="18" height="11" viewBox="0 0 18 11"><rect x="0" y="7" width="3" height="4" rx="0.6" fill="#fff"/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill="#fff"/><rect x="9" y="2.5" width="3" height="8.5" rx="0.6" fill="#fff"/><rect x="13.5" y="0" width="3" height="11" rx="0.6" fill="#fff"/></svg>
        <svg width="16" height="11" viewBox="0 0 16 11"><path d="M8 3C10 3 12 4 13 5l1-1C12 2 10 1.5 8 1.5S4 2 2 4l1 1c1-1 3-2 5-2zM8 6c1 0 2 .4 3 1.2l1-1C10.8 5 9.5 4.5 8 4.5S5.2 5 3.9 6.2l1 1C5.9 6.4 7 6 8 6z" fill="#fff"/><circle cx="8" cy="9.5" r="1.2" fill="#fff"/></svg>
        <svg width="26" height="12" viewBox="0 0 26 12"><rect x="0.5" y="0.5" width="22" height="11" rx="3" stroke="#fff" strokeOpacity="0.4" fill="none"/><rect x="2" y="2" width="19" height="8" rx="1.6" fill="#fff"/><path d="M24 4v4c.8-.3 1.2-1 1.2-2S24.8 4.3 24 4z" fill="#fff" fillOpacity="0.4"/></svg>
      </div>
    </div>
  );
}

// ─── Bottom nav ──────────────────────────────────────────────────
function BottomNav({ items, active, onItemClick }) {
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      paddingTop: 10, paddingBottom: 28, paddingLeft: 8, paddingRight: 8,
      background: 'rgba(15,15,16,0.92)', backdropFilter: 'blur(20px)',
      borderTop: `1px solid ${T.border}`, zIndex: 20,
      display: 'flex', justifyContent: 'space-around',
    }}>
      {items.map((it, i) => (
        <div key={i}
          onClick={onItemClick ? () => onItemClick(i) : undefined}
          style={{
          display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
          color: i === active ? T.text : T.text3, padding: '4px 12px',
          minWidth: 56,
          cursor: onItemClick ? 'pointer' : 'default',
          userSelect: 'none',
        }}>
          <div style={{ position: 'relative', color: i === active ? T.accent : 'inherit', display: 'flex' }}>
            {React.cloneElement(it.icon, { color: i === active ? 'var(--bf-accent, #FF4D2E)' : 'currentColor', size: 22 })}
            {it.badge ? (
              <span style={{
                position: 'absolute', top: -4, right: -8,
                minWidth: 16, height: 16, padding: '0 4px', borderRadius: 8,
                background: T.error, color: '#fff', fontSize: 10, fontWeight: 700,
                display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                border: `2px solid ${T.bg}`, fontFamily: FontMono, lineHeight: 1,
              }}>{it.badge > 9 ? '9+' : it.badge}</span>
            ) : null}
          </div>
          <span style={{ fontSize: 10.5, fontWeight: 500, letterSpacing: -0.1 }}>{it.label}</span>
        </div>
      ))}
    </div>
  );
}

// ─── Card ────────────────────────────────────────────────────────
function Card({ children, style }) {
  return (
    <div style={{
      background: T.surface, border: `1px solid ${T.border}`, borderRadius: 16,
      padding: 16, ...style,
    }}>{children}</div>
  );
}

// ─── Button ──────────────────────────────────────────────────────
function Btn({ children, variant = 'primary', icon, style, full = false, onClick }) {
  const base = {
    height: 52, borderRadius: 14, fontSize: 16, fontWeight: 600,
    letterSpacing: -0.2, display: 'inline-flex', alignItems: 'center',
    justifyContent: 'center', gap: 8, padding: '0 20px', border: 'none',
    cursor: 'pointer', fontFamily: FontUI,
    width: full ? '100%' : 'auto',
  };
  const v = variant === 'primary'
    ? { background: T.accent, color: '#fff' }
    : variant === 'ghost'
      ? { background: 'transparent', color: T.text, border: `1px solid ${T.border}` }
      : variant === 'secondary'
        ? { background: T.surface2, color: T.text }
        : variant === 'danger'
          ? { background: T.errorSoft, color: T.error }
          : { background: T.surface2, color: T.text };
  return <button onClick={onClick} style={{ ...base, ...v, ...style }}>{icon}{children}</button>;
}

// ─── QR placeholder — fixed-pattern grid, seedable ──────────────
function QRCode({ size = 240, seed = 0 }) {
  // deterministic pseudo-random pattern for realism
  const s = (x, y) => ((x * 37 + y * 23 + (x ^ y) * 13 + seed * 19 + seed * seed * 7) % 11) < 5;
  const N = 25;
  const cell = size / N;
  const cells = [];
  for (let y = 0; y < N; y++) {
    for (let x = 0; x < N; x++) {
      // finder patterns at corners
      const isFinder = (a, b, x, y) => x >= a && x < a + 7 && y >= b && y < b + 7;
      const inFinder = isFinder(0,0,x,y) || isFinder(N-7,0,x,y) || isFinder(0,N-7,x,y);
      if (inFinder) continue;
      if (s(x, y)) cells.push(<rect key={`${x}-${y}`} x={x*cell} y={y*cell} width={cell} height={cell} fill="#0F0F10"/>);
    }
  }
  const finder = (ox, oy) => (
    <g transform={`translate(${ox*cell},${oy*cell})`}>
      <rect width={cell*7} height={cell*7} fill="#0F0F10"/>
      <rect x={cell} y={cell} width={cell*5} height={cell*5} fill="#fff"/>
      <rect x={cell*2} y={cell*2} width={cell*3} height={cell*3} fill="#0F0F10"/>
    </g>
  );
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ display: 'block' }}>
      <rect width={size} height={size} fill="#fff"/>
      {cells}
      {finder(0, 0)}
      {finder(N-7, 0)}
      {finder(0, N-7)}
    </svg>
  );
}

// Avatar — initials on tinted background
function Avatar({ name, size = 40, tint }) {
  const initials = name.split(' ').map(s => s[0]).slice(0,2).join('').toUpperCase();
  const palette = ['#FF4D2E','#FFCC00','#34C759','#5AC8FA','#BF5AF2','#FF9F0A','#64D2FF'];
  const idx = name.charCodeAt(0) % palette.length;
  const c = tint || palette[idx];
  return (
    <div style={{
      width: size, height: size, borderRadius: '50%',
      background: c + '26', color: c, display: 'flex',
      alignItems: 'center', justifyContent: 'center',
      fontSize: size * 0.36, fontWeight: 600, letterSpacing: -0.4,
      flexShrink: 0,
    }}>{initials}</div>
  );
}

// PhotoAvatar — kruhový image-slot s iniciálami jako fallback (Olda na něj pustí foto).
function PhotoAvatar({ id, name, size = 64 }) {
  const initials = name.split(' ').map(s => s[0]).slice(0, 2).join('').toUpperCase();
  const palette = ['#FF4D2E','#FFCC00','#34C759','#5AC8FA','#BF5AF2','#FF9F0A','#64D2FF'];
  const idx = name.charCodeAt(0) % palette.length;
  const c = palette[idx];
  const slotRef = React.useRef(null);
  // Sleduj zda je slot vyplněn — pokud ne, ukážeme overlay s iniciálami.
  const [filled, setFilled] = React.useState(false);
  React.useEffect(() => {
    const el = slotRef.current;
    if (!el) return;
    const check = () => {
      // image-slot vyplněný stav: má vnitřní <img> viditelný nebo má .filled state
      const img = el.shadowRoot && el.shadowRoot.querySelector('img');
      setFilled(!!(img && img.style.display !== 'none' && img.src));
    };
    check();
    const t = setInterval(check, 600);
    return () => clearInterval(t);
  }, []);
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <image-slot
        ref={slotRef}
        id={id}
        shape="circle"
        placeholder=""
        style={{
          display: 'block', width: size, height: size,
          background: c + '26',
          borderRadius: '50%',
        }}
        class="bf-photo-slot"
      ></image-slot>
      {!filled && (
        <div style={{
          position: 'absolute', inset: 0, borderRadius: '50%',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: c, fontFamily: FontUI,
          fontSize: size * 0.36, fontWeight: 600, letterSpacing: -0.4,
          pointerEvents: 'none',
        }}>{initials}</div>
      )}
    </div>
  );
}

// ─── Member bottom nav (shared by member screens) ────────────────
const MEMBER_NAV_ROUTES = ['dashboard', 'card', 'history', 'board', 'profile'];
function MemberBottomNav({ active, onNav = () => {} }) {
  return (
    <BottomNav
      active={active}
      onItemClick={(i) => onNav(MEMBER_NAV_ROUTES[i])}
      items={[
        { icon: Icons.home,      label: 'Domů' },
        { icon: Icons.card,      label: 'Karta' },
        { icon: Icons.history,   label: 'Historie' },
        { icon: Icons.board,     label: 'Nástěnka' },
        { icon: Icons.user,      label: 'Profil' },
      ]}
    />
  );
}

Object.assign(window, { T, FontUI, FontMono, Icons, Icon, StatusDot, StatusPill, StatusBar, BottomNav, MemberBottomNav, MEMBER_NAV_ROUTES, Card, Btn, QRCode, Avatar, PhotoAvatar });
