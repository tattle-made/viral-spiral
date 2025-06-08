import { Application, Assets, Container, Sprite } from 'pixi.js';
import { HTMLText } from 'pixi.js';
// import '@pixi/layout';

const html = (label) => new HTMLText({
    text: label,
    style: {
        fontFamily: 'Arial',
        fontSize: 24,
        fill: '#999999',
        align: 'center',
    },
});

let app;


const HookPixiRoomMultiplayer = {
    mounted(){
        const element = this.el;

        (async ()=>{
        console.log("mounted")
        app = new Application();

        // Initialize the application
        await app.init({ background: '#000000', resizeTo: window });

        // Append the application canvas to the document body
        // document
        // .querySelector("#pixi-room-multiplayer")
        // .appendChild(app.canvas);

        // document.body.appendChild(app.canvas);

        // app.stage.layout = {
        //     width: app.screen.width,
        //     height: app.screen.height,
        //     justifyContent: 'center',
        //     alignItems: 'center',
        // }

        // app.stage.addChild(html("Hello"));
        
        
        // const state_str = element.dataset.state
        // state = JSON.parse(state_str)
        
        // app.stage.addChild(html(state.msg));
        })()


        
    },
    updated(){
        console.log("before update")
         const state_str = this.el.dataset.state
        state = JSON.parse(state_str)
        console.log(state)
        // app.stage.addChild(html(state.msg));
    }
}

export default HookPixiRoomMultiplayer