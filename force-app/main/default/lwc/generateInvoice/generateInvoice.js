import { LightningElement, api } from "lwc";
import generateInvoice from "@salesforce/apex/InvoiceGenerator.generateInvoice";
import attachInvoice from "@salesforce/apex/InvoiceGenerator.attachInvoice";
import toastUtils from "c/util_module";


export default class GenerateInvoice extends LightningElement {
  @api recordId; // ID of the Opportunity
  pdfUrl; // URL for the generated PDF
  isModalOpen = false; // State to track if the modal is open
  isLoading = false; // Indicator for loading state

  // Method to open the modal window
  openModal() {
    this.isLoading = true; // Set loading state to true

    // Call Apex method to generate the invoice
    generateInvoice({ opportunityId: this.recordId })
      .then((result) => {
        this.pdfUrl = result; // Set the PDF URL returned from the Apex method
        this.isLoading = false; // Hide loading indicator
        this.isModalOpen = true; // Open the modal window
      })
      .catch((error) => {
        this.isLoading = false; // Hide loading indicator on error
        const errorMessage = error.body ? error.body.message : error.message; // Get error message
        toastUtils.showToast(this, "Error", errorMessage, "error"); // Show error toast
      });
  }

  // Method to close the modal window
  closeModal() {
    this.isModalOpen = false; // Set modal state to closed
    this.pdfUrl = null; // Reset PDF URL
  }

  // Method to attach the PDF to the Opportunity
  attachInvoice() {
    attachInvoice({ opportunityId: this.recordId, pdfUrl: this.pdfUrl })
      .then(() => {
        toastUtils.showToast(
          this,
          "Success",
          "The file has been successfully attached!", // Success message
          "success"
        );
        this.closeModal(); // Close the modal window
      })
      .catch((error) => {
        const errorMessage = error.body ? error.body.message : error.message; // Get error message
        toastUtils.showToast(this, "Error", errorMessage, "error"); // Show error toast
      });
  }
}