/* eslint-disable no-unused-vars */
// simpleTrack.js
import { LightningElement, api,track } from 'lwc';

export default class App extends LightningElement {
    //@track
    itemName = 'milk';
    name ='deepak';

    handleClick(){
        this.itemName = 'bread';
        this.name='rahul';
        // eslint-disable-next-line no-console
        console.log('itemName is ' + this.itemName);
    }
}