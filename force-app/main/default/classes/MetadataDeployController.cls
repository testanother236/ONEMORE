public with sharing class MetadataDeployController 
{
	public String ZipData { get; set; }	
	
	public MetadataService.AsyncResult AsyncResult {get; private set;}
	public Id validateId;
	
	public String getPackageXml()
	{
		/*return '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
    			'<types>' + 
        			'<members>HelloWorld</members>' +
        			'<name>ApexClass</name>' + 
    			'</types>' + 
    			'<version>26.0</version>' + 
			'</Package>';*/
		return '<?xml version="1.0" encoding="UTF-8"?>' + 
			'<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
				'<fullName>Flosum</fullName>'+
			    '<apiAccessLevel>Unrestricted</apiAccessLevel>'+
			    '<namespacePrefix>Flosum</namespacePrefix>'+
    			'<types>' + 
        			'<members>Snapshot__c-Snapshot Layout</members>'+
        			'<name>Layout</name>' + 
    			'</types>' + 
    			'<version>26.0</version>' + 
			'</Package>';		
	}
	
	public String getHelloWorldMetadata()
	{
		return '<?xml version="1.0" encoding="UTF-8"?> <Layout xmlns="http://soap.sforce.com/2006/04/metadata"> <customButtons>Deploy</customButtons> <customButtons>Commit</customButtons> <excludeButtons>Clone</excludeButtons> <excludeButtons>Edit</excludeButtons> <excludeButtons>Submit</excludeButtons> <layoutSections> <customLabel>false</customLabel> <detailHeading>false</detailHeading> <editHeading>true</editHeading> <label>Information</label> <layoutColumns> <layoutItems> <behavior>Required</behavior> <field>Name</field> </layoutItems> <layoutItems> <behavior>Required</behavior> <field>Organisation__c</field> </layoutItems> </layoutColumns> <layoutColumns> <layoutItems> <behavior>Edit</behavior> <field>Feature__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>Is_Completed__c</field> </layoutItems> <layoutItems> <behavior>Edit</behavior> <field>Is_Error__c</field> </layoutItems> </layoutColumns> <style>TwoColumnsTopToBottom</style> </layoutSections> <layoutSections> <customLabel>true</customLabel> <detailHeading>true</detailHeading> <editHeading>true</editHeading> <label>Snapshot Summary</label> <layoutColumns> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Metadata_Items__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Custom_Objects__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Apex_Classes__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Apex_Pages__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Apex_Triggers__c</field> </layoutItems> </layoutColumns> <layoutColumns> <layoutItems> <behavior>Readonly</behavior> <field>Other_Metadata_Items__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Custom_Labels__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Workflow_Rules__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Record_Types__c</field> </layoutItems> <layoutItems> <behavior>Readonly</behavior> <field>No_of_Reports__c</field> </layoutItems> </layoutColumns> <style>TwoColumnsLeftToRight</style> </layoutSections> <layoutSections> <customLabel>false</customLabel> <detailHeading>true</detailHeading> <editHeading>true</editHeading> <label>System Information</label> <layoutColumns> <layoutItems> <behavior>Readonly</behavior> <field>CreatedById</field> </layoutItems> </layoutColumns> <layoutColumns> <layoutItems> <behavior>Readonly</behavior> <field>LastModifiedById</field> </layoutItems> </layoutColumns> <style>TwoColumnsTopToBottom</style> </layoutSections> <layoutSections> <customLabel>false</customLabel> <detailHeading>false</detailHeading> <editHeading>true</editHeading> <label>Custom Links</label> <layoutColumns/> <layoutColumns/> <layoutColumns/> <style>CustomLinks</style> </layoutSections> <relatedLists> <excludeButtons>New</excludeButtons> <fields>NAME</fields> <fields>Name__c</fields> <fields>Last_Updated_By__c</fields> <fields>Last_Modified_Date__c</fields> <relatedList>Metadata_Item__c.Snapshot__c</relatedList> </relatedLists> <relatedLists> <relatedList>RelatedNoteList</relatedList> </relatedLists> <relatedLists> <excludeButtons>New</excludeButtons> <fields>NAME</fields> <fields>Patch__c</fields> <fields>Job_Completed__c</fields> <fields>Succeed__c</fields> <fields>Process_Type__c</fields> <fields>Status__c</fields> <fields>Total_Items__c</fields> <fields>UPDATEDBY_USER</fields> <fields>Metadata_Types__c</fields> <relatedList>Metadata_Log__c.Snapshot__c</relatedList> <sortField>UPDATEDBY_USER</sortField> <sortOrder>Desc</sortOrder> </relatedLists> <relatedLists> <excludeButtons>New</excludeButtons> <fields>NAME</fields> <fields>Org__c</fields> <fields>Patch__c</fields> <fields>User__c</fields> <fields>LAST_UPDATE</fields> <relatedList>Patch_Application__c.Snapshot__c</relatedList> <sortField>LAST_UPDATE</sortField> <sortOrder>Desc</sortOrder> </relatedLists> <showEmailCheckbox>false</showEmailCheckbox> <showHighlightsPanel>false</showHighlightsPanel> <showInteractionLogPanel>false</showInteractionLogPanel> <showRunAssignmentRulesCheckbox>false</showRunAssignmentRulesCheckbox> <showSubmitAndAttachButton>false</showSubmitAndAttachButton> <summaryLayout> <masterLabel>00ho0000001vvOU</masterLabel> <sizeX>4</sizeX> <sizeY>0</sizeY> <summaryLayoutStyle>Default</summaryLayoutStyle> </summaryLayout> </Layout>';	
	}
	
	public String getHelloWorld()	
	{
		return 'public class HelloWorld' + 
				'{' + 
					'public static void helloWorld()' +
					'{' + 
						'System.debug(\' Hello World\');' +
					'}' +
				'}';

	}
	
	public PageReference deployZip()
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        /*deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = true;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        //deployOptions.runAllTests = false;
        deployOptions.runTests = new List<String>();
        deployOptions.singlePackage = true;		
        deployOptions.testLevel = 'NoTestRun';
        //deployOptions.testLevel = 'RunLocalTests';
        //deployOptions.testLevel = 'RunAllTestsInOrg';*/
        
        deployOptions.allowMissingFiles = true;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false; 
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        //deployOptions.runAllTests = false;
        deployOptions.runTests = new List<String>();
        deployOptions.singlePackage = false;
        deployOptions.testLevel = 'NoTestRun';
		AsyncResult = service.deploy(ZipData, DeployOptions);	
		System.debug('validate id---:'+AsyncResult.Id);			
		return null;
	}	
	
	public PageReference checkAsyncRequest()
	{	
		// Check the status of the retrieve request
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
		if(deployResult.done)
		{
			if(deployResult.success)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deployment complete'));
				if(deployResult.details != null && deployResult.details.componentSuccesses != null)
				{
					for(MetadataService.DeployMessage deployMessage : deployResult.details.componentSuccesses)
						if(deployMessage.success)
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,deployMessage.componentType+' - '+deployMessage.fullName+' Deployed.'));
				}
			}
			else
			{
				if(deployResult.errorMessage != null)
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, deployResult.errorMessage));
			}
			System.debug(deployResult.details);
			// Deployment errors?
			if(deployResult.details!=null)
			{
				if(deployResult.details.componentFailures!=null)
				{
					for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures)
						if(deployMessage.problem!=null)
							ApexPages.addMessage(
								new ApexPages.Message(ApexPages.Severity.Error, 
									deployMessage.fileName + 
										' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
											deployMessage.problem));
				}
				if(deployResult.details.runTestResult != null)
				{
					if(deployResult.details.runTestResult.failures != null)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Run Test Failures.'));
						for(MetadataService.RunTestFailure fail : deployResult.details.runTestResult.failures)
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,fail.methodName+'  '+fail.message));
						}
					}
					if(deployResult.details.runTestResult.codeCoverageWarnings != null)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Code Coverage Warning.'));
						for(MetadataService.CodeCoverageWarning warning : deployResult.details.runTestResult.codeCoverageWarnings)
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,warning.message+'  '+warning.name));
						}
					}
					if(deployResult.details.runTestResult.successes != null)
					{
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Code Coverage Success.'));
						for(MetadataService.RunTestSuccess fail : deployResult.details.runTestResult.successes)
						{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,fail.methodName+'  '+fail.name));
						}
					}
				}
			}
			validateId = AsyncResult.Id;
			AsyncResult = null;
		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Deploying...'));
		}	
		return null;
	}
	
	public void deployRecentValidation()
	{
		if(validateId != null )
		{
			try
			{
				MetadataService.MetadataPort service = createService();
				String result = service.deployRecentValidation(validateId);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,result));
			}
			catch(Exception ex)
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
			}
		}
		else
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Validate Id not found.'));
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