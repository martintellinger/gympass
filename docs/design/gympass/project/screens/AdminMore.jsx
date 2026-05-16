// AdminMore.jsx — "Více" pro majitele: nastavení Klubu, nástěnka, schvalování, FAQ
// Funkční řádky vedou na další obrazovky; ostatní jsou připravené sekce.

function AdminMore({ onNav = () => {} }) {
  const s = useStore();
  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar/>
      <div style={{ padding: '4px 20px 110px' }}>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8 }}>Více</div>

        {/* Olda — vizitka */}
        <div style={{
          marginTop: 14, padding: 14, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 14,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <Avatar name="Oldřich Klub" size={48}/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15.5, fontWeight: 700, letterSpacing: -0.3 }}>Oldřich Klub</div>
            <div style={{ fontSize: 12.5, color: T.text2, marginTop: 2 }}>majitel · BýtFit Klub</div>
          </div>
          <span style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 16 })}</span>
        </div>

        {/* Aktivita */}
        <MoreSectionLabel>Aktivita</MoreSectionLabel>
        <MoreCard>
          <MoreRow icon={Icons.user_check}
            label="Schvalování registrací"
            sub="2 čekající žádosti"
            badge={2}
            onClick={() => onNav('approval')}/>
          <MoreDivider/>
          <MoreRow icon={Icons.board}
            label="Nástěnka"
            sub="Připnout, mimo provoz, akce"
            onClick={() => onNav('board')}/>
          <MoreDivider/>
          <MoreRow icon={Icons.megaphone}
            label="Hromadná zpráva všem"
            sub={`${s.members.length} členů`}
            onClick={() => onNav('messages', { broadcast: true })}/>
        </MoreCard>

        {/* Klub */}
        <MoreSectionLabel>Klub</MoreSectionLabel>
        <MoreCard>
          <MoreRow icon={Icons.tag}
            label="Tarify a ceny"
            sub="Standard 2 250 · Student 1 500 · 6m / 12m"/>
          <MoreDivider/>
          <MoreRow icon={Icons.calendar}
            label="Otevírací doba"
            sub="Po–Pá 6:00–22:00 · So–Ne 8:00–20:00"/>
          <MoreDivider/>
          <MoreRow icon={Icons.key}
            label="Klíče a kauce"
            sub="34 vydaných · 2 propadlé kauce"/>
          <MoreDivider/>
          <MoreRow icon={Icons.shield}
            label="Pravidla Klubu"
            sub="Naposledy aktualizováno 3. 4. 2026" last/>
        </MoreCard>

        {/* Data */}
        <MoreSectionLabel>Data</MoreSectionLabel>
        <MoreCard>
          <MoreRow icon={Icons.download}
            label="Export plateb (CSV)"
            sub="Pro účetnictví · poslední 12 měsíců"/>
          <MoreDivider/>
          <MoreRow icon={Icons.refresh}
            label="Záloha databáze"
            sub="Poslední záloha · dnes 03:00" last/>
        </MoreCard>

        {/* Účet */}
        <MoreSectionLabel>Účet</MoreSectionLabel>
        <MoreCard>
          <MoreRow icon={Icons.help}
            label="Nápověda &amp; FAQ"
            sub="Pravidla aplikace, dotazy"/>
          <MoreDivider/>
          <MoreRow icon={Icons.logout}
            label="Odhlásit Oldu"
            danger last/>
        </MoreCard>

        <div style={{ marginTop: 20, textAlign: 'center', fontSize: 11, color: T.text3, fontFamily: FontMono, letterSpacing: 0.5 }}>
          BÝTFIT KLUB · v1.0.0
        </div>
      </div>

      <AdminBottomNav active={4} onNav={onNav}/>
    </div>
  );
}

function MoreSectionLabel({ children }) {
  return (
    <div style={{ marginTop: 22, marginBottom: 10, fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>
      {children}
    </div>
  );
}
function MoreCard({ children }) {
  return <div style={{ background: T.surface, border: `1px solid ${T.border}`, borderRadius: 14, overflow: 'hidden' }}>{children}</div>;
}
function MoreDivider() {
  return <div style={{ height: 1, background: T.divider, marginLeft: 56 }}/>;
}
function MoreRow({ icon, label, sub, badge, danger, last, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '13px 14px',
      cursor: onClick ? 'pointer' : 'default',
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: 9,
        background: danger ? T.errorSoft : T.surface2,
        color: danger ? T.error : T.text,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>{React.cloneElement(icon, { size: 16 })}</div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: danger ? T.error : T.text, letterSpacing: -0.2 }}>{label}</div>
        {sub && <div style={{ fontSize: 12, color: T.text2, marginTop: 2 }}>{sub}</div>}
      </div>
      {badge ? (
        <span style={{
          background: T.accent, color: '#fff', fontSize: 11, fontWeight: 700,
          padding: '2px 7px', borderRadius: 100, fontFamily: FontMono,
        }}>{badge}</span>
      ) : null}
      {onClick && <span style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 16 })}</span>}
    </div>
  );
}

Object.assign(window, { AdminMore });
