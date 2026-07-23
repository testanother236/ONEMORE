import { ShowToastEvent } from "lightning/platformShowToastEvent";

const showToast = (component, title, message, variant) => {
  const evt = new ShowToastEvent({
    title: title,
    message: message,
    variant: variant
  });
  component.dispatchEvent(evt);
};

export default {
  showToast
};