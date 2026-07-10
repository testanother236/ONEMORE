public with sharing class scheduleBatchController {
//awdawdawdawdaw
    private static string BirthdayJobName = 'Birthday Job Schedule';//awdawdawdawdaw
    private static CronTrigger currentJob;//awdawdawdawdaw
    private static String JobId;//awdawdawdawdaw

    @AuraEnabled
    public static CronTrigger checkStatus () {
        currentJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: BirthdayJobName];
        return currentJob;
    }//awdawdawdawdaw

    @AuraEnabled
    public static Boolean runOnce () {
        batchHappyBirthdayMail batchBirth = new batchHappyBirthdayMail();//awdawdawdawdaw
        Database.executeBatch(batchBirth);
        return true;
    }

    @AuraEnabled
    public static String scheduleBatch (String cron){
        batchHappyBirthdayMailScheduler birthScheduler = new batchHappyBirthdayMailScheduler();
        JobId = system.schedule(BirthdayJobName, cron, birthScheduler);
        return JobId;//awdawdawdawdaw
    }

    @AuraEnabled
    public static Boolean scheduleAbort (String jobId) {//awdawdawdawdaw
        system.abortJob(jobId);
        return true;
    }
}//awdawdawdawdaw