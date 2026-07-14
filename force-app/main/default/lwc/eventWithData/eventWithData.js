/* eslint-disable no-console */
import { LightningElement, wire, track } from 'lwc';
import getContactList from '@salesforce/apex/ContactController.getContactList';

export default class EventWithData extends LightningElement {
    @track selectedContact;

    @wire(getContactList) contacts;

    contactSelected(event) {
        const contactId = event.detail;
        console.log('contactId  '+contactId);
        this.selectedContact = this.contacts.data.find(contact => contact.Id === contactId);
        console.log('contactId1111  '+this.selectedContacttId);
    }

    get listIsNotEmpty() {
        console.log('11 '+JSON.stringify(this.contacts));
        console.log('22 '+Array.isArray(this.contacts.data));
       // console.log('33 '+contacts.data.length);
        return this.contacts && Array.isArray(this.contacts.data) && this.contacts.data.length > 0;
    }
}