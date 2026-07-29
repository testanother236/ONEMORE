
@isTest
private class DynamicRelaySchedulerTest {

    /**
     * Mock Batchable implementation used to verify that
     * the scheduler correctly invokes the batch process.
     */
    private class MockBatch implements Database.Batchable<Object> {
        // Static flag to track whether the batch was started
        public static Boolean startCalled = false;

        public Iterable<Object> start(Database.BatchableContext context) {
            startCalled = true;
            return new List<Object>();
        }

        public void execute(Database.BatchableContext context, List<Object> scope) {
            // No-op for validation
        }

        public void finish(Database.BatchableContext context) {
            // No-op for validation
        }
    }

    /**
     * Test that the constructor initialises the batch reference
     * and that calling execute() triggers the batch.
     */
    @isTest
    static void testExecute_TriggersBatch() {
        // Given
        MockBatch batch = new MockBatch();
        Integer batchSize = 20;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(batch, batchSize);
        MockBatch.startCalled = false;

        // When: execute the schedulable directly (context can be null)
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Then: the wrapped batch should have been started
        System.assert(MockBatch.startCalled, 'Batch should be executed when batchToRun is non-null');
    }

    /**
     * Test that when the scheduler is created with a null batch,
     * the execute method does not throw and no batch is run.
     */
    @isTest
    static void testExecute_NullBatch_NoBatchStarted() {
        // Given
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(null, 10);
        MockBatch.startCalled = false;

        // When
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Then: no batch should have been started
        System.assert(!MockBatch.startCalled, 'No batch should be executed when batchToRun is null');
    }

    /**
     * Test the full schedule flow: schedule the DynamicRelayScheduler
     * and verify the batch is executed when the scheduled job runs.
     */
    @isTest
    static void testScheduledExecution_TriggersBatch() {
        // Given
        MockBatch batch = new MockBatch();
        Integer batchSize = 5;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(batch, batchSize);
        MockBatch.startCalled = false;

        // When: schedule the job and force immediate execution with Test.stopTest()
        Test.startTest();
        System.schedule('Test Dynamic Scheduler', '0 0 13 * * ?', scheduler);
        Test.stopTest();

        // Then: the batch should have been executed
        System.assert(MockBatch.startCalled, 'Batch should be executed when the scheduled job runs');
    }

    /**
     * Negative testTOPOLOGY: a negative batch size should cause
     * an IllegalArgumentException when executeBatch is called.
     */
    @isTest
    static void testExecute_NegativeBatchSize_ThrowsException() {
        // Given
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(new MockBatch(), -1);
        MockBatch.startCalled = false;

        // When / Then
        Test.startTest();
        try {
            scheduler.execute(null);
            Test.stopTest();
            System.assert(false, 'Expected an exception due to negative batch size');
        } catch (Exception e) {
            // Database.executeBatch with a negative size throws a synchronous IllegalArgumentException
            System.assert(e instanceof System.IllegalArgumentException,
                'Exception should be IllegalArgumentException, got: ' + e.getTypeName());
        }
    }
}
