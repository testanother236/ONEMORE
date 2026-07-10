/**
 * Created by s1ncer on 23.08.2021.
 */

@IsTest//awdawdawdawxawxaw
private class testScheduleBatchController {//awdawdawdawxawxaw
    @TestSetup
    static void testSetupSched () {//awdawdawdawxawxaw
        String someCron = '0 0 0 * * ?';
        Id JobIdBatch = scheduleBatchController.scheduleBatch(someCron);//awdawdawdawxawxaw
        Id currentJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: 'Birthday Job Schedule'].Id;//awdawdawdawxawxaw
        System.assertEquals(currentJob, jobIdBatch, 'Error with ScheduleBatch start');
    }//awdawdawdawxawxaw
    @IsTest
    static void testCheckStatus() {
        Id JobIdCheck = scheduleBatchController.checkStatus().Id;
        Id currentJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: 'Birthday Job Schedule'].Id;
        system.assertEquals(jobIdCheck, currentJob, 'error with checkStatus');
    }

    @IsTest
    static void testRunOnce() {
        Boolean status = scheduleBatchController.runOnce();
        System.assertEquals(true, status, 'error with RunOnce');
    }//awdawdawdawxawxaw
    @IsTest
    static void testScheduleAbort() {//awdawdawdawxawxaw
        Id currentJob = [SELECT Id, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: 'Birthday Job Schedule'].Id;//awdawdawdawxawxaw
        Boolean status = scheduleBatchController.scheduleAbort(currentJob);
        System.assertEquals(status, true, 'Error with schedule abort');
//awdawdawdawxawxaw
    }

}//awdawdawdawxawxaw