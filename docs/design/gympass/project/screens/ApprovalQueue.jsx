// ApprovalQueue.jsx — schvalování nových registrací

function ApprovalQueue({ onNav = () => {}, goBack }) {
  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      {/* Top */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '4px 16px 12px' }}>
        <div onClick={() => goBack ? goBack() : onNav('admin')} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.back, { size: 18 })}
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 14, fontWeight: 600, color: T.text2 }}>Schvalování</div>
          <div style={{ fontSize: 11, color: T.text3, marginTop: 2, fontFamily: FontMono }}>1 / 2</div>
        </div>
        <div style={{ width: 36 }}/>
      </div>

      <div style={{ padding: '8px 20px 24px' }}>
        {/* Hero */}
        <div style={{ padding: '12px 4px 24px' }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: T.accent, letterSpacing: 0.4, textTransform: 'uppercase' }}>Nový žadatel</div>
          <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: -0.8, marginTop: 6 }}>Jana Kovářová</div>
          <div style={{ fontSize: 13, color: T.text2, marginTop: 4, fontFamily: FontMono }}>žádost odeslána 14. 5. 2026 v 18:22</div>
        </div>

        {/* Details card */}
        <Card style={{ padding: 0 }}>
          <KV2 label="E-mail" value="jana.kovarova@email.cz"/>
          <Divider/>
          <KV2 label="Telefon" value="+420 605 218 731" mono/>
          <Divider/>
          <KV2 label="Tarif" value="Student" pill="ISIC"/>
          <Divider/>
          <KV2 label="GDPR souhlas" value="Udělen 14. 5. 2026" tinyMono last/>
        </Card>

        {/* ISIC */}
        <div style={{ marginTop: 20 }}>
          <div style={{ fontSize: 12.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>ISIC průkaz</div>
          <div style={{
            marginTop: 12, height: 200, borderRadius: 14,
            background: 'linear-gradient(135deg, #1a1a1c, #232326)',
            border: `1px solid ${T.border}`, position: 'relative', overflow: 'hidden',
          }}>
            {/* placeholder photo with diagonal hatch */}
            <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
              <defs>
                <pattern id="hatch" x="0" y="0" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                  <rect width="4" height="8" fill="rgba(255,255,255,0.03)"/>
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#hatch)"/>
            </svg>
            <div style={{ position: 'absolute', top: 12, left: 12, fontSize: 10, fontFamily: FontMono, color: T.text3, letterSpacing: 1 }}>FOTO ISIC · UPLOAD 14.5.2026</div>
            <div style={{ position: 'absolute', inset: 12, border: `1px dashed ${T.border}`, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, color: T.text3 }}>
                {React.cloneElement(Icons.isic, { size: 36, stroke: 1 })}
                <div style={{ fontSize: 12, fontFamily: FontMono }}>1242 × 1860 px · 2.1 MB</div>
              </div>
            </div>
            <div style={{ position: 'absolute', bottom: 10, right: 10, padding: '4px 8px', background: 'rgba(0,0,0,0.6)', borderRadius: 6, fontSize: 10.5, fontFamily: FontMono, color: T.text, letterSpacing: 0.4 }}>tap pro zvětšení</div>
          </div>
          <div style={{
            marginTop: 10, padding: '10px 12px', borderRadius: 10,
            background: T.warnSoft, color: T.warn,
            fontSize: 12.5, display: 'flex', gap: 8, alignItems: 'flex-start',
          }}>
            <div style={{ marginTop: 1 }}>{React.cloneElement(Icons.alert, { size: 14 })}</div>
            <div style={{ lineHeight: 1.4, color: T.text2 }}><span style={{ color: T.warn, fontWeight: 600 }}>Zkontroluj:</span> jméno na ISICu sedí, platnost do 30. 9. 2026.</div>
          </div>
        </div>

        {/* Why now */}
        <div style={{ marginTop: 20 }}>
          <div style={{ fontSize: 12.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>Poznámka od žadatele</div>
          <div style={{
            marginTop: 12, padding: 14, borderRadius: 12,
            background: T.surface, border: `1px solid ${T.border}`,
            fontSize: 14, color: T.text, lineHeight: 1.5,
          }}>
            „Ahoj, doporučil mě Pavel. Chtěla bych začít hned od pondělí, pokud to půjde."
          </div>
        </div>
      </div>

      {/* Sticky action bar */}
      <div style={{
        background: 'rgba(15,15,16,0.95)', backdropFilter: 'blur(20px)',
        borderTop: `1px solid ${T.border}`, padding: '16px 20px 32px',
        display: 'flex', gap: 10,
      }}>
        <Btn variant="ghost" onClick={() => onNav('admin', { toast: 'Zamítnuto · Jana K.' })} style={{ flex: 1, color: T.error, borderColor: 'rgba(255,59,48,0.3)' }}>
          Zamítnout
        </Btn>
        <Btn variant="primary" onClick={() => onNav('admin', { toast: 'Jana K. přidána mezi členy' })} style={{ flex: 1.6 }} icon={React.cloneElement(Icons.check, { size: 18, stroke: 2.4 })}>
          Schválit
        </Btn>
      </div>
    </div>
  );
}

function KV2({ label, value, mono, pill, tinyMono, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 16px', borderBottom: last ? 'none' : undefined }}>
      <span style={{ fontSize: 13, color: T.text2 }}>{label}</span>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        {pill && <span style={{ fontSize: 10, fontWeight: 700, color: T.text2, border: `1px solid ${T.border}`, padding: '2px 6px', borderRadius: 5, letterSpacing: 0.4 }}>{pill}</span>}
        <span style={{ fontSize: tinyMono ? 12.5 : 14, fontWeight: 500, fontFamily: (mono || tinyMono) ? FontMono : FontUI, color: tinyMono ? T.text2 : T.text }}>{value}</span>
      </div>
    </div>
  );
}

Object.assign(window, { ApprovalQueue });
