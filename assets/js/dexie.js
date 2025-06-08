import Dexie from "dexie";

const LocalDB = {
    init: () => {
        const db = new Dexie("multiplayer_room")
        db.version(1).stores({
		    mutltiplayer_room: 'room_name, player_name'
	    });

        return db
    },

    save_room_name_and_player_name: async(db, room_name, player_name) =>{
        await db.mutltiplayer_room.add({
            room_name: room_name,
            player_name: player_name
        })
    },
    save_room_name: async(db, room_name) =>{
        await db.mutltiplayer_room.add({
            room_name: room_name
        })
    },
    save_player_name_for_room: async(db, room_name, player_name) =>{
        // room = await db.mutltiplayer_room
        // .where('room_name').equals(room_name)
        await db.mutltiplayer_room.update(room_name, {
            player_name: player_name
        })
    },
    get_room_by_room_name: async(db, room_name) => {
        // await db.mutltiplayer_room.where('room_name').equals(room_name)
        return db.mutltiplayer_room.get(room_name)
    }
}

export {LocalDB}