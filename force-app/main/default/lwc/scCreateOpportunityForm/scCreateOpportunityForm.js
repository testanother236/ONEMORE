import { LightningElement} from "lwc";
import createOpportunity from '@salesforce/apex/ScCreateOpportunityController.createOpportunity';

export default class ScCreateOpportunityForm extends LightningElement {
  name = '';
  amount = 0;
  isDisabled = false; // Track the disabled state

  handleInputChange(event) {
    
    const field = event.target.name;
    if (field === 'name') {
        this.name = event.target.value;
    } else if (field === 'amount') {
        this.amount = event.target.value;
    } 
  }


  async handleSubmit() {
    // Validation checks
    if (!this.name || !this.amount ) {
        this.showToast('error', 'Please fill in all required fields.')
        return;
    }


     // Check if name length is less than 8
     if (this.name.length < 8) {
      this.showToast('error', 'Name must be at least 8 characters long.');
      return;
    }

  // Check if amount is less than 100
    if (this.amount < 100) {
      this.showToast('error', 'Amount must be at least 100.');
      return;
    }

     // Disable inputs when submitting
    this.isDisabled = true;

    try {
        // Call Apex method to create Opportunity
        const result = await createOpportunity({
            name: this.name,
            amount: this.amount
        });
        this.showToast('Success', 'Opportunity created successfully.', 'success');
        // Reset fields after successful submission
        this.resetFields();
    } catch (error) {
        this.showToast('Error', 'Failed to create Opportunity: ' + error.body.message, 'error');
    }finally {
        // Re-enable inputs regardless of success or error
        this.isDisabled = false;
    } 
  }



  resetFields() {
    this.name = '';
    this.amount = '';
  }

  showToast(type, message){
    this.template.querySelector('c-sc-custom-toast').showToast(type, message);

  }

}