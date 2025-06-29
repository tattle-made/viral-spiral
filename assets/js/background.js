import {animate} from 'animejs'

let activeIndex = 0;

function makeImageUrl(image_id) {
    return `http://localhost:8081/bg_${image_id}.png`
}

const BackgroundHook = {
    mounted(){
        let imageId = this.el.dataset.imageId
        const imgUrl = makeImageUrl(imageId)
        let activeContainerIndex = activeIndex

        containers = this.el.querySelectorAll('img')

        const image = new Image()
        image.src = imgUrl
        image.onload = ()=>{
            activeContainer = containers[activeContainerIndex]
            activeContainer.src = image.src;
            animate(activeContainer, {opacity: {from: 0, to: 1, duration: 250}})
        }
    },
    updated(){
        let el = this.el
        let imageId = el.dataset.imageId
        let activeContainerIndex  = activeIndex

        containers = el.querySelectorAll('img')        
        const imgUrl = `http://localhost:8081/bg_${imageId}.png`

        const image = new Image();
        image.src = imgUrl;
        image.onload = function () {
            var activeContainer = containers[activeContainerIndex]
            var otherContainerIndex = (activeContainerIndex + 1) % 2
            var otherContainer = containers[otherContainerIndex]

            otherContainer.src = image.src

            animate(activeContainer, {opacity: {from: 1, to: 0, duration: 2000, ease: 'inOut'}})
            animate(otherContainer, {opacity: {from: 0, to: 1, duration: 2000, ease: 'out'}})  
                      
            activeIndex = otherContainerIndex
        }; 
    }
}

export { BackgroundHook }