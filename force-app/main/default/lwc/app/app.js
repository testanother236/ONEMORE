/* eslint-disable no-console */
import { LightningElement } from 'lwc';

export default class App extends LightningElement {
    handleNotify() {
        console.log('handleNotify executed');
    }
}