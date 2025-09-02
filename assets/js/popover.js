import { Popover } from "flowbite";

const PopoverHook = {
  mounted() {
    this.initializePopover();
  },

  updated() {
    if (this.popover) this.popover.destroy();
    this.initializePopover();
  },

  destroyed() {
    if (this.popover) this.popover.destroy();
  },

  initializePopover() {
    const triggerEl = this.el.querySelector("[data-popover-target]");
    const targetId = triggerEl?.getAttribute("data-popover-target");
    const targetEl = targetId ? this.el.querySelector(`#${targetId}`) : null;

    if (triggerEl && targetEl) {
      const options = {
        placement: "bottom",
        triggerType: "hover",
        offset: 10,
      };

      this.popover = new Popover(targetEl, triggerEl, options, {
        id: targetId,
        override: true,
      });
    } else {
      console.error("Could not find target");
    }
  },
};

export default PopoverHook;