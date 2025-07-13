import { Carousel } from "flowbite";

const CarouselHook = {
  mounted() {
    const carouselEl = this.el.querySelector('[data-carousel="static"]');
    if (carouselEl) {
      try {
        if (!carouselEl.dataset.flowbiteInitialized) {
          // Initialize the carousel
          const carousel = new Carousel(carouselEl);
          carouselEl.dataset.flowbiteInitialized = "true";
          
          // Store the carousel instance for later use
          this.carousel = carousel;
          
          // Set up event listeners for prev and next buttons
          const prevButton = this.el.querySelector('[data-carousel-prev]');
          const nextButton = this.el.querySelector('[data-carousel-next]');
          
          if (prevButton) {
            prevButton.addEventListener('click', () => {
              carousel.prev();
            });
          }
          
          if (nextButton) {
            nextButton.addEventListener('click', () => {
              carousel.next();
            });
          }
        }
      } catch (err) {
        console.error("Flowbite carousel init failed", err);
      }
    }
  },
  
  destroyed() {
    // Clean up if needed
    if (this.carousel) {
      this.carousel = null;
    }
  }
};

export { CarouselHook };