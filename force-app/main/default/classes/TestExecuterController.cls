public with sharing class TestExecuterController
{
    public transient String ZipData{get;set;}
    public List<SelectOption> runTestOptions{get;set;}
    public String selectedRunTest{get;set;}
    public String AsyncResultId{get;set;}
    
    public static final String NO_TEST_RUN = 'NoTestRun';
    public static final String RUN_LOCAL_TEST = 'RunLocalTests';
    public static final String RUN_ALL_TEST_IN_ORG = 'RunAllTestsInOrg';
    public static final Map<String,String> runTestParamPatchMap = new Map<String,String>{NO_TEST_RUN => 'Do not run any tests',
                                                                                    RUN_LOCAL_TEST => 'Run local tests, ignore tests from managed packages',
                                                                                    RUN_ALL_TEST_IN_ORG => 'Run all tests'
                                                                                    };
    
    public TestExecuterController()
    {
        runTestOptions = new List<SelectOption>();
        for(String key : runTestParamPatchMap.keySet())
        {
            runTestOptions.add(new SelectOption(key,runTestParamPatchMap.get(key)));
        }
        /*runTestOptions = new List<SelectOption>();
        for(String key : runTestParamPatchMap.keySet())
        {
            runTestOptions.add(new SelectOption(key,runTestParamPatchMap.get(key)));
        }*/
    }
    
    public void executeTest()
    {
        AsyncResultId = '';
        if(selectedRunTest != null && selectedRunTest != '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
            MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
            deployOptions.allowMissingFiles = true;
            deployOptions.autoUpdatePackage = false;
            deployOptions.checkOnly = false; 
            deployOptions.ignoreWarnings = false;
            deployOptions.performRetrieve = false;
            deployOptions.purgeOnDelete = false;
            deployOptions.rollbackOnError = true;
            deployOptions.runTests = new List<String>();
            deployOptions.singlePackage = false;
            deployOptions.testLevel = selectedRunTest;
            MetadataService.AsyncResult async = service.deploy(ZipData, DeployOptions);
            AsyncResultId = async.Id;
        }
    }
    
    public void checkStatus()
    {
        try
        {
            if(AsyncResultId != null && AsyncResultId != '')
            {
                MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
                MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResultId , true);
                if(deployResult.done)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deployment complete'));
                    AsyncResultId = '';
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));
                }
            }
        }
        catch(Exception ex)
        {
            AsyncResultId = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
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