import { LightningElement, api, track, wire } from "lwc"; 
import getMyOpportunities from "@salesforce/apex/ScUserOpportunityController.getMyOpportunities"; 

export default class ScOpportunityPage extends LightningElement {
  @track opportunities = []; // Array to hold the user's opportunities
  @track currentOpp; // Variable to hold the currently selected opportunity
  currentOppId = ""; // ID of the currently selected opportunity
  opportunityText = `Make sure the data displayed is correct. If is the data not correct, contact your system adminstrator`; // Text to display for opportunity confirmation
  oppHeaderText = "My Opportunities"; // Header text for the opportunities section
  isLoading = true; // Loading state for the component
  opportunityName = "";

  @track oppPropObj={
    Type: null,
    Amount: null,
    "Lead Source":null,
    "Order Number":null,
    "Current Generator(s)":null,
    "Tracking Number":null,
    "Stage":null,
    "Close Date":null,
    "Main Competitor(s)":null,
    "Delivery Installation Status":null,
  };


  // Getter to check if loading is in progress
  get checkLoading() {
    return this.isLoading;
  }

  // Getter to return the opportunities
  get oppNames() {
    return this.opportunities;
  }

  // Getter to determine if an opportunity should be rendered
  get isRenderOpp() {
    return !!this.currentOppId; // Returns true if currentOppId is not empty
  }

  // Handle event to get the opportunity ID from child component
  handleGetOppId(e) {
    let id = e.detail.message; // Get the opportunity ID from the event
    this.currentOppId = id; // Set the current opportunity ID
    this.currentOpp = this.opportunities.find(
      (opp) => opp.opportunityId === id // Find the selected opportunity based on ID
    );
    this.opportunityName = this.currentOpp.opportunityName;

    this.oppPropObj.Type = this.currentOpp.type;
    this.oppPropObj.Amount = this.currentOpp.amount;
    this.oppPropObj["Lead Source"] = this.currentOpp.leadSource;
    this.oppPropObj["Order Number"] = this.currentOpp.orderNumber;
    this.oppPropObj["Current Generator(s)"] = this.currentOpp.currentGenerators;
    this.oppPropObj["Tracking Number"] = this.currentOpp.trackingNumber;
    this.oppPropObj.Stage = this.currentOpp.stageName;
    this.oppPropObj["Close Date"] = this.currentOpp.closeDate;
    this.oppPropObj["Main Competitor(s)"] = this.currentOpp.mainCompetitors;
    this.oppPropObj["Delivery Installation Status"] = this.currentOpp.deliveryInstallationStatus;
  }

   @api get oppInfoProperties() {
    // Create an object without the photoUrl property
    const {...filteredProperties } = this.oppPropObj;

    // Map over the filtered properties and set empty values to "------"
    return Object.entries(filteredProperties).map(([key, value]) => ({
        key,
        value: value ? value : "------" // Set to "------" if value is empty
    }));
  }


  // Wire service to fetch opportunities from the Apex controller
  @wire(getMyOpportunities)
  wiredOpportunities({ error, data }) {
    if (data) {
      this.opportunities = data; // Set the opportunities array with the fetched data
      this.isLoading = false; // Set loading to false
    } else if (error) {
      // Handle error
      this.isLoading = false; // Set loading to false on error
    }
  }
}