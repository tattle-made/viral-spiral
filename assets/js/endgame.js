export const EndGameHook = {
    mounted() {
        // console.log("EndGameHook mounted")
        this.handleEvent("send_endgame_metric", data => {
            // console.log("inside metric hook")
            // console.log(data)
            
            plausible('Game End', {props: {room: data.room}})
        })

    
    },
    updated(){}
}