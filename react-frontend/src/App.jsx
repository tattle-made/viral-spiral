import { useEffect } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import Home from './pages/Home'
import JoinRoom from './pages/JoinRoom'
import WaitingRoom from './pages/WaitingRoom'
import GameRoom from './pages/GameRoom'
import { playButtonClick } from './audio'

export default function App() {
  useEffect(() => {
    function handleClick(e) {
      if (e.target.closest('button')) playButtonClick()
    }
    document.addEventListener('click', handleClick)
    return () => document.removeEventListener('click', handleClick)
  }, [])

  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/join/:roomName" element={<JoinRoom />} />
      <Route path="/waiting-room/:roomName" element={<WaitingRoom />} />
      <Route path="/room/:roomName" element={<GameRoom />} />
      <Route path="*" element={<Navigate to="/" />} />
    </Routes>
  )
}
