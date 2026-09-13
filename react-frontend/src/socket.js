import { Socket } from 'phoenix'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || ''
let socket = null

export function getSocket() {
  if (!socket) {
    socket = new Socket(`${BACKEND_URL}/socket`)
    socket.connect()
  }
  return socket
}

export function joinWaitingRoom(roomName, playerName, callbacks) {
  const s = getSocket()
  const channel = s.channel(`waiting_room:${roomName}`, { player_name: playerName })

  channel.on('state_update', callbacks.onStateUpdate)
  channel.on('start_game', callbacks.onStartGame)

  return new Promise((resolve, reject) => {
    channel.join()
      .receive('ok', (resp) => resolve({ channel, state: resp }))
      .receive('error', reject)
  })
}

export function joinGameRoom(roomName, playerName, callbacks) {
  const s = getSocket()
  const channel = s.channel(`game_room:${roomName}`, { player_name: playerName })

  channel.on('state_update', callbacks.onStateUpdate)
  channel.on('notification', callbacks.onNotification)

  return new Promise((resolve, reject) => {
    channel.join()
      .receive('ok', (resp) => resolve({ channel, state: resp }))
      .receive('error', reject)
  })
}

export function channelPush(channel, event, payload) {
  return new Promise((resolve, reject) => {
    channel.push(event, payload)
      .receive('ok', resolve)
      .receive('error', reject)
  })
}
