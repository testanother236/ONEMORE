@isTest
public class ScUserOpportunityControllerTest {
    
    @isTest
    static void testGetMyOpportunities() {
        // Create a unique username using the current timestamp
        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@example.com';

        // Create a test user
        User testUser = new User(
            Username = uniqueUsername,
            Email = uniqueUsername,
            Alias = 'tuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'User',
            FirstName = 'Test'        
        );
        insert testUser;

        // Declare the opportunities list outside the runAs block
        List<Opportunity> opportunities = new List<Opportunity>();

        // Use System.runAs to create opportunities as the test user
        System.runAs(testUser) {
            // Create and insert opportunities
            for (Integer i = 0; i < 5; i++) {
                Opportunity opp = new Opportunity(
                    Name = 'Test Opportunity ' + i,
                    StageName = 'Prospecting',
                    CloseDate = Date.today().addDays(30),
                    Amount = 1000 + (i * 100),
                    OwnerId = testUser.Id,
                    LeadSource = 'Web',
                    OrderNumber__c = 'ORD' + i,
                    TrackingNumber__c = 'TRACK' + i,
                    MainCompetitors__c = 'Competitor ' + i,
                    DeliveryInstallationStatus__c = 'In Progress',
                    CurrentGenerators__c = 'Generator ' + i
                );
                opportunities.add(opp);
            }
            insert opportunities; // Insert opportunities within the runAs block
        }

        // Verify that the opportunities were created
        List<Opportunity> createdOpportunities = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId = :testUser.Id];
        
        // Now test the getMyOpportunities method in the context of the test user
        Test.startTest();
        System.runAs(testUser) {
            List<ScUserOpportunityController.OpportunityWrapper> results = ScUserOpportunityController.getMyOpportunities();
        Test.stopTest();

            
            // Verify results
            System.assertNotEquals(null, results, 'The result should not be null.');
            System.assertEquals(5, results.size(), 'There should be 5 opportunities returned.');

            // Validate the properties of the first opportunity
            ScUserOpportunityController.OpportunityWrapper firstOpp = results[0];
            System.assertEquals('Test Opportunity 0 null ORD0', firstOpp.opportunityName, 'Opportunity name should match.');
            System.assertEquals(createdOpportunities[0].Id, firstOpp.opportunityId, 'Opportunity ID should match.');
            System.assertEquals('Prospecting', firstOpp.stage, 'Stage should match.');
            System.assertEquals(1000, firstOpp.amount, 'Amount should match.');
            System.assertEquals(Date.today().addDays(30), firstOpp.closeDate, 'Close date should match.');
        }
    }
}