import { LightningElement, api } from "lwc";
import scheduleBatch from "@salesforce/apex/GenericBatchScheduler.scheduleBatch";
import runBatchOnce from "@salesforce/apex/GenericBatchScheduler.runBatchOnce";
import abortBatch from "@salesforce/apex/GenericBatchScheduler.abortBatch";
import toastUtils from "c/util_module";

export default class EmailScheduler extends LightningElement {
  @api batchClassName; // Accepts the name of the Batch class
  @api schedulerClassName; // Accepts the name of the Scheduler class
  cronString = ""; // CRON string input by the user
  isBatchScheduled = false; // Tracks whether a batch is scheduled

  connectedCallback() {
    // Restore state from localStorage
    const storedCronString = localStorage.getItem('cronString') || '';
    const storedIsBatchScheduled = localStorage.getItem("isBatchScheduled");

    if (storedCronString) {
      this.cronString = storedCronString; // Load the stored CRON string
    }

    if (storedIsBatchScheduled === "true") {
      this.isBatchScheduled = true; // Load the stored batch scheduled state
    }
  }

  // Returns the class for the schedule button based on scheduled state
  get scheduleButtonClass() {
    return this.isBatchScheduled ? "slds-button_brand" : "";
  }

  // Disables the CRON input field if a batch is scheduled
  get isCronInputDisabled() {
    return this.isBatchScheduled; // Input is disabled if the batch is running
  }

  // Method to validate the CRON string format
  validateCronString(cron) {
    // Regular expression to check CRON string validity
    const cronRegex =
      /^(\*|([0-5]?\d)) (\*|([0-5]?\d)) (\*|([01]?\d|2[0-3])) (\*|(0?[1-9]|[12]\d|3[01])) (\*|(0?[1-9]|1[0-2])) (\*|[0-6]|\?)$/;
    return cronRegex.test(cron); // Returns true if valid, false otherwise
  }

  // Handles changes to the CRON input field
  handleCronChange(event) {
    const newCronString = event.target.value; // Save the entered CRON string
    this.cronString = newCronString; // Update component state
    if (this.validateCronString(newCronString)) {
      localStorage.setItem('cronString', this.cronString); // Store valid CRON string
    } else {
      // Clear the stored value if the new CRON string is invalid
      localStorage.removeItem('cronString');
      //this.cronString = ""; // Optional: clear input if needed
    }
  }

  // Method to schedule a batch job
  handleScheduleBatch() {
    // Ensure the CRON string is valid before scheduling
    if (!this.validateCronString(this.cronString)) {
      toastUtils.showToast(
        this,
        "Error",
        "Cannot schedule batch: Invalid CRON string.",
        "error"
      );
      return; // Exit if the CRON string is invalid
    }
    scheduleBatch({
      schedulerClassName: this.schedulerClassName,
      batchClassName: this.batchClassName,
      cronString: this.cronString
    })
      .then(() => {
        // Handle success
        toastUtils.showToast(
          this,
          "Success",
          "Batch scheduled successfully",
          "success"
        );
        this.isBatchScheduled = true; // Set batch as scheduled
        localStorage.setItem("isBatchScheduled", "true"); // Save state
      })
      .catch((error) => {
        // Handle error
        toastUtils.showToast(
          this,
          "Error",
          "Error scheduling batch: " + error.body.message,
          "error"
        );
      });
  }

  // Method to run the batch job once
  handleRunOnce() {
    runBatchOnce({ batchClassName: this.batchClassName })
      .then(() => {
        // Handle success
        toastUtils.showToast(
          this,
          "Success",
          "Batch run successfully",
          "success"
        );
      })
      .catch((error) => {
        // Handle error
        toastUtils.showToast(
          this,
          "Error",
          "Error running batch: " + error.body.message,
          "error"
        );
      });
  }

  // Method to abort the scheduled batch job
  handleAbortBatch() {
    abortBatch({ schedulerClassName: this.schedulerClassName })
      .then(() => {
        // Handle success
        toastUtils.showToast(
          this,
          "Success",
          "Batch aborted successfully",
          "success"
        );
        this.isBatchScheduled = false; // Reset state after aborting
        localStorage.setItem("isBatchScheduled", "false"); // Reset stored state
      })
      .catch((error) => {
        // Handle error
        toastUtils.showToast(
          this,
          "Error",
          "Error aborting batch: " + error.body.message,
          "error"
        );
      });
  }
}