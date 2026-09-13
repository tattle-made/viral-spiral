import Dexie from 'dexie'

const db = new Dexie('ViralSpiral')
db.version(1).stores({
  rooms: 'room_name, player_name'
})

export async function saveRoomAndPlayer(roomName, playerName) {
  await db.rooms.put({ room_name: roomName, player_name: playerName })
}

export async function getPlayerForRoom(roomName) {
  const record = await db.rooms.get(roomName)
  return record?.player_name || null
}

export default db
