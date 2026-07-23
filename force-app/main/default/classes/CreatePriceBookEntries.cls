public class CreatePriceBookEntries {
  public static void createEntries() {
    Id standardPricebookId;

    // Checking whether the code is executed in a text context
    if (Test.isRunningTest()) {
      standardPricebookId = Test.getStandardPricebookId(); // Получаем стандартную книгу цен в тестах
    } else {
      // In a normal environment, we get a standard book
      standardPricebookId = [
        SELECT Id
        FROM Pricebook2
        WHERE IsActive = TRUE AND IsStandard = TRUE
        LIMIT 1
      ]
      .Id;
    }

    // Get all active products
    List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = TRUE];

    // Create records PriceBookEntry for standart bookprice
    List<PricebookEntry> standardPriceBookEntries = new List<PricebookEntry>();

    for (Product2 product : products) {
      PricebookEntry entry = new PricebookEntry();
      entry.Product2Id = product.Id;
      entry.Pricebook2Id = standardPricebookId;
      entry.UnitPrice = Math.round(Math.random() * 1000); // Random price from 0 to 1000
      entry.IsActive = true;
      standardPriceBookEntries.add(entry);
    }

    // Insert standart records PriceBookEntry
    insert standardPriceBookEntries;
  }
}