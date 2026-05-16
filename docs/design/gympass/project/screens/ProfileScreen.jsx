// ProfileScreen.jsx — profil člena (údaje, nastavení, klíč, odhlášení)

function ProfileScreen({ onNav = () => {} }) {
  const [push, setPush] = React.useState(true);
  const [outage, setOutage] = React.useState(true);
  const [promo, setPromo] = React.useState(false);
  const [lang, setLang] = React.useState('cs');
  const [theme, setTheme] = React.useState('dark');

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '4px 24px 110px' }}>
        {/* Hero */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginTop: 8 }}>
          <Avatar name="Pavel Novák" size={64}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 20, fontWeight: 700, letterSpacing: -0.5 }}>Pavel Novák</div>
            <div style={{ fontSize: 13, color: T.text2, marginTop: 4 }}>člen od 9 · 2025</div>
            <div style={{ marginTop: 8 }}><StatusPill state="ok">Aktivní · 23 dní</StatusPill></div>
          </div>
          <div onClick={() => onNav('card')} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text2 }}>
            {React.cloneElement(Icons.edit, { size: 14 })}
          </div>
        </div>

        {/* Kontakt */}
        <PSection label="Kontakt">
          <PRow icon={Icons.message} label="E-mail" value="pavel.novak@email.cz"/>
          <PDivider/>
          <PRow icon={Icons.bell} label="Telefon" value="+420 728 451 209" mono last/>
        </PSection>

        {/* Členství */}
        <PSection label="Členství">
          <PRow icon={Icons.dumbbell} label="Tarif" value="Standard · 3 měs."/>
          <PDivider/>
          <PRow icon={Icons.calendar} label="Platí do" value="23. 6. 2026" mono/>
          <PDivider/>
          <PRow icon={Icons.key} label="Klíč" value="u tebe" pill={<StatusPill state="ok">100 Kč</StatusPill>} last/>
        </PSection>

        {/* Notifikace */}
        <PSection label="Notifikace">
          <PToggle icon={Icons.bell} label="Push notifikace" sub="Konec členství, schválení žádostí" value={push} onChange={setPush}/>
          <PDivider/>
          <PToggle icon={Icons.tool} label="Výpadky a zavírací doba" sub="Když je v Klubu něco mimo provoz" value={outage} onChange={setOutage}/>
          <PDivider/>
          <PToggle icon={Icons.tag} label="Akce a slevy" sub="Občas, ne víc než 1× měsíčně" value={promo} onChange={setPromo} last/>
        </PSection>

        {/* Vzhled & jazyk */}
        <PSection label="Vzhled & jazyk">
          <PSegment icon={Icons.moon} label="Téma" value={theme} options={[['dark','Tmavé'],['system','Systém'],['light','Světlé']]} onChange={setTheme}/>
          <PDivider/>
          <PSegment icon={Icons.globe} label="Jazyk" value={lang} options={[['cs','CZ'],['en','EN']]} onChange={setLang} last/>
        </PSection>

        {/* Pomoc */}
        <PSection label="Pomoc">
          <PNav icon={Icons.help} label="FAQ" sub="Časté otázky a pravidla Klubu"/>
          <PDivider/>
          <PNav icon={Icons.message} label="Napsat Oldovi" sub="Odpovídá obvykle do hodiny" last/>
        </PSection>

        {/* Sign out */}
        <div style={{ marginTop: 16 }}>
          <div style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: 14,
            background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12,
            cursor: 'pointer', color: T.error,
          }}>
            {React.cloneElement(Icons.logout, { size: 16 })}
            <span style={{ fontSize: 14.5, fontWeight: 500 }}>Odhlásit</span>
          </div>
        </div>

        <div style={{ marginTop: 18, fontSize: 11, color: T.text3, textAlign: 'center', lineHeight: 1.5 }}>
          BýtFit Klub · v1.0.0 · sestaveno 5/2026
        </div>
      </div>

      <MemberBottomNav active={4} onNav={onNav}/>
    </div>
  );
}

function PSection({ label, children }) {
  return (
    <div style={{ marginTop: 22 }}>
      <div style={{ fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase', marginBottom: 8 }}>{label}</div>
      <Card style={{ padding: 0 }}>{children}</Card>
    </div>
  );
}

function PDivider() {
  return <div style={{ height: 1, background: T.divider, marginLeft: 50 }}/>;
}

function PRow({ icon, label, value, mono, pill, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
      <div style={{ width: 28, height: 28, borderRadius: 8, background: T.surface2, color: T.text2, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {React.cloneElement(icon, { size: 15 })}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 11.5, color: T.text2 }}>{label}</div>
        <div style={{ fontSize: 14, fontWeight: 500, marginTop: 2, fontFamily: mono ? FontMono : FontUI, letterSpacing: mono ? 0 : -0.1, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{value}</div>
      </div>
      {pill}
    </div>
  );
}

function PToggle({ icon, label, sub, value, onChange, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
      <div style={{ width: 28, height: 28, borderRadius: 8, background: T.surface2, color: T.text2, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {React.cloneElement(icon, { size: 15 })}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 500, letterSpacing: -0.1 }}>{label}</div>
        <div style={{ fontSize: 11.5, color: T.text2, marginTop: 2, lineHeight: 1.3 }}>{sub}</div>
      </div>
      <Switch value={value} onChange={() => onChange(!value)}/>
    </div>
  );
}

function Switch({ value, onChange }) {
  return (
    <div onClick={onChange}
      style={{
        width: 42, height: 24, borderRadius: 100,
        background: value ? T.accent : T.surface2,
        border: `1px solid ${value ? T.accent : T.border}`,
        position: 'relative', cursor: 'pointer',
        transition: 'background 160ms',
        flexShrink: 0,
      }}>
      <div style={{
        position: 'absolute', top: 2, left: value ? 20 : 2,
        width: 18, height: 18, borderRadius: '50%', background: '#fff',
        transition: 'left 160ms',
        boxShadow: '0 1px 3px rgba(0,0,0,0.3)',
      }}/>
    </div>
  );
}

function PSegment({ icon, label, value, options, onChange, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px' }}>
      <div style={{ width: 28, height: 28, borderRadius: 8, background: T.surface2, color: T.text2, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {React.cloneElement(icon, { size: 15 })}
      </div>
      <div style={{ flex: 1, fontSize: 14, fontWeight: 500 }}>{label}</div>
      <div style={{ display: 'flex', background: T.surface2, borderRadius: 8, padding: 2, border: `1px solid ${T.border}` }}>
        {options.map(([k, lbl]) => (
          <div key={k} onClick={() => onChange(k)} style={{
            padding: '5px 10px', fontSize: 11.5, fontWeight: 600, borderRadius: 6,
            background: value === k ? T.bg : 'transparent',
            color: value === k ? T.text : T.text2,
            cursor: 'pointer', userSelect: 'none',
            transition: 'background 140ms, color 140ms',
          }}>{lbl}</div>
        ))}
      </div>
    </div>
  );
}

function PNav({ icon, label, sub, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', cursor: 'pointer' }}>
      <div style={{ width: 28, height: 28, borderRadius: 8, background: T.surface2, color: T.text2, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        {React.cloneElement(icon, { size: 15 })}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 500, letterSpacing: -0.1 }}>{label}</div>
        <div style={{ fontSize: 11.5, color: T.text2, marginTop: 2, lineHeight: 1.3 }}>{sub}</div>
      </div>
      <span style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 16 })}</span>
    </div>
  );
}

Object.assign(window, { ProfileScreen });
