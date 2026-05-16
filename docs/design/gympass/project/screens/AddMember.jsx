// AddMember.jsx — Přidat NEBO upravit člena (formulář pro majitele)
// Pokud je předán `memberId`, předvyplní data a uloží přes updateMember.

function AddMember({ onNav = () => {}, goBack, memberId }) {
  const s = useStore();
  const editing = !!(memberId && s.memberById(memberId));
  const existing = editing ? s.memberById(memberId) : null;

  const [name, setName]     = React.useState(existing?.name  || '');
  const [email, setEmail]   = React.useState(existing?.email || '');
  const [phone, setPhone]   = React.useState(existing?.phone || '');
  const [tariff, setTariff] = React.useState(existing?.tariff || 'Standard');
  const [length, setLength] = React.useState(3);
  const [hasKey, setHasKey] = React.useState(existing ? !!existing.hasKey : true);
  const [isic, setIsic]     = React.useState(existing ? !!existing.isic : false);

  // Vlastní cena
  const tariffDefault = tariff === 'Student' ? 500 : 750;
  const isCustom = !!(existing && existing.monthlyPrice && existing.monthlyPrice !== tariffDefault);
  const [customOn, setCustomOn] = React.useState(isCustom);
  const [price, setPrice] = React.useState(existing?.monthlyPrice ?? tariffDefault);
  const [submitted, setSubmitted] = React.useState(false);

  // Když se přepne tarif a vlastní cena není aktivní, sleduj výchozí cenu tarifu
  React.useEffect(() => {
    if (!customOn) setPrice(tariff === 'Student' ? 500 : 750);
  }, [tariff, customOn]);

  const monthly = customOn ? (Number(price) || 0) : tariffDefault;
  const total = monthly * length;
  const isCustomActive = customOn && monthly !== tariffDefault;

  const ok = name.trim().length >= 2 && (email.includes('@') || phone.length >= 9) && monthly > 0;

  const submit = () => {
    setSubmitted(true);
    if (!ok) return;
    const patch = {
      name: name.trim(),
      email: email.trim() || '—',
      phone: phone.trim() || '—',
      tariff,
      isic: tariff === 'Student' && isic,
      hasKey,
      monthlyPrice: monthly,
    };
    if (editing) {
      s.updateMember(existing.id, patch);
      onNav('detail', { memberId: existing.id, toast: `${patch.name} uložen/a` });
    } else {
      const m = s.addMember({
        ...patch,
        daysNum: length * 30,
        expiresAt: `~ ${length * 30} dní`,
      });
      onNav('list', { toast: `${m.name} přidán/a · ${length} měs.` });
    }
  };

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar/>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 16px 12px' }}>
        <div onClick={() => goBack ? goBack() : onNav(editing ? 'detail' : 'list', editing ? { memberId: existing.id } : undefined)} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.back, { size: 18 })}
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.text2 }}>{editing ? 'Upravit člena' : 'Nový člen'}</div>
        <div style={{ width: 36 }}/>
      </div>

      <div style={{ padding: '4px 20px 110px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '6px 2px' }}>
          <Avatar name={name || 'Nový člen'} size={56}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.6, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {name.trim() || <span style={{ color: T.text3 }}>Bez jména</span>}
            </div>
            <div style={{ fontSize: 13, color: T.text2, marginTop: 4 }}>
              {tariff}{tariff === 'Student' && isic ? ' · ISIC' : ''}
              {isCustomActive && <span style={{ color: T.accent }}> · vlastní cena</span>}
            </div>
          </div>
        </div>

        {/* Základní údaje */}
        <FormSection label="Základní">
          <Field
            label="Jméno a příjmení"
            value={name}
            onChange={setName}
            placeholder="např. Pavel Novák"
            invalid={submitted && name.trim().length < 2}
            hint={submitted && name.trim().length < 2 ? 'Vyplň jméno' : null}
          />
          <Field
            label="E-mail"
            value={email}
            onChange={setEmail}
            placeholder="pavel.novak@email.cz"
            type="email"
          />
          <Field
            label="Telefon"
            value={phone}
            onChange={setPhone}
            placeholder="+420 728 451 209"
            mono
            type="tel"
            last
          />
          {submitted && !ok && name.trim().length >= 2 && monthly > 0 && (
            <div style={{ padding: '0 14px 12px', fontSize: 12, color: T.error }}>Potřebuju aspoň e-mail nebo telefon.</div>
          )}
        </FormSection>

        {/* Tarif */}
        <FormSection label="Tarif">
          <RowSegment value={tariff} onChange={setTariff} options={[
            { value: 'Standard', label: 'Standard', sub: '750 Kč/měs' },
            { value: 'Student',  label: 'Student',  sub: '500 Kč/měs · ISIC' },
          ]}/>
          {tariff === 'Student' && (
            <Toggle label="Má ISIC" value={isic} onChange={setIsic} sub="Potřebuju vidět platnou kartu"/>
          )}
          {!editing && (
            <RowSegment label="Délka" value={length} onChange={setLength} options={[
              { value: 3,  label: '3 měs.' },
              { value: 6,  label: '6 měs.' },
              { value: 12, label: '12 měs.' },
            ]}/>
          )}
        </FormSection>

        {/* Vlastní cena */}
        <FormSection label="Cena za měsíc">
          <Toggle
            label="Individuální cena"
            value={customOn}
            onChange={(v) => setCustomOn(v)}
            sub={customOn ? `Přepisuje standardní ${tariffDefault} Kč/měs` : `Použít standardní ${tariffDefault} Kč/měs`}
          />
          {customOn && (
            <PriceField
              label="Vlastní cena"
              value={price}
              onChange={(v) => setPrice(v)}
              invalid={submitted && (!monthly || monthly <= 0)}
              hint={submitted && (!monthly || monthly <= 0) ? 'Zadej částku větší než 0' : null}
            />
          )}
          {!editing && <KCalcRow monthly={monthly} length={length} total={total} isCustom={isCustomActive}/>}
          {editing && (
            <div style={{ padding: '12px 14px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
              <div style={{ fontSize: 13, color: T.text2 }}>Aktuální měsíční cena</div>
              <div style={{ fontSize: 16, fontWeight: 700, fontFamily: FontMono, letterSpacing: -0.4, color: isCustomActive ? T.accent : T.text, whiteSpace: 'nowrap' }}>
                {monthly.toLocaleString('cs-CZ').replace(/,/g, ' ')} <span style={{ fontSize: 11, color: T.text2 }}>Kč</span>
              </div>
            </div>
          )}
        </FormSection>

        {/* Klíč */}
        <FormSection label="Klíč &amp; kauce">
          <Toggle label={editing ? 'Má klíč' : 'Vydat klíč'} value={hasKey} onChange={setHasKey} sub={editing ? 'Klíč je u člena' : 'Kauce 100 Kč v hotovosti'}/>
        </FormSection>

        <button onClick={submit} style={{
          marginTop: 20, width: '100%', height: 52, borderRadius: 14, border: 'none',
          background: ok ? T.accent : T.surface2, color: ok ? '#fff' : T.text3,
          fontSize: 16, fontWeight: 600, fontFamily: FontUI, letterSpacing: -0.2,
          cursor: ok ? 'pointer' : 'not-allowed',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          {React.cloneElement(editing ? Icons.check : Icons.user_plus, { size: 18 })}
          {editing ? 'Uložit změny' : 'Přidat člena'}
        </button>
        <button onClick={() => goBack ? goBack() : onNav(editing ? 'detail' : 'list', editing ? { memberId: existing.id } : undefined)} style={{
          marginTop: 8, width: '100%', height: 44, borderRadius: 12,
          background: 'transparent', border: `1px solid ${T.border}`,
          color: T.text2, fontSize: 14, fontWeight: 500, fontFamily: FontUI, cursor: 'pointer',
        }}>Zrušit</button>
      </div>
    </div>
  );
}

function FormSection({ label, children }) {
  return (
    <>
      <div style={{ marginTop: 22, marginBottom: 10, fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>{label}</div>
      <div style={{ background: T.surface, border: `1px solid ${T.border}`, borderRadius: 14, overflow: 'hidden' }}>
        {children}
      </div>
    </>
  );
}

function Field({ label, value, onChange, placeholder, mono, type = 'text', last, invalid, hint }) {
  return (
    <div style={{
      padding: '11px 14px',
      borderBottom: last ? 'none' : `1px solid ${T.divider}`,
    }}>
      <div style={{ fontSize: 11, color: T.text2, fontWeight: 500, letterSpacing: 0.2 }}>{label}</div>
      <input
        value={value} onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder} type={type}
        style={{
          width: '100%', marginTop: 4, padding: 0, background: 'transparent',
          border: 'none', outline: 'none', color: invalid ? T.error : T.text,
          fontSize: 15.5, fontWeight: 500, fontFamily: mono ? FontMono : FontUI,
          letterSpacing: -0.2,
        }}/>
      {hint && <div style={{ marginTop: 4, fontSize: 11.5, color: T.error }}>{hint}</div>}
    </div>
  );
}

function PriceField({ label, value, onChange, invalid, hint }) {
  // Číselný vstup s "Kč" suffix + krokové tlačítka po 50
  const num = Number(value) || 0;
  const step = (delta) => onChange(Math.max(0, num + delta));
  return (
    <div style={{ padding: '11px 14px', borderBottom: `1px solid ${T.divider}` }}>
      <div style={{ fontSize: 11, color: T.text2, fontWeight: 500, letterSpacing: 0.2 }}>{label}</div>
      <div style={{ marginTop: 6, display: 'flex', alignItems: 'center', gap: 8 }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'baseline', gap: 4 }}>
          <input
            value={value}
            onChange={(e) => onChange(e.target.value.replace(/[^\d]/g, ''))}
            inputMode="numeric"
            style={{
              flex: 1, minWidth: 0, padding: 0, background: 'transparent',
              border: 'none', outline: 'none', color: invalid ? T.error : T.accent,
              fontSize: 22, fontWeight: 700, fontFamily: FontMono, letterSpacing: -0.6,
            }}/>
          <span style={{ fontSize: 13, color: T.text2, fontFamily: FontUI }}>Kč/měs</span>
        </div>
        <div style={{ display: 'flex', gap: 4 }}>
          <Step onClick={() => step(-50)} icon="−"/>
          <Step onClick={() => step(+50)} icon="+"/>
        </div>
      </div>
      {hint && <div style={{ marginTop: 4, fontSize: 11.5, color: T.error }}>{hint}</div>}
      {/* Preset chips */}
      <div style={{ marginTop: 10, display: 'flex', gap: 6, flexWrap: 'wrap' }}>
        {[400, 500, 600, 750, 900, 1200].map(p => (
          <div key={p} onClick={() => onChange(p)} style={{
            padding: '4px 10px', borderRadius: 100, cursor: 'pointer',
            background: num === p ? T.accent : T.surface2,
            color: num === p ? '#fff' : T.text2,
            fontSize: 12, fontWeight: 500, fontFamily: FontMono,
            border: `1px solid ${num === p ? 'transparent' : T.border}`,
          }}>{p} Kč</div>
        ))}
      </div>
    </div>
  );
}

function Step({ onClick, icon }) {
  return (
    <div onClick={onClick} style={{
      width: 32, height: 32, borderRadius: 8,
      background: T.surface2, border: `1px solid ${T.border}`,
      color: T.text, fontSize: 18, fontWeight: 600,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      cursor: 'pointer', userSelect: 'none', fontFamily: FontMono,
    }}>{icon}</div>
  );
}

function RowSegment({ label, value, onChange, options }) {
  return (
    <div style={{ padding: '12px 14px', borderBottom: `1px solid ${T.divider}` }}>
      {label && <div style={{ fontSize: 11, color: T.text2, fontWeight: 500, letterSpacing: 0.2, marginBottom: 8 }}>{label}</div>}
      <div style={{ display: 'grid', gridTemplateColumns: `repeat(${options.length}, 1fr)`, gap: 6, padding: 4, background: T.surface2, borderRadius: 10 }}>
        {options.map(o => {
          const active = o.value === value;
          return (
            <div key={o.value} onClick={() => onChange(o.value)} style={{
              padding: '8px 6px', textAlign: 'center', borderRadius: 8,
              background: active ? T.bg : 'transparent',
              border: active ? `1px solid ${T.border}` : '1px solid transparent',
              cursor: 'pointer', userSelect: 'none',
            }}>
              <div style={{ fontSize: 13, fontWeight: 600, color: active ? T.text : T.text2, letterSpacing: -0.2 }}>{o.label}</div>
              {o.sub && <div style={{ fontSize: 10.5, color: T.text3, marginTop: 2, fontFamily: FontMono }}>{o.sub}</div>}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function Toggle({ label, value, onChange, sub }) {
  return (
    <div onClick={() => onChange(!value)} style={{
      padding: '13px 14px', borderBottom: `1px solid ${T.divider}`,
      display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
    }}>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 14.5, fontWeight: 500, letterSpacing: -0.2 }}>{label}</div>
        {sub && <div style={{ fontSize: 12, color: T.text2, marginTop: 2 }}>{sub}</div>}
      </div>
      <div style={{
        width: 46, height: 28, borderRadius: 100, padding: 2,
        background: value ? T.accent : T.surface2,
        border: `1px solid ${value ? 'transparent' : T.border}`,
        display: 'flex', alignItems: 'center',
        justifyContent: value ? 'flex-end' : 'flex-start',
        transition: 'background 160ms',
        flexShrink: 0,
      }}>
        <div style={{ width: 22, height: 22, borderRadius: '50%', background: '#fff', transition: 'transform 160ms' }}/>
      </div>
    </div>
  );
}

function KCalcRow({ monthly, length, total, isCustom }) {
  return (
    <div style={{ padding: '12px 14px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
      <div style={{ fontSize: 13, color: T.text2 }}>
        K zaplacení <span style={{ color: T.text3, fontFamily: FontMono }}>· {monthly} × {length}</span>
      </div>
      <div style={{ fontSize: 18, fontWeight: 700, fontFamily: FontMono, letterSpacing: -0.4, color: isCustom ? T.accent : T.text, whiteSpace: 'nowrap' }}>
        {total.toLocaleString('cs-CZ').replace(/,/g, ' ')} <span style={{ fontSize: 12, color: T.text2 }}>Kč</span>
      </div>
    </div>
  );
}

Object.assign(window, { AddMember });
