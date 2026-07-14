import { LightningElement, api } from "lwc";
export default class MyFilterComponent extends LightningElement {
  @api
  price = 0;
  @api
  discountPercentage = 0;
}