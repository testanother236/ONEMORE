public with sharing class CreateSecuritySettingController 
{
    public CreateSecuritySettingController()
    {
        try
        {
            //createSecuritySetting();
            //createRemoteSiteSetting();
            createCustomMetadata();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, + ex.getMessage()));
        }
    }
    
    public void createCustomMetadata()
    {
        /*MetadataService.CustomMetadata cmd = new MetadataService.CustomMetadata();
        cmd.fullName = 'Test';
        cmd.label = 'Test';
        cmd.values = new List<MetadataService.CustomMetadataValue>();
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] { cmd});
        
        for (MetadataService.SaveResult r : results) 
        {
            if (r.Success) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Created component: ' + r.FullName));
            }  
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Errors were encountered while creating ' + r.FullName));
                for (MetadataService.Error e : r.Errors) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Error message: ' + e.Message));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Status code: ' + e.StatusCode));
                }
            }
        }*/
    }
    
    /*public void createSecuritySetting()
    {
        MetadataService.SecuritySettings setting = new MetadataService.SecuritySettings();
        setting.networkAccess = new MetadataService.NetworkAccess();
        setting.networkAccess.ipRanges = new List<MetadataService.IpRange>();
        MetadataService.IpRange range = new MetadataService.IpRange();
        range.start = '1.0.0.0';
        range.end_x = '1.1.1.1';
        range.description = 'test';
        setting.networkAccess.ipRanges.add(range);
        
        
        
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] { setting});
        
        for (MetadataService.SaveResult r : results) 
        {
            if (r.Success) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Created component: ' + r.FullName));
            }  
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Errors were encountered while creating ' + r.FullName));
                for (MetadataService.Error e : r.Errors) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Error message: ' + e.Message));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Status code: ' + e.StatusCode));
                }
            }
        }
    }
    
    public void createRemoteSiteSetting()
    {
        MetadataService.RemoteSiteSetting rss = new MetadataService.RemoteSiteSetting();
        rss.isActive = true;
        rss.fullName = 'SAinie';
        rss.description = 'Manual';
        rss.url = 'https://ap5.salesforce.com';
        rss.disableProtocolSecurity = false;
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] { rss});
        
        for (MetadataService.SaveResult r : results) 
        {
            if (r.Success) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Created component: ' + r.FullName));
            }  
            else 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Errors were encountered while creating ' + r.FullName));
                for (MetadataService.Error e : r.Errors) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Error message: ' + e.Message));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Status code: ' + e.StatusCode));
                }
            }
        }
    }*/
    
    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.setEndpoint_x(URL.getSalesforceBaseUrl().toExternalForm());
        return service;     
    }
}