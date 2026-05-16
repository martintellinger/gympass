// MemberDashboard.jsx — Hlavní obrazovka člena

function MemberDashboard({ onNav = () => {} }) {
  const [reportOpen, setReportOpen] = React.useState(false);

  const handleReportSubmit = ({ text, photoCount }) => {
    setReportOpen(false);
    const photoLabel = photoCount === 0 ? '' :
      ` · ${photoCount} ${photoCount === 1 ? 'fotka' : photoCount < 5 ? 'fotky' : 'fotek'}`;
    onNav('dashboard', { toast: `Závada nahlášena. Díky!${photoLabel}` });
  };

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* Top header — minimal */}
      <div style={{ padding: '4px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>BýtFit</div>
        <div onClick={() => onNav('board')} style={{ cursor: 'pointer', position: 'relative', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text2 }}>
          {React.cloneElement(Icons.board, { size: 18 })}
          <span style={{ position: 'absolute', top: 6, right: 6, width: 8, height: 8, borderRadius: '50%', background: T.accent, border: `2px solid ${T.bg}` }}/>
        </div>
      </div>

      <div style={{ padding: '20px 24px 110px' }}>
        {/* Greeting + big status */}
        <div style={{ color: T.text2, fontSize: 15, marginBottom: 4 }}>Ahoj, Pavle.</div>
        <div style={{ fontSize: 32, fontWeight: 700, letterSpacing: -1, lineHeight: 1.15, marginTop: 8 }}>
          Do posilovny můžeš ještě<br />
          <span style={{ color: T.text2, fontWeight: 500 }}></span>
          <span style={{ fontSize: 64, fontWeight: 700, letterSpacing: -2.4, lineHeight: 1, display: 'inline-flex', alignItems: 'baseline', gap: 12, marginLeft: 10 }}>
            <span style={{ color: T.accent }}>23</span>
            <span style={{ fontSize: 28, fontWeight: 500, color: T.text2, letterSpacing: -0.6 }}>dní</span>
          </span>
        </div>
        <div style={{ color: T.text2, fontSize: 14, marginTop: 10, display: 'flex', alignItems: 'center', gap: 6, fontFamily: FontMono }}>
          {React.cloneElement(Icons.calendar, { size: 14 })}
          do 23. 6. 2026
        </div>

        {/* Primary CTA */}
        <Btn full style={{ marginTop: 24 }} onClick={() => onNav('qr')}>Prodloužit členství</Btn>

        {/* Secondary CTA — report fault */}
        <Btn
          full
          variant="ghost"
          icon={React.cloneElement(Icons.tool, { size: 16 })}
          onClick={() => setReportOpen(true)}
          style={{ marginTop: 10, height: 44, fontSize: 14, fontWeight: 500 }}
        >
          Nahlásit závadu
        </Btn>

        {/* Member card preview */}
        <div style={{ marginTop: 28 }}>
          <SectionLabel>Tvoje karta</SectionLabel>
          <div
            onClick={() => onNav('card')}
            style={{
            cursor: 'pointer',
            marginTop: 12, padding: 18,
            background: 'linear-gradient(135deg, #1E1E20 0%, #161618 100%)',
            border: `1px solid ${T.border}`, borderRadius: 18,
            display: 'flex', alignItems: 'center', gap: 14,
            position: 'relative', overflow: 'hidden'
          }}>
            <div style={{ position: 'absolute', right: -30, top: -30, width: 140, height: 140, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,77,46,0.18), transparent 70%)' }} />
            <div style={{ width: 48, height: 48, borderRadius: 12, background: T.bg, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.accent }}>
              {React.cloneElement(Icons.dumbbell, { size: 22 })}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: -0.3 }}>Pavel Novák</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
                <StatusPill state="ok">Aktivní</StatusPill>
                <span style={{ fontSize: 12, color: T.text2, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                  {React.cloneElement(Icons.key, { size: 12 })} klíč u tebe
                </span>
              </div>
            </div>
            <div style={{ color: T.text3 }}>{React.cloneElement(Icons.chevron, { size: 18 })}</div>
          </div>
        </div>

        {/* Poslední aktivity */}
        <div style={{ marginTop: 24 }}>
          <SectionLabel right="Vše">Poslední aktivity</SectionLabel>
          <Card style={{ marginTop: 12, padding: 0 }}>
            <ActivityRow icon={Icons.refresh} title="Prodloužení (3 měsíce)" date="23. 3. 2026" amount="+90 dní" amountSub="2 250 Kč" />
            <Divider />
            <ActivityRow icon={Icons.refresh} title="Prodloužení (3 měsíce)" date="22. 12. 2025" amount="+90 dní" amountSub="2 250 Kč" />
            <Divider />
            <ActivityRow icon={Icons.key} title="Vydán klíč + kauce" date="14. 9. 2025" amount="100 Kč" amountSub="" muted />
          </Card>
        </div>

        {/* Nástěnka preview */}
        <div style={{ marginTop: 24 }}>
          <SectionLabel right={<span onClick={() => onNav('board')} style={{ cursor: 'pointer', color: T.accent }}>vše →</span>}>Nástěnka</SectionLabel>
          <div onClick={() => onNav('board')} style={{ cursor: 'pointer' }}>
            <Card style={{ marginTop: 12 }}>
              <div style={{ display: 'flex', gap: 12 }}>
                <div style={{ width: 4, borderRadius: 2, background: T.accent, flexShrink: 0 }} />
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 9.5, fontWeight: 700, letterSpacing: 0.8, color: T.accent, textTransform: 'uppercase', padding: '2px 6px', border: `1px solid ${T.accent}`, borderRadius: 4 }}>Připnuto</span>
                    <span style={{ fontSize: 11.5, color: T.text3, fontFamily: FontMono }}>před 2 h</span>
                  </div>
                  <div style={{ fontSize: 15, fontWeight: 600, letterSpacing: -0.2, marginTop: 6 }}>Zítra zavřeno do 14:00</div>
                  <div style={{ fontSize: 13.5, color: T.text2, marginTop: 4, lineHeight: 1.4 }}>Revize elektroinstalace. Otevíráme po obědě. — Olda</div>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>

      <MemberBottomNav active={0} onNav={onNav} />
      <FaultReportSheet
        open={reportOpen}
        onClose={() => setReportOpen(false)}
        onSubmit={handleReportSubmit}
      />
    </div>);

}

function SectionLabel({ children, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
      <div style={{ fontSize: 12.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>{children}</div>
      {right && <div style={{ fontSize: 12.5, color: T.text2 }}>{right}</div>}
    </div>);

}
function Divider() {return <div style={{ height: 1, background: T.divider, marginLeft: 56 }} />;}

function ActivityRow({ icon, title, date, amount, amountSub, muted }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: 14 }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, background: T.surface2, display: 'flex', alignItems: 'center', justifyContent: 'center', color: muted ? T.text2 : T.text }}>
        {React.cloneElement(icon, { size: 16, stroke: 1.8 })}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 14.5, fontWeight: 500, letterSpacing: -0.2 }}>{title}</div>
        <div style={{ fontSize: 12.5, color: T.text2, fontFamily: FontMono, marginTop: 2 }}>{date}</div>
      </div>
      <div style={{ textAlign: 'right' }}>
        <div style={{ fontSize: 14, fontWeight: 600, fontFamily: FontMono, color: muted ? T.text2 : T.text }}>{amount}</div>
        {amountSub && <div style={{ fontSize: 12, color: T.text3, fontFamily: FontMono, marginTop: 2 }}>{amountSub}</div>}
      </div>
    </div>);

}

Object.assign(window, { MemberDashboard });