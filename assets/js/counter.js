import {animate, createTimeline} from 'animejs'

const HookCounter = {
    mounted(){
        console.log('mounted')
    },
    beforeUpdated(){
        console.log("before update")
    },
    updated(){
        console.log("after update")
        let label = this.el.querySelector("#counter-label")
        console.log(label)
        // animate(label, {
        //     // translateX: 100,
        //     // scale: .55,
        //     // rotate: "+=90",
        //     // 'font-size': "2em",
        //     translateY: -5.0,
        //     ease: 'outSine',
        //     duration: 150,
        //     loop: 2
        // })

        const tl = createTimeline({})

        tl.add(label, {translateY: -2.5, translateX: -2.5, ease: 'outSine', duration:150})
        .add(label, {'font-size': '3.2em', ease: 'outSine', duration:150})
        .add(label, {color: '#FF4444', duration: 150})
        .add(label, {color: '#000000', duration: 150, delay: 3000})
        .add(label, {translateY: 0, translateX: 0,  duration: 150})
        .add(label, {'font-size': '1em', ease: 'outSine', duration:150})
    }
}

export {HookCounter}