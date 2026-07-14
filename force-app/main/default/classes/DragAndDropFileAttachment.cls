@RestResource(urlMapping='/DragAndDrop/*')
global with sharing class DragAndDropFileAttachment 
{
	@HttpPost
    global static String attachDoc()
    {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String fName = req.params.get('FileName');
        String parId = req.params.get('parId');
        Blob postContent = req.requestBody; 

        Attachment a = new Attachment (ParentId = parId,Body = postContent,Name = fName);
		/*MetadataService.MetadataPort service = new MetadataService.MetadataPort();
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
		MetadataService.AsyncResult AsyncResult = service.deploy(EncodingUtil.base64Encode(postContent), DeployOptions);*/
        insert a;
        
        return a.Id;
   }
}