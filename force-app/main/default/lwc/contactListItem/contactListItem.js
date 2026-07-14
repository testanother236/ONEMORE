/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';

export default class ContactListItem extends LightningElement {
    @api contact;

    selectHandler(event) {
        // Prevents the anchor element from navigating to a URL.
        event.preventDefault();

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selected', { detail: this.contact.Id });
        console.log('selectedEvent   '+JSON.stringify(selectedEvent));
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}