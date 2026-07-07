
/**
 * Test class for DynamicRelayScheduler.
 * Contains unit tests to verify scheduler construction, execution, and edge cases.
 */
@isTest
public class DynamicRelaySchedulerTest {
    
    /**
     * Helper class to implement Batchable interface for testing purposes.
     */
    private class TestBatch implements Database.Batchable<Object> {
        public static Boolean wasExecuted = false;
        
        /**
         * Returns a Database.QueryLocator for a single Account record.
         * Resets the wasExecuted flag before starting.
         */
        public Database.QueryLocator start(Database.BatchableContext bc) {
            wasExecuted = false;
            return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
        }
        
        /**
         * Sets the wasExecuted flag to true when batch executes.
         */
        public void execute(Database.BatchableContext bc, List<Object> scope) {
            wasExecuted = true;
        }
        
        /**
         * Cleanup method called after batch execution completes.
         */
        public void finish(Database.BatchableContext bc) {
        }
    }
    
    /**
     * Test method for constructing DynamicRelayScheduler with valid parameters.
     */
    @isTest
    static void testConstructorWithValidParameters() {
        TestBatch testBatch = new TestBatch();
        Integer testBatchSize = 200;
        
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(testBatch, testBatchSize);
        
        System.assertNotEquals(null, scheduler, 'Scheduler should be created successfully');
    }
    
    /**
     * Test method for execute method with a valid batch.
     */
    @isTest
    static void testExecuteWithValidBatch() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        TestBatch testBatch = new TestBatch();
        Integer testBatchSize = 200;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(testBatch, testBatchSize);
        
        Test.startTest();
        System.schedule('TestJob', '0 0 0 * * ?', scheduler);
        Test.stopTest();
        
        System.assertEquals(true, TestBatch.wasExecuted, 'Batch should have been executed');
    }
    
    /**
     * Test method for execute method when batchToRun is null.
     */
    @isTest
    static void testExecuteWithNullBatch() {
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(null, 200);
        
        Test.startTest();
        System.schedule('NullJob', '0 0 0 * * ?', scheduler);
        Test.stopTest();
        
        System.assertEquals(false, TestBatch.wasExecuted, 'No batch should have been executed');
    }
    
    /**
     * Test method for execute method with minimum batch size.
     */
    @isTest
    static void testExecuteWithMinimumBatchSize() {
        Account testAccount = new Account(Name = 'Test Account for Min Batch');
        insert testAccount;
        
        TestBatch testBatch = new TestBatch();
        Integer minimumBatchSize = 1;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(testBatch, minimumBatchSize);
        
        Test.startTest();
        System.schedule('MinBatchSizeJob', '0 0 0 * * ?', scheduler);
        Test.stopTest();
        
        System.assertEquals(true, TestBatch.wasExecuted, 'Batch with minimum size should execute');
    }
    
    /**
     * Test method for execute method with maximum typical batch size.
     */
    @isTest
    static void testExecuteWithMaximumBatchSize() {
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;
        
        TestBatch testBatch = new TestBatch();
        Integer maximumBatchSize = 2000;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(testBatch, maximumBatchSize);
        
        Test.startTest();
        System.schedule('MaxBatchSizeJob', '0 0 0 * * ?', scheduler);
        Test.stopTest();
        
        System.assertEquals(true, TestBatch.wasExecuted, 'Batch with maximum size should execute');
    }
    
    /**
     * Test method to verify the Schedulable interface implementation.
     */
    @isTest
    static void testSchedulableInterfaceImplementation() {
        TestBatch testBatch = new TestBatch();
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(testBatch, 200);
        
        System.assert(scheduler instanceof Schedulable, 'Class must implement Schedulable interface');
    }
}
