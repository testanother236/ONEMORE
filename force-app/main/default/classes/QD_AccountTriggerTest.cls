
@isTest
private class QD_AccountTriggerTest {
    @isTest
    static void testTriggerSetsDescriptionOnSingleInsert() {
        Account testAccount = new Account(
            Name = 'Test Account Single'
        );
        
        Test.startTest();
        insert testAccount;
        Test.stopTest();
        
        Account insertedAccount = [SELECT Id, Description FROM Account WHERE Id = :testAccount.Id];
        
        System.assertEquals('Processed by Quick Deploy test trigger', 
                            insertedAccount.Description, 
                            'The Account Description should be set by the trigger.');
    }

    @isTest
    static void testTriggerSetsDescriptionOnBulkInsert() {
        final Integer NUM_ACCOUNTS = 200;
        
        List<Account> testAccounts = new List<Account>();
        
        for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
            testAccounts.add(new Account(Name = 'Test Account Bulk ' + i));
        }
        
        Test.startTest();
        insert testAccounts;
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, Description FROM Account WHERE Id IN :testAccounts];
        
        for (Account acc : insertedAccounts) {
            System.assertEquals('Processed by Quick Deploy test trigger', 
                                acc.Description, 
                                'Every Account Description should be set by the trigger in bulk.');
        }
        System.assertEquals(NUM_ACCOUNTS, insertedAccounts.size(), 'All test Accounts should have been inserted.');
    }
}
