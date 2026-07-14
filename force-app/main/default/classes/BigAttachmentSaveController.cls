public with sharing class BigAttachmentSaveController 
{
	public BigAttachmentSaveController()
	{
		
	}
	
	@RemoteAction
	public static string  deployOnProduction(String attId)
	{
		try
		{
			List<Attachment> attList = new List<Attachment>();
			attList = [SELECT Id,Body FROM Attachment WHERE Id=:attId];
			if(attList.size() > 0)
			{
				MetadataService.MetadataPort service = new MetadataService.MetadataPort();
				service.SessionHeader = new MetadataService.SessionHeader_element();
				service.SessionHeader.sessionId = UserInfo.getSessionId();
				service.setEndpoint_x(URL.getSalesforceBaseUrl().toExternalForm());
				
				MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
		        deployOptions.allowMissingFiles = true;
		        deployOptions.autoUpdatePackage = false;
		        deployOptions.checkOnly = true;
		        deployOptions.ignoreWarnings = false;
		        deployOptions.performRetrieve = false;
		        deployOptions.purgeOnDelete = false;
		        deployOptions.rollbackOnError = true;
		        deployOptions.runTests = new List<String>();
		        deployOptions.singlePackage = true;
		        deployOptions.testLevel = 'RunLocalTests';
				MetadataService.AsyncResult AsyncResult = service.deploy(EncodingUtil.base64Encode(attList[0].Body), DeployOptions);
				attList.clear();
				return AsyncResult.Id;
			}
			else
			{
				return 'Attachment Not Found.';
			}
		}
		catch(Exception ex)
		{
			return 'Exception :'+ex.getMessage();
		}
		return null;
	}
}