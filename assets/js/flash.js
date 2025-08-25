export const FlashAutoHide = {
    mounted() {
        const msAttr = this.el.getAttribute("data-timeout-ms");
        const timeout = parseInt(msAttr || "0", 10);
        if (!Number.isFinite(timeout) || timeout <= 0) return;

        this.timer = setTimeout(() => {
            // Trigger the same behavior as manual close by clicking the element
            // which has a phx-click to clear and hide itself
            this.el.click();
        }, timeout);
    },
    destroyed() {
        if (this.timer) {
            clearTimeout(this.timer);
            this.timer = null;
        }
    }
};
