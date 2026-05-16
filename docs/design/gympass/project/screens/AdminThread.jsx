// AdminThread.jsx — Jedna konverzace majitel ↔ člen.
// Bubliny zpráv, kompozér, rychlé šablony, hlavička s kontextem (tarif, expirace).

function AdminThread({ onNav = () => {}, goBack, memberId }) {
  const s = useStore();
  const member = s.memberById(memberId) || s.members[0];
  const msgs = s.threadFor(member.id);
  const [text, setText] = React.useState('');
  const scrollRef = React.useRef(null);

  // Označit přečtené při otevření
  React.useEffect(() => { s.markRead(member.id); }, [member.id]);

  // Scroll na konec při nové zprávě
  React.useEffect(() => {
    if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [msgs.length]);

  const send = () => {
    const t = text.trim();
    if (!t) return;
    s.sendMessage(member.id, t, 'olda');
    setText('');
  };

  // Šablony podle stavu člena
  const templates = React.useMemo(() => {
    const out = [];
    if (member.state === 'error') {
      out.push(`Připomínka platby ${member.tariff === 'Student' ? '1 500' : '2 250'} Kč. Pošlu QR.`);
    }
    if (member.state === 'warn') {
      out.push(`Ahoj ${member.name.split(' ')[0]}, končí ti za pár dní. Chceš prodloužit?`);
    }
    out.push('Stavím se zítra v Klubu.');
    out.push('Díky, mám.');
    return out;
  }, [member.id, member.state]);

  // Bubliny seskupené po dnech
  const groups = React.useMemo(() => {
    const map = new Map();
    msgs.forEach(m => {
      const d = new Date(m.at);
      const key = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`;
      if (!map.has(key)) map.set(key, { date: d, items: [] });
      map.get(key).items.push(m);
    });
    return [...map.values()];
  }, [msgs]);

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column', height: 760 }}>
      <StatusBar/>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '4px 16px 12px', borderBottom: `1px solid ${T.divider}` }}>
        <div onClick={() => goBack ? goBack() : onNav('messages')} style={{ cursor: 'pointer', width: 36, height: 36, borderRadius: '50%', background: T.surface, border: `1px solid ${T.border}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: T.text }}>
          {React.cloneElement(Icons.back, { size: 18 })}
        </div>
        <div onClick={() => onNav('detail', { memberId: member.id })} style={{ flex: 1, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 10 }}>
          <Avatar name={member.name} size={36}/>
          <div style={{ minWidth: 0 }}>
            <div style={{ fontSize: 14.5, fontWeight: 700, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {member.name}
            </div>
            <div style={{ fontSize: 11.5, color: T.text2, marginTop: 1, display: 'flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap' }}>
              <StatusDot state={member.state} size={5}/>
              <span>{member.tariff}</span>
              <span style={{ color: T.text3 }}>·</span>
              <span style={{ fontFamily: FontMono }}>{member.expiresAt}</span>
            </div>
          </div>
        </div>
        <div onClick={() => onNav('detail', { memberId: member.id })} style={{ cursor: 'pointer', color: T.text2, width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {React.cloneElement(Icons.more, { size: 18 })}
        </div>
      </div>

      {/* Kontextová lišta (volitelná upozornění) */}
      {(member.state === 'error' || member.state === 'warn') && (
        <div style={{
          margin: '10px 16px 0', padding: '10px 12px',
          background: member.state === 'error' ? T.errorSoft : T.warnSoft,
          color: member.state === 'error' ? T.error : T.warn,
          borderRadius: 10, fontSize: 12.5, fontWeight: 500,
          display: 'flex', alignItems: 'center', gap: 8,
        }}>
          {React.cloneElement(Icons.alert, { size: 14, stroke: 2.2 })}
          {member.state === 'error'
            ? `Platba po lhůtě · prodlení`
            : `Členství končí za ${member.daysNum} ${member.daysNum === 1 ? 'den' : member.daysNum < 5 ? 'dny' : 'dní'}`}
        </div>
      )}

      {/* Zprávy */}
      <div ref={scrollRef} style={{ flex: 1, overflowY: 'auto', padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: 6 }}>
        {groups.length === 0 ? (
          <div style={{ textAlign: 'center', padding: 30, color: T.text3, fontSize: 13 }}>
            Začni první zprávou.
          </div>
        ) : groups.map((g, gi) => (
          <React.Fragment key={gi}>
            <div style={{ textAlign: 'center', margin: '12px 0 4px', fontSize: 11, color: T.text3, fontFamily: FontMono, letterSpacing: 0.4, textTransform: 'uppercase' }}>
              {fmtRelDay(g.date)}
            </div>
            {g.items.map((m, mi) => <Bubble key={mi} msg={m} prev={g.items[mi - 1]} next={g.items[mi + 1]}/>)}
          </React.Fragment>
        ))}
      </div>

      {/* Šablony */}
      <div style={{ padding: '8px 12px 0', display: 'flex', gap: 6, overflowX: 'auto' }}>
        {templates.map((t, i) => (
          <div key={i} onClick={() => setText(t)} style={{
            flexShrink: 0, padding: '7px 12px', borderRadius: 100,
            background: T.surface, border: `1px solid ${T.border}`, color: T.text2,
            fontSize: 12.5, cursor: 'pointer', maxWidth: 240,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
          }}>{t}</div>
        ))}
      </div>

      {/* Kompozér */}
      <div style={{ padding: '10px 14px 28px', display: 'flex', alignItems: 'flex-end', gap: 8 }}>
        <div style={{ flex: 1, minHeight: 44, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 22, padding: '6px 12px', display: 'flex', alignItems: 'center', gap: 8 }}>
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); } }}
            placeholder={`Napiš ${member.name.split(' ')[0]}…`}
            rows={1}
            style={{
              flex: 1, background: 'transparent', border: 'none', outline: 'none',
              color: T.text, fontSize: 14.5, fontFamily: FontUI, resize: 'none',
              padding: '6px 0', lineHeight: 1.4, maxHeight: 80,
            }}/>
        </div>
        <button onClick={send} disabled={!text.trim()} style={{
          width: 44, height: 44, borderRadius: '50%', border: 'none',
          background: text.trim() ? T.accent : T.surface2,
          color: text.trim() ? '#fff' : T.text3,
          cursor: text.trim() ? 'pointer' : 'not-allowed',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          {React.cloneElement(Icons.send, { size: 18 })}
        </button>
      </div>
    </div>
  );
}

function Bubble({ msg, prev, next }) {
  const isOlda = msg.from === 'olda';
  const prevSame = prev && prev.from === msg.from;
  const nextSame = next && next.from === msg.from;
  const top = prevSame ? 4 : 18;
  const bottom = nextSame ? 4 : 18;
  const t = new Date(msg.at);
  return (
    <div style={{
      display: 'flex', justifyContent: isOlda ? 'flex-end' : 'flex-start',
      marginTop: top - 6, marginBottom: 0,
    }}>
      <div style={{ maxWidth: '78%', display: 'flex', flexDirection: 'column', alignItems: isOlda ? 'flex-end' : 'flex-start' }}>
        <div style={{
          background: isOlda ? T.accent : T.surface,
          color: isOlda ? '#fff' : T.text,
          border: isOlda ? 'none' : `1px solid ${T.border}`,
          padding: '9px 13px',
          borderRadius: 18,
          borderBottomRightRadius: isOlda && nextSame ? 6 : isOlda ? 18 : 18,
          borderTopRightRadius: isOlda && prevSame ? 6 : 18,
          borderBottomLeftRadius: !isOlda && nextSame ? 6 : 18,
          borderTopLeftRadius: !isOlda && prevSame ? 6 : 18,
          fontSize: 14.5, lineHeight: 1.4, letterSpacing: -0.1,
          wordBreak: 'break-word',
        }}>
          {msg.text}
        </div>
        {!nextSame && (
          <div style={{ fontSize: 10.5, color: T.text3, fontFamily: FontMono, marginTop: 3, padding: '0 4px' }}>
            {fmtTime(t)}
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { AdminThread });
