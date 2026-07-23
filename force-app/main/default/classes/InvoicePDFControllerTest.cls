@isTest
private class InvoicePDFControllerTest {
  @isTest
  static void testInvoicePDFController() {
    // Create test account
    Account testAccount = new Account(Name = 'Test Account');
    try {
      insert testAccount;
    } catch (Exception e) {
      throw new CustomException('Error inserting Account: ' + e.getMessage());
    }

    // Create test contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      AccountId = testAccount.Id,
      Email = 'test@example.com',
      Phone = '123-456-7890'
    );
    try {
      insert testContact;
    } catch (Exception e) {
      throw new CustomException('Error inserting Contact: ' + e.getMessage());
    }

    // Create test opportunity
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30),
      AccountId = testAccount.Id,
      Invoice_Date__c = Date.today()
    );
    try {
      insert testOpportunity;
    } catch (Exception e) {
      throw new CustomException(
        'Error inserting Opportunity: ' + e.getMessage()
      );
    }

    // Create test contact role
    OpportunityContactRole testContactRole = new OpportunityContactRole(
      OpportunityId = testOpportunity.Id,
      ContactId = testContact.Id,
      Role = 'Decision Maker',
      IsPrimary = true
    );
    try {
      insert testContactRole;
    } catch (Exception e) {
      throw new CustomException(
        'Error inserting OpportunityContactRole: ' + e.getMessage()
      );
    }

    // Create test product
    Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
    try {
      insert testProduct;
    } catch (Exception e) {
      throw new CustomException('Error inserting Product: ' + e.getMessage());
    }

    // Create pricebook entry
    PricebookEntry pricebookEntry = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = testProduct.Id,
      UnitPrice = 100.00,
      IsActive = true
    );
    try {
      insert pricebookEntry;
    } catch (Exception e) {
      throw new CustomException(
        'Error inserting PricebookEntry: ' + e.getMessage()
      );
    }

    // Create opportunity line item
    OpportunityLineItem testProductLineItem = new OpportunityLineItem(
      OpportunityId = testOpportunity.Id,
      PricebookEntryId = pricebookEntry.Id,
      Quantity = 2,
      UnitPrice = 100.00
    );
    try {
      insert testProductLineItem;
    } catch (Exception e) {
      throw new CustomException(
        'Error inserting OpportunityLineItem: ' + e.getMessage()
      );
    }

    // Set current page parameters
    Test.setCurrentPage(Page.Invoice);
    ApexPages.currentPage().getParameters().put('id', testOpportunity.Id);

    // Create standard controller
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testOpportunity
    );
    System.debug(stdController);

    // Create controller
    InvoicePDFController controller = new InvoicePDFController(stdController);

    // Validate values
    System.assertNotEquals(
      null,
      controller.opportunity,
      'Opportunity should not be null'
    );
    System.assertEquals(
      'Test Opportunity',
      controller.opportunity.Name,
      'Opportunity name should match'
    );
    System.assertNotEquals(
      null,
      controller.invoiceNumber,
      'Invoice number should not be null'
    );
    System.assertEquals(
      Date.today(),
      controller.invoiceDate,
      'Invoice date should match'
    );
    System.assertEquals(
      'test@example.com',
      controller.customerEmail,
      'Customer email should match'
    );
    System.assertEquals(
      '123-456-7890',
      controller.customerPhone,
      'Customer phone should match'
    );
    System.assertNotEquals(
      null,
      controller.products,
      'Products list should not be null'
    );
    System.assertEquals(
      1,
      controller.products.size(),
      'There should be one product'
    );
    System.assertEquals(
      200.00,
      controller.totalAmount,
      'Total amount should be calculated correctly'
    );

    // Validate formatted date
    String formattedDate = controller.getFormattedInvoiceDate();
    System.assertNotEquals(
      '',
      formattedDate,
      'Formatted date should not be empty'
    );
    System.assertEquals(
      Date.today().format(),
      formattedDate,
      'Formatted date should match'
    );
  }
}