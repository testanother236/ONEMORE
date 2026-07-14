/**
 * This example demonstrates how to utilise the Metadata API Retrieve operation inconjunction with the JSZip JavaScript library
 *
 dfg
 
 */
public with sharing class MetadataRetrieveController 
{
    public List<SelectOption> MetaDataTypes {get; set;}
    public String MetaDataType {get; set;}      
    public List<SelectOption> MetaDataItems {get; set;}
    public String MetaDataFolder {get; set;} 
    public String MetaDataItem {get; set;}  
    public String MetadataFileName {get; set;}
    public String MetadataFileData {get; set;}
    public MetadataService.AsyncResult AsyncResult {get; private set;}
    public String MetaDataRetrieveZip { get; private set; } 
    public List<MetadataFile> MetadataFiles { get; set; }       
    private static Integer version = 65;
    
    public PageReference init()
    {
        // List available Metadata Types via the 'describeMetadata' API call
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());                 
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(version );
        List<String> metadataTypeNames = new List<String>();
        for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
        {
            System.debug('metadataObject.directoryName-'+metadataObject.directoryName);
            System.debug('metadataObject.inFolder-'+metadataObject.inFolder);
            System.debug('metadataObject.metaFile-'+metadataObject.metaFile);
            System.debug('metadataObject.suffix-'+metadataObject.suffix);
            System.debug('metadataObject.xmlName-'+metadataObject.xmlName);
            if(metadataObject.childXmlNames!=null){
                System.debug('metadataObject.xmlName---------'+metadataObject.xmlName);
                System.debug('metadataObject.childXmlNames---'+metadataObject.childXmlNames);
            }
            
            metadataTypeNames.add(metadataObject.xmlName);
            // Include child Metadata Types (such as CustomField, ValidationRule etc..)
            if(metadataObject.childXmlNames!=null)
                for(String childXmlName : metadataObject.childXmlNames)
                    if(childXmlName!=null)
                        metadataTypeNames.add(childXmlName);
        }   
        metadataTypeNames.add('DocumentFolder');
        metadataTypeNames.add('DashboardFolder');
        metadataTypeNames.add('ReportFolder');
        metadataTypeNames.add('EmailFolder');
        //metadataTypeNames.add('WaveFolder');
        // Sort Metadata Types
        metadataTypeNames.sort();
        MetaDataTypes = new List<SelectOption>();               
        for(String metadataTypeName : metadataTypeNames)
            MetaDataTypes.add(new SelectOption(metadataTypeName, metadataTypeName));
                    
        // Default to first Metadata Type returned  
        MetaDataType = MetaDataTypes[0].getValue();             
        // Retrieve Metadata items for the selected Metadata Type
        listMetadataItems();        
        return null;    
    }
    
    public PageReference listMetadataItems()
    {
        // List Metadata items for the selected Metadata Type
        MetaDataItems = new List<SelectOption>();       
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());              
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.folder = MetaDataFolder;
        queryLayout.type_x = MetaDataType;
        queries.add(queryLayout);         
            
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, version );
        // Sort
        List<String> fullNames = new List<String>();
        Set<String> fullNamesSet = new Set<String>();
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties)
            {
                if(fileProperty.type_x == 'Layout' && fileProperty.manageableState == 'installed' && fileProperty.namespacePrefix != null)
                {
                    fileProperty.fullName = fileProperty.fullName.replaceFirst('-','-'+fileProperty.namespacePrefix+'__');
                    fileProperty.fileName= fileProperty.fileName.replaceFirst('-','-'+fileProperty.namespacePrefix+'__');
                }
                else if(fileProperty.type_x == 'CustomField' && MetaDataFolder != null && !fileProperty.fullName.endsWith('__c') && !fileProperty.fullName.startsWith(MetaDataFolder +'.'))
                {
                    fileProperty.fileName = 'objects/'+ MetaDataFolder +'.object';
                    fileProperty.fullName = MetaDataFolder +'.'+ fileProperty.fullName;
                }
                fullNamesSet.add(fileProperty.fullName);
                fullNames.add(fileProperty.fullName);
                //System.debug('manageableState--'+fileProperty.manageableState);
                System.debug('Id---------'+fileProperty.Id+'----'+fileProperty.fullName);
                System.debug('Id---------'+fileProperty.Id);
                System.debug('fullName---------'+fileProperty.fullName);
                System.debug('fileName---------'+fileProperty.fileName);
                System.debug('manageableState--'+fileProperty.manageableState);
                System.debug('namespacePrefix-'+fileProperty.namespacePrefix);
                System.debug('type__x----------'+fileProperty.type_x);
                System.debug('lastModifiedDate-'+fileProperty.lastModifiedDate);
                System.debug('lastModifiedDate-'+fileProperty.createdDate);
            }
            fullNames.sort();
            for(String fullName : fullNames)
                MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
            MetaDataItems.add(new SelectOption('FRecipe','FRecipe'));
            System.debug('fileProperties.size()--'+fileProperties.size());
            System.debug('fullNames.size()--'+fullNames.size());
            System.debug(JSON.serialize(fullNamesSet));
        }
        
        return null;    
    }
    
    public PageReference retrieveMetadataItem()
    {       
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
        
        // Reset state from any previous requests
        MetaDataRetrieveZip = null;
        MetadataFiles = null;
         
        // Construct unmanaged package with list of desired components to retrieve in zip
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());              
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = version ;
        retrieveRequest.packageNames = null;//new List<String>{'SDocs'};
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = new List<String>();
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.apiAccessLevel = 'Unrestricted';
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
        packageType.name = MetaDataType;
        List<String> names = new List<String>();
        names.add(MetaDataItem);
        if(MetaDataFolder != null && MetaDataFolder != '')
        {
            names.add(MetaDataFolder);
        }
        packageType.members = names;
        retrieveRequest.unpackaged.types.add(packageType);
        if(MetaDataType == 'Report')
        {
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'ReportFolder';
            packageType.members = new List<String>{MetaDataFolder};
            retrieveRequest.unpackaged.types.add(packageType);
        }
        if(MetaDataType == 'Profile')
        {
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'ApexPage';
            packageType.members = new List<String>{'Flosum__TrackStandardChanges'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            
        }
        /*if(MetaDataType == 'RecordType')
        {
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomObject';
            packageType.members = new List<String>{MetaDataItem.substring(0,MetaDataItem.indexOf('.'))};
            retrieveRequest.unpackaged.types.add(packageType);
            
            
        }*/
        if(MetaDataType == 'CustomObjectTranslation')
        {
            System.debug(MetaDataItem);
            String parentObjectName = MetaDataItem.substring(0,MetaDataItem.indexOf('-'));
            System.debug(parentObjectName);
            //object related translations
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomObject';
            packageType.members = new List<String>{parentObjectName };
            retrieveRequest.unpackaged.types.add(packageType);
            //workflow related translations
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'Workflow';
            packageType.members = new List<String>{parentObjectName };
            retrieveRequest.unpackaged.types.add(packageType);
            //quick action related translations
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'QuickAction';
            packageType.members = new List<String>{'TempTest__Test_Object__c.TempTest__Test_Action'};
            retrieveRequest.unpackaged.types.add(packageType);
                        
            //layout related translations
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'Layout';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
        }
        if(MetaDataType == 'Translations')
        {
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomApplication';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomLabels';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomPageWebLink';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'CustomTab';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'QuickAction';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'ReportType';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'Scontrol';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
            
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'Layout';
            packageType.members = new List<String>{'*'};
            retrieveRequest.unpackaged.types.add(packageType);
        }
        if(MetaDataType == 'WaveRecipe'){//
            packageType = new MetadataService.PackageTypeMembers();
            packageType.name = 'WaveDataFlow';
            packageType.members = new List<String>{MetaDataItem};
            retrieveRequest.unpackaged.types.add(packageType);
        }
        System.debug('retrieveRequest---'+retrieveRequest);
        AsyncResult = service.retrieve_x(retrieveRequest);
        return null;    
    }
    
    public PageReference checkAsyncRequest()
    {
        //try
        //{
            // Check the status of the retrieve request
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
            MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.Id,true);
            System.debug('retrieveResult---'+retrieveResult);
            if(retrieveResult.done)
            {
                // Errors?
                if(retrieveResult.status != 'Succeeded')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, retrieveResult.errorMessage));
                    AsyncResult = null;             
                }
                else
                {
                    if(retrieveResult.messages != null){
                        for(MetadataService.RetrieveMessage rm : retrieveResult.messages){
                            System.debug('rm.fileName-'+rm.fileName);
                            System.debug('rm.problem--'+rm.problem);
                        }
                    }
                    
                    // Place Base64 encoded zip data onto the page for the JSZip library to handle
                    MetaDataRetrieveZip = retrieveResult.zipFile;
                    MetadataFiles = new List<MetadataFile>();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
                    AsyncResult = null;
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
            }   
        //}
        //catch(Exception e)
        //{
          //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        //}
        return null;
    }
    
    public PageReference receiveMetadataZipFile()
    {
        // In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding ' + MetaDataFileName + '...'));
        MetadataFile metaDataFile = new MetadataFile();
        metaDataFile.fullName = MetaDataFileName;
        metaDataFile.content = MetaDataFileData;
        MetadataFiles.add(metaDataFile);
        return null;
    }
    
    public PageReference receiveComplete()
    {
        // Completed, cleared Base64 encoded zip data from viewstate
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
        MetaDataRetrieveZip = null;     
        return null;
    }
    
    private static MetadataService.MetadataPort createService()
    {   
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }   
    
    public static MetadataService.MetadataPort createService(String session, String instance)
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.timeout_x = 120000;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = session == null ? UserInfo.getSessionId(): session;
        //service.SessionHeader.sessionId = '00DHu00000IZq5p!AQ8AQOC.OSGGzYmzULBxsO9gOc12q3AjOwlEG2yKDUl4hBO1_P1ymTFH6WpjG6e5SFPepwI59X7Y3hw2cMO8EaV36wlmuqy_';
        service.setEndpoint_x(instance,version+'.0');
        //service.setEndpoint_x('https://fl1739874018357.my.salesforce.com',version+'.0');    
        return service; 
    }
    
    /**
     * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
     **/
    public class MetadataFile
    {
        public String fullName{get;set;}
        public String content{get;set;}
    }
}