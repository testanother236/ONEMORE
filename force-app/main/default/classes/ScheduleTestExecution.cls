public with sharing class ScheduleTestExecution implements Schedulable
{
    public String orgID;
    public String asyncId;
    public boolean validateTestExecution;
    public boolean checkStatusOfTestExecution;
    
    public ScheduleTestExecution(String orgID)
    {
        this.orgID = orgID;
        validateTestExecution = true;
        checkStatusOfTestExecution = false;
    }
    
    public ScheduleTestExecution(String orgID, String asyncId)
    {
        this.orgID = orgID;
        this.asyncId = asyncId;
        validateTestExecution = false;
        checkStatusOfTestExecution = true;
    }
    
    public void execute(SchedulableContext sc)
    {
        if(validateTestExecution && orgID != null)
        {
            String ZipData = 'UEsDBAoAAAAIABiGKUkEh+ewbwAAAIAAAAALAAAAcGFja2FnZS54bWw1zMEKwjAMgOFXKbnbxCGiknY3zx70AUIX59A2Yy3i4+thHn/4+bj/5Jd761InKwG2nsBpSTZMZQxwu543B+gjXyQ9ZVT3m0sN8GhtPiFWk9nXuy1JfbKMHdEeaYdZmwzSBCKvcuyOnhj/xbiC8QtQSwECFAAKAAAACAAYhilJBIfnsG8AAACAAAAACwAAAAAAAAAAAAAAAAAAAAAAcGFja2FnZS54bWxQSwUGAAAAAAEAAQA5AAAAmAAAAAAA';
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
            MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
            deployOptions.allowMissingFiles = true;
            deployOptions.autoUpdatePackage = false;
            deployOptions.checkOnly = true;
            deployOptions.ignoreWarnings = false;
            deployOptions.performRetrieve = false;
            deployOptions.purgeOnDelete = false;
            deployOptions.rollbackOnError = true;
            deployOptions.runTests = new List<String>();
            deployOptions.singlePackage = false;
            deployOptions.testLevel = 'RunAllTestsInOrg';
            MetadataService.AsyncResult async = service.deploy(ZipData, DeployOptions);
            asyncId = async.Id;
            Datetime sysTime = System.now().addSeconds(20);       
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'CheckStatusTestExecution' + System.now().getTime(), chronExpression,new ScheduleTestExecution(orgID,asyncId ));
        }
        else if(checkStatusOfTestExecution && orgID != null && asyncId != null)
        {
            try
            {
                MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
                MetadataService.DeployResult deployResult = service.checkDeployStatus(asyncId , true);
                if(deployResult.done)
                {
                    System.abortJob(sc.getTriggerId());
                }
                else
                {
                    Datetime sysTime = System.now().addSeconds(20);       
                    String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    System.schedule( 'CheckStatusTestExecution' + System.now().getTime(), chronExpression,new ScheduleTestExecution(orgID,asyncId ));
                }
            }
            catch(Exception ex)
            {
                System.abortJob(sc.getTriggerId());
            }
        }
    }
    
    public static MetadataService.MetadataPort createService(String session, String instance)
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.timeout_x = 120000;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = session == null ? UserInfo.getSessionId(): session;
        service.setEndpoint_x(instance);      
        return service; 
    }
}