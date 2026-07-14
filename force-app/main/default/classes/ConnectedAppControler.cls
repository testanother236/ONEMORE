public with sharing class ConnectedAppControler
{
    public ConnectedAppControler()
    {
        try
        {
            //readConnectedApp();
            //createConnectedApp();
            updateConnectedApp();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    public void createConnectedApp() {
        MetadataService.ConnectedApp app = new MetadataService.ConnectedApp();
            //app.fullName = 'test3';
            app.contactEmail = UserInfo.getUserEmail();
            app.label = 'test3';
            MetadataService.ConnectedAppOauthConfig config = new MetadataService.ConnectedAppOauthConfig();
            config.callbackUrl = 'https://saini123-dev-ed.my.salesforce.com';
            //config.certificate;
            config.consumerKey = 'abcd1234567890abcd1234567890';
            config.consumerSecret = 'abcd1234567890';
            config.scopes = new List<String>{'Full'};
            app.oauthConfig = config;
            //MetadataService.ConnectedAppOauthConfig oauthConfig
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
            List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
            /*results = service.createMetadata(new MetadataService.Metadata[] { app});
            
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
    
    public void updateConnectedApp() {
        MetadataService.ConnectedApp app = new MetadataService.ConnectedApp();
        //app.fullName = 'test3';
        app.contactEmail = UserInfo.getUserEmail();
        app.label = 'test3';
        MetadataService.ConnectedAppOauthConfig config = new MetadataService.ConnectedAppOauthConfig();
        config.callbackUrl = 'https://saini123-dev-ed.my.salesforce.com\noob';
        //config.certificate;
        config.consumerKey = 'abcd1234567890abcd1234567890';
        config.consumerSecret = 'abcd1234567890';
        config.scopes = new List<String>{'Address','Api','Basic','Chatter','CustomApplications','CustomPermissions','Email','Full','OfflineAccess','OpenID','Phone','Profile','RefreshToken','Wave','Web'};
        app.oauthConfig = config;
        //MetadataService.ConnectedAppOauthConfig oauthConfig
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
        List<MetadataService.UpsertResult> results = new List<MetadataService.UpsertResult>();
        /*results = service.upsertMetadata(new MetadataService.Metadata[] { app});
        
        for (MetadataService.UpsertResult r : results) 
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
    
    public void readConnectedApp() {
        
        //MetadataService.ConnectedAppOauthConfig oauthConfig
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
        /*MetadataService.IReadResult result = service.readMetadata('ConnectedApp',new List<String>{'test3'});
        if(result != null)
        {
            MetadataService.Metadata[] metaLi = result.getRecords();
            if(metaLi != null && metaLi.size() > 0)
            {
                MetadataService.ConnectedApp app = (MetadataService.ConnectedApp)metaLi[0];
                if(app != null && app.oauthConfig != null)
                {
                    System.debug(app.oauthConfig.consumerKey);
                    System.debug(app.oauthConfig.consumerSecret);
                    System.debug(app.oauthConfig.scopes);
                    System.debug(app.oauthConfig.callbackUrl);
                }
            }
        }*/    
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