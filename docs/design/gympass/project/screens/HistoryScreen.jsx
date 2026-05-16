// HistoryScreen.jsx — historie aktivit člena

const HISTORY_ITEMS = [
  { type: 'pay',    date: '23. 3. 2026', month: '2026 · březen',  title: 'Prodloužení (3 měsíce)', amount: '2 250 Kč', sub: '+90 dní', method: 'QR · bank' },
  { type: 'pay',    date: '22. 12. 2025', month: '2025 · prosinec',title: 'Prodloužení (3 měsíce)', amount: '2 250 Kč', sub: '+90 dní', method: 'QR · bank' },
  { type: 'pay',    date: '14. 9. 2025',  month: '2025 · září',    title: 'Vstupní platba', amount: '850 Kč',  sub: '+30 dní', method: 'QR · bank' },
  { type: 'key',    date: '14. 9. 2025',  month: '2025 · září',    title: 'Vydán klíč',     amount: '100 Kč',  sub: 'kauce',  method: 'cash · Olda' },
  { type: 'signup', date: '12. 9. 2025',  month: '2025 · září',    title: 'Schválena registrace', amount: '',  sub: '',       method: '' },
];

const TYPE_META = {
  pay:    { icon: () => Icons.refresh, color: () => T.accent, label: 'Platba' },
  key:    { icon: () => Icons.key,     color: () => T.warn,   label: 'Klíč' },
  signup: { icon: () => Icons.user_check, color: () => T.ok,  label: 'Účet' },
};

function HistoryScreen({ onNav = () => {} }) {
  const [filter, setFilter] = React.useState('all');
  const items = HISTORY_ITEMS.filter(i => filter === 'all' || i.type === filter);

  // Group by month
  const byMonth = {};
  items.forEach(it => { (byMonth[it.month] ??= []).push(it); });

  const totalPaid = HISTORY_ITEMS
    .filter(i => i.type === 'pay')
    .reduce((s, i) => s + parseInt(i.amount.replace(/\D/g,'') || '0'), 0);

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '0 24px 12px' }}>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8, marginTop: 4 }}>Historie</div>
        <div style={{ fontSize: 13.5, color: T.text2, marginTop: 4 }}>Všechno, co se v Klubu stalo s tvým účtem.</div>

        {/* Stats */}
        <div style={{ marginTop: 16, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <MiniStat label="Zaplaceno" value={`${totalPaid.toLocaleString('cs-CZ').replace(/,/g,' ')} Kč`}/>
          <MiniStat label="Člen od" value="9 · 2025" sub="8 měsíců"/>
        </div>

        {/* Filter chips */}
        <div style={{ marginTop: 16, display: 'flex', gap: 6, overflowX: 'auto' }}>
          <FChip active={filter === 'all'} onClick={() => setFilter('all')}>Vše · {HISTORY_ITEMS.length}</FChip>
          <FChip active={filter === 'pay'} onClick={() => setFilter('pay')}>Platby · 3</FChip>
          <FChip active={filter === 'key'} onClick={() => setFilter('key')}>Klíč · 1</FChip>
          <FChip active={filter === 'signup'} onClick={() => setFilter('signup')}>Účet · 1</FChip>
        </div>
      </div>

      <div style={{ padding: '4px 24px 110px' }}>
        {Object.entries(byMonth).map(([month, list]) => (
          <div key={month} style={{ marginTop: 18 }}>
            <div style={{ fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase', marginBottom: 8 }}>{month}</div>
            <Card style={{ padding: 0 }}>
              {list.map((it, i) => (
                <React.Fragment key={i}>
                  <HistoryItem item={it}/>
                  {i < list.length - 1 && <div style={{ height: 1, background: T.divider, marginLeft: 60 }}/>}
                </React.Fragment>
              ))}
            </Card>
          </div>
        ))}

        <div style={{ marginTop: 18, fontSize: 12, color: T.text3, textAlign: 'center', lineHeight: 1.5 }}>
          To je všechno. Účet máš od září&nbsp;2025.
        </div>
      </div>

      <MemberBottomNav active={2} onNav={onNav}/>
    </div>
  );
}

function MiniStat({ label, value, sub }) {
  return (
    <div style={{ background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12, padding: 12 }}>
      <div style={{ fontSize: 11, fontWeight: 600, letterSpacing: 0.3, color: T.text2, textTransform: 'uppercase' }}>{label}</div>
      <div style={{ marginTop: 6, fontSize: 18, fontWeight: 700, fontFamily: FontMono, letterSpacing: -0.4 }}>{value}</div>
      {sub && <div style={{ fontSize: 11.5, color: T.text3, marginTop: 2, fontFamily: FontMono }}>{sub}</div>}
    </div>
  );
}

function FChip({ children, active, onClick }) {
  return (
    <div onClick={onClick} style={{
      flexShrink: 0, height: 30, padding: '0 12px', borderRadius: 100,
      background: active ? T.text : T.surface,
      border: `1px solid ${active ? T.text : T.border}`,
      color: active ? T.bg : T.text, fontSize: 12.5, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', cursor: 'pointer',
      userSelect: 'none',
    }}>{children}</div>
  );
}

function HistoryItem({ item }) {
  const meta = TYPE_META[item.type];
  const c = meta.color();
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 14px' }}>
      <div style={{
        width: 36, height: 36, borderRadius: 10,
        background: c + '22', color: c,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        {React.cloneElement(meta.icon(), { size: 16, stroke: 2 })}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 500, letterSpacing: -0.2 }}>{item.title}</div>
        <div style={{ fontSize: 12, color: T.text2, marginTop: 3, display: 'flex', alignItems: 'center', gap: 6, fontFamily: FontMono }}>
          <span>{item.date}</span>
          {item.method && <><span style={{ color: T.text3 }}>·</span><span>{item.method}</span></>}
        </div>
      </div>
      {item.amount && (
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: 14, fontWeight: 600, fontFamily: FontMono }}>{item.amount}</div>
          {item.sub && <div style={{ fontSize: 11, color: T.text3, marginTop: 2, fontFamily: FontMono }}>{item.sub}</div>}
        </div>
      )}
    </div>
  );
}

Object.assign(window, { HistoryScreen });
