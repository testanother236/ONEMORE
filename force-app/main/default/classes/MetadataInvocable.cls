public with sharing class MetadataInvocable 
{
	@InvocableMethod(label='Get Metadata Types' description='Returns the list of metadata types.')
	public static List<String> listMetadaTypes(List<String> strList)
	{
		Integer version = 33;
		// List available Metadata Types via the 'describeMetadata' API call
		MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());					
		MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(version);
		List<String> metadataTypeNames = new List<String>();
		for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
		{
			metadataTypeNames.add(metadataObject.xmlName);
			// Include child Metadata Types (such as CustomField, ValidationRule etc..)
			if(metadataObject.childXmlNames!=null)
			{
				for(String childXmlName : metadataObject.childXmlNames)
				{
					if(childXmlName!=null)
					{
						metadataTypeNames.add(childXmlName);
					}
				}
			}
		}

		// Sort Metadata Types
		metadataTypeNames.sort();
		return metadataTypeNames;
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