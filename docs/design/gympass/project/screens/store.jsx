// store.jsx — sdílené in-memory data + jednoduchý pub/sub
// Drží členy, vlákna zpráv a platby — používané napříč admin obrazovkami.

const _MEMBERS_INIT = [
  { id: 'adam',    name: 'Adam Beneš',       phone: '+420 605 112 388', email: 'adam.benes@email.cz',     state: 'ok',    daysNum: 47,  tariff: 'Standard', hasKey: true,  joined: '3 · 2025',  expiresAt: '17. 7. 2026', monthlyPrice: 600 },
  { id: 'anna',    name: 'Anna Dvořáková',   phone: '+420 720 884 102', email: 'anna.dvorakova@email.cz', state: 'ok',    daysNum: 12,  tariff: 'Student',  hasKey: true,  isic: true, joined: '10 · 2025', expiresAt: '12. 6. 2026' },
  { id: 'bara',    name: 'Barbora Horáková', phone: '+420 731 224 871', email: 'bara.horakova@email.cz',  state: 'warn',  daysNum: 6,   tariff: 'Standard', hasKey: true,  joined: '11 · 2024', expiresAt: '6. 6. 2026' },
  { id: 'david',   name: 'David Janků',      phone: '+420 776 998 213', email: 'david.janku@email.cz',    state: 'error', daysNum: -3,  tariff: 'Standard', hasKey: true,  overdue: true, joined: '1 · 2025', expiresAt: '28. 5. 2026' },
  { id: 'eva',     name: 'Eva Krátká',       phone: '+420 608 712 339', email: 'eva.kratka@email.cz',     state: 'ok',    daysNum: 21,  tariff: 'Standard', hasKey: true,  joined: '8 · 2025',  expiresAt: '21. 6. 2026' },
  { id: 'filip',   name: 'Filip Marek',      phone: '+420 728 116 442', email: 'filip.marek@email.cz',    state: 'ok',    daysNum: 63,  tariff: 'Standard', hasKey: false, joined: '4 · 2026',  expiresAt: '2. 8. 2026' },
  { id: 'jana',    name: 'Jana Kovářová',    phone: '+420 776 553 098', email: 'jana.kovarova@email.cz',  state: 'muted', daysNum: -45, tariff: 'Standard', hasKey: false, suspended: true, joined: '2 · 2024', expiresAt: '—' },
  { id: 'lukas',   name: 'Lukáš Procházka',  phone: '+420 605 889 213', email: 'lukas.prochazka@email.cz',state: 'warn',  daysNum: 3,   tariff: 'Student',  hasKey: true,  isic: true, joined: '12 · 2025', expiresAt: '3. 6. 2026' },
  { id: 'martin',  name: 'Martin Tichý',     phone: '+420 720 441 882', email: 'martin.tichy@email.cz',   state: 'ok',    daysNum: 52,  tariff: 'Standard', hasKey: true,  joined: '7 · 2025',  expiresAt: '22. 7. 2026', monthlyPrice: 700 },
  { id: 'pavel',   name: 'Pavel Novák',      phone: '+420 728 451 209', email: 'pavel.novak@email.cz',    state: 'ok',    daysNum: 23,  tariff: 'Standard', hasKey: true,  joined: '9 · 2025',  expiresAt: '23. 6. 2026' },
  { id: 'petr',    name: 'Petr Soukup',      phone: '+420 776 221 558', email: 'petr.soukup@email.cz',    state: 'error', daysNum: -12, tariff: 'Standard', hasKey: true,  overdue: true, joined: '6 · 2024', expiresAt: '19. 5. 2026' },
  { id: 'tomas',   name: 'Tomáš Hladký',     phone: '+420 605 882 410', email: 'tomas.hladky@email.cz',   state: 'ok',    daysNum: 34,  tariff: 'Student',  hasKey: true,  isic: true, joined: '9 · 2025',  expiresAt: '3. 7. 2026' },
  { id: 'klara',   name: 'Klára Bártová',    phone: '+420 720 998 003', email: 'klara.bartova@email.cz',  state: 'ok',    daysNum: 18,  tariff: 'Standard', hasKey: true,  joined: '11 · 2025', expiresAt: '18. 6. 2026' },
  { id: 'jakub',   name: 'Jakub Veselý',     phone: '+420 728 003 661', email: 'jakub.vesely@email.cz',   state: 'ok',    daysNum: 41,  tariff: 'Standard', hasKey: true,  joined: '4 · 2025',  expiresAt: '11. 7. 2026' },
  { id: 'tereza',  name: 'Tereza Černá',     phone: '+420 776 410 882', email: 'tereza.cerna@email.cz',   state: 'warn',  daysNum: 4,   tariff: 'Standard', hasKey: true,  joined: '6 · 2025',  expiresAt: '4. 6. 2026' },
  { id: 'ondrej',  name: 'Ondřej Mareš',     phone: '+420 605 221 998', email: 'ondrej.mares@email.cz',   state: 'ok',    daysNum: 29,  tariff: 'Standard', hasKey: true,  joined: '8 · 2025',  expiresAt: '29. 6. 2026' },
];

// Formátování datumu/času
function fmtTime(d) {
  const pad = (n) => String(n).padStart(2, '0');
  return `${pad(d.getHours())}:${pad(d.getMinutes())}`;
}
function fmtRelDay(d, now = new Date()) {
  const a = new Date(d.getFullYear(), d.getMonth(), d.getDate());
  const b = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const diff = Math.round((b - a) / (24 * 3600 * 1000));
  if (diff === 0) return 'dnes';
  if (diff === 1) return 'včera';
  if (diff < 7) return `před ${diff} dny`;
  return `${d.getDate()}. ${d.getMonth() + 1}.`;
}

// Pomocné: relativní časy
const now = new Date('2026-05-16T09:41:00');
function ago(min) { return new Date(now.getTime() - min * 60000); }

const _THREADS_INIT = {
  david:  [
    { from: 'olda',   text: 'Ahoj Davide, platba ti propadla o 3 dny. Dáš to do víkendu?', at: ago(60 * 22) },
    { from: 'member', text: 'Promiň, zapomněl jsem. Pošlu dnes večer.', at: ago(60 * 20) },
    { from: 'olda',   text: 'Super, dík. QR ti pošlu znovu kdyžtak.', at: ago(60 * 20 - 5) },
    { from: 'member', text: 'Jo prosím tě, pošli ho ještě.', at: ago(15) },
  ],
  petr:   [
    { from: 'olda', text: 'Petře, platba 12 dní po lhůtě. Volej mi prosím, ať to vyřešíme.', at: ago(60 * 24 * 2) },
  ],
  bara:   [
    { from: 'member', text: 'Sprcha č. 3 zase teče málo.', at: ago(60 * 26) },
    { from: 'olda',   text: 'Díky za hlášku, ráno se na to podívám.', at: ago(60 * 25) },
    { from: 'olda',   text: 'Hotovo, sifon vyčištěn. Funguje?', at: ago(60 * 4) },
  ],
  pavel:  [
    { from: 'olda',   text: 'Pavle, dík za platbu, vidím to v účtu.', at: ago(60 * 24 * 3) },
    { from: 'member', text: 'Super, dík!', at: ago(60 * 24 * 3 - 10) },
  ],
  anna:   [
    { from: 'olda', text: 'Ahoj Anno, končí ti ISIC. Přines prosím nový, ať tě nepřepnu na Standard.', at: ago(60 * 5) },
  ],
  tomas:  [
    { from: 'member', text: 'Olda ahoj, můžu zítra přivést kamaráda na zkoušku?', at: ago(60 * 8) },
    { from: 'olda',   text: 'Jasně, klidně. Ať mi řekne u dveří.', at: ago(60 * 7) },
  ],
  lukas:  [
    { from: 'olda', text: 'Lukáši, končí ti za 3 dny — pošlu QR?', at: ago(60 * 3) },
  ],
};

// nepřečtené (poslední zpráva od člena)
function _unreadCount(msgs) {
  let c = 0;
  for (let i = msgs.length - 1; i >= 0; i--) {
    if (msgs[i].from === 'member' && !msgs[i].read) c++;
    else break;
  }
  return c;
}

const _PAYMENTS_INIT = [
  { id: 'p1',  memberId: 'pavel',  date: new Date('2026-03-23'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p2',  memberId: 'adam',   date: new Date('2026-04-17'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p3',  memberId: 'anna',   date: new Date('2026-03-12'), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student',  state: 'ok' },
  { id: 'p4',  memberId: 'eva',    date: new Date('2026-03-21'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p5',  memberId: 'martin', date: new Date('2026-04-22'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p6',  memberId: 'klara',  date: new Date('2026-03-18'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p7',  memberId: 'jakub',  date: new Date('2026-04-11'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p8',  memberId: 'tomas',  date: new Date('2026-04-03'), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student',  state: 'ok' },
  { id: 'p9',  memberId: 'tereza', date: new Date('2026-03-04'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p10', memberId: 'filip',  date: new Date('2026-04-02'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p11', memberId: 'bara',   date: new Date('2026-03-06'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p12', memberId: 'ondrej', date: new Date('2026-04-29'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  // Květen 2026 (aktuální měsíc)
  { id: 'p16', memberId: 'pavel',  date: new Date('2026-05-08'), amount: 4500, type: 'Prodloužení 6 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p17', memberId: 'martin', date: new Date('2026-05-12'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  { id: 'p18', memberId: 'tomas',  date: new Date('2026-05-14'), amount: 1500, type: 'Prodloužení 3 měs.', tariff: 'Student',  state: 'ok' },
  { id: 'p19', memberId: 'klara',  date: new Date('2026-05-15'), amount: 2250, type: 'Prodloužení 3 měs.', tariff: 'Standard', state: 'ok' },
  // Čekající (QR vystaven, nedošlo)
  { id: 'p13', memberId: 'lukas',  date: new Date('2026-05-13'), amount: 1500, type: 'QR čeká',            tariff: 'Student',  state: 'pending' },
  // Po lhůtě
  { id: 'p14', memberId: 'david',  date: new Date('2026-05-13'), amount: 2250, type: 'Po lhůtě 3 dny',     tariff: 'Standard', state: 'overdue' },
  { id: 'p15', memberId: 'petr',   date: new Date('2026-05-04'), amount: 2250, type: 'Po lhůtě 12 dní',    tariff: 'Standard', state: 'overdue' },
];

const store = {
  members: _MEMBERS_INIT.slice(),
  threads: JSON.parse(JSON.stringify(Object.fromEntries(
    Object.entries(_THREADS_INIT).map(([k, v]) => [k, v.map(m => ({ ...m, at: m.at.toISOString() }))])
  ))),
  payments: _PAYMENTS_INIT.map(p => ({ ...p, date: p.date.toISOString() })),
  _listeners: new Set(),

  subscribe(fn) { this._listeners.add(fn); return () => this._listeners.delete(fn); },
  _emit() { this._listeners.forEach(fn => fn()); },

  memberById(id) { return this.members.find(m => m.id === id); },

  addMember(m) {
    const id = (m.name || 'novy').toLowerCase().replace(/\s.*/, '').replace(/[^a-z]/g, '').slice(0, 8) + Math.floor(Math.random() * 99);
    const defaultPrice = m.tariff === 'Student' ? 500 : 750;
    const next = { id, state: 'ok', hasKey: false, tariff: 'Standard', daysNum: 90, joined: '5 · 2026', expiresAt: '14. 8. 2026', monthlyPrice: defaultPrice, ...m };
    this.members = [next, ...this.members];
    this._emit();
    return next;
  },

  updateMember(id, patch) {
    this.members = this.members.map(m => m.id === id ? { ...m, ...patch } : m);
    this._emit();
    return this.members.find(m => m.id === id);
  },

  sendMessage(memberId, text, from = 'olda') {
    if (!this.threads[memberId]) this.threads[memberId] = [];
    this.threads[memberId] = [
      ...this.threads[memberId],
      { from, text, at: new Date().toISOString(), read: from === 'olda' ? true : false },
    ];
    this._emit();
  },

  markRead(memberId) {
    if (!this.threads[memberId]) return;
    this.threads[memberId] = this.threads[memberId].map(m => ({ ...m, read: true }));
    this._emit();
  },

  threadFor(memberId) { return this.threads[memberId] || []; },

  threadsSorted() {
    // [{member, msgs, last, unread}]
    return this.members
      .map(m => {
        const msgs = this.threads[m.id] || [];
        if (msgs.length === 0) return null;
        const last = msgs[msgs.length - 1];
        return { member: m, msgs, last, unread: _unreadCount(msgs) };
      })
      .filter(Boolean)
      .sort((a, b) => new Date(b.last.at) - new Date(a.last.at));
  },

  totalUnread() {
    return Object.values(this.threads).reduce((s, msgs) => s + _unreadCount(msgs), 0);
  },
};

// Hook — re-renderuje při změně storu
function useStore() {
  const [, force] = React.useReducer(x => x + 1, 0);
  React.useEffect(() => store.subscribe(force), []);
  return store;
}

// ─── Admin bottom nav (společný pro všechny admin obrazovky) ────
const ADMIN_NAV_ROUTES = ['admin', 'list', 'payments', 'messages', 'adminMore'];
function AdminBottomNav({ active, onNav = () => {} }) {
  const totalUnread = (window.store && store.totalUnread()) || 0;
  return (
    <BottomNav
      active={active}
      onItemClick={(i) => onNav(ADMIN_NAV_ROUTES[i])}
      items={[
        { icon: Icons.home, label: 'Přehled' },
        { icon: Icons.user, label: 'Členové' },
        { icon: Icons.cash, label: 'Platby' },
        { icon: Icons.message, label: 'Zprávy', badge: totalUnread },
        { icon: Icons.more, label: 'Více' },
      ]}
    />
  );
}

Object.assign(window, { store, useStore, AdminBottomNav, ADMIN_NAV_ROUTES, fmtTime, fmtRelDay });
