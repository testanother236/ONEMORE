@isTest
public class ScCreateOpportunityControllerTest {
    
    @isTest
    static void testCreateOpportunity() {
        // Prepare test data
        String opportunityName = 'Test Opportunity';
        Decimal opportunityAmount = 1000.00;

        // Start the test context
        Test.startTest();
        
        // Call the method being tested
        Id opportunityId = ScCreateOpportunityController.createOpportunity(opportunityName, opportunityAmount);
        
        Test.stopTest();
        
        // Verify that the opportunity was created
        Opportunity createdOpportunity = [
            SELECT Id, Name, Amount, StageName, LeadSource, Type 
            FROM Opportunity 
            WHERE Id = :opportunityId
        ];
        
        // Assertions to verify the created opportunity
        System.assertNotEquals(null, createdOpportunity, 'The Opportunity should be created.');
        System.assertEquals(opportunityName, createdOpportunity.Name, 'The Opportunity name should match.');
        System.assertEquals(opportunityAmount, createdOpportunity.Amount, 'The Opportunity amount should match.');
        System.assertEquals('New Customer', createdOpportunity.Type, 'The Opportunity type should match.');
        System.assertEquals('Partner Referral', createdOpportunity.LeadSource, 'The Opportunity lead source should match.');
        System.assertEquals('Prospecting', createdOpportunity.StageName, 'The Opportunity stage should match.');
    }

    }