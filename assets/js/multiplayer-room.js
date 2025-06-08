import { LocalDB } from "./dexie";

/**
 * @type {import("phoenix_live_view").Hook}
 */
const HookMultiplayerRoom = {
    mounted(){
        this.handleEvent("vs:mp_room:view_mounted", async ({room_name})=>{
            let room = await LocalDB.get_room_by_room_name(window.localDB, room_name)
            this.pushEvent("save_player_name_in_assigns", {player_name: room.player_name})
        })
    }
}

export {HookMultiplayerRoom}



// window.addEventListener("phx:vs:mp_room:init_load_room", async ({detail})=>{
//   let room = await LocalDB.get_room_by_room_name(db, detail.room_name)
//   console.log(room)
//   // await LocalDB.save_room_name_and_player_name(db, detail.room_name, detail.player_name)
// })
// window.addEventListener("phx:vs:mp_waiting_room:start", (e)=>{console.log(e)})