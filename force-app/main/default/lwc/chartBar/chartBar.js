/* eslint-disable no-unused-vars */
// chartBar.js
import { LightningElement, api } from 'lwc';

export default class ChartBar extends LightningElement {
    @api 
    percentage;

    get style() {
        return `width: ${this.percentage}%`;
    }
}