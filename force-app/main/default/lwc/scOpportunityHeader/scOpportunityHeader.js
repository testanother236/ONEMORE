import { LightningElement, api } from "lwc";

export default class ScOpportunityHeader extends LightningElement {
  @api oppNames = [];
  @api oppId;
  @api oppName;

  handleClick(e) {
    let id = e.currentTarget.dataset.id;
    const event = new CustomEvent("getoppid", { detail: { message: id } });
    this.dispatchEvent(event);
  }
}