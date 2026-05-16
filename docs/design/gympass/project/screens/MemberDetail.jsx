// MemberDetail.jsx — detail člena pro admina

function MemberDetail({ onNav = () => {}, goBack, memberId }) {
  const s = useStore();
  const m = (memberId && s.memberById(memberId)) || s.memberById('pavel') || s.members[0];
  const stateLabel = m.state === 'ok' ? `Aktivní · ${m.daysNum} dní`
    : m.state === 'warn' ? `Končí za ${m.daysNum} dní`
    : m.state === 'error' ? `Po lhůtě · ${Math.abs(m.daysNum)} dní`
    : 'Pozastaveno';
  const memberPayments = s.payments
    .map(p => ({ ...p, date: new Date(p.date) }))
    .filter(p => p.memberId === m.id)
    .sort((a, b) => b.date - a.date);

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* Top bar */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 16px 12px' }}>
        <div onClick={() => goBack ? goBack() : onNav('list')} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.back, { size: 18 })}
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.text2 }}>Detail člena</div>
        <div onClick={() => onNav('addMember', { memberId: m.id })} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.edit, { size: 16 })}
        </div>
      </div>

      <div style={{ padding: '4px 20px 40px' }}>
        {/* Hero */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <PhotoAvatar id={`member-${m.id}`} name={m.name} size={72}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.6, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{m.name}</div>
            <div style={{ fontSize: 13, color: T.text2, marginTop: 4 }}>{m.tariff}{m.isic ? ' · ISIC' : ''} · člen od {m.joined}</div>
            <div style={{ marginTop: 8 }}><StatusPill state={m.state === 'muted' ? 'muted' : m.state}>{stateLabel}</StatusPill></div>
          </div>
        </div>

        {/* Rychlé akce */}
        <div style={{ marginTop: 18, display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8 }}>
          <DetailQuick icon={Icons.message} label="Zpráva" onClick={() => onNav('thread', { memberId: m.id })}/>
          <DetailQuick icon={Icons.cash}    label="Platba"  onClick={() => onNav('payments')}/>
          <DetailQuick icon={Icons.refresh} label="Prodloužit" onClick={() => onNav('qr')}/>
        </div>

        {/* Contact */}
        <Card style={{ marginTop: 18, padding: 0 }}>
          <KV label="E-mail" value={m.email}/>
          <Divider/>
          <KV label="Telefon" value={m.phone} mono/>
          <Divider/>
          <KV label="Tarif" value={`${m.tariff}${m.isic ? ' · ISIC' : ''}`}/>
          <Divider/>
          <KVPrice m={m} onEdit={() => onNav('addMember', { memberId: m.id })}/>
          <Divider/>
          <KV label="Platí do" value={m.expiresAt} mono last/>
        </Card>

        {/* Klimat (vyžaduje pozornost) */}
        {(m.state === 'error' || m.state === 'warn') && (
          <div style={{
            marginTop: 16, padding: '12px 14px',
            background: m.state === 'error' ? T.errorSoft : T.warnSoft,
            color: m.state === 'error' ? T.error : T.warn,
            borderRadius: 12, fontSize: 13, fontWeight: 500,
            display: 'flex', alignItems: 'center', gap: 10,
          }}>
            {React.cloneElement(Icons.alert, { size: 16, stroke: 2 })}
            <span style={{ flex: 1 }}>{m.state === 'error' ? `Platba ${Math.abs(m.daysNum)} dní po lhůtě` : `Končí za ${m.daysNum} dní`}</span>
            <span onClick={() => onNav('thread', { memberId: m.id })} style={{
              cursor: 'pointer', fontSize: 12, fontWeight: 600, padding: '4px 10px',
              background: 'rgba(255,255,255,0.08)', borderRadius: 100,
            }}>Napsat</span>
          </div>
        )}

        {/* Klíč + kauce */}
        <SectionLabelBlock>Klíč &amp; kauce</SectionLabelBlock>
        <Card style={{ marginTop: 12, padding: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{ width: 44, height: 44, borderRadius: 12, background: T.accentSoft, color: T.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {React.cloneElement(Icons.key, { size: 22 })}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 600 }}>Klíč</div>
              <div style={{ fontSize: 12.5, color: T.text2, marginTop: 2, fontFamily: FontMono }}>vydán 14. 9. 2025</div>
            </div>
            <StatusPill state="ok">U člena</StatusPill>
          </div>
          <div style={{ height: 1, background: T.divider, margin: '14px 0' }}/>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontSize: 13, color: T.text2 }}>Kauce</div>
              <div style={{ fontSize: 17, fontWeight: 700, fontFamily: FontMono, marginTop: 2 }}>100 Kč</div>
            </div>
            <StatusPill state="ok">Přijata</StatusPill>
          </div>
          <Btn full variant="secondary" style={{ marginTop: 14, height: 44 }}>Označit jako vrácený</Btn>
        </Card>

        {/* Platby */}
        <SectionLabelBlock right={<span style={{ color: T.text2 }}>od {m.joined}</span>}>Platby</SectionLabelBlock>
        <Card style={{ marginTop: 12, padding: 0 }}>
          {memberPayments.length === 0 ? (
            <div style={{ padding: 20, textAlign: 'center', color: T.text3, fontSize: 13 }}>Zatím žádné platby.</div>
          ) : memberPayments.map((p, i) => (
            <PayRow key={p.id}
              date={`${p.date.getDate()}. ${p.date.getMonth() + 1}. ${p.date.getFullYear()}`}
              desc={p.type}
              amount={`${p.amount.toLocaleString('cs-CZ').replace(/,/g, ' ')} Kč`}
              state={p.state}
              last={i === memberPayments.length - 1}/>
          ))}
        </Card>
        <Btn full variant="ghost" icon={React.cloneElement(Icons.plus, { size: 16 })} style={{ marginTop: 12 }}>Manuální platba (cash)</Btn>

        {/* Danger zone */}
        <SectionLabelBlock>Akce</SectionLabelBlock>
        <div style={{ marginTop: 12, display: 'flex', flexDirection: 'column', gap: 8 }}>
          <ActionRow icon={Icons.pause} label="Pozastavit členství" sub="Členství zůstane v systému, neeviduje se platba" />
          <ActionRow icon={Icons.trash} label="Smazat člena" sub="Nevratná akce, vyžaduje potvrzení" danger />
        </div>
      </div>
    </div>
  );
}

function KV({ label, value, mono, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 16px', borderBottom: last ? 'none' : undefined, gap: 12 }}>
      <span style={{ fontSize: 13, color: T.text2, flexShrink: 0 }}>{label}</span>
      <span style={{ fontSize: 14, fontWeight: 500, fontFamily: mono ? FontMono : FontUI, textAlign: 'right', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{value}</span>
    </div>
  );
}

function KVPrice({ m, onEdit }) {
  const tariffDefault = m.tariff === 'Student' ? 500 : 750;
  const price = m.monthlyPrice || tariffDefault;
  const isCustom = price !== tariffDefault;
  return (
    <div onClick={onEdit} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 16px', cursor: 'pointer', gap: 12 }}>
      <span style={{ fontSize: 13, color: T.text2 }}>Cena/měs.</span>
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8, whiteSpace: 'nowrap' }}>
        {isCustom && (
          <span style={{ fontSize: 9.5, fontWeight: 700, color: T.accent, background: T.accentSoft, padding: '2px 6px', borderRadius: 4, letterSpacing: 0.4, textTransform: 'uppercase' }}>vlastní</span>
        )}
        <span style={{ fontSize: 14, fontWeight: 600, fontFamily: FontMono, color: isCustom ? T.accent : T.text }}>{price} Kč</span>
        <span style={{ color: T.text3 }}>{React.cloneElement(Icons.edit, { size: 13 })}</span>
      </span>
    </div>
  );
}

function SectionLabelBlock({ children, right }) {
  return (
    <div style={{ marginTop: 24, display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
      <div style={{ fontSize: 12.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>{children}</div>
      {right && <div style={{ fontSize: 12.5 }}>{right}</div>}
    </div>
  );
}

function PayRow({ date, desc, amount, state, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderBottom: last ? 'none' : `1px solid ${T.divider}` }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, background: T.okSoft, color: T.ok, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {React.cloneElement(Icons.check, { size: 16, stroke: 2.4 })}
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14, fontWeight: 500 }}>{desc}</div>
        <div style={{ fontSize: 12, color: T.text2, fontFamily: FontMono, marginTop: 2 }}>{date}</div>
      </div>
      <div style={{ fontSize: 14, fontWeight: 600, fontFamily: FontMono }}>{amount}</div>
      <span style={{ color: T.text3 }}>{React.cloneElement(Icons.download, { size: 16 })}</span>
    </div>
  );
}

function ActionRow({ icon, label, sub, danger }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: 14,
      background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12,
    }}>
      <div style={{ color: danger ? T.error : T.text2 }}>{React.cloneElement(icon, { size: 18 })}</div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, fontWeight: 500, color: danger ? T.error : T.text }}>{label}</div>
        <div style={{ fontSize: 12, color: T.text2, marginTop: 2, lineHeight: 1.3 }}>{sub}</div>
      </div>
      <span style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 16 })}</span>
    </div>
  );
}

function DetailQuick({ icon, label, onClick }) {
  return (
    <div onClick={onClick} style={{
      padding: '12px 8px', background: T.surface, border: `1px solid ${T.border}`,
      borderRadius: 12, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
      cursor: 'pointer',
    }}>
      <div style={{ width: 30, height: 30, borderRadius: 9, background: T.accentSoft, color: T.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {React.cloneElement(icon, { size: 16 })}
      </div>
      <div style={{ fontSize: 11.5, fontWeight: 500, letterSpacing: -0.1 }}>{label}</div>
    </div>
  );
}

Object.assign(window, { MemberDetail });
