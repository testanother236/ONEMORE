@isTest
public class AccountHandlerTest {
    @isTest
    static void testUpdateAccountName() {
        // Create a test account
        Account testAcc = new Account(Name = 'Old Name');
        insert testAcc;

        // Call the method to update the account name
        AccountHandler.updateAccountName(testAcc.Id, 'New Name');

        // Verify the update
        Account updatedAcc = [SELECT Name FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals('New Name', updatedAcc.Name);
    }
}