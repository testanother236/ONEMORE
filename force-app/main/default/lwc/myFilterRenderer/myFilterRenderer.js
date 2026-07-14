import { LightningElement, api } from "lwc";
export default class MyFilterRenderer extends LightningElement {
  @api
  myString = '';
  @api
  myBoolean = false;
}