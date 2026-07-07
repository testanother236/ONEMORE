@isTest
public class MyAccountTriggerTest {
    
    // Test method for validating the trigger on Account insertion
    @isTest
    static void testMyAccountTrigger_BeforeInsert() {
        // Setup: Create a new Account record
        Account testAccount = new Account(Name = 'Test Account');
        
        // Add the account to a list to simulate Trigger context
        List<Account> accountList = new List<Account>();
        accountList.add(testAccount);
        
        // Start the test context
        Test.startTest();
        // Insert the account, which will invoke the trigger
        insert accountList;
        // End the test context
        Test.stopTest();
        
        // Verify that the Account's description was set by the trigger
        Account insertedAccount = [SELECT Id, Description FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('aaaaa', insertedAccount.Description, 'The description should be set by the trigger.');
    }
    
    // Test method to check for bulk insert scenario
    @isTest
    static void testMyAccountTrigger_BulkInsert() {
        // Setup: Create multiple Account records
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            accountList.add(new Account(Name = 'Test Account ' + i));
        }
        
        // Start the test context
        Test.startTest();
        // Insert the accounts, which will invoke the trigger
        insert accountList;
        // End the test context
        Test.stopTest();
        
        // Verify that the description was set for all inserted accounts
        List<Account> insertedAccounts = [SELECT Id, Description FROM Account WHERE Name LIKE 'Test Account%'];
        for(Account acc : insertedAccounts) {
            System.assertEquals('aaaaa', acc.Description, 'The description should be set by the trigger for account: ' + acc.Name);
        }
    }
}