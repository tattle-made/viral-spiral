export const FlashAutoHide = {
    mounted() {
        console.log("Flash auto hide hook mounted", this.el);
        const msAttr = this.el.getAttribute("data-timeout-ms");
        const timeout = parseInt(msAttr || "4000", 10);
        if (!Number.isFinite(timeout) || timeout <= 0) return;

        this.el.style.transition = 'opacity 0.5s ease-out';

        this.hideTimer = setTimeout(() => {

            this.el.style.opacity = '0';

            this.removeTimer = setTimeout(() => {
                if (this.el && this.el.parentNode) {
                    this.el.parentNode.removeChild(this.el);
                }
            }, 500);
        }, timeout);
    },

    destroyed() {
        if (this.hideTimer) clearTimeout(this.hideTimer);
        if (this.removeTimer) clearTimeout(this.removeTimer);
    }
};
