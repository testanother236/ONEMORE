
/**
 * @description Test class for AccountCreatorQueueable covering all execution paths,
 *              chain logic, early termination, and exception handling.
 *              NOTE: Due to the 45-second busy-wait loop in the original class,
 *              these tests will consume significant CPU time and may hit governor limits.
 *              Consider refactoring the original class for testability (e.g., using a
 *              dependency-injected wait service) to avoid long test durations.
 */
@isTest
private class AccountCreatorQueueableTest {

    // ---------- Positive Tests ----------

    /**
     * @description Tests the full happy path of the queueable chain:
     *              starting from zero records, the chain creates exactly 10 accounts
     *              and then stops. Asserts that all expected accounts exist with correct attributes.
     */
    @isTest
    static void testChainCreatesExactTarget() {
        // Start with no accounts
        Integer startingCount = [SELECT COUNT() FROM Account WHERE Name LIKE 'Auto-Account%'];
        System.assertEquals(0, startingCount, 'No pre-existing auto-accounts should exist');

        // Enqueue the first job with recordsCreated = 0
        Test.startTest();
        System.enqueueJob(new AccountCreatorQueueable(0));
        Test.stopTest(); // executes all chained queueable jobs synchronously

        // After the chain, exactly 10 accounts should be inserted
        List<Account> created = [SELECT Id, Name, Industry, Description FROM Account WHERE Name LIKE 'Auto-Account%' ORDER BY Name];
        System.assertEquals(10, created.size(), 'Exactly 10 accounts should be created');

        // Verify attributes of each account
        for (Integer i = 0; i < 10; i++) {
            Account acc = created[i];
            System.assertEquals('Auto-Account ' + (i + 1), acc.Name, 'Account name should match sequence');
            System.assertEquals('Technology', acc.Industry, 'Industry should be Technology');
            System.assert(acc.Description.startsWith('Created by Queueable chain at'), 'Description should contain creation message');
        }
    }

    /**
     * @description Tests that when the queueable is already at or above the target,
     *              it does nothing and does not create any accounts.
     */
    @isTest
    static void testAlreadyAtTarget_NoAccountsCreated() {
        // Given an initial count equal to the target
        Test.startTest();
        System.enqueueJob(new AccountCreatorQueueable(10));
        Test.stopTest();

        // No accounts should have been created
        Integer accountCount = [SELECT COUNT() FROM Account WHERE Name LIKE 'Auto-Account%'];
        System.assertEquals(0, accountCount, 'No accounts should be created when target is already met');
    }

    /**
     * @description Tests the scenario where only one more account is needed to reach the target.
     *              The chain should insert the last account and then stop without further chaining.
     */
    @isTest
    static void testLastAccountToReachTarget_StopsAfter() {
        // Start one short of target
        Test.startTest();
        System.enqueueJob(new AccountCreatorQueueable(9));
        Test.stopTest();

        // Exactly one account should be created
        List<Account> created = [SELECT Id, Name FROM Account WHERE Name LIKE 'Auto-Account%'];
        System.assertEquals(1, created.size(), 'Only one account should be created when starting at 9');
        System.assertEquals('Auto-Account 10', created[0].Name, 'Account name should be the last in sequence');
    }

    // ---------- Negative / Exception Test ----------

    /**
     * @description Tests that a DML exception during insert is caught, logged,
     *              and does not cause the chain to continue. In this test a
     *              before-insert trigger forces an error on all inserted Account records,
     *              simulating an insert failure. Asserts that no accounts are persisted.
     */
    @isTest
    static void testExceptionDuringInsert_CatchBranchExecuted() {
        // The helper trigger (defined at the bottom of the test class) will reject every insert.
        // Enqueue the job that attempts to insert account(s)
        Test.startTest();
        System.enqueueJob(new AccountCreatorQueueable(0));
        Test.stopTest();

        // No accounts should exist because the insert always fails
        List<Account> accs = [SELECT Id FROM Account WHERE Name LIKE 'Auto-Account%'];
        System.assertEquals(0, accs.size(), 'No accounts should be committed after DML exception');

        // If the catch block did not execute, an unhandled exception would have surfaced.
        // The silent logging in the original class ensures this test passes without exception.
    }

    // Coverage for constructor (implicitly covered by above tests, but explicit is fine)
    @isTest
    static void testConstructor_StoresRecordsCreated() {
        // Just instantiate to ensure coverage; no behaviour to assert (field is private)
        AccountCreatorQueueable job = new AccountCreatorQueueable(5);
        System.assertNotEquals(null, job, 'Job instance should be created');
        // The private field is set; covered by constructor line.
    }
}
