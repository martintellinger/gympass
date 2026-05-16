// FaultReport.jsx — bottom sheet pro nahlášení závady (text + fotky)

function FaultReportSheet({ open, onClose, onSubmit }) {
  const [text, setText] = React.useState('');
  const [photos, setPhotos] = React.useState([]); // { id, url, name }
  const fileInputRef = React.useRef(null);

  // cleanup all blob URLs on unmount
  React.useEffect(() => {
    return () => photos.forEach(p => URL.revokeObjectURL(p.url));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (!open) return null;

  const onPick = (e) => {
    const files = Array.from(e.target.files || []);
    const next = files.map(f => ({
      id: Math.random().toString(36).slice(2),
      url: URL.createObjectURL(f),
      name: f.name,
    }));
    setPhotos(p => [...p, ...next]);
    e.target.value = '';
  };

  const removePhoto = (id) => {
    setPhotos(p => {
      const removed = p.find(x => x.id === id);
      if (removed) URL.revokeObjectURL(removed.url);
      return p.filter(x => x.id !== id);
    });
  };

  const canSubmit = text.trim().length > 0;

  const handleSubmit = () => {
    if (!canSubmit) return;
    onSubmit({ text: text.trim(), photoCount: photos.length });
    photos.forEach(p => URL.revokeObjectURL(p.url));
    setText('');
    setPhotos([]);
  };

  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 500,
      display: 'flex', alignItems: 'flex-end', justifyContent: 'center',
    }}>
      {/* Backdrop */}
      <div
        onClick={onClose}
        style={{
          position: 'absolute', inset: 0,
          background: 'rgba(0,0,0,0.65)',
          backdropFilter: 'blur(2px)',
          animation: 'sheetBackdropIn 200ms ease-out',
        }}
      />

      {/* Sheet */}
      <div style={{
        position: 'relative',
        width: 'min(376px, 100%)',
        background: T.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '10px 20px 28px',
        boxShadow: '0 -20px 40px rgba(0,0,0,0.4)',
        animation: 'sheetSlideIn 280ms cubic-bezier(0.25,0.8,0.25,1)',
        maxHeight: '90vh', display: 'flex', flexDirection: 'column',
        color: T.text, fontFamily: FontUI,
      }}>
        {/* Drag handle */}
        <div style={{ width: 36, height: 4, background: T.surface2, borderRadius: 2, margin: '4px auto 14px' }}/>

        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
          <div>
            <div style={{ fontSize: 20, fontWeight: 700, letterSpacing: -0.5 }}>Nahlásit závadu</div>
            <div style={{ fontSize: 13, color: T.text2, marginTop: 4, lineHeight: 1.4 }}>
              Co se pokazilo, co nejde? Pošli to Oldovi, on vyřídí.
            </div>
          </div>
          <div
            onClick={onClose}
            style={{
              cursor: 'pointer', width: 30, height: 30, borderRadius: '50%',
              background: T.surface2, color: T.text2,
              display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
            }}>
            {React.cloneElement(Icons.x, { size: 14 })}
          </div>
        </div>

        {/* Textarea */}
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Třeba: bench č. 2 má rozsekané lano nebo ve sprše č. 3 protéká kohoutek."
          rows={4}
          style={{
            width: '100%', marginTop: 16, padding: 14,
            background: T.bg, border: `1px solid ${T.border}`, borderRadius: 12,
            color: T.text, fontSize: 14, lineHeight: 1.5,
            fontFamily: FontUI, letterSpacing: -0.1,
            resize: 'none', outline: 'none',
            transition: 'border-color 160ms',
          }}
          onFocus={(e) => e.target.style.borderColor = T.accent}
          onBlur={(e) => e.target.style.borderColor = T.border}
        />

        {/* Photos */}
        <div style={{ marginTop: 14 }}>
          <div style={{
            display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8,
          }}>
            <div style={{ fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>
              Fotky
            </div>
            <div style={{ fontSize: 11.5, color: T.text3 }}>
              {photos.length === 0 ? 'volitelné' : `${photos.length} ${photos.length === 1 ? 'foto' : photos.length < 5 ? 'fotky' : 'fotek'}`}
            </div>
          </div>

          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {photos.map(p => (
              <div key={p.id} style={{
                width: 64, height: 64, borderRadius: 10,
                background: T.bg, border: `1px solid ${T.border}`,
                position: 'relative', overflow: 'hidden',
              }}>
                <img src={p.url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }}/>
                <div
                  onClick={() => removePhoto(p.id)}
                  style={{
                    position: 'absolute', top: 4, right: 4,
                    width: 18, height: 18, borderRadius: '50%',
                    background: 'rgba(0,0,0,0.7)', color: '#fff',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer',
                  }}>
                  {React.cloneElement(Icons.x, { size: 10, stroke: 2.5 })}
                </div>
              </div>
            ))}

            <div
              onClick={() => fileInputRef.current?.click()}
              style={{
                width: 64, height: 64, borderRadius: 10,
                background: T.bg, border: `1px dashed ${T.border}`,
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                gap: 4, color: T.text2, cursor: 'pointer',
                transition: 'border-color 140ms, color 140ms',
              }}
              onMouseEnter={(e) => { e.currentTarget.style.borderColor = T.accent; e.currentTarget.style.color = T.accent; }}
              onMouseLeave={(e) => { e.currentTarget.style.borderColor = T.border; e.currentTarget.style.color = T.text2; }}
            >
              {React.cloneElement(Icons.plus, { size: 18 })}
              <span style={{ fontSize: 10, letterSpacing: -0.1 }}>fotka</span>
            </div>
          </div>

          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            multiple
            onChange={onPick}
            style={{ display: 'none' }}
          />
        </div>

        {/* Submit */}
        <Btn
          full
          onClick={handleSubmit}
          style={{
            marginTop: 20,
            opacity: canSubmit ? 1 : 0.4,
            pointerEvents: canSubmit ? 'auto' : 'none',
          }}>
          Odeslat
        </Btn>
      </div>

      <style>{`
        @keyframes sheetSlideIn { 0% { transform: translateY(100%); } 100% { transform: translateY(0); } }
        @keyframes sheetBackdropIn { 0% { opacity: 0; } 100% { opacity: 1; } }
      `}</style>
    </div>
  );
}

Object.assign(window, { FaultReportSheet });
