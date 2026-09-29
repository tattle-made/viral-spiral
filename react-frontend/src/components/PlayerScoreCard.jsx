import { useWiggle } from '../hooks/useWiggle'

function dpUrl(playerId) {
  let hash = 0
  for (let i = 0; i < playerId.length; i++) {
    hash = Math.imul(31, hash) + playerId.charCodeAt(i) | 0
  }
  const n = (Math.abs(hash) % 7) + 1
  return `https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/avatar/dp_0${n}.png`
}

function identityBg(identity) {
  switch (identity) {
    case 'red': return 'bg-red-500 border-red-500'
    case 'blue': return 'bg-blue-500 border-blue-500'
    case 'yellow': return 'bg-yellow-500 border-yellow-500'
    default: return 'bg-gray-200 border-gray-200'
  }
}

function biasColorClass(community) {
  switch (community) {
    case 'red': return 'bg-red-500'
    case 'blue': return 'bg-blue-500'
    case 'yellow': return 'bg-yellow-400'
    default: return 'bg-gray-400'
  }
}

function affinityImage(affinity) {
  switch (affinity) {
    case 'cat': return 'cat'
    case 'sock': return 'sock'
    case 'highfive': return 'high-five'
    case 'houseboat': return 'boat'
    case 'skub': return 'skub'
    default: return 'cat'
  }
}

function LinearMeter({ value, max, colorClass, wiggle, label }) {
  const fillPct = Math.min(Math.max(value / max, 0), 1) * 100

  return (
    <div className="flex items-center gap-1.5">
      <span className="text-xs text-slate-400 w-10 capitalize truncate">{label}</span>
      <div className="relative h-4 w-24 bg-slate-700 rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full transition-[width] duration-700 ease-out ${colorClass}`}
          style={{ width: `${fillPct}%` }}
        />
      </div>
      <span className={`text-xs text-slate-200 font-bold w-5 text-right ${wiggle}`}>{value}</span>
    </div>
  )
}

function BiasLinearMeter({ community, value, max }) {
  const wiggle = useWiggle(value)
  return (
    <LinearMeter
      value={value}
      max={max}
      colorClass={biasColorClass(community)}
      wiggle={wiggle}
      label={community}
    />
  )
}

function CloutLinearMeter({ value, max }) {
  const wiggle = useWiggle(value)
  return (
    <LinearMeter
      value={value}
      max={max}
      colorClass="bg-accent-1"
      wiggle={wiggle}
      label="Clout"
    />
  )
}

function AffinityRadialMeter({ affinity, value, max }) {
  const wiggle = useWiggle(value)
  const size = 46
  const r = 17
  const cx = size / 2
  const cy = size / 2
  const circumference = 2 * Math.PI * r
  const absVal = Math.min(Math.abs(value), max)
  const arcLen = (absVal / max) * circumference
  const dashOffset = circumference * 0.25
  const isPositive = value >= 0

  return (
    <div className="flex flex-col items-center gap-0.5">
      <div className={`relative ${wiggle}`} style={{ width: size, height: size }}>
        <svg width={size} height={size} className="absolute inset-0">
          <circle cx={cx} cy={cy} r={r} fill="none" stroke="#334155" strokeWidth="3" />
          {value !== 0 && (
            <circle
              cx={cx} cy={cy} r={r}
              fill="none"
              stroke={isPositive ? '#10b981' : '#ef4444'}
              strokeWidth="3.5"
              strokeDasharray={`${arcLen} ${circumference}`}
              strokeDashoffset={dashOffset}
              strokeLinecap="round"
              style={isPositive ? {} : {
                transform: `scaleX(-1)`,
                transformOrigin: `${cx}px ${cy}px`,
              }}
            />
          )}
        </svg>
        <div className="absolute inset-0 flex items-center justify-center" style={{ padding: '10px' }}>
          <img
            className="w-full h-full object-contain"
            src={`/images/affinity-${affinityImage(affinity)}.png`}
            alt={affinity}
          />
        </div>
      </div>
      <span
        className="text-xs font-bold"
        style={{ color: value > 0 ? '#10b981' : value < 0 ? '#ef4444' : '#94a3b8' }}
      >
        {value > 0 ? '+' : ''}{value}
      </span>
    </div>
  )
}

export default function PlayerScoreCard({
  player,
  isMe,
  isCurrentTurn,
  biasMax = 6,
  cloutMax = 10,
  affinityMax = 5,
}) {
  const ringClass = isCurrentTurn
    ? 'ring-2 ring-fuchsia-500 shadow-[0_0_14px_rgba(217,70,239,0.55)]'
    : isMe
      ? 'ring-2 ring-fuchsia-400'
      : 'border border-slate-600'

  return (
    <div className={`flex flex-row h-fit w-fit p-2.5 gap-4 rounded-lg bg-slate-800 ${ringClass}`}>
      {/* Avatar + name */}
      <div className="flex flex-col gap-1 items-center">
        <div className={`h-12 w-12 border-2 rounded-md overflow-hidden ${identityBg(player.identity)}`}>
          <img className="h-12 w-12 object-cover" src={dpUrl(player.id)} alt={player.name} />
        </div>
        <p className="text-slate-200 font-extrabold text-sm text-center leading-tight max-w-[56px] truncate">
          {player.name}
        </p>
      </div>

      {/* Stats */}
      <div className="flex flex-col gap-2">
        <CloutLinearMeter value={player.clout} max={cloutMax} />

        <div className="flex flex-col gap-1">
          <span className="text-[10px] text-slate-500 uppercase tracking-widest">Biases</span>
          {Object.entries(player.biases || {}).map(([community, value]) => (
            <BiasLinearMeter key={community} community={community} value={value} max={biasMax} />
          ))}
        </div>

        <div className="flex flex-col gap-1">
          <span className="text-[10px] text-slate-500 uppercase tracking-widest">Affinities</span>
          <div className="flex flex-row items-end gap-2 flex-wrap">
            {Object.entries(player.affinities || {}).map(([affinity, value]) => (
              <AffinityRadialMeter key={affinity} affinity={affinity} value={value} max={affinityMax} />
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
