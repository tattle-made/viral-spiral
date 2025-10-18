import {animate, createTimeline} from 'animejs'

const HookCounter = {
    mounted(){
        console.log('mounted')
    },
    beforeUpdate(){
        console.log("before update")
        let label = this.el
        console.log(label.innerText)
    },
    updated(){
        console.log("after update")
        let label = this.el
        console.log(label.innerText)
        // animate(label, {
        //     // translateX: 100,
        //     // scale: .55,
        //     // rotate: "+=90",
        //     // 'font-size': "2em",
        //     scale: 1.2,
        //     rotate: 10,
        //     ease: 'outSine',
        //     duration: 150,
        //     loop: 5
        // })

        const tl = createTimeline({loop: 3})

        tl.add(label, {scale: 1.8, rotate: 20, ease: 'outSine', duration: 150})
        .add(label, {scale: 1, rotate: 0, ease: 'outSine', duration: 150})
        .add(label, {scale: 1.8, rotate: -20, ease: 'outSine', duration: 150})
        .add(label, {scale: 1, rotate: 0, ease: 'outSine', duration: 150})
 

        // tl.add(label, {scaleX: 1.1, scaleY: 1.1, ease: 'outSine', duration:150})
        // .add(label, {'font-size': '3.2em', ease: 'outSine', duration:150})
        // .add(label, {color: '#FF4444', duration: 150})
        // .add(label, {color: '#000000', duration: 150, delay: 3000})
        // .add(label, {scaleX: 1, scaleY: 1,  duration: 150})
        // .add(label, {'font-size': '1em', ease: 'outSine', duration:150})

        // animate(
        //     label,
        //     {
        //         translateX: [
        //             { value: -8, duration: 50 },
        //             { value: 8, duration: 50 },
        //             { value: -8, duration: 50 },
        //             { value:  8, duration: 50 },
        //             { value:  0, duration: 50 }
        //         ],
        //         easing: 'easeInOutSine',
        //         loop: true,
        //         direction: 'alternate'
        //     }
        // );
        

        
    }
}

export {HookCounter}