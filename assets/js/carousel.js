import { Carousel } from "flowbite";

const CarouselHook = {
  mounted() {
    console.log("CarouselHook mounted", this.el);
    
    const carouselEl = this.el;
    if (carouselEl) {
      try {
        if (!carouselEl.dataset.flowbiteInitialized) {
          console.log("Initializing carousel...");
          
          // Get all carousel items
          const carouselItems = carouselEl.querySelectorAll('[data-carousel-item]');
          console.log("Found carousel items:", carouselItems.length);
          
          if (carouselItems.length === 0) {
            console.warn("No carousel items found");
            return;
          }
          
          // Build the items array that Flowbite expects
          const items = Array.from(carouselItems).map((item, index) => ({
            position: index,
            el: item
          }));
          
          // Options (you can customize these)
          const options = {
            defaultPosition: 0, // Start with first item
            interval: false, // Disable auto-cycling since you want manual control
            // You can add other options here if needed
          };
          
          // Instance options
          const instanceOptions = {
            id: carouselEl.id || 'carousel-score-card',
            override: true
          };
          
          // Initialize the carousel with proper parameters
          const carousel = new Carousel(carouselEl, items, options, instanceOptions);
          carouselEl.dataset.flowbiteInitialized = "true";
          
          // Store the carousel instance for later use
          this.carousel = carousel;
          console.log("Carousel initialized:", carousel);
          
          // Set up event listeners for prev and next buttons
          const prevButton = this.el.querySelector('[data-carousel-prev]');
          const nextButton = this.el.querySelector('[data-carousel-next]');
          
          console.log("Prev button:", prevButton);
          console.log("Next button:", nextButton);
          
          if (prevButton) {
            prevButton.addEventListener('click', (e) => {
              e.preventDefault();
              console.log("Prev button clicked");
              carousel.prev();
            });
          }
          
          if (nextButton) {
            nextButton.addEventListener('click', (e) => {
              e.preventDefault();
              console.log("Next button clicked");
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