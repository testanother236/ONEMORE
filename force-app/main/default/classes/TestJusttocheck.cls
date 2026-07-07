/** Test class for the Justtocheck class. */
@isTest
public class TestJusttocheck {

    /** Helper method to create test account data. */
    static void setupTestData() {
        Justtocheck.createAccount('Test Account 1', 'Customer');
        Justtocheck.createAccount('Test Account 2', 'Partner');
        Justtocheck.createAccount('Test Account 3', 'Customer');
    }

    /** Tests the createAccount method of the Justtocheck class. */
    @isTest static void testCreateAccount() {
        Test.startTest();
        Id accId = Justtocheck.createAccount('New Test Account', 'Prospect');
        Account acc = [SELECT Id, Name, Type FROM Account WHERE Id = :accId];
        System.assertEquals('New Test Account', acc.Name);
        System.assertEquals('Prospect', acc.Type);
        Test.stopTest();
    }

    /** Tests the getAccountsByType method of the Justtocheck class. */
    @isTest static void testGetAccountsByType() {
        setupTestData();
        Test.startTest();
        List<Account> customerAccounts = Justtocheck.getAccountsByType('Customer');
        System.assertEquals(2, customerAccounts.size());
        for (Account acc : customerAccounts) {
            System.assertEquals('Customer', acc.Type);
        }
        Test.stopTest();
    }

    /** Tests the updateAccountNames method of the Justtocheck class. */
    @isTest static void testUpdateAccountNames() {
        setupTestData();
        List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        Test.startTest();
        Justtocheck.updateAccountNames(accountIds, 'Updated Name');
        List<Account> updatedAccounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        for (Account acc : updatedAccounts) {
            System.assertEquals('Updated Name', acc.Name);
        }
        Test.stopTest();
    }

    /** Tests the deleteAccounts method of the Justtocheck class. */
    @isTest static void testDeleteAccounts() {
        setupTestData();
        List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        List<Id> accountIds = new List<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        Test.startTest();
        Justtocheck.deleteAccounts(accountIds);
        Integer count = [SELECT COUNT() FROM Account WHERE Id IN :accountIds];
        System.assertEquals(0, count);
        Test.stopTest();
    }

    /** Tests the accountExists method of the Justtocheck class. */
    @isTest static void testAccountExists() {
        setupTestData();
        Test.startTest();
        Boolean exists = Justtocheck.accountExists('Test Account 1');
        System.assertEquals(true, exists);
        Boolean notExists = Justtocheck.accountExists('Nonexistent Account');
        System.assertEquals(false, notExists);
        Test.stopTest();
    }

    /** Tests the getAccountsByName method of the Justtocheck class. */
    @isTest static void testGetAccountsByName() {
        setupTestData();
        Test.startTest();
        List<Account> accounts = Justtocheck.getAccountsByName('Test Account 2');
        System.assertEquals(1, accounts.size());
        System.assertEquals('Partner', accounts[0].Type);
        List<Account> noMatch = Justtocheck.getAccountsByName('Nonexistent Name');
        System.assertEquals(0, noMatch.size());
        Test.stopTest();
    }

    /** Tests the getAccountsByNameContains method of the Justtocheck class. */
    @isTest static void testGetAccountsByNameContains() {
        setupTestData();
        Test.startTest();
        List<Account> accounts = Justtocheck.getAccountsByNameContains('Account 1');
        System.assert(accounts.size() >= 1, 'Should find at least one account containing "Account 1"');
        for (Account acc : accounts) {
            System.assert(acc.Name.contains('Account 1'), 'Account name should contain "Account 1"');
        }

        List<Account> multipleMatches = Justtocheck.getAccountsByNameContains('Test');
        System.assertEquals(3, multipleMatches.size(), 'Should find all test accounts with "Test" in their name');

        List<Account> noMatches = Justtocheck.getAccountsByNameContains('Nonexistent');
        System.assertEquals(0, noMatches.size(), 'Should find no accounts with "Nonexistent" in name');

        Test.stopTest();
    }

    /** Tests the getAccountsByNamePattern method for multiple matches. */
    @isTest static void testGetAccountsByNamePattern_MultipleMatches() {
        setupTestData();
        Test.startTest();
        List<Account> accounts = Justtocheck.getAccountsByNamePattern('Test');
        System.assertEquals(3, accounts.size(), 'Should find all accounts with "Test" in their name');
        for (Account acc : accounts) {
            System.assert(acc.Name.contains('Test'));
        }
        List<Account> noMatch = Justtocheck.getAccountsByNamePattern('NonexistentPattern');
        System.assertEquals(0, noMatch.size(), 'Should find no accounts with pattern "NonexistentPattern"');
        Test.stopTest();
    }

    /** Tests the createMultipleAccounts method of the Justtocheck class. */
    @isTest static void testCreateMultipleAccounts() {
        List<Map<String, String>> accountsData = new List<Map<String, String>>();
        accountsData.add(new Map<String, String>{'Name' => 'Bulk Account 1', 'Type' => 'Customer'});
        accountsData.add(new Map<String, String>{'Name' => 'Bulk Account 2', 'Type' => 'Partner'});

        Test.startTest();
        List<Id> ids = Justtocheck.createMultipleAccounts(accountsData);
        System.assertEquals(2, ids.size());
        List<Account> createdAccounts = [SELECT Id, Name FROM Account WHERE Id IN :ids];
        System.assertEquals('Bulk Account 1', createdAccounts[0].Name);
        System.assertEquals('Bulk Account 2', createdAccounts[1].Name);
        Test.stopTest();
    }

    /** Tests the deleteAccountsByName method of the Justtocheck class. */
    @isTest static void testDeleteAccountsByName() {
        setupTestData();
        List<Account> accountsBefore = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        System.assert(accountsBefore.size() > 0, 'Accounts should exist before deletion');

        Test.startTest();
        Justtocheck.deleteAccountsByName('Test Account 1');
        List<Account> remainingAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(accountsBefore.size() - 1, remainingAccounts.size(), 'One account should be deleted');
        Test.stopTest();
    }
}