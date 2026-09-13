import { useState } from 'react'

function cardUrl(filename) {
  if (!filename) return null
  return `https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/${filename.replace(/ /g, '+')}`
}

function CardPreviewModal({ card, onClose }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div className="border-2 border-solid border-zinc-600 w-48 rounded-md bg-white" onClick={e => e.stopPropagation()}>
        <div className="relative p-2">
          {card.image && <img src={cardUrl(card.image)} alt={card.headline} className="w-full" />}
          <p className="absolute bottom-2 mx-2 z-10 p-2 text-xs bg-zinc-200 bg-opacity-75 rounded-sm">
            {card.headline}
          </p>
        </div>
      </div>
    </div>
  )
}

export default function Hand({ cards }) {
  const [previewCard, setPreviewCard] = useState(null)

  if (!cards?.length) return null

  return (
    <div className="h-fit border rounded-md p-2 bg-slate-200 max-w-full">
      <div className="flex flex-row gap-1 overflow-x-auto flex-nowrap w-full">
        {cards.map(card => (
          <button
            key={card.id}
            className="p-1 w-8 h-auto shrink-0"
            onClick={() => setPreviewCard(card)}
          >
            {card.image && (
              <img src={cardUrl(card.image)} alt={card.headline} className="w-full h-auto" />
            )}
          </button>
        ))}
      </div>
      {previewCard && (
        <CardPreviewModal card={previewCard} onClose={() => setPreviewCard(null)} />
      )}
    </div>
  )
}
