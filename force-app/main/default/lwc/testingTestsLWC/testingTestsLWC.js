import { LightningElement, api } from 'lwc';

export default class MyComponent extends LightningElement {
    @api inputValue = '';

    // test commen

    handleInputChange(event) {
        this.inputValue = event.target.value;
    }
}