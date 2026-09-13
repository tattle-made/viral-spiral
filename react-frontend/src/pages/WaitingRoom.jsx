import { useState, useEffect, useRef } from 'react'
import { useParams, useNavigate, useSearchParams } from 'react-router-dom'
import { joinWaitingRoom } from '../socket'
import { getPlayerForRoom } from '../db'

export default function WaitingRoom() {
  const { roomName } = useParams()
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const [players, setPlayers] = useState([])
  const [error, setError] = useState(null)
  const channelRef = useRef(null)
  const joinLink = `${window.location.origin}/join/${roomName}`

  useEffect(() => {
    let mounted = true

    async function connect() {
      const playerFromUrl = searchParams.get('player')
      const playerName = playerFromUrl || await getPlayerForRoom(roomName)
      if (!playerName) {
        navigate(`/?join=${roomName}`)
        return
      }

      try {
        const { channel, state } = await joinWaitingRoom(roomName, playerName, {
          onStateUpdate: ({ players }) => {
            if (mounted) setPlayers(players)
          },
          onStartGame: () => {
            if (mounted) navigate(`/room/${roomName}`)
          }
        })
        channelRef.current = channel
        if (mounted) setPlayers(state.players || [])
      } catch (err) {
        if (mounted) setError('Could not join room')
      }
    }

    connect()
    return () => {
      mounted = false
      channelRef.current?.leave()
    }
  }, [roomName])

  async function copyLink() {
    await navigator.clipboard.writeText(joinLink)
  }

  async function startGame() {
    channelRef.current?.push('start_game', {})
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-900">
        <p className="text-red-400">{error}</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center flex items-center justify-center px-4">
      <div className="border-4 border-[#3E6FF2] rounded-md p-8 text-center max-w-lg w-full">
        <p className="text-textcolor-light text-xl font-semibold mb-4">
          Share the Room Link with other players
        </p>

        <div className="flex items-center gap-2 mb-8">
          <input
            readOnly
            value={joinLink}
            className="flex-1 bg-gray-800 text-gray-300 text-sm rounded-lg px-3 py-2 border border-gray-600"
          />
          <button
            onClick={copyLink}
            className="px-3 py-2 bg-gray-700 hover:bg-gray-600 rounded-lg text-white text-sm"
          >
            Copy
          </button>
        </div>

        <div className="mb-8 space-y-2">
          {players.map(name => (
            <p key={name} className="text-xl">
              <span className="text-[#C3268A] font-bold">{name}</span>
              <span className="text-textcolor-light"> has joined</span>
            </p>
          ))}
        </div>

        <button
          onClick={startGame}
          className="w-full bg-fuchsia-800 hover:bg-fuchsia-500 text-white px-4 py-2 rounded-md font-semibold"
        >
          Start Game
        </button>
      </div>
    </div>
  )
}
