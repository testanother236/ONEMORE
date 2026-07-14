/* eslint-disable no-console */
/* eslint-disable no-undef */
import { LightningElement,track } from 'lwc';

export default class Handler extends LightningElement {
    @track myValue = "initial value";

    handleChange(evt) {
        const typedValue = evt.target.value;
        console.log('typedValue  '+typedValue);
        const trimmedValue = typedValue.trim(); // trims the value entered by the user
        console.log('trimmedValue  '+trimmedValue);
        if (typedValue !== trimmedValue) {
            evt.target.value = trimmedValue;
        }
        this.myValue = trimmedValue; // updates the internal state
    }
}