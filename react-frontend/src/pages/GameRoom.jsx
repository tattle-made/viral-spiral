import { useState, useEffect, useRef, useCallback } from 'react'
import { useWiggle } from '../hooks/useWiggle'
import { useParams, useNavigate } from 'react-router-dom'
import { joinGameRoom, channelPush } from '../socket'
import { getPlayerForRoom } from '../db'
import PlayerScoreCard from '../components/PlayerScoreCard'
import CurrentCard from '../components/CurrentCard'
import Hand from '../components/Hand'
import CancelModal from '../components/CancelModal'
import ViralSpiralModal from '../components/ViralSpiralModal'

export default function GameRoom() {
  const { roomName } = useParams()
  const navigate = useNavigate()
  const [state, setState] = useState(null)
  const [notification, setNotification] = useState(null)
  const [error, setError] = useState(null)
  const [showCancel, setShowCancel] = useState(false)
  const [showViralSpiral, setShowViralSpiral] = useState(false)
  const channelRef = useRef(null)
  const notifTimerRef = useRef(null)

  function showNotif(text) {
    setNotification(text)
    clearTimeout(notifTimerRef.current)
    notifTimerRef.current = setTimeout(() => setNotification(null), 4000)
  }

  useEffect(() => {
    let mounted = true
    async function connect() {
      const playerName = await getPlayerForRoom(roomName)
      if (!playerName) { navigate('/'); return }
      try {
        const { channel, state: initState } = await joinGameRoom(roomName, playerName, {
          onStateUpdate: (s) => { if (mounted) setState(s) },
          onNotification: ({ text }) => { if (mounted && text) showNotif(text) }
        })
        channelRef.current = channel
        if (mounted) setState(initState)
      } catch (err) {
        if (mounted) setError('Could not connect to game room')
      }
    }
    connect()
    return () => {
      mounted = false
      channelRef.current?.leave()
      clearTimeout(notifTimerRef.current)
    }
  }, [roomName])

  const push = useCallback(async (event, payload) => {
    if (!channelRef.current) return
    try {
      const result = await channelPush(channelRef.current, event, payload)
      setState(result)
    } catch (err) {
      console.error('Action failed', err)
    }
  }, [])

  const chaosWiggle = useWiggle(state?.room?.chaos)

  if (error) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900">
      <p className="text-red-400">{error}</p>
    </div>
  )
  if (!state) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-900">
      <p className="text-white">Loading...</p>
    </div>
  )

  const {
    room, me, others, current_cards, hand, can_use_power,
    power_cancel, power_turn_fake, power_viral_spiral,
    current_turn_player, current_holder_name, end_game_message
  } = state

  const isMyTurn = current_turn_player?.id === me?.id

  return (
    <div
      className="relative w-full min-h-screen flex flex-col bg-cover bg-center bg-no-repeat"
      style={{ backgroundImage: `url(${room.bg_image})` }}
    >
      {/* Notification toast */}
      {notification && (
        <div className="fixed top-4 left-1/2 -translate-x-1/2 z-50 bg-gray-900 text-white px-6 py-3 rounded-lg shadow-lg">
          {notification}
        </div>
      )}

      {/* End game banner */}
      {end_game_message && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70">
          <div className="bg-gray-900 border-4 border-fuchsia-500 rounded-xl p-8 max-w-md text-center">
            <h2 className="text-2xl font-bold text-white mb-4">Game Over</h2>
            <p className="text-white">{end_game_message}</p>
            <button onClick={() => navigate('/')} className="mt-6 bg-fuchsia-800 hover:bg-fuchsia-500 text-white px-6 py-2 rounded-md">
              Back to Home
            </button>
          </div>
        </div>
      )}

      {/* ── Header bar ── */}
      <div className="p-2 flex flex-row flex-wrap gap-2 items-center">
        <p className="bg-fuchsia-950 p-2 w-fit h-fit rounded-xl text-fuchsia-100 text-sm">
          {room.name}
        </p>
        {current_holder_name && (
          <p className="bg-[#728645] p-2 w-fit h-fit rounded-xl text-fuchsia-100 text-sm">
            {current_holder_name}
          </p>
        )}
        <div className="flex-1" />
        <div className="bg-fuchsia-950 p-2 rounded-xl text-fuchsia-100 text-sm">
          Chaos Countdown: <strong className={`inline-block ${chaosWiggle}`}>{room.chaos}</strong>
        </div>
      </div>

      {/* ── Others at top ── */}
      {others?.length > 0 && (
        <div className="px-2 pb-2 flex flex-row gap-4 overflow-x-auto justify-center flex-wrap">
          {others.map(player => (
            <PlayerScoreCard
              key={player.id}
              player={player}
              isMe={false}
              isCurrentTurn={player.id === current_turn_player?.id}
            />
          ))}
        </div>
      )}

      {/* ── Current card — center, flex-1 ── */}
      <div className="flex-1 flex justify-center items-start mt-2">
        <div className="flex flex-col items-center gap-2">
          {/* Powers (on my turn, above card) */}
          {isMyTurn && (
            <div className="flex gap-2 flex-wrap justify-center">
              {power_cancel?.can_cancel && can_use_power && (
                <button
                  onClick={() => setShowCancel(true)}
                  className="py-1 px-2 bg-violet-300 hover:bg-violet-950 text-slate-800 hover:text-slate-50 text-xs rounded-md border border-zinc-900"
                >
                  Cancel Player
                </button>
              )}
              {power_viral_spiral?.enabled && can_use_power && (
                <button
                  onClick={() => setShowViralSpiral(true)}
                  className="py-1 px-2 bg-violet-300 hover:bg-violet-950 text-slate-800 hover:text-slate-50 text-xs rounded-md border border-zinc-900"
                >
                  Enable Viral Spiral Power
                </button>
              )}
            </div>
          )}

          {/* Cancel vote prompt */}
          {power_cancel?.can_vote && (
            <div className="p-3 border border-red-400 rounded-lg bg-white/90 text-center">
              <p className="text-sm mb-2">
                <strong>{power_cancel.from_player?.name}</strong> wants to cancel{' '}
                <strong>{power_cancel.target_player?.name}</strong>. Vote?
              </p>
              <div className="flex gap-3 justify-center">
                <button
                  onClick={() => push('cancel_vote', { from_id: me.id, vote: true })}
                  className="py-1 px-3 bg-[#015058] hover:bg-[#21802B] text-white rounded text-sm"
                >
                  👍 Yes
                </button>
                <button
                  onClick={() => push('cancel_vote', { from_id: me.id, vote: false })}
                  className="py-1 px-3 bg-[#015058] hover:bg-[#21802B] text-white rounded text-sm"
                >
                  👎 No
                </button>
              </div>
            </div>
          )}

          {current_cards?.map(card => (
            <CurrentCard
              key={card.id}
              card={card}
              me={me}
              isMyTurn={isMyTurn}
              canUsePower={can_use_power}
              powerTurnFake={power_turn_fake}
              onPassTo={(toId) => push('pass_to', { from_id: me.id, to_id: toId, card: { id: card.id, veracity: card.veracity } })}
              onKeep={() => push('keep', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
              onDiscard={() => push('discard', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
              onViewSource={() => push('view_source', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
              onHideSource={() => push('hide_source', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
              onMarkAsFake={() => push('mark_as_fake', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
              onTurnFake={() => push('turn_fake', { from_id: me.id, card: { id: card.id, veracity: card.veracity } })}
            />
          ))}
        </div>
      </div>

      {/* ── Me + Hand at bottom ── */}
      <div className="flex flex-wrap mx-auto gap-2 mb-4 mt-2 justify-center px-2">
        {me && (
          <PlayerScoreCard
            player={me}
            isMe={true}
            isCurrentTurn={me.id === current_turn_player?.id}
          />
        )}
        <Hand cards={hand} />
      </div>

      {/* Modals */}
      {showCancel && power_cancel && (
        <CancelModal
          power={power_cancel}
          me={me}
          onSubmit={(affinity, targetId) => {
            push('initiate_cancel', { from_id: me.id, target_id: targetId, affinity })
            setShowCancel(false)
          }}
          onClose={() => setShowCancel(false)}
        />
      )}

      {showViralSpiral && (
        <ViralSpiralModal
          hand={hand}
          others={others}
          me={me}
          onSubmit={(cardId, cardVeracity, toIds) => {
            push('initiate_viral_spiral', {
              from_id: me.id,
              to_id: toIds,
              card: { id: cardId, veracity: cardVeracity }
            })
            setShowViralSpiral(false)
          }}
          onClose={() => setShowViralSpiral(false)}
        />
      )}
    </div>
  )
}
