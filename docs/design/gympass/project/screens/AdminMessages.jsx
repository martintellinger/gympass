// AdminMessages.jsx — Inbox zpráv (majitel ↔ členové)
// Seznam vláken seřazený dle posledního příspěvku, vyhledávání, nová zpráva.

function AdminMessages({ onNav = () => {}, broadcast }) {
  const s = useStore();
  const [q, setQ] = React.useState('');
  const [composeOpen, setComposeOpen] = React.useState(false);
  const [broadcastOpen, setBroadcastOpen] = React.useState(!!broadcast);

  // Otevřít broadcast sheet pokud přišel flag z navigace
  React.useEffect(() => { if (broadcast) setBroadcastOpen(true); }, [broadcast]);

  const threads = s.threadsSorted();
  const filtered = q
    ? threads.filter(t => t.member.name.toLowerCase().includes(q.toLowerCase()))
    : threads;

  const totalUnread = s.totalUnread();
  const unreadThreads = threads.filter(t => t.unread > 0).length;

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar/>
      <div style={{ padding: '0 20px 12px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 4 }}>
          <div>
            <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8 }}>Zprávy</div>
            <div style={{ fontSize: 13, color: T.text2, marginTop: 4 }}>
              {totalUnread > 0
                ? <><span style={{ color: T.text }}>{totalUnread} nepřečteno</span> · {unreadThreads} {unreadThreads === 1 ? 'vlákno' : 'vlákna'}</>
                : 'Vše vyřízeno'}
            </div>
          </div>
          <div onClick={() => setComposeOpen(true)} style={{
            width: 40, height: 40, borderRadius: '50%',
            background: T.accent, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
          }}>{React.cloneElement(Icons.edit, { size: 18 })}</div>
        </div>

        {/* Search */}
        <div style={{ marginTop: 14, height: 40, background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12, display: 'flex', alignItems: 'center', padding: '0 12px', gap: 8 }}>
          <span style={{ color: T.text2, display: 'flex' }}>{React.cloneElement(Icons.search, { size: 16 })}</span>
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Hledat ve zprávách…"
            style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: T.text, fontSize: 14, fontFamily: FontUI }}
          />
          {q && <span onClick={() => setQ('')} style={{ cursor: 'pointer', color: T.text3 }}>{React.cloneElement(Icons.x, { size: 14 })}</span>}
        </div>

        {/* Rychlé hromadné akce */}
        {!q && (
          <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
            <QuickPill icon={Icons.megaphone} label="Hromadně všem"
              onClick={() => setBroadcastOpen(true)}/>
            <QuickPill icon={Icons.alert} label="Připomenout dlužníky"
              onClick={() => {
                ['david', 'petr'].forEach(id => s.sendMessage(id, 'Připomínka platby — pošlu QR. Dík.'));
                onNav('messages', { toast: 'Připomínky odeslány' });
              }}/>
          </div>
        )}
      </div>

      <div style={{ padding: '4px 20px 110px' }}>
        <div style={{ position: 'sticky', top: 0, background: T.bg, padding: '8px 4px', fontSize: 11.5, fontWeight: 600, letterSpacing: 0.4, color: T.text2, textTransform: 'uppercase' }}>
          {filtered.length} {filtered.length === 1 ? 'vlákno' : (filtered.length > 1 && filtered.length < 5 ? 'vlákna' : 'vláken')}
        </div>

        {filtered.length === 0 ? (
          <div style={{ padding: '40px 12px', textAlign: 'center', color: T.text3, fontSize: 13 }}>
            {q ? `Nikdo s "${q}"` : 'Zatím žádné zprávy.'}
          </div>
        ) : (
          filtered.map(t => (
            <ThreadRow key={t.member.id} thread={t}
              onClick={() => { s.markRead(t.member.id); onNav('thread', { memberId: t.member.id }); }}
            />
          ))
        )}
      </div>

      {composeOpen && (
        <ComposeSheet
          members={s.members}
          onClose={() => setComposeOpen(false)}
          onPick={(id) => { setComposeOpen(false); onNav('thread', { memberId: id }); }}
        />
      )}

      {broadcastOpen && (
        <BroadcastSheet
          members={s.members}
          store={s}
          onClose={() => setBroadcastOpen(false)}
          onSent={(count) => { setBroadcastOpen(false); onNav('messages', { toast: `Odesláno · ${count} členům` }); }}
        />
      )}

      <AdminBottomNav active={3} onNav={onNav}/>
    </div>
  );
}

function QuickPill({ icon, label, onClick }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, minHeight: 44, padding: '0 12px',
      background: T.surface, border: `1px solid ${T.border}`, borderRadius: 12,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      color: T.text, fontSize: 13, fontWeight: 500, fontFamily: FontUI, cursor: 'pointer',
    }}>
      <span style={{ color: T.accent, display: 'flex' }}>{React.cloneElement(icon, { size: 16 })}</span>
      {label}
    </button>
  );
}

function ThreadRow({ thread, onClick }) {
  const { member, last, unread } = thread;
  const t = new Date(last.at);
  const time = fmtRelDay(t) === 'dnes' ? fmtTime(t) : fmtRelDay(t);
  const isFromOlda = last.from === 'olda';

  return (
    <div onClick={onClick} style={{
      cursor: 'pointer',
      padding: '14px 4px', display: 'flex', gap: 12,
      borderBottom: `1px solid ${T.divider}`,
    }}>
      <div style={{ position: 'relative', flexShrink: 0 }}>
        <Avatar name={member.name} size={44}/>
        {unread > 0 && (
          <span style={{
            position: 'absolute', top: -2, right: -2,
            minWidth: 18, height: 18, padding: '0 5px', borderRadius: 9,
            background: T.accent, color: '#fff', fontSize: 10.5, fontWeight: 700,
            display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
            border: `2px solid ${T.bg}`, fontFamily: FontMono, lineHeight: 1,
          }}>{unread}</span>
        )}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: 8 }}>
          <span style={{ fontSize: 15, fontWeight: unread ? 700 : 600, letterSpacing: -0.2, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {member.name}
          </span>
          <span style={{ flexShrink: 0, fontSize: 11, color: unread ? T.accent : T.text3, fontFamily: FontMono, fontWeight: unread ? 600 : 400 }}>
            {time}
          </span>
        </div>
        <div style={{ marginTop: 4, display: 'flex', alignItems: 'center', gap: 6 }}>
          {isFromOlda && (
            <span style={{ fontSize: 10.5, fontWeight: 600, color: T.text3, fontFamily: FontMono, letterSpacing: 0.4, textTransform: 'uppercase', flexShrink: 0 }}>
              já →
            </span>
          )}
          <span style={{
            fontSize: 13, color: unread ? T.text : T.text2, lineHeight: 1.35,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
            fontWeight: unread ? 500 : 400,
          }}>{last.text}</span>
        </div>
      </div>
    </div>
  );
}

function ComposeSheet({ members, onClose, onPick }) {
  const [q, setQ] = React.useState('');
  const filtered = q
    ? members.filter(m => m.name.toLowerCase().includes(q.toLowerCase()))
    : members;
  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(4px)',
      display: 'flex', alignItems: 'flex-end',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: T.surface, borderTopLeftRadius: 20, borderTopRightRadius: 20,
        width: '100%', maxHeight: '72%', display: 'flex', flexDirection: 'column',
        border: `1px solid ${T.border}`,
      }}>
        <div style={{ padding: 14, display: 'flex', flexDirection: 'column', gap: 12, borderBottom: `1px solid ${T.divider}` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.3 }}>Nová zpráva</div>
            <div onClick={onClose} style={{ cursor: 'pointer', color: T.text2 }}>{React.cloneElement(Icons.x, { size: 20 })}</div>
          </div>
          <div style={{ height: 38, background: T.surface2, border: `1px solid ${T.border}`, borderRadius: 10, display: 'flex', alignItems: 'center', padding: '0 12px', gap: 8 }}>
            <span style={{ color: T.text2, display: 'flex' }}>{React.cloneElement(Icons.search, { size: 15 })}</span>
            <input autoFocus value={q} onChange={(e) => setQ(e.target.value)} placeholder="Komu napsat…"
              style={{ flex: 1, background: 'transparent', border: 'none', outline: 'none', color: T.text, fontSize: 14, fontFamily: FontUI }}/>
          </div>
        </div>
        <div style={{ flex: 1, overflowY: 'auto', padding: 6 }}>
          {filtered.map(m => (
            <div key={m.id} onClick={() => onPick(m.id)} style={{
              display: 'flex', alignItems: 'center', gap: 12, padding: 10, borderRadius: 10, cursor: 'pointer',
            }}>
              <Avatar name={m.name} size={36}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14.5, fontWeight: 600, letterSpacing: -0.2 }}>{m.name}</div>
                <div style={{ fontSize: 12, color: T.text2, marginTop: 2 }}>{m.tariff} · {m.expiresAt}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function BroadcastSheet({ members, store, onClose, onSent }) {
  const [text, setText] = React.useState('');
  const [target, setTarget] = React.useState('all'); // all | overdue | warn | active

  const targets = {
    all:     { label: 'Všem',         filter: () => true },
    overdue: { label: 'Dlužníkům',   filter: (m) => m.state === 'error' },
    warn:    { label: 'Končícím',     filter: (m) => m.state === 'warn' },
    active:  { label: 'Aktivním',     filter: (m) => m.state === 'ok' },
  };
  const recipients = members.filter(targets[target].filter);

  // Šablony — typické zprávy klubu
  const templates = [
    'Zítra máme zavřeno do 14:00, revize elektroinstalace.',
    'Multipress je dočasně mimo provoz, náhradní díl dorazil.',
    'Pamatujte na klid v Klubu po 21:00, je tu někdo, kdo by spál.',
  ];

  const send = () => {
    const t = text.trim();
    if (!t || recipients.length === 0) return;
    recipients.forEach(m => store.sendMessage(m.id, t, 'olda'));
    onSent(recipients.length);
  };

  return (
    <div onClick={onClose} style={{
      position: 'absolute', inset: 0, zIndex: 50,
      background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(4px)',
      display: 'flex', alignItems: 'flex-end',
    }}>
      <div onClick={(e) => e.stopPropagation()} style={{
        background: T.surface, borderTopLeftRadius: 20, borderTopRightRadius: 20,
        width: '100%', padding: 16, border: `1px solid ${T.border}`,
        display: 'flex', flexDirection: 'column', gap: 14,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontSize: 17, fontWeight: 700, letterSpacing: -0.3 }}>Hromadná zpráva</div>
            <div style={{ fontSize: 12, color: T.text2, marginTop: 2 }}>Přistáne všem jako normální zpráva od Oldy</div>
          </div>
          <div onClick={onClose} style={{ cursor: 'pointer', color: T.text2 }}>{React.cloneElement(Icons.x, { size: 20 })}</div>
        </div>

        {/* Komu */}
        <div>
          <div style={{ fontSize: 11, fontWeight: 600, color: T.text2, letterSpacing: 0.3, textTransform: 'uppercase', marginBottom: 6 }}>Komu</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 4, padding: 4, background: T.surface2, borderRadius: 10 }}>
            {Object.keys(targets).map(k => {
              const active = target === k;
              const count = members.filter(targets[k].filter).length;
              return (
                <div key={k} onClick={() => setTarget(k)} style={{
                  padding: '8px 4px', textAlign: 'center', borderRadius: 8,
                  background: active ? T.bg : 'transparent',
                  border: active ? `1px solid ${T.border}` : '1px solid transparent',
                  cursor: 'pointer', userSelect: 'none',
                }}>
                  <div style={{ fontSize: 12.5, fontWeight: 600, color: active ? T.text : T.text2, letterSpacing: -0.2 }}>{targets[k].label}</div>
                  <div style={{ fontSize: 10.5, color: T.text3, marginTop: 1, fontFamily: FontMono }}>{count}</div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Textarea */}
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Co chtěš říct…"
          rows={4}
          style={{
            width: '100%', padding: 12, background: T.surface2, color: T.text,
            border: `1px solid ${T.border}`, borderRadius: 10,
            fontSize: 14.5, fontFamily: FontUI, outline: 'none', resize: 'none',
            lineHeight: 1.4,
          }}
        />

        {/* Šablony */}
        <div style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2, margin: '0 -2px' }}>
          {templates.map((t, i) => (
            <div key={i} onClick={() => setText(t)} style={{
              flexShrink: 0, padding: '6px 11px', borderRadius: 100,
              background: T.surface2, border: `1px solid ${T.border}`, color: T.text2,
              fontSize: 11.5, cursor: 'pointer', maxWidth: 240,
              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
            }}>{t}</div>
          ))}
        </div>

        <button onClick={send} disabled={!text.trim() || recipients.length === 0} style={{
          width: '100%', height: 50, borderRadius: 12, border: 'none',
          background: text.trim() && recipients.length > 0 ? T.accent : T.surface2,
          color: text.trim() && recipients.length > 0 ? '#fff' : T.text3,
          fontSize: 15, fontWeight: 600, fontFamily: FontUI, letterSpacing: -0.2,
          cursor: text.trim() && recipients.length > 0 ? 'pointer' : 'not-allowed',
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          {React.cloneElement(Icons.send, { size: 16 })}
          Odeslat · {recipients.length} {recipients.length === 1 ? 'člen' : (recipients.length < 5 ? 'členové' : 'členů')}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { AdminMessages });

