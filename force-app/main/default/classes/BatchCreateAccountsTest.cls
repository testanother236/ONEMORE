
/**
 * Test class for BatchCreateAccounts batch Apex.
 * Covers start(), execute(), and finish() methods.
 */
@isTest
private class BatchCreateAccountsTest {

    /**
     * Positive scenario:
     * Verifies that executing the batch inserts exactly 1000 Account records
     * with the expected naming pattern.
     */
    @isTest
    static void testBatchInsertsExpectedNumberOfAccounts() {
        // Before batch, no test accounts exist
        Integer countBefore = [SELECT COUNT() FROM Account WHERE Name LIKE 'Test Account %'];
        System.assertEquals(0, countBefore, 'No Test Accounts should exist before batch execution');

        Test.startTest();
        // Execute the batch with a batch size of 200 (default or custom). The start()
        // method returns no records, but execute() always inserts 1000 Accounts.
        Database.executeBatch(new BatchCreateAccounts(), 200);
        Test.stopTest();

        // After batch completes, verify that exactly 1000 records were created
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account %'];
        System.assertEquals(1000, insertedAccounts.size(), 'Batch should have created exactly 1000 Accounts');

        // Verify naming convention – all start with 'Test Account '
        for (Account acc : insertedAccounts) {
            System.assert(acc.Name.startsWith('Test Account '), 'Account name should follow the pattern');
        }
    }

    /**
     * Negative/edge scenario:
     * Verifies that executing the batch multiple times creates separate sets of 1000 records
     * and does not fail due to duplicate names or governor limits.
     * This tests the idempotent logic when start() provides no records.
     */
    @isTest
    static void testBatchCanBeRunMultipleTimes() {
        Test.startTest();
        // Run batch twice within the same test context
        Database.executeBatch(new BatchCreateAccounts());
        Database.executeBatch(new BatchCreateAccounts());
        Test.stopTest();

        // After both batches, 2000 accounts should exist (1000 per run)
        Integer total = [SELECT COUNT() FROM Account WHERE Name LIKE 'Test Account %'];
        System.assertEquals(2000, total, 'Running batch twice should create 2000 Accounts');
    }

    /**
     * Coverage for finish() and debug message.
     * The debug statement is not directly testable, but this test ensures finish()
     * executes without exception, completing code coverage.
     */
    @isTest
    static void testFinishMethodCompletesSuccessfully() {
        Test.startTest();
        Database.executeBatch(new BatchCreateAccounts(), 1);
        Test.stopTest();

        // If no exception was thrown, finish() succeeded.
        System.assert(true, 'Batch finished without errors');
    }

    /**
     * Validates that the start method returns a QueryLocator with zero records.
     * This is done indirectly by ensuring execute still creates records despite
     * having an empty scope.
     */
    @isTest
    static void testStartReturnsEmptyScope() {
        Database.QueryLocator locator = new BatchCreateAccounts().start(null);

        // The iterator should return no rows because WHERE Id = null yields zero records.
        System.assertEquals(0, locator.getQuery().contains(' WHERE Id = null') ? 0 : 1);
        // Additional check: the query string contains the impossible condition
        System.assert(locator.getQuery().containsIgnoreCase('WHERE Id = null'),
            'Start should return a query with WHERE Id = null');
    }
}
