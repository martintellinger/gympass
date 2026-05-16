// AdminPayments.jsx — Platby (přehled pro majitele)
// Sekce: souhrn měsíce, filtry stavu, vyhledávání, řazený seznam plateb.

function AdminPayments({ onNav = () => {} }) {
  const s = useStore();
  const [filter, setFilter] = React.useState('all'); // all | ok | pending | overdue
  const [q, setQ] = React.useState('');

  const memberName = (id) => (s.memberById(id) || {}).name || '—';

  const enriched = React.useMemo(() => s.payments.map(p => ({
    ...p,
    date: new Date(p.date),
    memberName: memberName(p.memberId),
  })), [s.payments]);

  const filtered = enriched.filter(p => {
    if (filter !== 'all' && p.state !== filter) return false;
    if (q && !p.memberName.toLowerCase().includes(q.toLowerCase())) return false;
    return true;
  }).sort((a, b) => b.date - a.date);

  const counts = {
    all: enriched.length,
    ok: enriched.filter(p => p.state === 'ok').length,
    pending: enriched.filter(p => p.state === 'pending').length,
    overdue: enriched.filter(p => p.state === 'overdue').length,
  };

  // Souhrn za květen 2026 (aktuální měsíc)
  const monthRevenue = enriched
    .filter(p => p.state === 'ok' && p.date.getMonth() === 4 && p.date.getFullYear() === 2026)
    .reduce((sum, p) => sum + p.amount, 0);
  const ytdRevenue = enriched
    .filter(p => p.state === 'ok' && p.date.getFullYear() === 2026)
    .reduce((sum, p) => sum + p.amount, 0);
  const overdueTotal = enriched
    .filter(p => p.state === 'overdue')
    .reduce((sum, p) => sum + p.amount, 0);

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar/>
      <div style={{ padding: '0 20px 12px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 4 }}>
          <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8 }}>Platby</div>
          <div style={{ display: 'flex', gap: 8 }}>
            <RoundBtn icon={Icons.download}/>
            <RoundBtn icon={Icons.plus} primary/>
          </div>
        </div>

        {/* Měsíční souhrn */}
        <div style={{ marginTop: 12, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 14, padding: 14 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
            <div style={{ fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase', whiteSpace: 'nowrap' }}>Květen 2026</div>
            <div style={{ fontSize: 11.5, color: T.text3, fontFamily: FontMono, whiteSpace: 'nowrap' }}>YTD {fmtKc(ytdRevenue)}</div>
          </div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 6, marginTop: 8, whiteSpace: 'nowrap' }}>
            <span style={{ fontSize: 30, fontWeight: 700, letterSpacing: -1, fontFamily: FontMono, lineHeight: 1 }}>{fmtKc(monthRevenue)}</span>
            <span style={{ fontSize: 14, color: T.text2 }}>Kč</span>
          </div>
          <div style={{ display: 'flex', gap: 14, marginTop: 10, fontSize: 12, flexWrap: 'wrap' }}>
            <span style={{ color: T.ok, display: 'inline-flex', alignItems: 'center', gap: 5, whiteSpace: 'nowrap' }}>
              <StatusDot state="ok" size={6}/> {counts.ok} přijato
            </span>
            <span style={{ color: T.warn, display: 'inline-flex', alignItems: 'center', gap: 5, whiteSpace: 'nowrap' }}>
              <StatusDot state="warn" size={6}/> {counts.pending} čeká
            </span>
            <span style={{ color: T.error, display: 'inline-flex', alignItems: 'center', gap: 5, whiteSpace: 'nowrap' }}>
              <StatusDot state="error" size={6}/> {fmtKc(overdueTotal)} Kč dluh
            </span>
          </div>
        </div>

        {/* Search */}
        <div style={{ marginTop: 12, height: 40, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12, display: 'flex', alignItems: 'center', padding: '0 12px', gap: 8 }}>
          <span style={{ color: T.text2, display: 'flex' }}>{React.cloneElement(Icons.search, { size: 16 })}</span>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Hledat člena…"
            style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: T.text, fontSize: 14, fontFamily: FontUI }}
          />
          {q && <span onClick={() => setQ('')} style={{ cursor: 'pointer', color: T.text3 }}>{React.cloneElement(Icons.x, { size: 14 })}</span>}
        </div>

        {/* Filtr chips */}
        <div style={{ marginTop: 10, display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2 }}>
          <PChip active={filter === 'all'}      onClick={() => setFilter('all')}>Vše · {counts.all}</PChip>
          <PChip active={filter === 'ok'}       onClick={() => setFilter('ok')} dot={T.ok}>Přijato · {counts.ok}</PChip>
          <PChip active={filter === 'pending'}  onClick={() => setFilter('pending')} dot={T.warn}>Čeká · {counts.pending}</PChip>
          <PChip active={filter === 'overdue'}  onClick={() => setFilter('overdue')} dot={T.error}>Po lhůtě · {counts.overdue}</PChip>
        </div>
      </div>

      {/* Seznam */}
      <div style={{ padding: '4px 20px 110px' }}>
        <div style={{ position: 'sticky', top: 0, background: T.bg, padding: '8px 4px', fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase', display: 'flex', justifyContent: 'space-between' }}>
          <span>{filtered.length} {filtered.length === 1 ? 'záznam' : (filtered.length < 5 && filtered.length > 0 ? 'záznamy' : 'záznamů')} · datum ↓</span>
          {q && <span style={{ color: T.accent, textTransform: 'none', letterSpacing: 0 }}>filtr: „{q}"</span>}
        </div>

        {filtered.length === 0 ? (
          <div style={{ padding: '40px 12px', textAlign: 'center', color: T.text3, fontSize: 13 }}>
            Žádné platby pro vybraný filtr.
          </div>
        ) : (
          filtered.map(p => (
            <PaymentRow key={p.id} payment={p}
              onClick={() => onNav('detail', { memberId: p.memberId })}
              onRemind={() => { s.sendMessage(p.memberId, `Připomínka platby ${fmtKc(p.amount)} Kč — pošlu QR. Dík.`); onNav('thread', { memberId: p.memberId, toast: 'Připomínka odeslána' }); }}
            />
          ))
        )}
      </div>

      <AdminBottomNav active={2} onNav={onNav}/>
    </div>
  );
}

function fmtKc(n) {
  return n.toLocaleString('cs-CZ').replace(/,/g, ' ').replace(/\u00A0/g, ' ');
}

function PChip({ children, active, onClick, dot }) {
  return (
    <div onClick={onClick} style={{
      flexShrink: 0, height: 32, padding: '0 12px', borderRadius: 100,
      background: active ? T.text : T.surface,
      border: `1px solid ${active ? T.text : T.border}`,
      color: active ? T.bg : T.text, fontSize: 13, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', gap: 6,
      cursor: 'pointer', userSelect: 'none',
    }}>
      {dot && <span style={{ width: 6, height: 6, borderRadius: '50%', background: dot }}/>}
      {children}
    </div>
  );
}

function RoundBtn({ icon, primary }) {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: '50%',
      background: primary ? T.accent : T.surface,
      border: primary ? 'none' : `1px solid ${T.border}`,
      color: primary ? '#fff' : T.text,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer',
    }}>{React.cloneElement(icon, { size: 18 })}</div>
  );
}

function PaymentRow({ payment, onClick, onRemind }) {
  const p = payment;
  const isOK = p.state === 'ok';
  const isPending = p.state === 'pending';
  const isOverdue = p.state === 'overdue';

  const c = isOK ? T.ok : isPending ? T.warn : T.error;
  const cSoft = isOK ? T.okSoft : isPending ? T.warnSoft : T.errorSoft;
  const icon = isOK ? Icons.check : isPending ? Icons.refresh : Icons.alert;

  const dateStr = `${p.date.getDate()}. ${p.date.getMonth() + 1}. ${p.date.getFullYear()}`;

  return (
    <div style={{ borderBottom: `1px solid ${T.divider}` }}>
      <div onClick={onClick} style={{
        cursor: 'pointer',
        padding: '12px 4px', display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{ width: 36, height: 36, borderRadius: 10, background: cSoft, color: c, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          {React.cloneElement(icon, { size: 16, stroke: 2.2 })}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {p.memberName}
          </div>
          <div style={{ fontSize: 12.5, color: T.text2, marginTop: 2, display: 'flex', alignItems: 'center', gap: 6, overflow: 'hidden', whiteSpace: 'nowrap' }}>
            <span style={{ fontFamily: FontMono }}>{dateStr}</span>
            <span style={{ color: T.text3 }}>·</span>
            <span style={{ overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.type}</span>
          </div>
        </div>
        <div style={{ textAlign: 'right', flexShrink: 0, whiteSpace: 'nowrap' }}>
          <div style={{ fontSize: 14, fontWeight: 600, fontFamily: FontMono, color: isOverdue ? T.error : T.text }}>
            {fmtKc(p.amount)} Kč
          </div>
          <div style={{ fontSize: 10.5, color: T.text3, marginTop: 2, fontFamily: FontMono, letterSpacing: 0.3, textTransform: 'uppercase' }}>
            {p.tariff}
          </div>
        </div>
      </div>
      {(isPending || isOverdue) && (
        <div style={{ padding: '0 4px 12px 52px', display: 'flex', gap: 8 }}>
          <button onClick={(e) => { e.stopPropagation(); onRemind && onRemind(); }} style={{
            height: 30, padding: '0 12px', borderRadius: 100,
            background: T.accentSoft, color: T.accent, border: 'none', cursor: 'pointer',
            fontSize: 12.5, fontWeight: 600, fontFamily: FontUI,
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            {React.cloneElement(Icons.send, { size: 12, stroke: 2 })}
            Připomenout
          </button>
          <button onClick={(e) => e.stopPropagation()} style={{
            height: 30, padding: '0 12px', borderRadius: 100,
            background: T.surface2, color: T.text, border: `1px solid ${T.border}`, cursor: 'pointer',
            fontSize: 12.5, fontWeight: 500, fontFamily: FontUI,
            display: 'inline-flex', alignItems: 'center', gap: 6,
          }}>
            {React.cloneElement(Icons.check, { size: 12, stroke: 2.2 })}
            Označit zaplaceno
          </button>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { AdminPayments });
