import { LightningElement, track } from 'lwc';

export default class ReportsOnAccount extends LightningElement {

    @track greeting = 'Ravi';

    @track greeting2 = 'Ravi2';

    changeHandler(event) {
        //console.log(event.target.test);
        this.greeting = event.target.value;
    }
}