// MemberCard.jsx — fullscreen členská karta (Apple Wallet style)

function MemberCard({ onNav = () => {} }) {
  return (
    <div style={{ background: '#000', color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column', position: 'relative' }}>
      <StatusBar />
      {/* Close */}
      <div onClick={() => onNav('dashboard')} style={{ cursor: 'pointer', position: 'absolute', top: 60, right: 20, zIndex: 5 }}>
        <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'rgba(255,255,255,0.12)', backdropFilter: 'blur(20px)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.x, { size: 16 })}
        </div>
      </div>

      <div style={{ padding: '8px 20px 40px', display: 'flex', flexDirection: 'column' }}>
        {/* The card */}
        <div style={{
          marginTop: 12,
          background: 'linear-gradient(180deg, #161618 0%, #0E0E10 100%)',
          border: `1px solid ${T.border}`, borderRadius: 22,
          padding: 24, position: 'relative', overflow: 'hidden',
        }}>
          {/* accent corner */}
          <div style={{ position: 'absolute', top: -80, right: -80, width: 260, height: 260, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,77,46,0.22), transparent 70%)' }}/>
          {/* Header row */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', position: 'relative' }}>
            <div>
              <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1.5, color: T.text2, textTransform: 'uppercase' }}>BýtFit</div>
              <div style={{ fontSize: 11, color: T.text3, marginTop: 2 }}>Členská karta</div>
            </div>
            <div style={{ width: 36, height: 36, borderRadius: 10, background: T.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.accent }}>
              {React.cloneElement(Icons.dumbbell, { size: 18 })}
            </div>
          </div>

          {/* Name */}
          <div style={{ marginTop: 32, fontSize: 26, fontWeight: 700, letterSpacing: -0.8, position: 'relative' }}>Pavel Novák</div>
          <div style={{ fontSize: 13, color: T.text2, marginTop: 4, fontFamily: FontMono, position: 'relative' }}>člen od 9 · 2025</div>

          {/* Status row */}
          <div style={{ marginTop: 28, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, position: 'relative' }}>
            <div>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1, color: T.text3, textTransform: 'uppercase' }}>Stav</div>
              <div style={{ marginTop: 6 }}><StatusPill state="ok">Aktivní</StatusPill></div>
            </div>
            <div>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1, color: T.text3, textTransform: 'uppercase' }}>Platí do</div>
              <div style={{ fontSize: 15, fontWeight: 600, marginTop: 6, fontFamily: FontMono }}>23. 6. 2026</div>
            </div>
            <div>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1, color: T.text3, textTransform: 'uppercase' }}>Tarif</div>
              <div style={{ fontSize: 15, fontWeight: 600, marginTop: 6 }}>Standard · 3 měs.</div>
            </div>
            <div>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: 1, color: T.text3, textTransform: 'uppercase' }}>Klíč</div>
              <div style={{ fontSize: 15, fontWeight: 600, marginTop: 6, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                {React.cloneElement(Icons.key, { size: 14, color: T.text2 })}
                <span>u tebe</span>
              </div>
            </div>
          </div>

          {/* Barcode-ish strip */}
          <div style={{ marginTop: 28, padding: '14px 0', background: 'rgba(255,255,255,0.04)', border: `1px solid ${T.border}`, borderRadius: 12, display: 'flex', justifyContent: 'center', position: 'relative' }}>
            <svg width="220" height="40" viewBox="0 0 220 40">
              {Array.from({ length: 60 }, (_, i) => {
                const x = i * 3.6;
                const w = [1, 1.4, 2, 1, 2.4, 1.2][i % 6];
                return <rect key={i} x={x} y="0" width={w} height="40" fill="#F5F5F7"/>;
              })}
            </svg>
          </div>
          <div style={{ marginTop: 10, fontSize: 11, color: T.text3, fontFamily: FontMono, textAlign: 'center', letterSpacing: 2, position: 'relative' }}>BF-PN-260623</div>
        </div>

        {/* Brightness tip */}
        <div style={{
          marginTop: 20, padding: 14, borderRadius: 12,
          background: T.surface, border: `1px solid ${T.border}`,
          fontSize: 12.5, color: T.text2, lineHeight: 1.4,
          display: 'flex', gap: 10, alignItems: 'flex-start',
        }}>
          <div style={{ color: T.text3, marginTop: 1 }}>{React.cloneElement(Icons.alert, { size: 14 })}</div>
          Když ukazuješ kartu Oldovi, zvyš jas obrazovky — čte se to líp.
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { MemberCard });
