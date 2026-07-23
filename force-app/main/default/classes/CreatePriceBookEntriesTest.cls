@isTest
public class CreatePriceBookEntriesTest {
  @isTest
  static void testCreateEntries() {
    // Get the standard pricebook ID using Test.getStandardPricebookId()
    Id standardPricebookId = Test.getStandardPricebookId();

    // Create several products
    List<Product2> products = new List<Product2>();
    for (Integer i = 0; i < 5; i++) {
      products.add(new Product2(Name = 'Test Product ' + i, IsActive = true));
    }
    insert products;

    // Call the method to create PriceBookEntries
    Test.startTest();
    CreatePriceBookEntries.createEntries(); // The method should use the standard pricebook
    Test.stopTest();

    // Verify that the PriceBookEntries were created
    List<PricebookEntry> entries = [
      SELECT Id, Product2Id, Pricebook2Id, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :standardPricebookId
    ];

    // Ensure that the PriceBookEntry records were created
    System.assertEquals(
      5,
      entries.size(),
      'There should be 5 PriceBookEntry entries created'
    );

    // Verify that all entries are associated with the correct pricebook and products
    for (PricebookEntry entry : entries) {
      System.assertNotEquals(
        null,
        entry.Product2Id,
        'Product 2 Id must not be null'
      );
      System.assertEquals(
        standardPricebookId,
        entry.Pricebook2Id,
        'The Pricebook2Id must match the standard book'
      );
      System.assert(
        entry.UnitPrice >= 0 && entry.UnitPrice <= 1000,
        'The UnitPrice must be in the range from 0 to 1000'
      );
    }
  }
}