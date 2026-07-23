public with sharing class InvoicePDFController {
  
  // Properties for the invoice details
  public Opportunity opportunity { get; private set; }
  public List<OpportunityLineItem> products { get; private set; }
  public String companyName { get; private set; }
  public String companyAddress { get; private set; }
  public String customerName { get; private set; }
  public String customerEmail { get; private set; }
  public String customerPhone { get; private set; }
  public String oppOwnerName { get; private set; }
  public String clientCompanyName { get; private set; }
  public String invoiceNumber { get; private set; }
  public Date invoiceDate { get; private set; }
  public Decimal totalAmount { get; private set; }

  // Constructor that initializes the controller with the standard controller
  public InvoicePDFController(ApexPages.StandardController stdController) {
    // Retrieve the Opportunity record from the standard controller
    opportunity = (Opportunity) stdController.getRecord();
    // Get the opportunity ID from the page parameters
    String opportunityId = ApexPages.currentPage().getParameters().get('id');

    // Get the current user's information
    Id currentUserId = UserInfo.getUserId();
    User user = [
      SELECT Id, Name, Email, Street, City, State, PostalCode, Country
      FROM User
      WHERE Id = :currentUserId
      LIMIT 1
    ];
    
    // Get the organization information
    Organization org = [SELECT Name FROM Organization LIMIT 1];
    companyName = org.Name; // Set the company name
    // Construct the company address from the user details
    companyAddress = user.City + ', ' + user.Street + ', ' + user.State + ' ' + user.PostalCode;

    // Retrieve the Opportunity details
    Opportunity opp = [
      SELECT Owner.Name, Account.Name, Invoice_Number__c, Invoice_Date__c
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];
    oppOwnerName = opp.Owner.Name; // Get the opportunity owner's name
    invoiceNumber = opp.Invoice_Number__c; // Get the invoice number
    invoiceDate = opp.Invoice_Date__c; // Get the invoice date

    // Retrieve the primary contact roles associated with the Opportunity
    List<OpportunityContactRole> contactRoles = [
      SELECT Contact.Name, Contact.Email, Contact.Phone, Contact.Account.Name
      FROM OpportunityContactRole
      WHERE OpportunityId = :opportunityId AND IsPrimary = TRUE
    ];
    
    // If there are any contact roles, set the customer details
    if (!contactRoles.isEmpty()) {
      customerName = contactRoles[0].Contact.Name; // Set the customer name
      customerEmail = contactRoles[0].Contact.Email; // Set the customer email
      customerPhone = contactRoles[0].Contact.Phone; // Set the customer phone
      clientCompanyName = contactRoles[0].Contact.Account.Name; // Set the client's company name
    }

    // Retrieve the products associated with the Opportunity
    products = [
      SELECT Product2.Name, Quantity, UnitPrice
      FROM OpportunityLineItem
      WHERE OpportunityId = :opportunityId
    ];

    // Calculate the total amount for the invoice
    totalAmount = 0;
    for (OpportunityLineItem item : products) {
      totalAmount += item.Quantity * item.UnitPrice; // Sum the total for each product
    }
  }

  // Method to format the invoice date as a string
  public String getFormattedInvoiceDate() {
    if (invoiceDate != null) {
      return invoiceDate.format(); // Convert the date to a string
    }
    return ''; // Return an empty string if no date is set
  }
}