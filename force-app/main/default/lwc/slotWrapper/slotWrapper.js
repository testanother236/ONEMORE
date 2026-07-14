import { LightningElement } from 'lwc';

export default class SlotWrapper extends LightningElement {
    renderedCallback() {
       // this.template.querySelector('div'); // <div>First</div>
        this.template.querySelector('span'); // null
        //this.template.querySelectorAll(); // [<div>First</div>, <div>Second</div>]
    }
}