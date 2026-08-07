
@isTest
private class DynamicRelaySchedulerTest {
    
    /**
     * Mock Batchable implementation used to verify that the batch
     * was actually executed after the Schedulable invoke.
     */
    private class MockBatch implements Database.Batchable<Object> {
        // Static flag to track whether execute() was called
        public static Boolean executeCalled = false;

        /**
         * Reset the static flag before each test scenario.
         */
        public static void reset() {
            executeCalled = false;
        }

        /**
         * Returns a single-element iterable to force the batch AA
         * framework to invoke execute() at least once.
         */
        public Iterable<Object> start(Database.BatchableContext bc) {
            return new List<Object>{ new Account(Name = 'BatchRecord') };
        }

        /**
         * Set the flag to true when execute is invoked.
         */
        public void execute(Database.BatchableContext bc, List<Object> scope) {
            executeCalled = true;
        }

        /**
         * Placeholder method; no logic needed for the test.
         */
        public void finish(Database.BatchableContext bc) {
        }
    }

    /**
     * Test that the execute method successfully schedules and runs
     * the provided batch when batchToRun is not null.
     * Uses Test.startTest/stopTest to force synchronous execution
     * of the asynchronous batch.
     */
    @isTest
    static void testExecuteWithValidBatch() {
        // Arrange
        MockBatch batch = new MockBatch();
        MockBatch.reset();
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(batch, 200);

        // Act: simulate Schedulable execution; context is not used, can be null
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();  // batch executes synchronously here

        // Assert
        System.assert(
            MockBatch.executeCalled,
            'The batch execute method should have been called after scheduler execution.'
        );
    }

    /**
     * Test that the execute method does not throw any exception
     * when batchToRun is null. No batch should be queued.
     */
    @isTest
    static void testExecuteWithNullBatch() {
        // Arrange: scheduler with a null batch
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(null, 200);

        // Act
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Assert: verify that no exception occurred and no batch was executed
        System.assert(
            !MockBatch.executeCalled,
            'No batch should be executed when batchToRun is null.'
        );
    }
}
