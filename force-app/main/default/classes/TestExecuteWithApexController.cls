public with sharing class TestExecuteWithApexController
{
    public TestExecuteWithApexController()
    {
        try
        {
            /*ApexService.Apex  service = new ApexService.Apex();
            service.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/s/37.0';
            service.timeout_x = 120000;
            service.SessionHeader = new ApexService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            
            ApexService.RunTestsRequest  RunTestsRequest = new ApexService.RunTestsRequest();
            RunTestsRequest.AllTests = true;
            ApexService.RunTestsResult res = service.runTests(RunTestsRequest);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Number of tests: ' + res.NumTestsRun));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Number of failures: ' + res.NumFailures));
           if (res.NumFailures > 0) 
           {
              for (ApexService.RunTestFailure rtf : res.Failures) 
              {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Failure: ' + (rtf.Namespace == null ? '' : rtf.Namespace + '.') + rtf.Name + '.' + rtf.MethodName + ': '
                 + rtf.Message + '\n' + rtf.StackTrace));
              }
           }
           if (res.CodeCoverage != null) 
           {
              for (ApexService.CodeCoverageResult ccr : res.CodeCoverage) 
              {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, + ccr.type_x
                 +(ccr.Namespace == null ? '' : ccr.Namespace + '.')
                 + ccr.Name + ': '
                 + ccr.NumLocationsNotCovered
                 + ' locations not covered out of '
                 + ccr.NumLocations));
              }
           }*/
           /*ApexService.Apex  service = new ApexService.Apex();
            service.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/s/37.0';
            service.timeout_x = 120000;
            service.SessionHeader = new ApexService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            
            ApexService.RunTestsRequest  RunTestsRequest = new ApexService.RunTestsRequest();
            RunTestsRequest.AllTests = true;
            ApexService.RunTestsResult res = service.runTests(RunTestsRequest);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Number of tests: ' + res.NumTestsRun));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Number of failures: ' + res.NumFailures));
           if (res.NumFailures > 0) 
           {
              for (ApexService.RunTestFailure rtf : res.Failures) 
              {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Failure: ' + (rtf.Namespace == null ? '' : rtf.Namespace + '.') + rtf.Name + '.' + rtf.MethodName + ': '
                 + rtf.Message + '\n' + rtf.StackTrace));
              }
           }
           if (res.CodeCoverage != null) 
           {
              for (ApexService.CodeCoverageResult ccr : res.CodeCoverage) 
              {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, + ccr.type_x
                 +(ccr.Namespace == null ? '' : ccr.Namespace + '.')
                 + ccr.Name + ': '
                 + ccr.NumLocationsNotCovered
                 + ' locations not covered out of '
                 + ccr.NumLocations));
              }
           }*/
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ex.getMessage()));
        }
    }
}