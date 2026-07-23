import { LightningElement, wire, track } from 'lwc';
import getIsUsernamePasswordEnabled from '@salesforce/apex/SCLoginController.getIsUsernamePasswordEnabled';
import login from '@salesforce/apex/SCLoginController.login';

export default class ScCustomLoginPage extends LightningElement {
    // Properties to hold the state of the login page
    isUsernamePasswordEnabled;
    username;
    password;
    
    @track textObj={
        internalErrorValue: "Internal Server Error",
        urlErrorValue: "Invalid URL format",
        fieldsErrorValue: "Please fill both fields",
        username: "Username",
        password: "Password",
        errStatus:'error',
        successStatus: 'succes' 
    }

    // Wire service to call Apex method to check if username/password login is enabled
    @wire(getIsUsernamePasswordEnabled)
    wiredIsUsernamePasswordEnabled({ error, data }) {
        if (data) {
            this.isUsernamePasswordEnabled = data; // Set the property if data is received
        } else if (error) {
            this.showToast(this.textObj.errStatus, this.textObj.internalErrorValue); // Show error toast if there is an error
        }
    }

    // Handle changes to the password input
    handlePasswordChange(event) {
        this.password = event.target.value; // Update the password property with input value
    }

    // Handle changes to the username input
    handleUsernameChange(event) {
        this.username = event.target.value; // Update the username property with input value
    }

    // Handle the click event for the login button
    async handleClick(event) {
        const { urlErrorValue, internalErrorValue, fieldsErrorValue, errStatus } = this.textObj; // Destructure textObj
        if (this.username && this.password) { // Check if both fields are filled
            event.preventDefault(); // Prevent default form submission
            try {
                const result = await login({ username: this.username, password: this.password }); // Call the login Apex method
            
                const { success, url, message } = result; // Destructure the result
                if (success) { // Check if the result is a valid URL
                    if (this.isValidURL(url)) { // Validate the URL
                        window.location.href = url; // Redirect to the URL
                    } else {
                        this.showToast(errStatus, urlErrorValue); // Show error toast for invalid URL
                    }
                } else {
                    this.showToast(errStatus, message); // Show error toast with the result message
                }
            } catch (e) {
                this.showToast(errStatus, internalErrorValue); // Show error toast
            }
        } else {
            this.showToast(errStatus, fieldsErrorValue); // Show error toast if username or password is empty
        }
    }

    // Validate if the result is a proper URL
    isValidURL(url) {
        const urlPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/; // Regex pattern for URL validation
        return urlPattern.test(url); // Return true if valid, false otherwise
    }

    // Function to show toast messages
    showToast(type, message) {
        this.template.querySelector('c-sc-custom-toast').showToast(type, message); // Call the showToast method on the custom toast component
    }
}