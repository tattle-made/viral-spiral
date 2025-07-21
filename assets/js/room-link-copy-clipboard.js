export const RoomLinkCopyClipboardHook = {
  mounted() {
    const tryInit = () => {
      const clipboard = FlowbiteInstances.getInstance('CopyClipboard', 'display-join-link');
      const tooltip = FlowbiteInstances.getInstance('Tooltip', 'tooltip-copy-display-join-link');
      if (!clipboard || !tooltip) {
        setTimeout(tryInit, 100); // Try again in 100ms
        return;
      }

      const defaultIcon = document.getElementById('default-icon');
      const successIcon = document.getElementById('success-icon');
      const defaultTooltipMessage = document.getElementById('default-tooltip-message');
      const successTooltipMessage = document.getElementById('success-tooltip-message');

      clipboard.updateOnCopyCallback(() => {
        showSuccess();
        setTimeout(() => {
          resetToDefault();
        }, 2000);
      });

      function showSuccess() {
        defaultIcon.classList.add('hidden');
        successIcon.classList.remove('hidden');
        defaultTooltipMessage.classList.add('hidden');
        successTooltipMessage.classList.remove('hidden');
        tooltip.show();
      }

      function resetToDefault() {
        defaultIcon.classList.remove('hidden');
        successIcon.classList.add('hidden');
        defaultTooltipMessage.classList.remove('hidden');
        successTooltipMessage.classList.add('hidden');
        tooltip.hide();
      }
    };

    tryInit();
  }
};