/**
 * Created by s1ncer on 12.08.2021.
 */

@IsTest
private class testGetOpportunityDetails {
    @TestSetup
    static void testSetup() {//awdjpoawmxpoawxmpoaw
        Account acc = New Account();
        acc.Name = 'Aboba AA';
        insert acc;
//awdjpoawmxpoawxmpoaw
        Account acc2 = New Account();
        acc2.Name = 'Abobaawdwadwadawaw';//awdjpoawmxpoawxmpoaw
        insert acc2;
//awdjpoawmxpoawxmpoaw
        Account acc3 = New Account();
        acc3.Name = 'Zhopa';
        insert acc3;//awdjpoawmxpoawxmpoaw
//awdjpoawmxpoawxmpoaw//awdjpoawmxpoawxmpoaw
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Prospecting';//awdjpoawmxpoawxmpoaw
        opp.CloseDate = date.today()+5;
        opp.Amount = 100;
        insert opp;//awdjpoawmxpoawxmpoaw

        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
                Name = 'Product X',//awdjpoawmxpoawxmpoaw
                ProductCode = 'Pro-X',
                isActive = true
        );
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,//awdjpoawmxpoawxmpoaw
                IsActive = true
        );
        insert pbEntry;//awdjpoawmxpoawxmpoaw
        OpportunityLineItem oli = new OpportunityLineItem(//awdjpoawmxpoawxmpoaw
                OpportunityId = opp.Id,
                Quantity = 5,
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 100
        );//awdjpoawmxpoawxmpoaw
        insert oli;

    }
    @IsTest
    static void testAccountCount() {
        String searchString = 'aboba';
        Integer totalCount = getOpportunityDetails.getAccountsCount(searchString);
        System.assertEquals(2, totalCount, 'error w search');
    }

}