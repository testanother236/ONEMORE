import { LightningElement, api, wire } from "lwc";
import toastUtils from "c/util_module";
import getOpportunityContact from "@salesforce/apex/sendInvoceController.getOpportunityContact";
import sendEmail from "@salesforce/apex/sendInvoceController.sendEmail";
import getEmailTemplateData from "@salesforce/apex/sendInvoceController.getEmailTemplateData";
import generateInvoicePDF from "@salesforce/apex/sendInvoceController.generateInvoicePDF";

export default class SendInvoice extends LightningElement {
  @api recordId; // ID of the Opportunity record
  emailSubject = ""; // Pre-filled email subject
  emailBody = ""; // Pre-filled email body
  recipientName = ""; // Name of the email recipient
  recipientEmail = ""; // Email of the recipient
  isComponentVisible = true; // Control visibility of the component

  // Wire service to get the contact data when the component initializes
  @wire(getOpportunityContact, { opportunityId: "$recordId" })
  wiredContact({ error, data }) {
    if (data) {
      this.recipientName = data.Contact.Name; // Set recipient name
      this.recipientEmail = data.Contact.Email; // Set recipient email
      this.getEmailTemplateData(); // Fetch email template data
    } else if (error) {
      toastUtils.showToast(
         this,
        "Error",
        "Error fetching contact data: " + error.body.message,
        "error"
      ); // Show error if fetching fails
    }
  }

  // Fetch email template data based on recipient's name
  getEmailTemplateData() {
    if (this.recipientName) { // Check if recipient name is set
      getEmailTemplateData({
        opportunityId: this.recordId,
        customerName: this.recipientName
      })
        .then((data) => {
          this.emailSubject = data.subject; // Set pre-filled subject
          this.emailBody = data.body; // Set pre-filled body
        })
        .catch((error) => {
          toastUtils.showToast(
            this,
           "Error",
           "Error fetching contact data: " + error.body.message,
           "error"
         ); // Show error if fetching fails
        });
    } else {
      toastUtils.showToast(
        this,
        "Warning",
        "Recipient name is not set, cannot fetch email template data.",
        "warning" // Show warning if recipient name is missing
      );
    }
  }

  // Method to preview the invoice as a PDF
  previewInvoice() {
    generateInvoicePDF({ opportunityId: this.recordId })
      .then((pdfBase64) => {
        const blob = this.base64ToBlob(pdfBase64, "application/pdf"); // Convert base64 to Blob
        const url = URL.createObjectURL(blob); // Create URL for the Blob
        const pdfWindow = window.open(url); // Open the PDF in a new window
        if (!pdfWindow) {
          toastUtils.showToast(
            this,
            "Error",
            "Failed to open PDF in new window. Please check your pop-up blocker settings.",
            "error" // Show error if window fails to open
          );
        }
      })
      .catch((error) => {
        toastUtils.showToast(
          this,
          "Error",
          "Error generating PDF: " + error.body.message,
          "error" // Show error if PDF generation fails
        );
      });
  }

  // Handler for changes in the email body input
  handleEmailBodyChange(event) {
    this.emailBody = event.target.value; // Update the email body with user input
  }

  // Method to send the email
  sendEmail() {
    sendEmail({
      subject: this.emailSubject,
      body: this.emailBody,
      recipientEmail: this.recipientEmail
    })
      .then(() => {
        this.showToast("Success", "Email sent successfully!", "success"); // Show success message
        this.isComponentVisible = false; // Hide the component after sending
      })
      .catch((error) => {
        toastUtils.showToast(
          this,
          "Error",
          "Error sending email: " + error.body.message,
          "error" // Show error if sending fails
        );
      });
  }

  // Function to convert a base64 string to a Blob
  base64ToBlob(base64, type = "") {
    const byteCharacters = atob(base64); // Decode base64 string
    const byteNumbers = new Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
      byteNumbers[i] = byteCharacters.charCodeAt(i); // Convert to byte numbers
    }
    const byteArray = new Uint8Array(byteNumbers); // Create a typed array
    return new Blob([byteArray], { type: type }); // Return the Blob
  }
}