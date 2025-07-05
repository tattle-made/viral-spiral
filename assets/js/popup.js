import {animate} from 'animejs'

const HookPopup = {
    mounted(){
        let text = this.el.querySelector("#message")
        this.handleEvent("show_popup", e=>{
            text.innerText = e.message
            animate(this.el, {
                top : {from: '-20em', to: '0em', duration: 125, ease: 'in'},
            })
        })
    },
    updated(){
        // gameState = this.el.dataset.gameState
        // if(gameState==="finished"){
        //      animate(this.el, {
        //         top : {from: '-20em', to: '0em', duration: 125, ease: 'in'},
        //     })
        // }
    }
}

export {HookPopup}