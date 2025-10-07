import { Tooltip as FlowbiteTooltip } from "flowbite";

const TooltipHook = {
  mounted() {
    this.initializeTooltip();
  },

  updated() {
    if (this.tooltip) this.tooltip.destroy();
    this.initializeTooltip();
  },

  destroyed() {
    if (this.tooltip) this.tooltip.destroy();
  },

  initializeTooltip() {
    const triggerEl = this.el.querySelector("[data-tooltip-target]");
    const targetId = triggerEl?.getAttribute("data-tooltip-target");
    const targetEl = targetId ? document.querySelector(`#${targetId}`) : null;

    if (triggerEl && targetEl) {
      const options = {
        placement: triggerEl.getAttribute("data-placement") || "top",
        triggerType: "hover",
        offset: 10,
      };

      this.tooltip = new FlowbiteTooltip(targetEl, triggerEl, options, {
        id: targetId,
        override: true,
      });
    } else {
      console.error("Could not find tooltip target element");
    }
  },
};

export default TooltipHook;
