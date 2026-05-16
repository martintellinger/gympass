// AdminDashboard.jsx — denní pohled majitele

function AdminDashboard({ onNav = () => {} }) {
  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '4px 24px 110px' }}>
        {/* Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 4 }}>
          <div>
            <div style={{ fontSize: 12.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>BýtFit Admin</div>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.6, marginTop: 4 }}>Dobré ráno, Oldo.</div>
          </div>
          <div style={{ width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text2 }}>
            {React.cloneElement(Icons.bell, { size: 18 })}
          </div>
        </div>

        {/* Top stats — 2x2 */}
        <div style={{ marginTop: 20, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <Stat label="Aktivních" value="34" sub="z 34" />
          <Stat label="Končí ≤ 7 dní" value="5" sub="vyhraj výročí" color={T.warn} />
          <Stat label="Po lhůtě" value="2" sub="urgent" color={T.error} />
          <Stat label="Příjem 5/26" value="28 950" sub="Kč" />
        </div>

        {/* Vyžaduje pozornost */}
        <div style={{ marginTop: 24 }}>
          <SectionLabel>Vyžaduje pozornost</SectionLabel>
          <Card style={{ marginTop: 12, padding: 0 }}>
            <AttentionRow onClick={() => onNav('approval')} icon={Icons.user_check} title="2 čekající registrace" sub="Jana K., Tomáš H." accent />
            <Divider/>
            <AttentionRow onClick={() => onNav('list', { filterPreset: 'error' })} icon={Icons.alert} title="2 po lhůtě" sub="David, Petr · zaplať co nejdřív" warn />
            <Divider/>
            <AttentionRow onClick={() => onNav('list', { filterPreset: 'warn' })} icon={Icons.calendar} title="5 končí brzy" sub="Tento týden" />
          </Card>
        </div>

        {/* Quick actions */}
        <div style={{ marginTop: 24 }}>
          <SectionLabel>Rychlé akce</SectionLabel>
          <div style={{ marginTop: 12, display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
            <QuickAction icon={Icons.message}   label="Poslat zprávu" onClick={() => onNav('messages')} />
            <QuickAction icon={Icons.cash}      label="Platby"        onClick={() => onNav('payments')} />
            <QuickAction icon={Icons.user_plus} label="Přidat člena"  onClick={() => onNav('addMember')} />
          </div>
        </div>

        {/* Revenue chart */}
        <div style={{ marginTop: 24 }}>
          <SectionLabel right={<span style={{ color: T.text2 }}>6 měsíců</span>}>Příjem</SectionLabel>
          <Card style={{ marginTop: 12 }}>
            <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
              <span style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8, fontFamily: FontMono }}>28 950</span>
              <span style={{ fontSize: 13, color: T.text2 }}>Kč · květen</span>
              <span style={{ marginLeft: 'auto', fontSize: 12, fontWeight: 600, color: T.ok, fontFamily: FontMono }}>+8,5 %</span>
            </div>
            <RevenueChart/>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, fontSize: 10.5, color: T.text3, fontFamily: FontMono, letterSpacing: 0.5 }}>
              <span>PRO</span><span>LED</span><span>ÚNO</span><span>BŘE</span><span>DUB</span><span>KVĚ</span>
            </div>
          </Card>
        </div>
      </div>

      <AdminBottomNav active={0} onNav={onNav}/>
    </div>
  );
}

function Stat({ label, value, sub, color }) {
  return (
    <div style={{ background: T.surface, border: `1px solid ${T.border}`, borderRadius: 14, padding: 14 }}>
      <div style={{ fontSize: 11.5, fontWeight: 600, letterSpacing: 0.3, color: T.text2, textTransform: 'uppercase' }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 4, marginTop: 8 }}>
        <span style={{ fontSize: 28, fontWeight: 700, letterSpacing: -1, fontFamily: FontMono, color: color || T.text, lineHeight: 1 }}>{value}</span>
        <span style={{ fontSize: 12, color: T.text3 }}>{sub}</span>
      </div>
    </div>
  );
}

function AttentionRow({ icon, title, sub, accent, warn, onClick }) {
  const c = accent ? T.accent : warn ? T.warn : T.text;
  const bg = accent ? T.accentSoft : warn ? T.warnSoft : T.surface2;
  return (
    <div onClick={onClick} style={{ cursor: onClick ? 'pointer' : 'default', display: 'flex', alignItems: 'center', gap: 12, padding: 14 }}>
      <div style={{ width: 36, height: 36, borderRadius: 10, background: bg, color: c, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {React.cloneElement(icon, { size: 18 })}
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontSize: 12.5, color: T.text2, marginTop: 2 }}>{sub}</div>
      </div>
      <span style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 16 })}</span>
    </div>
  );
}

function QuickAction({ icon, label, onClick }) {
  return (
    <div onClick={onClick} style={{
      padding: '16px 8px', background: T.surface, border: `1px solid ${T.border}`,
      borderRadius: 14, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8,
      cursor: onClick ? 'pointer' : 'default',
    }}>
      <div style={{ width: 36, height: 36, borderRadius: 10, background: T.accentSoft, color: T.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {React.cloneElement(icon, { size: 18 })}
      </div>
      <div style={{ fontSize: 11.5, fontWeight: 500, textAlign: 'center', letterSpacing: -0.1, lineHeight: 1.2 }}>{label}</div>
    </div>
  );
}

function RevenueChart() {
  const data = [21500, 24200, 22800, 25400, 26700, 28950];
  const max = Math.max(...data);
  return (
    <div style={{ marginTop: 16, display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 8, height: 100, alignItems: 'flex-end' }}>
      {data.map((v, i) => {
        const last = i === data.length - 1;
        const h = (v / max) * 100;
        return (
          <div key={i} style={{
            height: `${h}%`, borderRadius: 6,
            background: last ? T.accent : T.surface2,
            border: last ? 'none' : `1px solid ${T.border}`,
            position: 'relative',
          }}>
            {last && (
              <div style={{ position: 'absolute', bottom: '100%', left: '50%', transform: 'translate(-50%, -4px)', fontSize: 10, fontFamily: FontMono, color: T.text2, whiteSpace: 'nowrap' }}>29k</div>
            )}
          </div>
        );
      })}
    </div>
  );
}

Object.assign(window, { AdminDashboard });
