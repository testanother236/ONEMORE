public with sharing class TestPageController {
    public String message { get; set; }
    public Map<String, String> result { get; set; }
    public TestPageController() {
    message = 'start';
        
    }
    public PageReference getResult() {
        /*try{
            ExtentionPackageIntegration2 integration = (ExtentionPackageIntegration2) Type.forName('testScan', 'LaunchBranchScanIntegration2').newInstance();
        result =(Map<String, String>) integration.getResult('a0KGC0000103Ug12AE');
        }
        catch(Exception e){
            System.debug(e.getMessage());
            message = e.getMessage();
        }*/
        Datetime timeNow = System.now().addMinutes(1);
        String cronExpression = timeNow.second() + ' ' + timeNow.minute() + ' ' + timeNow.hour() + ' * * ?';
            System.schedule('MLScheduler', cronExpression, new MLScheduler());
        return null;
    }
    
    public PageReference startScan() {
        try{
            ExtentionPackageIntegration2 integration = (ExtentionPackageIntegration2) Type.forName('testScan', 'LaunchBranchScanIntegration2').newInstance();
        message =(String) integration.execute('a0KGC0000103Ug12AE');
        }
        catch(Exception e){
            System.debug(e.getMessage());
            message = e.getMessage();
        }
        return null;
    }
}