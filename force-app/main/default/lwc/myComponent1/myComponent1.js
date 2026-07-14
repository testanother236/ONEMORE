// myComponent.js
import { LightningElement, api, track } from 'lwc';

export default class MyComponent1 extends LightningElement {
    @track privateTitle='hi';

    @api
    get title() {
        console.log(this.privateTitle);
        return this.privateTitle;
    }

    set title(value) {
        this.privateTitle = value.toUpperCase();
        this.setAttribute('title', this.privateTitle);
    }
}