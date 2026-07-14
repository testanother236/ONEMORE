public with sharing class MetadataDeployDeleteController 
{
	public String ZipData { get; set; }	
	
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	
	public String getPackageXml()
	{
		System.debug('Test123');
		return '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
				'<types>' + 
        			'<members>AsyncMetadataService</members>' +
        			'<name>ApexClass</name>' + 
    			'</types>'+
    			'<version>33.0</version>' + 
			'</Package>';		
	}
	
	public String getDestructiveChangesPreXml()
	{
		String desXML = '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			/*'<types>' + 
        			'<members>Hello_Object__c</members>' +
        			'<members>HelloWorld2</members>' +
        			'<members>HelloWorld3</members>' +
        			'<members>HelloWorld4</members>' +
        			'<members>HelloWorld5</members>' +
        			'<members>HelloWorld6</members>' +
        			'<members>HelloWorld7</members>' +
        			'<members>HelloWorld8</members>' +
        			'<members>HelloWorld9</members>' +
        			'<members>HelloWorld10</members>' +
        			'<name>CustomObject</name>' +
    			'</types>' +*/
			'</Package>';
			
		return desXML;
	}
	
	public String getDestructiveChangesPostXml()
	{
		/*String desXML = '<?xml version="1.0" encoding="UTF-8"?>' + 
		'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    		'<types>' + 
        		'<members>Hello_Object__c</members>' +
        		'<name>CustomObject</name>' +
    		'</types>' +
		'</Package>';*/

		String desXML = '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			'<types>' + 
        			'<members>HelloWorld</members>' +
        			'<name>ApexClass</name>' + 
    			'</types>' + 
			'</Package>';
		return desXML;
	}
	
	public String getDeployClass()
	{
		return 'public class AsyncMetadataService {String str;yahoo}';
	}
	
	public String getMetaXml()
	{
		return '<?xml version="1.0" encoding="UTF-8"?><ApexClass xmlns="http://soap.sforce.com/2006/04/metadata"><apiVersion>33.0</apiVersion><status>Active</status></ApexClass>';
	}
	
	public PageReference deployZip()
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deleting...'));

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        //deployOptions.runAllTests = false;
        deployOptions.runTests = null;
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);				
		return null;
	}	
	
	public PageReference checkAsyncRequest()
	{	
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
		if(deployResult.done)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Delete complete'));

			// Deployment errors?
			if(deployResult.details!=null && deployResult.details.componentFailures!=null)
			{
				for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures)
					if(deployMessage.problem!=null)
						ApexPages.addMessage(
							new ApexPages.Message(ApexPages.Severity.Error, 
								deployMessage.fileName + 
									' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
										deployMessage.problem));
			}
			if(deployResult.details.componentSuccesses != null)
			{				
				System.debug('Success------');
				for(MetadataService.DeployMessage deployMessage : deployResult.details.componentSuccesses)
				{
					System.debug('--componentType--'+deployMessage.componentType);
					System.debug('--deleted--'+deployMessage.deleted);
					System.debug('--fileName--'+deployMessage.fileName);
					System.debug('--fullName--'+deployMessage.fullName);
					System.debug('--problemType--'+deployMessage.problemType);
					System.debug('--success--'+deployMessage.success);
				}
			}
			if(deployResult.details.componentFailures != null)
			{
				System.debug('failed------');
				for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures)
				{
					System.debug('--componentType--'+deployMessage.componentType);
					System.debug('--deleted--'+deployMessage.deleted);
					System.debug('--fileName--'+deployMessage.fileName);
					System.debug('--fullName--'+deployMessage.fullName);
					System.debug('--problemType--'+deployMessage.problemType);
					System.debug('--success--'+deployMessage.success);
					System.debug('--problem--'+deployMessage.problem);
				}
			}
			
			AsyncResult = null;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deleting...'));
		}	
		return null;
	}
	
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		service.setEndpoint_x(URL.getSalesforceBaseUrl().toExternalForm());
		return service;		
	}
}