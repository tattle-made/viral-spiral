import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { saveRoomAndPlayer } from '../db'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:4000'

export default function Home() {
  const navigate = useNavigate()
  const [tab, setTab] = useState('create') // 'create' | 'join'
  const [createForm, setCreateForm] = useState({ player_name: '' })
  const [joinForm, setJoinForm] = useState({ room_name: '', player_name: '' })
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(false)

  async function handleCreate(e) {
    e.preventDefault()
    setError(null)
    setLoading(true)
    try {
      const res = await fetch(`${BACKEND_URL}/api/rooms`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ player_name: createForm.player_name })
      })
      if (!res.ok) throw new Error('Failed to create room')
      const { room_name } = await res.json()
      await saveRoomAndPlayer(room_name, createForm.player_name)
      navigate(`/waiting-room/${room_name}`)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  async function handleJoin(e) {
    e.preventDefault()
    setError(null)
    await saveRoomAndPlayer(joinForm.room_name, joinForm.player_name)
    navigate(`/waiting-room/${joinForm.room_name}?player=${encodeURIComponent(joinForm.player_name)}`)
  }

  return (
    <div className="min-h-screen bg-[url('/images/bg-gray.jpg')] bg-cover bg-center flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <h1 className="text-4xl font-bold text-textcolor-light text-center mb-8">Viral Spiral</h1>

        <div className="flex mb-4 border-b border-fuchsia-800">
          <button
            className={`flex-1 py-2 text-sm font-semibold ${tab === 'create' ? 'text-fuchsia-300 border-b-2 border-fuchsia-300' : 'text-textcolor-light'}`}
            onClick={() => setTab('create')}
          >
            Create Room
          </button>
          <button
            className={`flex-1 py-2 text-sm font-semibold ${tab === 'join' ? 'text-fuchsia-300 border-b-2 border-fuchsia-300' : 'text-textcolor-light'}`}
            onClick={() => setTab('join')}
          >
            Join Room
          </button>
        </div>

        {error && <p className="text-red-400 text-sm mb-4 text-center">{error}</p>}

        {tab === 'create' && (
          <form onSubmit={handleCreate} className="border-4 border-[#3E6FF2] rounded-md p-6 space-y-4">
            <div>
              <label className="block text-textcolor-light text-sm mb-1">Your Name</label>
              <input
                className="w-full rounded bg-gray-800 text-white px-3 py-2 border border-gray-600"
                value={createForm.player_name}
                onChange={e => setCreateForm(f => ({ ...f, player_name: e.target.value }))}
                required
              />
            </div>
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-fuchsia-800 hover:bg-fuchsia-500 text-white px-4 py-2 rounded-md font-semibold disabled:opacity-50"
            >
              {loading ? 'Creating...' : 'Create Room'}
            </button>
          </form>
        )}

        {tab === 'join' && (
          <form onSubmit={handleJoin} className="border-4 border-[#3E6FF2] rounded-md p-6 space-y-4">
            <div>
              <label className="block text-textcolor-light text-sm mb-1">Room Name</label>
              <input
                className="w-full rounded bg-gray-800 text-white px-3 py-2 border border-gray-600"
                value={joinForm.room_name}
                onChange={e => setJoinForm(f => ({ ...f, room_name: e.target.value }))}
                required
              />
            </div>
            <div>
              <label className="block text-textcolor-light text-sm mb-1">Your Name</label>
              <input
                className="w-full rounded bg-gray-800 text-white px-3 py-2 border border-gray-600"
                value={joinForm.player_name}
                onChange={e => setJoinForm(f => ({ ...f, player_name: e.target.value }))}
                required
              />
            </div>
            <button
              type="submit"
              className="w-full bg-fuchsia-800 hover:bg-fuchsia-500 text-white px-4 py-2 rounded-md font-semibold"
            >
              Join Room
            </button>
          </form>
        )}
      </div>
    </div>
  )
}
