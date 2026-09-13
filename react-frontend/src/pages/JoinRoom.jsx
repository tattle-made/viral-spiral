import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { saveRoomAndPlayer } from '../db'

export default function JoinRoom() {
  const { roomName } = useParams()
  const navigate = useNavigate()
  const [playerName, setPlayerName] = useState('')

  async function handleSubmit(e) {
    e.preventDefault()
    await saveRoomAndPlayer(roomName, playerName)
    navigate(`/waiting-room/${roomName}?player=${encodeURIComponent(playerName)}`)
  }

  return (
    <div className="min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center flex items-center justify-center px-4">
      <form onSubmit={handleSubmit} className="w-full max-w-sm border-4 border-[#3E6FF2] rounded-md p-8 space-y-4">
        <h2 className="text-2xl font-semibold text-textcolor-light text-center">Join Room</h2>
        <p className="text-gray-400 text-sm text-center">Room: <span className="text-fuchsia-300 font-semibold">{roomName}</span></p>
        <div>
          <label className="block text-textcolor-light text-sm mb-1">Your Name</label>
          <input
            autoFocus
            className="w-full rounded bg-gray-800 text-white px-3 py-2 border border-gray-600"
            value={playerName}
            onChange={e => setPlayerName(e.target.value)}
            required
          />
        </div>
        <button
          type="submit"
          className="w-full bg-fuchsia-800 hover:bg-fuchsia-500 text-white px-4 py-2 rounded-md font-semibold"
        >
          Join
        </button>
      </form>
    </div>
  )
}
