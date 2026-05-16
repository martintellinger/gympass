// BoardScreen.jsx — nástěnka klubu (zprávy, výpadky, akce, novinky)

const POST_TYPES = {
  pinned:  { label: 'Připnuto',  color: () => T.accent, icon: () => Icons.pin },
  outage:  { label: 'Mimo provoz', color: () => T.error,  icon: () => Icons.tool },
  warning: { label: 'Pozor',     color: () => T.warn,   icon: () => Icons.alert },
  promo:   { label: 'Akce',      color: () => T.ok,     icon: () => Icons.tag },
  event:   { label: 'Událost',   color: () => '#5AC8FA', icon: () => Icons.calendar },
  fixed:   { label: 'Opraveno',  color: () => T.ok,     icon: () => Icons.check },
  info:    { label: 'Info',      color: () => T.text2,  icon: () => Icons.megaphone },
};

const POSTS = [
  {
    id: 1, type: 'pinned', pinned: true,
    title: 'Zítra zavřeno do 14:00',
    body: 'Revize elektroinstalace. Otevíráme po obědě, omlouvám se za komplikace. Pokud potřebuješ vyzvednout věci ze skříňky dřív, napiš mi.',
    date: '15. 5. · 16:30', author: 'Olda',
  },
  {
    id: 2, type: 'outage',
    title: 'Bench press č. 2 — mimo provoz',
    body: 'Prasklo lano. Náhradní díl objednaný, dorazí příští týden. Bench č. 1 a multipress fungují normálně.',
    date: '14. 5. · 09:12', author: 'Olda',
  },
  {
    id: 3, type: 'promo',
    title: 'Doporuč kamaráda, dostaneš měsíc zdarma',
    body: 'Pošli někomu, kdo by sem zapadl. Když si zaplatí první 3 měsíce, automaticky se ti přidá +30 dní ke členství. Stačí, aby v žádosti napsal tvoje jméno.',
    date: '12. 5. · 11:00', author: 'Olda', cta: 'Sdílet pozvánku',
  },
  {
    id: 4, type: 'event',
    title: 'Společné běhání · pondělky 18:00',
    body: 'Od příštího týdne zkoušíme pravidelný okruh kolem Stromovky. Tempo lehké, 5–8 km. Sraz vždy v 18:00 u vchodu. Bez přihlášky, kdo přijde, ten běží.',
    date: '10. 5. · 19:45', author: 'Pavel N.',
  },
  {
    id: 5, type: 'fixed',
    title: 'Sprcha č. 3 opravena',
    body: 'Sifon vyčištěn, voda zase teče. Díky všem, kdo nahlásili.',
    date: '8. 5. · 14:20', author: 'Olda',
  },
  {
    id: 6, type: 'warning',
    title: 'Klíče — neházejte je za dveře',
    body: 'Pár lidí mi nechalo klíč zaklepaný za vstupními dveřmi. Prosím nedělejte to — zámek se zasekává a kdokoli to vidí. Buď klíč nechte u sebe, nebo mi ho předejte osobně.',
    date: '5. 5. · 08:00', author: 'Olda',
  },
];

function BoardScreen({ onNav = () => {} }) {
  const [filter, setFilter] = React.useState('all');
  const filtered = POSTS.filter(p => filter === 'all' || (filter === 'pinned' && p.pinned) || p.type === filter);

  // pinned first
  const sorted = [...filtered].sort((a, b) => (b.pinned ? 1 : 0) - (a.pinned ? 1 : 0));

  return (
    <div style={{ background: T.bg, color: T.text, fontFamily: FontUI, display: 'flex', flexDirection: 'column' }}>
      <StatusBar />
      <div style={{ padding: '0 24px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginTop: 4 }}>
          <div>
            <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.8 }}>Nástěnka</div>
            <div style={{ fontSize: 13.5, color: T.text2, marginTop: 4 }}>Co se děje v Klubu</div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: T.text2 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: T.ok }}/>
            otevřeno
          </div>
        </div>

        {/* Filters */}
        <div style={{ marginTop: 16, display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 2 }}>
          <BChip active={filter === 'all'}     onClick={() => setFilter('all')}>Vše</BChip>
          <BChip active={filter === 'outage'}  onClick={() => setFilter('outage')} dot={T.error}>Výpadky</BChip>
          <BChip active={filter === 'warning'} onClick={() => setFilter('warning')} dot={T.warn}>Pozor</BChip>
          <BChip active={filter === 'promo'}   onClick={() => setFilter('promo')} dot={T.ok}>Akce</BChip>
          <BChip active={filter === 'event'}   onClick={() => setFilter('event')} dot="#5AC8FA">Události</BChip>
        </div>
      </div>

      <div style={{ padding: '12px 24px 110px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {sorted.length === 0 && (
          <div style={{ padding: '40px 12px', textAlign: 'center', color: T.text3, fontSize: 13 }}>
            Pro tento filtr nic není.
          </div>
        )}
        {sorted.map(p => <BoardPost key={p.id} post={p}/>)}
      </div>

      <MemberBottomNav active={3} onNav={onNav}/>
    </div>
  );
}

function BChip({ children, active, onClick, dot }) {
  return (
    <div onClick={onClick} style={{
      flexShrink: 0, height: 30, padding: '0 12px', borderRadius: 100,
      background: active ? T.text : T.surface,
      border: `1px solid ${active ? T.text : T.border}`,
      color: active ? T.bg : T.text, fontSize: 12.5, fontWeight: 500,
      display: 'inline-flex', alignItems: 'center', gap: 6, cursor: 'pointer',
      userSelect: 'none',
    }}>
      {dot && <span style={{ width: 6, height: 6, borderRadius: '50%', background: dot }}/>}
      {children}
    </div>
  );
}

function BoardPost({ post }) {
  const meta = POST_TYPES[post.type] || POST_TYPES.info;
  const c = meta.color();
  return (
    <div style={{
      background: T.surface,
      border: `1px solid ${post.pinned ? c : T.border}`,
      borderRadius: 14,
      overflow: 'hidden',
      position: 'relative',
    }}>
      {/* Left accent bar */}
      <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: c }}/>

      <div style={{ padding: '14px 16px 14px 18px' }}>
        {/* Type + date */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '3px 8px', borderRadius: 6, background: c + '22', color: c, fontSize: 10.5, fontWeight: 700, letterSpacing: 0.5, textTransform: 'uppercase' }}>
            {React.cloneElement(meta.icon(), { size: 11, stroke: 2.2 })}
            {meta.label}
          </div>
          <span style={{ fontSize: 11.5, color: T.text3, fontFamily: FontMono }}>{post.date}</span>
        </div>

        <div style={{ fontSize: 16, fontWeight: 600, letterSpacing: -0.3, marginTop: 10, lineHeight: 1.25 }}>{post.title}</div>
        <div style={{ fontSize: 13.5, color: T.text2, marginTop: 6, lineHeight: 1.5 }}>{post.body}</div>

        <div style={{ marginTop: 12, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 12, color: T.text3 }}>
            <Avatar name={post.author} size={20}/>
            <span>{post.author}</span>
          </div>
          {post.cta && (
            <span style={{ fontSize: 12.5, fontWeight: 600, color: c, display: 'inline-flex', alignItems: 'center', gap: 4 }}>
              {post.cta} {React.cloneElement(Icons.chevron, { size: 13 })}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { BoardScreen });
