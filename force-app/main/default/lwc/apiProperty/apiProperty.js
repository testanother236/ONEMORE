/* eslint-disable no-undef */
import { LightningElement, track } from 'lwc';
export default class ApiProperty extends LightningElement {
    @track x;

    initDate() {
        this.x = new Date();
    }

    updateDate() {
        this.x.setHours(7);
    }
}