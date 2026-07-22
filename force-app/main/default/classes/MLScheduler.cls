public with sharing class MLScheduler implements Schedulable, Database.AllowsCallouts {
public void execute(SchedulableContext sc) {
 
        startCheckingStatus();
   System.abortJob(sc.getTriggerId());


            Datetime timeNow = System.now().addMinutes(1);
        String cronExpression = timeNow.second() + ' ' + timeNow.minute() + ' ' + timeNow.hour() + ' * * ?';
            System.schedule('MLScheduler', cronExpression, new MLScheduler());
     }  
     
     @future(callout=true)
    public static void startCheckingStatus() {
    Map<String, String> result = new Map<String, String>();
    try{
            ExtentionPackageIntegration2 integration = (ExtentionPackageIntegration2) Type.forName('testScan', 'LaunchBranchScanIntegration2').newInstance();
        result =(Map<String, String>) integration.getResult('a0KGC0000103Ug12AE');
        }
        catch(Exception e){
            System.debug(e.getMessage());
                   }
        String bugs = '';
            String vulnerabilities = '1';
            Boolean isSuccess = false;
        if (result!=null && !Test.isRunningTest()){
            String resultBugs = result.get('bugs');
            String resultVulnerabilities = result.get('vulnerabilities');
            if (String.isNotEmpty(resultBugs) && String.isNotEmpty(bugs) && Integer.valueOf(resultBugs)<=Integer.valueOf(bugs)){
                isSuccess = true;
            } else if (String.isNotEmpty(resultBugs) && String.isEmpty(bugs)){
                isSuccess = true;
            }
            if (isSuccess && String.isNotEmpty(resultVulnerabilities) && String.isNotEmpty(vulnerabilities) && Integer.valueOf(resultVulnerabilities)>Integer.valueOf(vulnerabilities)){
                isSuccess = false;
            }
        Attachment attError = new Attachment(
                        ParentId = 'a0KGC0000103Ug12AE', // attach error log to metadata log
                        Name = isSuccess?'Succes Log':'Error Log',
                        Body = Blob.valueOf(JSON.serialize(result)),
                        ContentType = 'text/plain'
                );
                insert attError;
        }
    }     
}