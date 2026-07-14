/**
 * Test class for MyAccountTrigger to verify trigger functionality.
 */
@isTest
private class MyAccountTriggerTest {

    /**
     * Tests the Account trigger by inserting a record and verifying the Description field is updated. Test
     */
    @isTest static void testTrigger() {
        Account a = new Account(Name='Test Account');
        insert a;
        // aaaaaTestnew
        Account insertedAccount = [SELECT Description FROM Account WHERE Id = :a.Id];
        System.assertEquals('Trigger ran', insertedAccount.Description);
    }
}
//testrrr