import { useState } from 'react'

function cardUrl(filename) {
  if (!filename) return null
  return `https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/${filename.replace(/ /g, '+')}`
}

export default function ViralSpiralModal({ hand, others, me, onSubmit, onClose }) {
  const [selectedCard, setSelectedCard] = useState(null)

  const toIds = others.map(p => p.id)

  if (!hand?.length) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
        <div className="bg-white border-2 border-zinc-600 rounded-xl p-6 max-w-sm w-full mx-4 text-center" onClick={e => e.stopPropagation()}>
          <h3 className="font-bold text-lg mb-2">Viral Spiral</h3>
          <p className="text-gray-600">There are no cards in hand.</p>
          <button onClick={onClose} className="mt-4 py-1 px-4 border border-zinc-900 rounded-md text-sm hover:bg-orange-300">Close</button>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div className="bg-white border-2 border-zinc-600 rounded-xl p-6 max-w-md w-full mx-4" onClick={e => e.stopPropagation()}>
        <h3 className="font-bold text-lg mb-1">Enable Viral Spiral Power</h3>
        <p className="text-gray-600 text-sm mb-4">Select a card to send to every player:</p>

        <div className="flex flex-row gap-2 overflow-x-auto mb-4">
          {hand.map(card => (
            <button
              key={card.id}
              onClick={() => setSelectedCard(card)}
              className={`p-1 w-24 h-auto shrink-0 border-2 rounded ${selectedCard?.id === card.id ? 'border-fuchsia-600' : 'border-transparent'}`}
            >
              {card.image && <img src={cardUrl(card.image)} alt={card.headline} className="w-full h-auto" />}
            </button>
          ))}
        </div>

        <div className="flex gap-2">
          <button
            disabled={!selectedCard}
            onClick={() => onSubmit(selectedCard.id, selectedCard.veracity, toIds)}
            className="flex-1 py-1 px-2 bg-violet-300 hover:bg-violet-950 text-slate-800 hover:text-slate-50 text-sm rounded-md border border-zinc-900 disabled:opacity-50"
          >
            Send to all players
          </button>
          <button onClick={onClose} className="py-1 px-2 border border-zinc-900 rounded-md text-sm hover:bg-orange-300">
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
