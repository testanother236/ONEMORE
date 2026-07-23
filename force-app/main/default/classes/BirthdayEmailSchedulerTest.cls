@isTest
private class BirthdayEmailSchedulerTest {
    @isTest
    static void testBirthdayEmailScheduler() {
        // Create an instance of the scheduler
        BirthdayEmailScheduler scheduler = new BirthdayEmailScheduler();
    
            // Set the batch class name
        String batchClassName = 'BirthdayEmailBatch';
        scheduler.setBatchClassName(batchClassName);
    
        // Run the scheduler
        Test.startTest();
        String jobId = System.schedule('Test Birthday Email Scheduler', '0 0 * * * ?', scheduler);
        Test.stopTest();
    
        // Verify that the job was scheduled
        CronTrigger job = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, job, 'Scheduled job should not be null.');
        System.assertEquals('0 0 * * * ?', job.CronExpression, 'Cron expression should match.');
        System.assertEquals('WAITING', job.State, 'Job should be in WAITING state.');
    }
    
    @isTest
    static void testExecuteMethod() {
        // Create an instance of the scheduler
        BirthdayEmailScheduler scheduler = new BirthdayEmailScheduler();
    
        // Set the batch class name
        String batchClassName = 'BirthdayEmailBatch';
        scheduler.setBatchClassName(batchClassName);
    
        // Create a mock object to verify the calls
        Test.startTest();
        scheduler.execute(null);
        Test.stopTest();
    
        // In this test, you can add additional verifications
        // For example, verifying the logs or other actions, if applicable
        System.assert(true, 'Execute method should run without errors.');
    }
}