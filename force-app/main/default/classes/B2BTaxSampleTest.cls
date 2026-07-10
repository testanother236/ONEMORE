
@isTest
private class B2BTaxSampleTest {

    // Helper method to create test data with a WebCart, CartDeliveryGroup, CartItem, etc.
    // Returns the cartId and also the BackgroundOperation Id for use in IntegrationInfo.
    private static Map<String, Id> setupTestData(String taxType, String state, String country, Boolean withPromotions) {
        // Create Account
        Account acc = new Account(Name='TestAccount');
        insert acc;

        // Create WebStore
        WebStore ws = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert ws;

        // Create WebCart
        WebCart cart = new WebCart(
            Name='TestCart',
            AccountId=acc.Id,
            CurrencyIsoCode='USD',
            WebStoreId=ws.Id,
            TaxType=taxType
        );
        insert cart;

        // Create CartDeliveryGroup
        CartDeliveryGroup cdg = new CartDeliveryGroup(
            CartId=cart.Id,
            Name='Default Delivery',
            DeliverToState=state,
            DeliverToCountry=country
        );
        insert cdg;

        // Create Product2 and PricebookEntry
        Product2 prod = new Product2(Name='TestProduct', StockKeepingUnit='SKU001', IsActive=true);
        insert prod;

        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id=standardPricebookId,
            Product2Id=prod.Id,
            UnitPrice=100,
            IsActive=true
        );
        insert pbe;

        // Create CartItem with required fields
        CartItem ci = new CartItem(
            CartId=cart.Id,
            CartDeliveryGroupId=cdg.Id,
            Sku='SKU001',
            Type='Product',
            Quantity=2,
            TotalLineAmount=200,
            AdjustmentAmount=10,
            Name='TestCartItem',
            PricebookEntryId=pbe.Id
        );
        insert ci;

        // Optionally create CartItemPriceAdjustment (promotions)
        if (withPromotions) {
            CartItemPriceAdjustment cipa = new CartItemPriceAdjustment(
                CartItemId=ci.Id,
                TotalAmount=5,
                Name='TestPromotion'
            );
            insert cipa;
        }

        // Create BackgroundOperation for the integration job
        BackgroundOperation bo = new BackgroundOperation(
            Name='TestBackgroundOp',
            Status='New',
            StartTime=System.now()
        );
        insert bo;

        // Return relevant IDs
        Map<String, Id> ids = new Map<String, Id>();
        ids.put('cartId', cart.Id);
        ids.put('backgroundOperationId', bo.Id);
        ids.put('cartItemId', ci.Id);
        return ids;
    }

    // Test: Successful tax calculation using static response, with US state that has sales tax (default 8%)
    @isTest
    static void testStartCartProcessAsync_Success_US_Tax() {
        // Setup data with TaxType='Net' and a US state that has sales tax (e.g., CA)
        Map<String, Id> ids = setupTestData('Net', 'CA', 'US', false);

        // Create IntegrationInfo using the BackgroundOperation Id
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        // Instantiate the class and call the method
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, result.status, 'Expected SUCCESS status');
        // Verify that CartTax records were inserted
        List<CartTax> taxes = [SELECT Id, Amount, CartItemId, TaxRate FROM CartTax WHERE CartItemId = :ids.get('cartItemId')];
        System.assert(taxes.size() > 0, 'CartTax should be created');
        // Verify tax rate is 0.08 for CA, US
        for (CartTax t : taxes) {
            System.assertEquals(0.08, t.TaxRate, 'Tax rate should be 0.08');
        }
        // Verify CartItem fields were updated (NetUnitPrice, GrossUnitPrice, AdjustmentTaxAmount)
        CartItem updatedCi = [SELECT Id, NetUnitPrice, GrossUnitPrice, AdjustmentTaxAmount FROM CartItem WHERE Id = :ids.get('cartItemId')];
        System.assert(updatedCi.NetUnitPrice != null, 'NetUnitPrice should be set');
        System.assert(updatedCi.GrossUnitPrice != null, 'GrossUnitPrice should be set');
        System.assert(updatedCi.AdjustmentTaxAmount != null, 'AdjustmentTaxAmount should be set');
    }

    // Test: Successful tax calculation with Gross tax type (multiplier = taxRate / (1+taxRate))
    @isTest
    static void testStartCartProcessAsync_Success_Gross_TaxType() {
        Map<String, Id> ids = setupTestData('Gross', 'CA', 'US', false);

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, result.status);
        List<CartTax> taxes = [SELECT Id, Amount, TaxRate FROM CartTax WHERE CartItemId = :ids.get('cartItemId')];
        System.assert(taxes.size() > 0);
        // For Gross, expected tax = TotalLineAmount * (taxRate/(1+taxRate)) = 200 * (0.08/1.08) = 200*0.074074... = 14.8148
        // Allow minor rounding.
        Decimal expectedTax = 200 * (0.08 / 1.08);
        Decimal actualTax = 0;
        for (CartTax t : taxes) {
            if (t.TaxRate == 0.08) {
                actualTax = t.Amount;
            }
        }
        System.assertEquals(expectedTax.setScale(2), actualTax.setScale(2), 'Gross tax amount mismatch');
    }

    // Test: Successful tax calculation for US state with no sales tax (e.g., OR)
    @isTest
    static void testStartCartProcessAsync_Success_US_NoSalesTax() {
        Map<String, Id> ids = setupTestData('Net', 'OR', 'US', false);

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, result.status);
        List<CartTax> taxes = [SELECT Id, Amount, TaxRate FROM CartTax WHERE CartItemId = :ids.get('cartItemId')];
        // Tax rate should be 0.00 for OR
        for (CartTax t : taxes) {
            System.assertEquals(0.00, t.TaxRate, 'Tax rate should be 0 for OR');
        }
    }

    // Test: Successful tax calculation with itemized promotions (CartItemPriceAdjustment)
    @isTest
    static void testStartCartProcessAsync_Success_WithPromotions() {
        Map<String, Id> ids = setupTestData('Net', 'CA', 'US', true);

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, result.status);
        // Verify that CartTax records include a tax line for the promotion
        List<CartTax> taxes = [SELECT Id, CartItemPriceAdjustmentId, Amount FROM CartTax WHERE CartItemId = :ids.get('cartItemId')];
        // Expect at least one CartTax with CartItemPriceAdjustmentId populated
        Boolean hasPromotionTax = false;
        for (CartTax t : taxes) {
            if (t.CartItemPriceAdjustmentId != null) {
                hasPromotionTax = true;
                break;
            }
        }
        System.assert(hasPromotionTax, 'There should be a CartTax for the promotion');
    }

    // Test: Failure when a CartItem has null SKU
    @isTest
    static void testStartCartProcessAsync_NullSku_ReturnsFail() {
        // Create test data but then update a CartItem to have null SKU
        Map<String, Id> ids = setupTestData('Net', 'CA', 'US', false);
        // Update the CartItem to set SKU to null
        CartItem ci = [SELECT Id, Sku FROM CartItem WHERE Id = :ids.get('cartItemId')];
        ci.Sku = null;
        update ci;

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, result.status, 'Expected FAILED status when SKU is null');
        // Verify a CartValidationOutput record was inserted with error message
        List<CartValidationOutput> cvoList = [SELECT Id, Message FROM CartValidationOutput WHERE CartId = :ids.get('cartId')];
        System.assert(cvoList.size() > 0, 'CartValidationOutput should be created');
        System.assert(cvoList[0].Message.contains('SKUs'), 'Error message should mention SKUs');
    }

    // Test: Failure when no CartItem exists (causes exception accessing [0])
    @isTest
    static void testStartCartProcessAsync_NoCartItem_ReturnsFail() {
        // Create a WebCart without any CartItem
        Account acc = new Account(Name='TestAccount');
        insert acc;
        WebStore ws = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert ws;
        WebCart cart = new WebCart(Name='EmptyCart', AccountId=acc.Id, CurrencyIsoCode='USD', WebStoreId=ws.Id);
        insert cart;

        // Need a BackgroundOperation
        BackgroundOperation bo = new BackgroundOperation(Name='Op', Status='New', StartTime=System.now());
        insert bo;

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = bo.Id;

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, cart.Id);
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, result.status, 'Expected FAILED status because no CartItem exists');
        // Verify CartValidationOutput with exception message
        List<CartValidationOutput> cvoList = [SELECT Id, Message FROM CartValidationOutput WHERE CartId = :cart.Id];
        System.assert(cvoList.size() > 0, 'CartValidationOutput should be created');
        // The exception message should contain 'ListException' or similar
        System.assert(cvoList[0].Message.contains('exception'), 'Error message should indicate exception');
    }

    // Test: Successful tax calculation with non-US country (default tax rate 15%)
    @isTest
    static void testStartCartProcessAsync_Success_NonUS() {
        Map<String, Id> ids = setupTestData('Net', 'ON', 'CA', false); // Canada, Ontario

        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
        jobInfo.jobId = ids.get('backgroundOperationId');

        sfdc_checkout.IntegrationStatus result;

        Test.startTest();
        B2BTaxSample taxCalculator = new B2BTaxSample();
        result = taxCalculator.startCartProcessAsync(jobInfo, ids.get('cartId'));
        Test.stopTest();

        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, result.status);
        List<CartTax> taxes = [SELECT Id, TaxRate FROM CartTax WHERE CartItemId = :ids.get('cartItemId')];
        // For non-US, country not 'US', taxRate stays 0.15
        for (CartTax t : taxes) {
            System.assertEquals(0.15, t.TaxRate, 'Tax rate should be 0.15 for non-US country');
        }
    }
}
