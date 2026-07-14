public with sharing class MetadataDeleteController 
{
    public List<SelectOption> MetaDataTypes {get; set;}
	public String MetaDataType {get; set;}
	public List<SelectOption> MetaDataItems {get; set;}
	public String MetaDataFolder {get; set;} 
	public String MetaDataItem {get; set;}
	
	public List<ErrorWraper> deleteResultList{get; set;}
	
	private Integer version = 33;
	
	public PageReference init()
	{
		deleteResultList = new List<ErrorWraper>();
		// List available Metadata Types via the 'describeMetadata' API call
		// List available Metadata Types via the 'describeMetadata' API call
		// List available Metadata Types via the 'describeMetadata' API call
		MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());					
		MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(version);
		List<String> metadataTypeNames = new List<String>();
		for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
		{
			metadataTypeNames.add(metadataObject.xmlName);
			// Include child Metadata Types (such as CustomField, ValidationRule etc..)
			if(metadataObject.childXmlNames!=null)
				for(String childXmlName : metadataObject.childXmlNames)
					if(childXmlName!=null)
						metadataTypeNames.add(childXmlName);
		}	

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
		
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, version);
		
		// Sort
		List<String> fullNames = new List<String>();
		if(fileProperties!=null)
		{
			for(MetadataService.FileProperties fileProperty : fileProperties)
			{
				fullNames.add(fileProperty.fullName);
			}
			fullNames.sort();
			for(String fullName : fullNames)
				MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
		}

		return null;	
	}
	
	public PageReference deleteMetadataItems()
	{		 
		deleteResultList.clear();
		// Construct unmanaged package with list of desired components to retrieve in zip
		MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());	
		List<String> deleteList = new List<String>();
		System.debug('MetaDataType---:'+MetaDataType);
		System.debug('MetaDataItem---:'+MetaDataItem);
		List<MetadataService.DeleteResult> deleteRusultList = new List<MetadataService.DeleteResult>();
		deleteRusultList = service.deleteMetadata(MetaDataType,new List<String>{MetaDataItem});
		for(MetadataService.DeleteResult dr :deleteRusultList)			
		{
			System.debug('dr.fullName-----:'+dr.fullName);
			ErrorWraper  erw = new ErrorWraper(dr.fullName);
			if(!dr.success)
			{
				for(MetadataService.Error err : dr.errors)
				{
					erw.errors.add(err.message);
					System.debug('err.message-----:'+err.message);
				}
			}
			else
			{
				erw.errors.add('Deleted Succesfully');
				System.debug('Deleted Succesfully');
			}
			deleteResultList.add(erw);
			
		}	
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Delete Done.'));
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
		//service.SessionHeader.sessionId = '00D90000000xAkK!ARgAQJMGz71quzJUPh4m8SmXy8Z1GD8RQ7ZHEsAhmlUSfK7sRMXKcQAVbEXmWIPsNYWCoW.qVvkFWCUlsG.F_uJkSILGU9Qx';
		service.setEndpoint_x(instance);
		//service.setEndpoint_x('https://ap1.salesforce.com');
		return service;		
	}
	
	public class ErrorWraper 
	{
		public String fullName{get;set;}
		public List<String> errors{get;set;}
        
        public ErrorWraper(String fullName)
        {
        	this.fullName = fullName;
        	this.errors = new List<String>();
        }
	}
}