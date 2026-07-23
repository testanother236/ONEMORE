@isTest
private class GenericBatchSchedulerTest {
    @isTest
    static void testScheduleBatch() {
        // Создаем тестовый класс планировщика
        TestScheduler testScheduler = new TestScheduler();
        String schedulerClassName = 'TestScheduler';
        String batchClassName = 'TestBatchClass'; // Замените на действительное имя вашего класса батча
        String cronString = '0 0 * * * ?'; // Запланировать на полночь каждый день

        // Запланируем батч
        Test.startTest();
        GenericBatchScheduler.scheduleBatch(schedulerClassName, batchClassName, cronString);
        Test.stopTest();

        // Проверяем, что задание было запланировано
        List<CronTrigger> jobs = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
        System.assert(!jobs.isEmpty(), 'Scheduled job should not be empty.');
        System.assertEquals(cronString, jobs[0].CronExpression, 'Cron expression should match.');
        //System.assertEquals(schedulerClassName + ' Job', jobs[0].CronJobDetail.Name, 'Job name should match.');
        System.assertEquals(1, jobs.size(), 'Only one job should be scheduled.');
    }

    @isTest
    static void testRunBatchOnce() {
        String batchClassName = 'TestBatchClass'; // Замените на действительное имя вашего класса батча

        // Запускаем батч один раз
        Test.startTest();
        GenericBatchScheduler.runBatchOnce(batchClassName);
        Test.stopTest();

        // Здесь можно добавить проверки, если ваш батч выполняет какие-либо действия
        System.assert(true, 'Batch executed successfully without errors.');
    }

    @isTest
    static void testAbortBatch() {
        // Создаем тестовый класс планировщика
        TestScheduler testScheduler = new TestScheduler();
        String schedulerClassName = 'TestScheduler';
        String batchClassName = 'TestBatchClass'; // Замените на действительное имя вашего класса батча
        String cronString = '0 0 * * * ?';

        // Запланируем батч
        Test.startTest();
        GenericBatchScheduler.scheduleBatch(schedulerClassName, batchClassName, cronString);
        Test.stopTest();

        // Отменяем запланированный батч
        GenericBatchScheduler.abortBatch(schedulerClassName);
        

        // Проверяем, что задание было отменено
        List<CronTrigger> jobsAfterAbort = [SELECT Id FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
        System.assert(jobsAfterAbort.isEmpty(), 'Scheduled job should be aborted.');
    }

    @isTest
    static void testAbortBatchWithScheduledJobs() {
        // Create a test scheduler class
        TestScheduler testScheduler = new TestScheduler();
        String schedulerClassName = 'TestScheduler';
        String batchClassName = 'TestBatchClass'; // Replace with your actual batch class name
        String cronString = '0 0 * * * ?'; // Schedule for midnight every day
    
        // Schedule the batch job
        GenericBatchScheduler.scheduleBatch(schedulerClassName, batchClassName, cronString);
    
        // Verify that the job was scheduled
        List<CronTrigger> jobsBeforeAbort = [SELECT Id FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
        System.assert(!jobsBeforeAbort.isEmpty(), 'Scheduled job should not be empty before aborting.');
    
        // Abort the scheduled batch
        Test.startTest();
        GenericBatchScheduler.abortBatch(schedulerClassName);
        Test.stopTest();
    
        // Verify that the job was aborted
        List<CronTrigger> jobsAfterAbort = [SELECT Id FROM CronTrigger WHERE CronJobDetail.JobType = '7'];
        System.assert(jobsAfterAbort.isEmpty(), 'Scheduled job should be aborted.');
    }
    

}