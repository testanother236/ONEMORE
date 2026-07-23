import { LightningElement, wire, track } from 'lwc';
import getUserInfo from '@salesforce/apex/ScUserInfoController.getUserInfo';

export default class ScUserInfo extends LightningElement {
    error;
    isLoading = true;
    errorMsg = 'Internal Server Error'
    
    @track infoUserProperties = {
        'First Name':null,
        'Last Name':null,
        'Mobile Number':null,
        'Phone Number': null,
        'Email Address': null,
        'Address': null,
        photoUrl: null
    };


    get userObjectProperties() {
        // Create an object without the photoUrl property
        const { photoUrl, ...filteredProperties } = this.infoUserProperties;
    
        // Map over the filtered properties and set empty values to "------"
        return Object.entries(filteredProperties).map(([key, value]) => ({
            key,
            value: value ? value : "------" // Set to "------" if value is empty
        }));
    }

    
    @wire(getUserInfo)
    wiredUserOpportunities({ error, data }) {
        this.isLoading = true; // Start loading
        if (data) {
            this.infoUserProperties['First Name'] = data.user?.FirstName;
            this.infoUserProperties['Last Name'] = data.user?.LastName;
            this.infoUserProperties['Mobile Number'] = data.user?.MobilePhone;
            this.infoUserProperties['Phone Number'] = data.user?.Phone;
            this.infoUserProperties['Email Address'] = data.user?.Email;
            this.infoUserProperties.Address = `${data.user?.Street} , ${data.user?.City}, ${data.user?.Country}`;
            this.infoUserProperties.photoUrl = data.user?.SmallPhotoUrl;
            this.error = undefined;
            this.isLoading = false; // Loading complete
        } else if (error) {
            this.error = error;
            this.isLoading = false; // Loading complete
            this.showToast('error', this.errorMsg)
        }
    }

    showToast(type, message){
        this.template.querySelector('c-sc-custom-toast').showToast(type, message);

    }
}