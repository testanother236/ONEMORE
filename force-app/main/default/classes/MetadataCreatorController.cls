public with sharing class MetadataCreatorController 
{
    public MetadataCreatorController()
    {
        //MetadataService.Role rl = new MetadataService.Role();
    }
    
    public void roleCreator()
    {
        MetadataService.Role rl = new MetadataService.Role();
    }
    
    public void objectCreator()
    {
        /*MetadataService.CustomObject co = new MetadataService.CustomObject();
        String name = 'MyCustomObject1';
        co.FullName= name + '__c';
        co.DeploymentStatus = 'Deployed';
        co.Description='Created by the Metadata API';
        co.EnableActivities=true;
        co.Label=name + ' Object';
        co.PluralLabel=co.Label + 's';
        co.SharingModel='ReadWrite';

        MetadataService.CustomField nf = new MetadataService.CustomField();
        nf.type_x='Text';
        nf.Label=co.FullName + ' Name';
        co.NameField = nf;*/
        /*MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Hello_Object__c.TestField__c';
        customField.label = 'Test Field';
        customField.type_x = 'Text';
        customField.length = 42;*/
        /*MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = 'Test__c';
        customObject.label = 'Test';
        customObject.pluralLabel = 'Tests';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';*/
        /*MetadataService.DocumentFolder folder = new MetadataService.DocumentFolder();
        //folder.type = 'DocumentFolder';
        //folder.fullName = 'sourav';
        //folder.accessType = 'Public';
        //public MetadataService.FolderShare[] folderShares;
        folder.name = 'sourav';
        folder.publicFolderAccess = 'ReadWrite';
        //public MetadataService.SharedTo sharedTo;
        
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] { folder});
        
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
    
    public void customMetadataCreator()
    {
        /*MetadataService.CustomMetadata cmd = new MetadataService.CustomMetadata();
        cmd.label = 'MyCustomMetadata';
        cmd.pluralLabel = 'MyCustomMetadata';
        cmd.startsWith = 'Consonant';
        cmd.visibility = 'Public';
        
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] { cmd });
        
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
    
    public void createRemoteSiteSetting()
    {
        MetadataService.RemoteSiteSetting rms = new MetadataService.RemoteSiteSetting();
        MetadataService.MetadataPort service = createService();
        List<MetadataService.SaveResult> results = new List<MetadataService.SaveResult>();
        results = service.createMetadata(new MetadataService.Metadata[] {  });
        
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
    
    @RemoteAction
    public static String getAttahcmentStr(String attId)
    {
        for(Attachment att :[SELECT Id,Body FROM Attachment WHERE Id=:attId LIMIT 1])
        {
            return EncodingUtil.base64Encode(att.Body);
        }
        return null;
    }
    
    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.setEndpoint_x(URL.getSalesforceBaseUrl().toExternalForm());
        return service;     
    }
}