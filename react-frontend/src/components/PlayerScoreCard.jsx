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

function biasColor(community) {
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

function BiasCircle({ community, value }) {
  const wiggle = useWiggle(value)
  return (
    <div className={`w-7 h-7 rounded-full flex items-center justify-center text-sm font-extrabold text-white ${biasColor(community)} ${wiggle}`}>
      {value}
    </div>
  )
}

function AffinityBubble({ affinity, value }) {
  const wiggle = useWiggle(value)
  return (
    <div className="relative w-8 h-8">
      <img
        className="w-full h-full object-contain -rotate-12"
        src={`/images/affinity-${affinityImage(affinity)}.png`}
        alt={affinity}
      />
      <div className={`absolute -top-1 -right-1 bg-accent-1 text-neutral-3 text-xs w-4 h-4 rounded-full flex items-center justify-center shadow font-bold ${wiggle}`}>
        {value}
      </div>
    </div>
  )
}

export default function PlayerScoreCard({ player, isMe, isCurrentTurn }) {
  const cloutWiggle = useWiggle(player.clout)

  return (
    <div className={`flex flex-row h-fit w-fit p-2 gap-4 border rounded-md bg-slate-100
      ${isCurrentTurn ? 'border-fuchsia-600 border-2' : 'border-slate-300'}
      ${isMe ? 'ring-2 ring-fuchsia-400' : ''}`}
    >
      {/* Avatar + name */}
      <div className="flex flex-col gap-1 items-center">
        <div className={`h-12 w-12 border-2 rounded-md overflow-hidden ${identityBg(player.identity)}`}>
          <img className="h-12 w-12 object-cover" src={dpUrl(player.id)} alt={player.name} />
        </div>
        <p className="text-slate-800 font-extrabold text-sm text-center leading-tight max-w-[56px] truncate">
          {player.name}
        </p>
      </div>

      {/* Stats */}
      <div className="flex flex-col gap-2">
        {/* Clout */}
        <div className="flex flex-row items-baseline gap-1">
          <span className="text-xs text-slate-700">Clout</span>
          <span className={`text-slate-900 font-extrabold text-xl inline-block ${cloutWiggle}`}>{player.clout}</span>
        </div>

        {/* Biases — colored circles */}
        <div className="flex flex-row items-center gap-1 flex-wrap">
          <span className="text-xs text-slate-700 mr-1">Biases</span>
          {Object.entries(player.biases || {}).map(([community, value]) => (
            <BiasCircle key={community} community={community} value={value} />
          ))}
        </div>

        {/* Affinities — images with value bubble */}
        <div className="flex flex-row items-center gap-2 flex-wrap">
          <span className="text-xs text-slate-700 mr-1">Affinities</span>
          {Object.entries(player.affinities || {}).map(([affinity, value]) => (
            <AffinityBubble key={affinity} affinity={affinity} value={value} />
          ))}
        </div>
      </div>
    </div>
  )
}
