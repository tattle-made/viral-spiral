import {animate, createTimeline} from 'animejs'
import * as Tone from "tone";
const synth = new Tone.Synth().toDestination();

const BackgroundHook = {
    mounted(){
        console.log('on mount')
        let image_id = this.el.dataset.imageId
        const imgUrl = `http://localhost:8081/bg_${image_id}.png`

        const container_bg = this.el.querySelector("#container-bg-stage")
        const container_bg_backstage = this.el.querySelector("#container-bg-backstage")

        const tempImage = new Image()
        tempImage.onload = ()=>{
            container_bg.src = tempImage.src;
            animate(container_bg, {opacity: {from: 0, to: 1, duration: 5000}})
        }
        tempImage.src = imgUrl
        
        // container_bg.src = imgUrl
    },
    beforeUpdated(){
        console.log("before update")
    },
    updated(){
        
        console.log('after update')
        let image_id = this.el.dataset.imageId
        console.log(image_id)
        // synth.triggerAttackRelease(`C${Number.parseInt(image_id)+3}`, "8n");
        const imgUrl = `http://localhost:8081/bg_${image_id}.png`
     
        const container_bg = this.el.querySelector("#container-bg-stage")
        const container_bg_backstage = this.el.querySelector("#container-bg-backstage")

       

        const tempImage = new Image();
        tempImage.onload = function () {
            const tl = createTimeline({})
            container_bg_backstage.src = tempImage.src;

            animate(container_bg, {opacity: {from: 1, to: 0, duration: 5000}})
            animate(container_bg_backstage, {opacity: {from: 0, to: 1, duration: 5000}})

            setTimeout(()=>{

            })
            
        };
        tempImage.src = imgUrl;
    }
}

export { BackgroundHook }