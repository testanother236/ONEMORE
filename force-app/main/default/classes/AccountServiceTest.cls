@isTest
public class AccountServiceTest {

    @isTest
    static void testCreateAccount() {
        AccountService service = new AccountService();
        
        Account acc = service.createAccount('Test Account');
        
        System.assertNotEquals(null, acc);
        System.assertEquals('Test Account', acc.Name);
    }

    @isTest
    static void testGetAccounts() {
        // Test data
        insert new Account(Name = 'Acc1');
        insert new Account(Name = 'Acc2');

        AccountService service = new AccountService();
        List<Account> accounts = service.getAccounts();

        System.assert(accounts.size() > 0);
    }

    @isTest
    static void testUpdateAccount() {
        Account acc = new Account(Name = 'Old Name');
        insert acc;

        AccountService service = new AccountService();
        Account updated = service.updateAccount(acc.Id, 'New Name');

        System.assertEquals('New Name', updated.Name);
    }

    @isTest
    static void testDeleteAccount() {
        Account acc = new Account(Name = 'To Delete');
        insert acc;

        AccountService service = new AccountService();
        service.deleteAccount(acc.Id);

        List<Account> result = [SELECT Id FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetAccountsWithFilter() {
        insert new Account(Name = 'Apple');
        insert new Account(Name = 'Banana');

        AccountService service = new AccountService();

        Test.startTest();
        List<Account> result = service.getAccounts('%App%');
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Apple', result[0].Name);
    }

    @isTest
    static void testCreateAccountException() {
        AccountService service = new AccountService();

        // Пытаемся создать Account без Name (вызовет DML Exception)
        Account acc = service.createAccount(null);

        System.assertEquals(null, acc);
    }

}