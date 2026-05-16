// QRPayment.jsx — obrazovka platby přes QR (interaktivní výběr tarifu)

const TARIFFS = {
  m1:  { id: 'm1',  title: '1 měsíc',   months: 1,  price: 850,  vs: '260001', saving: null,           seed: 1 },
  m3:  { id: 'm3',  title: '3 měsíce',  months: 3,  price: 2250, vs: '260003', saving: 'ušetříš 300 Kč', seed: 3 },
  m6:  { id: 'm6',  title: '6 měsíců',  months: 6,  price: 4250, vs: '260006', saving: 'ušetříš 850 Kč', seed: 6 },
};

function QRPayment({ onNav = () => {} }) {
  const [tariffId, setTariffId] = React.useState('m3');
  const tariff = TARIFFS[tariffId];

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* Header with close + title */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 16px 12px' }}>
        <div onClick={() => onNav('dashboard')} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.back, { size: 18 })}
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, color: T.text2 }}>Platba</div>
        <div style={{ width: 36 }} />
      </div>

      <div style={{ padding: '8px 24px 40px' }}>
        {/* Tariff picker */}
        <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase', marginBottom: 10 }}>Tarif</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8, marginBottom: 24 }}>
          {Object.values(TARIFFS).map(t => (
            <TariffPick
              key={t.id}
              title={t.title}
              price={fmtCZK(t.price)}
              sub={t.saving}
              active={tariffId === t.id}
              onClick={() => setTariffId(t.id)}
            />
          ))}
        </div>

        {/* Headline */}
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: -0.6, lineHeight: 1.2 }}>
          Naskenuj QR nebo si ho ulož
        </div>

        {/* QR */}
        <div style={{
          marginTop: 16, padding: 20, background: '#fff', borderRadius: 18,
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          position: 'relative', overflow: 'hidden',
        }}>
          <div key={tariffId} style={{ animation: 'qrSwap 280ms cubic-bezier(0.25,0.8,0.25,1)' }}>
            <QRCode size={224} seed={tariff.seed} />
          </div>
          <div style={{ marginTop: 12, fontFamily: FontMono, fontSize: 11, color: '#0F0F10', letterSpacing: 0.5 }}>
            SPAYD · {fmtCZK(tariff.price)} · VS {tariff.vs}
          </div>
        </div>

        {/* Payment details */}
        <Card style={{ marginTop: 16, padding: 0 }}>
          <DetailRow label="Částka" value={fmtCZK(tariff.price)} big tariffId={tariffId}/>
          <DetailRow label="Účet" value="1234567890 / 0100" mono />
          <DetailRow label="VS" value={tariff.vs} mono tariffId={tariffId}/>
          <DetailRow label="Zpráva" value={`Členství Pavel Novák · ${tariff.title}`} mono last/>
        </Card>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginTop: 12 }}>
          <Btn full variant="ghost" icon={React.cloneElement(Icons.download, { size: 16 })}>
            Uložit QR
          </Btn>
          <Btn full variant="ghost" icon={React.cloneElement(Icons.copy, { size: 16 })}>
            Zkopírovat
          </Btn>
        </div>
        <div style={{
          marginTop: 10, fontSize: 12, color: T.text3, lineHeight: 1.4,
          display: 'flex', alignItems: 'flex-start', gap: 8, padding: '0 4px',
        }}>
          <span style={{ marginTop: 1 }}>{React.cloneElement(Icons.alert, { size: 12 })}</span>
          QR se uloží do Fotek. Otevři ho v bance přes „Naskenovat ze souboru".
        </div>
      </div>

      <style>{`
        @keyframes qrSwap {
          0%   { opacity: 0; transform: scale(0.96); }
          100% { opacity: 1; transform: scale(1); }
        }
        @keyframes valueSwap {
          0%   { opacity: 0.4; transform: translateY(-2px); }
          100% { opacity: 1;   transform: translateY(0);    }
        }
      `}</style>
    </div>
  );
}

function fmtCZK(n) {
  return n.toLocaleString('cs-CZ').replace(/,/g, ' ') + ' Kč';
}

function TariffPick({ title, price, sub, active, onClick }) {
  return (
    <div
      onClick={onClick}
      style={{
        padding: 12, borderRadius: 14,
        background: active ? T.accentSoft : T.surface,
        border: `1px solid ${active ? T.accent : T.border}`,
        position: 'relative',
        cursor: 'pointer',
        transition: 'background 160ms, border-color 160ms',
        userSelect: 'none',
      }}>
      <div style={{ fontSize: 12.5, fontWeight: 500, color: active ? T.accent : T.text2 }}>{title}</div>
      <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: -0.3, marginTop: 6, fontFamily: FontMono }}>{price}</div>
      {sub && <div style={{ fontSize: 10, color: T.ok, marginTop: 4, fontWeight: 500, lineHeight: 1.3 }}>{sub}</div>}
      {active &&
        <div style={{ position: 'absolute', top: 8, right: 8, width: 14, height: 14, borderRadius: '50%', background: T.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {React.cloneElement(Icons.check, { size: 9, color: '#fff', stroke: 3 })}
        </div>
      }
    </div>
  );
}

function DetailRow({ label, value, mono, big, last, tariffId }) {
  return (
    <div style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '12px 16px', borderBottom: last ? 'none' : `1px solid ${T.divider}`,
    }}>
      <span style={{ fontSize: 13.5, color: T.text2 }}>{label}</span>
      <span key={tariffId} style={{
        fontSize: big ? 18 : 14, fontWeight: big ? 700 : 500,
        fontFamily: mono || big ? FontMono : FontUI,
        letterSpacing: big ? -0.5 : 0,
        animation: tariffId ? 'valueSwap 220ms ease-out' : undefined,
      }}>{value}</span>
    </div>
  );
}

Object.assign(window, { QRPayment });
