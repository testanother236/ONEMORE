
/**
 * Test class for validating the behavior of the Account trigger that sets the Description field.
 */
@isTest
private class QD_AccountTriggerTest {

    /**
     * Test method to verify the trigger sets the Description field correctly for a single Account record on insert.
     * This is the primary positive test case.
     */
    @isTest
    static void testTriggerSetsDescriptionOnSingleInsert() {
        // Create a test Account record, but do not set the Description field.
        Account testAccount = new Account(
            Name = 'Test Account Single'
        );
        
        // Start test to isolate trigger execution and reset governor limits.
        Test.startTest();
        // Insert the Account, which will fire the before insert trigger.
        insert testAccount;
        Test.stopTest();
        
        // Re-query the Account to get the trigger-modified Description field.
        Account insertedAccount = [SELECT Id, Description FROM Account WHERE Id = :testAccount.Id];
        
        // Assert that the trigger has correctly set the Description field.
        System.assertEquals('Processed by Quick Deploy test trigger', 
                            insertedAccount.Description, 
                            'The Account Description should be set by the trigger.');
    }

    /**
     * Test method to verify the trigger works correctly for bulk insertion of Account records.
     * This ensures the trigger logic is bulk-safe and processes all records.
     */
    @isTest
    static void testTriggerSetsDescriptionOnBulkInsert() {
        // Define the number of records for bulk test.
        final Integer NUM_ACCOUNTS = 200;
        
        // Create a list of test Account records.
        List<Account> testAccounts = new List<Account>();
        
        for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
            testAccounts.add(new Account(Name = 'Test Account Bulk ' + i));
        }
        
        // Start test to isolate trigger execution and reset governor limits.
        Test.startTest();
        // Insert the list of Accounts, firing the trigger in bulk context.
        insert testAccounts;
        Test.stopTest();
        
        // Re-query all inserted Accounts to verify their Description fields.
        List<Account> insertedAccounts = [SELECT Id, Description FROM Account WHERE Id IN :testAccounts];
        
        // Assert that every Account's Description was set by the trigger.
        for (Account acc : insertedAccounts) {
            System.assertEquals('Processed by Quick Deploy test trigger', 
                                acc.Description, 
                                'Every Account Description should be set by the trigger in bulk.');
        }
        // Also assert the count to confirm all records were processed.
        System.assertEquals(NUM_ACCOUNTS, insertedAccounts.size(), 'All test Accounts should have been inserted.');
    }
}
