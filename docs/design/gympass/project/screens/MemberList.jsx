// MemberList.jsx — Seznam členů pro admina
// Funkční vyhledávání, filtrování dle stavu, řazení (jméno / expirace / tarif).

function MemberList({ onNav = () => {}, filterPreset }) {
  const s = useStore();
  const [q, setQ] = React.useState('');
  const [filter, setFilter] = React.useState(filterPreset || 'all'); // all | ok | warn | error
  const [sortBy, setSortBy] = React.useState('expiration'); // expiration | name | tariff
  const [sortDir, setSortDir] = React.useState('asc');
  const [keyFilter, setKeyFilter] = React.useState('any'); // any | with | without
  const [tariffFilter, setTariffFilter] = React.useState('any'); // any | Standard | Student
  const [sortOpen, setSortOpen] = React.useState(false);

  // Aplikuj preset filtru z navigace (Dashboard → list)
  React.useEffect(() => { if (filterPreset) setFilter(filterPreset); }, [filterPreset]);

  // Stav členů
  const all = s.members;
  const counts = {
    all: all.length,
    ok:    all.filter(m => m.state === 'ok').length,
    warn:  all.filter(m => m.state === 'warn').length,
    error: all.filter(m => m.state === 'error').length,
  };

  const filtered = all.filter(m => {
    if (filter !== 'all' && m.state !== filter) return false;
    if (keyFilter === 'with' && !m.hasKey) return false;
    if (keyFilter === 'without' && m.hasKey) return false;
    if (tariffFilter !== 'any' && m.tariff !== tariffFilter) return false;
    if (q) {
      const haystack = `${m.name} ${m.email || ''} ${m.phone || ''} ${m.tariff || ''}`.toLowerCase();
      if (!haystack.includes(q.toLowerCase())) return false;
    }
    return true;
  });

  const extraFiltersCount = (keyFilter !== 'any' ? 1 : 0) + (tariffFilter !== 'any' ? 1 : 0);

  const sorted = [...filtered].sort((a, b) => {
    let d = 0;
    if (sortBy === 'name')      d = a.name.localeCompare(b.name, 'cs');
    if (sortBy === 'expiration') d = (a.daysNum ?? 9999) - (b.daysNum ?? 9999);
    if (sortBy === 'tariff')    d = a.tariff.localeCompare(b.tariff, 'cs') || (a.daysNum - b.daysNum);
    return sortDir === 'asc' ? d : -d;
  });

  const fmtDays = (m) => {
    if (m.suspended) return 'pozastaveno';
    if (m.daysNum < 0) return `před ${Math.abs(m.daysNum)} ${Math.abs(m.daysNum) === 1 ? 'dnem' : 'dny'}`;
    if (m.daysNum === 1) return '1 den';
    if (m.daysNum < 5) return `${m.daysNum} dny`;
    return `${m.daysNum} dní`;
  };

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '0 20px 12px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 4 }}>
          <div>
            <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8 }}>Členové</div>
            <div style={{ fontSize: 12.5, color: T.text2, marginTop: 4 }}>
              {counts.all} celkem · {counts.ok} aktivní · {counts.warn + counts.error} potřebuje pozornost
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <div style={{ position: 'relative' }}>
              <RoundBtn icon={Icons.sliders} onClick={() => setSortOpen(true)}/>
              {extraFiltersCount > 0 && (
                <span style={{
                  position: 'absolute', top: -2, right: -2,
                  minWidth: 16, height: 16, padding: '0 4px', borderRadius: 8,
                  background: T.accent, color: '#fff', fontSize: 10, fontWeight: 700,
                  display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
                  border: `2px solid ${T.bg}`, fontFamily: FontMono, lineHeight: 1,
                }}>{extraFiltersCount}</span>
              )}
            </div>
            <RoundBtn icon={Icons.user_plus} primary onClick={() => onNav('addMember')}/>
          </div>
        </div>

        {/* Search */}
        <div style={{ marginTop: 12, height: 40, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12, display: 'flex', alignItems: 'center', padding: '0 12px', gap: 8 }}>
          <span style={{ color: T.text2, display: 'flex' }}>{React.cloneElement(Icons.search, { size: 16 })}</span>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Hledat člena, telefon, e-mail…"
            style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: T.text, fontSize: 14, fontFamily: FontUI }}
          />
          {q && <span onClick={() => setQ('')} style={{ cursor: 'pointer', color: T.text3 }}>{React.cloneElement(Icons.x, { size: 14 })}</span>}
        </div>

        {/* Filter chips */}
        <div style={{ marginTop: 10, display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2 }}>
          <Chip active={filter === 'all'}    onClick={() => setFilter('all')}>Vše · {counts.all}</Chip>
          <Chip active={filter === 'ok'}     onClick={() => setFilter('ok')}><StatusDot state="ok" size={6}/> Aktivní {counts.ok}</Chip>
          <Chip active={filter === 'warn'}   onClick={() => setFilter('warn')}><StatusDot state="warn" size={6}/> Končí {counts.warn}</Chip>
          <Chip active={filter === 'error'}  onClick={() => setFilter('error')}><StatusDot state="error" size={6}/> Po lhůtě {counts.error}</Chip>
        </div>
      </div>

      <div style={{ padding: '4px 20px 110px' }}>
        {/* Section header */}
        <div onClick={() => setSortDir(d => d === 'asc' ? 'desc' : 'asc')} style={{
          position: 'sticky', top: 0, background: T.bg,
          padding: '8px 4px', fontSize: 11.5, fontWeight: 600,
          letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase',
          display: 'flex', justifyContent: 'space-between', cursor: 'pointer', userSelect: 'none',
        }}>
          <span>
            {sorted.length} {sorted.length === 1 ? 'člen' : (sorted.length > 1 && sorted.length < 5 ? 'členové' : 'členů')}
            <span style={{ color: T.text3 }}> · </span>
            <span style={{ color: T.accent }}>{SORT_LABELS[sortBy]}</span>
          </span>
          <span style={{ fontFamily: FontMono }}>{sortDir === 'asc' ? '↑' : '↓'}</span>
        </div>

        {sorted.length === 0 ? (
          <div style={{ padding: '40px 12px', textAlign: 'center', color: T.text3, fontSize: 13 }}>
            {q ? `Nikdo neodpovídá "${q}"` : 'Žádní členové pro vybraný filtr.'}
          </div>
        ) : sorted.map((m) => (
          <MemberRow key={m.id} member={m} daysLabel={fmtDays(m)}
            onClick={() => onNav('detail', { memberId: m.id })}/>
        ))}
      </div>

      {sortOpen && (
        <FilterSortSheet
          sortBy={sortBy} sortDir={sortDir}
          keyFilter={keyFilter} tariffFilter={tariffFilter}
          onPickSort={(by) => setSortBy(by)}
          onToggleDir={() => setSortDir(d => d === 'asc' ? 'desc' : 'asc')}
          onPickKey={setKeyFilter}
          onPickTariff={setTariffFilter}
          onReset={() => { setSortBy('expiration'); setSortDir('asc'); setKeyFilter('any'); setTariffFilter('any'); }}
          onClose={() => setSortOpen(false)}
        />
      )}

      <AdminBottomNav active={1} onNav={onNav}/>
    </div>
  );
}

const SORT_LABELS = {
  expiration: 'expirace',
  name: 'jméno',
  tariff: 'tarif',
};

function RoundBtn({ icon, primary, onClick }) {
  return (
    <div onClick={onClick} style={{
      width: 40, height: 40, borderRadius: '50%',
      background: primary ? T.accent : T.surface,
      border: primary ? 'none' : `1px solid ${T.border}`,
      color: primary ? '#fff' : T.text,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer',
    }}>{React.cloneElement(icon, { size: 18 })}</div>
  );
}

function Chip({ children, active, onClick }) {
  return (
    <div onClick={onClick} style={{
      flexShrink: 0, height: 32, padding: '0 12px', borderRadius: 100,
      background: active ? T.text : T.surface,
      border: `1px solid ${active ? T.text : T.border}`,
      color: active ? T.bg : T.text, fontSize: 13, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', gap: 6,
      cursor: 'pointer', userSelect: 'none',
    }}>{children}</div>
  );
}

function MemberRow({ member, daysLabel, onClick }) {
  const m = member;
  const stateColor = m.state === 'ok' ? T.ok : m.state === 'warn' ? T.warn : m.state === 'error' ? T.error : T.text2;
  return (
    <div onClick={onClick} style={{
      cursor: onClick ? 'pointer' : 'default',
      padding: '14px 4px', display: 'flex', alignItems: 'center', gap: 12,
      borderBottom: `1px solid ${T.divider}`,
    }}>
      <Avatar name={m.name} size={40}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: -0.2, display: 'flex', alignItems: 'center', gap: 6 }}>
          {m.name}
          {m.isic && <span style={{ fontSize: 9.5, fontWeight: 700, color: T.text2, border: `1px solid ${T.border}`, padding: '1px 4px', borderRadius: 4, letterSpacing: 0.4 }}>ISIC</span>}
        </div>
        <div style={{ fontSize: 12.5, color: T.text2, marginTop: 2, display: 'flex', alignItems: 'center', gap: 6 }}>
          <span>{m.tariff}</span>
          <span style={{ color: T.text3 }}>·</span>
          {m.hasKey ? (
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 3, color: m.overdue ? T.error : T.text2 }}>
              {React.cloneElement(Icons.key, { size: 11 })}
              klíč
            </span>
          ) : (
            <span style={{ color: T.text3 }}>bez klíče</span>
          )}
        </div>
      </div>
      <div style={{ textAlign: 'right', flexShrink: 0, whiteSpace: 'nowrap' }}>
        <div style={{ fontSize: 13, fontWeight: 600, color: stateColor, fontFamily: FontMono }}>{daysLabel}</div>
        <div style={{ fontSize: 11, color: T.text3, marginTop: 2 }}>
          {m.state === 'ok' && 'do expirace'}
          {m.state === 'warn' && 'končí'}
          {m.state === 'error' && 'po lhůtě'}
          {m.state === 'muted' && '30+ dní'}
        </div>
      </div>
    </div>
  );
}

function FilterSortSheet({ sortBy, sortDir, keyFilter, tariffFilter, onPickSort, onToggleDir, onPickKey, onPickTariff, onReset, onClose }) {
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(4px)',
      display: 'flex', alignItems: 'flex-end',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: T.surface, borderTopLeftRadius: 20, borderTopRightRadius: 20,
        width: '100%', padding: 14, border: `1px solid ${T.border}`, maxHeight: '85%', overflowY: 'auto',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
          <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.3 }}>Filtr a řazení</div>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <span onClick={onReset} style={{ cursor: 'pointer', fontSize: 12.5, color: T.text2 }}>resetovat</span>
            <div onClick={onClose} style={{ cursor: 'pointer', color: T.text2 }}>{React.cloneElement(Icons.x, { size: 20 })}</div>
          </div>
        </div>

        <SheetLabel>Řadit podle</SheetLabel>
        {[
          { value: 'expiration', label: 'Expirace', sub: 'kdo končí nejdřív' },
          { value: 'name',       label: 'Jméno',    sub: 'abecedně' },
          { value: 'tariff',     label: 'Tarif',    sub: 'Standard / Student' },
        ].map(o => {
          const active = o.value === sortBy;
          return (
            <div key={o.value} onClick={() => onPickSort(o.value)} style={{
              padding: '10px 10px', borderRadius: 10, cursor: 'pointer',
              background: active ? T.surface2 : 'transparent',
              display: 'flex', alignItems: 'center', gap: 12,
            }}>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: -0.2 }}>{o.label}</div>
                <div style={{ fontSize: 11.5, color: T.text2, marginTop: 1 }}>{o.sub}</div>
              </div>
              {active && <span style={{ color: T.accent }}>{React.cloneElement(Icons.check, { size: 18, stroke: 2.4 })}</span>}
            </div>
          );
        })}
        <div onClick={onToggleDir} style={{
          marginTop: 4, padding: '10px 10px', borderRadius: 10, cursor: 'pointer',
          background: T.surface2, display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <span style={{ color: T.accent, fontFamily: FontMono, fontSize: 18, width: 18, textAlign: 'center' }}>{sortDir === 'asc' ? '↑' : '↓'}</span>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 14, fontWeight: 600, letterSpacing: -0.2 }}>{sortDir === 'asc' ? 'Vzestupně' : 'Sestupně'}</div>
            <div style={{ fontSize: 11.5, color: T.text2, marginTop: 1 }}>Klepni pro otočení</div>
          </div>
        </div>

        <SheetLabel>Tarif</SheetLabel>
        <Seg value={tariffFilter} onChange={onPickTariff} options={[
          { value: 'any',      label: 'Oba' },
          { value: 'Standard', label: 'Standard' },
          { value: 'Student',  label: 'Student' },
        ]}/>

        <SheetLabel>Klíč</SheetLabel>
        <Seg value={keyFilter} onChange={onPickKey} options={[
          { value: 'any',     label: 'Všichni' },
          { value: 'with',    label: 'S klíčem' },
          { value: 'without', label: 'Bez klíče' },
        ]}/>

        <button onClick={onClose} style={{
          marginTop: 18, width: '100%', height: 48, borderRadius: 12, border: 'none',
          background: T.accent, color: '#fff', fontSize: 15, fontWeight: 600, fontFamily: FontUI,
          cursor: 'pointer', letterSpacing: -0.2,
        }}>Použít</button>
      </div>
    </div>
  );
}

function SheetLabel({ children }) {
  return (
    <div style={{ marginTop: 14, marginBottom: 6, fontSize: 11, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>{children}</div>
  );
}

function Seg({ value, onChange, options }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: `repeat(${options.length}, 1fr)`, gap: 4, padding: 4, background: T.surface2, borderRadius: 10 }}>
      {options.map(o => {
        const active = o.value === value;
        return (
          <div key={o.value} onClick={() => onChange(o.value)} style={{
            padding: '8px 6px', textAlign: 'center', borderRadius: 8,
            background: active ? T.bg : 'transparent',
            border: active ? `1px solid ${T.border}` : '1px solid transparent',
            cursor: 'pointer', userSelect: 'none',
            fontSize: 13, fontWeight: 600, color: active ? T.text : T.text2, letterSpacing: -0.2,
          }}>{o.label}</div>
        );
      })}
    </div>
  );
}

Object.assign(window, { MemberList });
