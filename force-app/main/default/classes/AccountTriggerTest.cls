@isTest
public class AccountTriggerTest {
    @isTest
    static void testAccountBeforeInsert() {
        // Create account with no name
        Account acc = new Account();
        insert acc;

        // Verify that the trigger sets the default name
        Account insertedAcc = [SELECT Name FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Default Name', insertedAcc.Name);
    }
}