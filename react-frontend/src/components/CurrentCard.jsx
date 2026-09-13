function cardUrl(filename) {
  if (!filename) return null
  return `https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/${filename.replace(/ /g, '+')}`
}

const btnClass = 'py-1 px-2 hover:bg-orange-300 text-xs rounded-md border border-zinc-900 bg-white'

export default function CurrentCard({
  card, me, isMyTurn, canUsePower, powerTurnFake,
  onPassTo, onKeep, onDiscard, onViewSource, onHideSource, onMarkAsFake, onTurnFake
}) {
  return (
    <div className="border-2 border-solid border-zinc-600 w-fit rounded-md bg-slate-50 flex flex-col gap-2 m-2 mx-auto max-w-sm">
      {/* Card image with headline overlay */}
      <div className="relative w-full h-80 flex flex-col gap-2">
        {card.image && (
          <img className="w-full h-80 object-contain" src={cardUrl(card.image)} alt={card.headline} />
        )}
        <p className="absolute z-10 bottom-0 px-2 py-2 mx-4 text-sm bg-zinc-200 bg-opacity-95 rounded-md text-xs">
          {card.headline}
        </p>
      </div>

      <div className="flex flex-col py-2">
        {/* Pass to */}
        {isMyTurn && card.pass_to?.filter(t => t.id !== me?.id).length > 0 && (
          <div className="px-2 flex flex-row gap-2 items-center mb-2">
            <span className="text-sm self-center">Pass to</span>
            <div className="flex flex-row flex-wrap gap-2">
              {card.pass_to.filter(t => t.id !== me?.id).map(target => (
                <button key={target.id} onClick={() => onPassTo(target.id)} className={btnClass}>
                  {target.name}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Keep / Discard */}
        {isMyTurn && (
          <div className="mt-1 flex flex-row gap-2 flex-wrap px-2">
            <button onClick={onKeep} className={btnClass}>Keep</button>
            <button onClick={onDiscard} className={btnClass}>Discard</button>
          </div>
        )}

        <div className="border border-dashed border-zinc-400 mt-2 mb-2 mx-2" />

        {/* Secondary actions */}
        <div className="flex flex-row flex-wrap gap-2 px-2">
          {card.source ? (
            <button onClick={onHideSource} className={btnClass}>Hide Source</button>
          ) : (
            <button onClick={onViewSource} className={btnClass}>View Source</button>
          )}
          {isMyTurn && canUsePower && card.can_mark_as_fake && (
            <button onClick={onMarkAsFake} className={btnClass}>Mark as Fake</button>
          )}
          {isMyTurn && canUsePower && powerTurnFake?.enabled && card.can_turn_fake && (
            <button onClick={onTurnFake} className={btnClass}>Add Hate</button>
          )}
        </div>

        {/* Source article inline */}
        {card.source && (
          <div className="mx-2 mt-2 bg-zinc-100 p-2 rounded text-sm">
            <p className="font-light text-gray-500 text-xs">Author</p>
            <p className="font-normal text-sm">{card.source.author}</p>
            <p className="font-light text-gray-500 text-xs mt-1">Headline</p>
            <p className="font-normal text-sm">{card.source.headline}</p>
            <p className="font-light text-gray-500 text-xs mt-1">Content</p>
            <p className="font-normal text-sm">{card.source.content}</p>
          </div>
        )}
      </div>
    </div>
  )
}
