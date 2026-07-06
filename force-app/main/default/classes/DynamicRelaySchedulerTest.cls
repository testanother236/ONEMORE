
@isTest
private class DynamicRelaySchedulerTest {

    /**
     * Mock implementation of Database.Batchable<Object> used to verify
     * that the batch lifecycle methods are invoked when the Schedulable executes.
     */
    private class MockBatchable implements Database.Batchable<Object> {
        public static Integer startCallCount = 0;
        public static Integer executeCallCount = 0;
        public static Integer finishCallCount = 0;

        public Iterable<Object> start(Database.BatchableContext bc) {
            startCallCount++;
            // Return a non-empty list so the execute method is called.
            return new List<Object>{ new Object() };
        }

        public void execute(Database.BatchableContext bc, List<Object> scope) {
            executeCallCount++;
        }

        public void finish(Database.BatchableContext bc) {
            finishCallCount++;
        }
    }

    /**
     * Verifies that when a valid Batchable instance and batch size are provided,
     * the execute method correctly invokes Database.executeBatch and the batch
     * completes successfully (start, execute, and finish are each called once).
     */
    @isTest
    static void testExecute_WithNonNullBatchable_RunsBatch() {
        // Arrange
        MockBatchable mockBatch = new MockBatchable();
        Integer batchSize = 10;
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(mockBatch, batchSize);
        
        // Reset static counters before the test to ensure isolation
        MockBatchable.startCallCount = 0;
        MockBatchable.executeCallCount = 0;
        MockBatchable.finishCallCount = 0;

        // Act
        Test.startTest();
        scheduler.execute(null); // null SchedulableContext is acceptable; it is not used
        Test.stopTest();

        // Assert
        System.assertEquals(1, MockBatchable.startCallCount, 'Expected start to be called once');
        System.assertEquals(1, MockBatchable.executeCallCount, 'Expected execute to be called once');
        System.assertEquals(1, MockBatchable.finishCallCount, 'Expected finish to be called once');
    }

    /**
     * Verifies that no exception is thrown when the scheduler is constructed
     * with a null Batchable. The execute method simply skips the batch
     * execution, avoiding a NullPointerException.
     */
    @isTest
    static void testExecute_WithNullBatchable_DoesNotThrow() {
        // Arrange
        DynamicRelayScheduler scheduler = new DynamicRelayScheduler(null, 10);

        // Act
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();

        // Assert
        // No exception means the test passes. An explicit assertion is added for clarity.
        System.assert(true, 'Method should not throw when batchable is null');
    }
}
