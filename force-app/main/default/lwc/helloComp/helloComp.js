import { LightningElement } from 'lwc';

export default class HelloComp extends LightningElement {
    greeting = 'World';
    contacts = [
        {Id:'1',Name:'One',Title:'One Title'},
        {Id:'2',Name:'Two',Title:'Two Title'}
    ];

    handleChange(event) {
        this.greeting = event.target.value;
    }
}