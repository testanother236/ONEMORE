@isTest
public class CustomerSummaryControllerTest {
  
  @isTest
  static void testGetAccounts() {
    // Create test data: a test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create an opportunity associated with the test account
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = testAccount.Id,
      CloseDate = Date.today(),
      StageName = 'Closed Won',
      Amount = 1000
    );
    insert testOpportunity;

    // Test the getAccounts method
    Test.startTest();
    Map<String, Object> result = CustomerSummaryController.getAccounts(
      'Test',
      0,
      1,
      10
    );
    Test.stopTest();

    // Assertions to verify the results
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) result.get(
      'accounts'
    );
    System.assertEquals(
      1,
      accounts.size(),
      'Should return one record for account'
    );
    System.assertEquals(
      testAccount.Id,
      accounts[0].get('Id'),
      'ID of the account must match'
    );
    System.assertEquals(
      1000,
      accounts[0].get('OpportunityTotal'),
      'Amount must match'
    );
  }

  @isTest
  static void testGetOpportunities() {
    // Create test data: a test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Create an opportunity associated with the test account
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = testAccount.Id,
      CloseDate = Date.today(),
      StageName = 'Closed Won',
      Amount = 1000
    );
    insert testOpportunity;

    // Test the getOpportunities method
    Test.startTest();
    List<Opportunity> opportunities = CustomerSummaryController.getOpportunities(
      testAccount.Id
    );
    Test.stopTest();

    // Assertions to verify the results
    System.assertEquals(
      1,
      opportunities.size(),
      'Should return one opportunity'
    );
    System.assertEquals(
      testOpportunity.Id,
      opportunities[0].Id,
      'ID of the opportunity must match'
    );
  }

  @isTest
  static void testGetProducts() {
    // Create test data: a test account
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    // Get the standard pricebook ID for the test
    Id standardPricebookId = Test.getStandardPricebookId();

    // Create an opportunity associated with the test account
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = testAccount.Id,
      CloseDate = Date.today(),
      StageName = 'Closed Won',
      Amount = 1000,
      Pricebook2Id = standardPricebookId // Set the pricebook
    );
    insert testOpportunity;

    // Create a test product
    Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
    insert testProduct;

    // Create a PricebookEntry for the product
    PricebookEntry pricebookEntry = new PricebookEntry(
      Pricebook2Id = standardPricebookId,
      Product2Id = testProduct.Id,
      UnitPrice = 100,
      IsActive = true
    );
    insert pricebookEntry;

    // Create an OpportunityLineItem for the product
    OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
      OpportunityId = testOpportunity.Id,
      PricebookEntryId = pricebookEntry.Id, // Use PricebookEntryId instead of Product2Id
      Quantity = 1,
      UnitPrice = 100
    );
    insert testOpportunityLineItem;

    // Test the getProducts method
    Test.startTest();
    List<OpportunityLineItem> products = CustomerSummaryController.getProducts(
      testOpportunity.Id
    );
    Test.stopTest();

    // Assertions to verify the results
    System.assertEquals(1, products.size(), 'Should return one product');
    System.assertEquals(
      testOpportunityLineItem.Id,
      products[0].Id,
      'ID of the product must match'
    );
  }

  @isTest
  static void testNoAccountsFound() {
    // Test the getAccounts method when no accounts are found
    Test.startTest();
    Map<String, Object> result = CustomerSummaryController.getAccounts(
      'Nonexistent',
      0,
      1,
      10
    );
    Test.stopTest();

    // Assertions to verify no accounts are returned
    List<Map<String, Object>> accounts = (List<Map<String, Object>>) result.get(
      'accounts'
    );
    System.assertEquals(0, accounts.size(), 'Should return 0 accounts');
  }
}