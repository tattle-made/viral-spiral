const HookMultiplayerHome = {
    mounted(){
        console.log("mounted mp home")
        const el = this.el
    
        el.addEventListener("phx:vs:mproom:create_room", (e)=>{
            console.log("room_name", e)
        })
    }
}

export {
    HookMultiplayerHome
}