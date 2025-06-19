import { LocalDB } from "./dexie";
import { Application, Sprite, Loader, } from 'pixi.js';

function setBackgroundImage(div, imageUrl) {
  const img = new Image();
  img.onload = function() {
    div.style.backgroundImage = `url('${imageUrl}')`;
    div.style.backgroundSize = 'cover';      
    div.style.backgroundPosition = 'center'; 
  };
  img.onerror = function() {
    console.error("Failed to load image:", imageUrl);
  };
  img.src = imageUrl;
}


/**
 * @type {import("phoenix_live_view").Hook}
 */
const HookMultiplayerRoom = {
    mounted(){
        this.handleEvent("vs:mp_room:view_mounted", async ({room_name})=>{
            let room = await LocalDB.get_room_by_room_name(window.localDB, room_name)
            this.pushEvent("save_player_name_in_assigns", {player_name: room.player_name})
        })
    },
    updated(){
        // console.log("updated")
        // let element = this.el
        // chaos = element.dataset.chaos
        // console.log(chaos)

        // let bg_container = element.querySelector("#bg-image")
        // setBackgroundImage(bg_container, `https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/bg/default_${chaos}.jpg`)
        // loadImageWithPixi(bg_container, "https://s3.ap-south-1.amazonaws.com/media.viralspiral.net/bg/default.jpg")
    }
}

export {HookMultiplayerRoom}



// window.addEventListener("phx:vs:mp_room:init_load_room", async ({detail})=>{
//   let room = await LocalDB.get_room_by_room_name(db, detail.room_name)
//   console.log(room)
//   // await LocalDB.save_room_name_and_player_name(db, detail.room_name, detail.player_name)
// })
// window.addEventListener("phx:vs:mp_waiting_room:start", (e)=>{console.log(e)})