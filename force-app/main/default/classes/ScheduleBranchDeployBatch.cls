public with sharing class ScheduleBranchDeployBatch implements Database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful {
    private List<String> unknownErrorInDeploy;

    //private Id buildId;
    private Id branchId;
    private String query = 'SELECT Id FROM Attachment WHERE Id=\'\' WITH SECURITY_ENFORCED';
    private Id targetOrgId;
    private Id logRecordId;
    private Id lastDeplLogRecordId;
    private String backupAsyncId;

    private AuthUtils.AuthenticateDetails authDetails;
    private String deploymentType;
    private String idsComp;
    private String destrChangJSON;
    private String postDestrChangesId;
    private Boolean isDeploymentInProgress = false;
    private Boolean isDeploymentCompleted = false;
    private Boolean isPipeline = false;
    private Boolean isFullPipe = false;
    private Boolean isProfileValidation = false;
    private Map<String, Object> vlocityParamsMap;
    MetadataUtils.CredWrapper cred = new MetadataUtils.CredWrapper();
    private boolean DEPLOYMENT_ON_HOLD = false;

    // controller for start backup
    public ScheduleBranchDeployBatch(List<Id> detailIds, Map<String, Object> vlocityParamsMap) {
        this.unknownErrorInDeploy = new List<String>();
        this.branchId = detailIds[0];
        this.targetOrgId = detailIds[1];
        this.logRecordId = detailIds[2];
        this.vlocityParamsMap = vlocityParamsMap;
        deploymentType = 'BACKUP';
        this.query =
            'SELECT ID,Async_Request_Id__c,Succeed__c,Job_Completed__c,Status__c,Run_Test_Param__c FROM Metadata_Log__c WHERE Branch__c =:branchId AND Status__c=\'' +
            FlosumConstants.STATUS_NOT_STARTED +
            '\' AND Process_Type__c=\'' +
            FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT +
            '\' AND Job_Completed__c=false AND ID=:logRecordId WITH SECURITY_ENFORCED';
        isDeploymentInProgress = false;
    }
    // controller for start backup from Pipeline
    public ScheduleBranchDeployBatch(List<Id> detailIds, String idsComp, String destrChangJSON, Boolean isFullPipe) {
        this.unknownErrorInDeploy = new List<String>();
        this.branchId = detailIds[0];
        this.targetOrgId = detailIds[1];
        this.logRecordId = detailIds[2];
        this.isPipeline = true;
        this.isFullPipe = isFullPipe;
        this.idsComp = idsComp;
        this.destrChangJSON = destrChangJSON;
        this.vlocityParamsMap = new Map<String, Object>();
        deploymentType = 'BACKUP';
        this.query =
            'SELECT ID,Async_Request_Id__c,Succeed__c,Job_Completed__c,Status__c,Run_Test_Param__c FROM Metadata_Log__c WHERE Branch__c =:branchId AND Status__c=\'' +
            FlosumConstants.STATUS_IN_PROGRESS +
            '\' AND Job_Completed__c=false AND ID=:logRecordId WITH SECURITY_ENFORCED';
        isDeploymentInProgress = false;
    }

    // controller for checkStatusOfBackup
    public ScheduleBranchDeployBatch(
        List<Id> detailIds,
        String backupAsyncId,
        List<String> unknownErrorInDeploy,
        Map<String, Object> vlocityParamsMap
    ) {
        this.unknownErrorInDeploy = unknownErrorInDeploy;
        this.branchId = detailIds[0];
        this.targetOrgId = detailIds[1];
        this.logRecordId = detailIds[2];
        this.backupAsyncId = backupAsyncId;
        this.vlocityParamsMap = vlocityParamsMap;
        deploymentType = 'BACKUP CHECK STATUS';
        this.query =
            'SELECT ID,Start_Date__c,Completed_Date__c,Async_Request_Id__c,Succeed__c,Job_Completed__c,Status__c,Run_Test_Param__c FROM Metadata_Log__c WHERE Branch__c =:branchId AND Status__c=\'' +
            FlosumConstants.STATUS_NOT_STARTED +
            '\' AND Process_Type__c=\'' +
            FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT +
            '\' AND Job_Completed__c=false AND ID=:logRecordId WITH SECURITY_ENFORCED';
        isDeploymentInProgress = false;
    }
    // controller for checkStatusOfBackup from Pipeline
    public ScheduleBranchDeployBatch(
        List<Id> detailIds,
        String backupAsyncId,
        List<String> unknownErrorInDeploy,
        String idsComp,
        String destrChangJSON,
        Boolean isFullPipe
    ) {
        this.unknownErrorInDeploy = unknownErrorInDeploy;
        this.branchId = detailIds[0];
        this.targetOrgId = detailIds[1];
        this.logRecordId = detailIds[2];
        this.backupAsyncId = backupAsyncId;
        this.isPipeline = true;
        this.isFullPipe = isFullPipe;
        this.idsComp = idsComp;
        this.destrChangJSON = destrChangJSON;
        this.vlocityParamsMap = new Map<String, Object>();
        deploymentType = 'BACKUP CHECK STATUS';
        this.query =
            'SELECT ID,Start_Date__c,Completed_Date__c,Async_Request_Id__c,Succeed__c,Job_Completed__c,Status__c,Run_Test_Param__c FROM Metadata_Log__c WHERE Branch__c =:branchId AND Status__c=\'' +
            FlosumConstants.STATUS_IN_PROGRESS +
            '\'  AND Job_Completed__c=false AND ID=:logRecordId WITH SECURITY_ENFORCED';
        isDeploymentInProgress = false;
    }

    // controller for start deployment
    public ScheduleBranchDeployBatch(
        Id branchId,
        Id targetOrgId,
        Id logRecordId,
        List<String> unknownErrorInDeploy,
        Map<String, Object> vlocityParamsMap
    ) {
        this.unknownErrorInDeploy = unknownErrorInDeploy;
        this.branchId = branchId;
        this.targetOrgId = targetOrgId;
        this.logRecordId = logRecordId;
        this.vlocityParamsMap = vlocityParamsMap;
        deploymentType = 'DEPLOY';
        this.query = 'SELECT ID,Body,ParentId FROM Attachment WHERE ParentId =:branchId AND Description=:logRecordId WITH SECURITY_ENFORCED ORDER BY Name LIMIT 1';
        isDeploymentInProgress = false;
    }

    // controller for start Rollback from Pipeline Agent
    public ScheduleBranchDeployBatch(
        Id branchId,
        Id targetOrgId,
        Id logRecordId,
        Id lastDeplLogRecordId,
        String postDestrChangesId
    ) {
        this.unknownErrorInDeploy = new List<String>();
        this.branchId = branchId;
        this.postDestrChangesId = postDestrChangesId;
        this.targetOrgId = targetOrgId;
        this.logRecordId = logRecordId;
        this.lastDeplLogRecordId = lastDeplLogRecordId;
        this.vlocityParamsMap = new Map<String, Object>();
        deploymentType = 'ROLLBACK';
        this.query =
            'SELECT Id FROM Attachment WHERE ParentId =:lastDeplLogRecordId AND Description=\'' +
            FlosumConstants.ROLL_BACK_ZIP_DESCRIPTION +
            '\' WITH SECURITY_ENFORCED ORDER BY Name LIMIT 2';
        isDeploymentInProgress = false;
    }

    // controller for check deployment status
    public ScheduleBranchDeployBatch(
        Id branchId,
        Id targetOrgId,
        Id logRecordId,
        String deploymentType,
        List<String> unknownErrorInDeploy,
        Map<String, Object> vlocityParamsMap
    ) {
        this.unknownErrorInDeploy = unknownErrorInDeploy;
        this.branchId = branchId;
        this.targetOrgId = targetOrgId;
        this.logRecordId = logRecordId;
        this.vlocityParamsMap = vlocityParamsMap;
        isDeploymentInProgress = false;
        this.deploymentType = 'CHECK STATUS';
        this.query =
            'SELECT ID,Async_Request_Id__c,Succeed__c,Job_Completed__c,Status__c,Run_Test_Param__c FROM Metadata_Log__c WHERE Branch__c =:branchId AND Status__c=\'' +
            FlosumConstants.STATUS_IN_PROGRESS +
            '\' AND Job_Completed__c=false AND Id =:logRecordId AND Async_Request_Id__c != null WITH SECURITY_ENFORCED'; // AND Process_Type__c=\''+FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT+'\'
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        cred = MetadataUtils.setUpAuthentication(logRecordId);
        return Database.getQueryLocator(query);
    }

    // Batch size must be 1
    public void execute(Database.BatchableContext info, List<sObject> scope) {
        authDetails = AuthUtils.authenticateAnOrg(targetOrgId, FlosumConstants.RELEASE_MANAGER);
        //Boolean hasDeployPermission = FlosumSecurity.checkDeployPermission(targetOrgId);
        Model.Logger logger = new Model.Logger('Logs', logRecordId, 2000000, false);
        logger.log('Schedule ' + deploymentType);
        if (authDetails.isSuccess) {
            if (deploymentType == 'BACKUP') {
                try {
                    Map<String, Set<String>> retrieveMap = new Map<String, Set<String>>();
                    if (isPipeline && !isFullPipe) {
                        retrieveMap = collectBackupInfo(branchId, idsComp, destrChangJSON);
                    } else {
                        //for patch type PatchManifest
                        for (Component__c pm : [
                            SELECT Id, File_Name__c, Component_Name__c, Component_Type__c
                            FROM Component__c
                            WHERE Branch__c = :branchId
                            WITH SECURITY_ENFORCED
                        ]) {
                            String compType = pm.Component_Type__c;
                            if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                                compType = FlosumConstants.metadataFolderMap.get(compType);
                            }
                            Set<String> temp = new Set<String>();
                            if (retrieveMap.containsKey(compType)) {
                                temp = retrieveMap.get(compType);
                            }
                            temp.add(pm.Component_Name__c);
                            retrieveMap.put(compType, temp);
                        }
                        //For Destructive changes.
                        for (Destructive_Changes__c dm : [
                            SELECT Id, Post_Deployment_Change__c, Component_Type__c, Component_Name__c
                            FROM Destructive_Changes__c
                            WHERE Branch__c = :branchId
                            WITH SECURITY_ENFORCED
                        ]) {
                            String compType = dm.Component_Type__c;
                            if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                                compType = FlosumConstants.metadataFolderMap.get(compType);
                            }
                            Set<String> temp = new Set<String>();
                            if (retrieveMap.containsKey(compType)) {
                                temp = retrieveMap.get(compType);
                            }
                            temp.add(dm.Component_Name__c);
                            retrieveMap.put(compType, temp);
                        }
                    }

                    MetadataService.AsyncResult asyncResult = MetadataUtils.retrieveMetadataItem(
                        retrieveMap,
                        authDetails.details.AccessToken__c,
                        authDetails.details.InstanceURL__c
                    );
                    if (asyncResult.Id != null) {
                        backupAsyncId = asyncResult.Id;
                        isDeploymentInProgress = true;
                    } else {
                        logger.log('The async request ID was not received.');
                        logger.updateLog('Logs');
                    }
                    try {
                        List<Metadata_Log__c> metadataLogs = [
                            SELECT Id, Process_Log__c, Process_Type__c, Run_Test_Param__c, Schedule_Time__c
                            FROM Metadata_Log__c
                            WHERE Id = :this.logRecordId
                            WITH SECURITY_ENFORCED
                        ];
                        if (metadataLogs.size() == 1) {
                            Deployment_Approval__c deploymentApproval = new Deployment_Approval__c();
                            deploymentApproval.Org__c = targetOrgId;
                            deploymentApproval.Branch__c = branchId;
                            deploymentApproval.Run_Test_Param__c = metadataLogs[0].Run_Test_Param__c;
                            deploymentApproval.Process_Type__c = metadataLogs[0].Process_Type__c;
                            deploymentApproval.Specified_Tests__c = metadataLogs[0].Process_Log__c;
                            deploymentApproval.User__c = UserInfo.getUserId();
                            if (metadataLogs[0].Schedule_Time__c != null) {
                                deploymentApproval.Options__c = JSON.serialize(
                                    new Map<String, String>{
                                        'ScheduledTime' => metadataLogs[0]
                                            .Schedule_Time__c.format('yyyy-MM-dd hh:mm:ss aaa')
                                    }
                                );
                            }
                            DatabaseUtils.insertRecord(
                                deploymentApproval,
                                new List<Schema.DescribeFieldResult>{
                                    Deployment_Approval__c.Org__c.getDescribe(),
                                    Deployment_Approval__c.Branch__c.getDescribe(),
                                    Deployment_Approval__c.Run_Test_Param__c.getDescribe(),
                                    Deployment_Approval__c.Process_Type__c.getDescribe(),
                                    Deployment_Approval__c.Specified_Tests__c.getDescribe(),
                                    Deployment_Approval__c.Options__c.getDescribe(),
                                    Deployment_Approval__c.User__c.getDescribe()
                                }
                            );
                        }
                    } catch (DmlException ex) {
                        deploymentType = '';
                        unknownErrorInDeploy.add('Exception ' + ex.getMessage());
                        makeDeploymentLog(null, this.logRecordId);
                        completeDeployment(this.logRecordId);
                        System.abortJob(info.getJobId());
                    }
                } catch (Exception ex) {
                    unknownErrorInDeploy.add(
                        'A request was sent to Salesforce to retrieve the prior version of the files before deployment. However, Salesforce did not return any response. Flosum was not able to create a rollback.'
                    );
                    unknownErrorInDeploy.add('Exception ' + ex.getMessage());
                }
            } else if (deploymentType == 'BACKUP CHECK STATUS') {
                try {
                    if (backupAsyncId != null && backupAsyncId != '') {
                        MetadataService.RetrieveResult retrieveResult;
                        MetadataService.MetadataPort service = MetadataUtils.createService(
                            authDetails.details.AccessToken__c,
                            authDetails.details.InstanceURL__c
                        );

                        if (Test.isRunningTest()) {
                            retrieveResult = new MetadataService.RetrieveResult();
                            retrieveResult.done = true;
                            retrieveResult.status = 'Succeeded';
                            retrieveResult.zipFile = EncodingUtil.base64Encode(blob.valueOf('zip file'));
                            isDeploymentInProgress = false;
                        } else {
                            // check retrieve status
                            retrieveResult = isPipeline
                                ? service.checkRetrieveStatus(backupAsyncId, false)
                                : service.checkRetrieveStatus(backupAsyncId, true);
                        }

                        if (retrieveResult.done) {
                            // Errors?
                            if (
                                retrieveResult.status == 'Succeeded' &&
                                !isPipeline &&
                                retrieveResult.zipFile != null &&
                                retrieveResult.zipFile.length() < 3000000
                            ) {
                                Attachment zipPayload = new Attachment();
                                zipPayload.Body = EncodingUtil.base64Decode(retrieveResult.zipFile);
                                zipPayload.ContentType = 'application/zip';
                                zipPayload.Name = 'BACKUP ZIP';
                                zipPayload.ParentId = logRecordId;
                                zipPayload.Description = FlosumConstants.ROLL_BACK_ZIP_DESCRIPTION;
                                DatabaseUtils.insertRecord(
                                    zipPayload,
                                    new List<Schema.DescribeFieldResult>{
                                        Attachment.Body.getDescribe(),
                                        Attachment.Name.getDescribe(),
                                        Attachment.Description.getDescribe(),
                                        Attachment.ContentType.getDescribe(),
                                        Attachment.ParentId.getDescribe()
                                    }
                                );
                            } else if (retrieveResult.status == 'Succeeded' && isPipeline) {
                                //Point to run function Pipeline Flosum Agent
                                String body = '';
                                String apiVersion = FlosumConstants.apiversion + '.0';
                                Model.AuthDataWraper data = new Model.AuthDataWraper(
                                    logRecordId,
                                    backupAsyncId,
                                    cred,
                                    apiVersion
                                );
                                body = JSON.serialize(data);
                                MetadataUtils.sentRequestToFlosumAgent(body, 'SAVE_BACKUP_ZIP', logRecordId);

                                List<CronTrigger> jobs = [
                                    SELECT Id, CronJobDetail.Name, State
                                    FROM CronTrigger
                                    WHERE CronJobDetail.Name = :'MetadataLogScheduler' + UserInfo.getUserId()
                                ];

                                Datetime sysTime = System.now().addMinutes(1);
                                String cronExpression = String.format(
                                    FlosumConstants.CRON_EXPRESSION_TEMPLATE,
                                    new List<Integer>{
                                        sysTime.second(),
                                        sysTime.minute(),
                                        sysTime.hour(),
                                        sysTime.day(),
                                        sysTime.month(),
                                        sysTime.year()
                                    }
                                );
                                if (jobs.isEmpty()) {
                                    System.schedule(
                                        'MetadataLogScheduler' + UserInfo.getUserId(),
                                        cronExpression,
                                        new MetadataLogScheduler(UserInfo.getUserId())
                                    );
                                } else if (jobs[0].State == 'DELETED') {
                                    System.abortJob(jobs[0].Id);
                                    System.schedule(
                                        'MetadataLogScheduler' + UserInfo.getUserId(),
                                        cronExpression,
                                        new MetadataLogScheduler(UserInfo.getUserId())
                                    );
                                } else if (jobs[0].State == 'PAUSED') {
                                    System.resumeJobById(jobs[0].Id);
                                }
                            } else {
                                unknownErrorInDeploy.add(
                                    'A request was sent to Salesforce to retrieve the prior version of the files before deployment. However, Salesforce did not return any response. Flosum was not able to create a rollback.'
                                );
                                if (retrieveResult.errorMessage != null) {
                                    unknownErrorInDeploy.add(retrieveResult.errorMessage);
                                } else {
                                    unknownErrorInDeploy.add('' + retrieveResult.zipFile.length());
                                }
                            }
                        } else {
                            isDeploymentInProgress = true;
                        }
                    } else {
                        logger.log('The async request ID was not received.');
                        logger.updateLog('Logs');
                    }
                } catch (Exception ex) {
                    unknownErrorInDeploy.add(
                        'A request was sent to Salesforce to retrieve the prior version of the files before deployment. However, Salesforce did not return any response. Flosum was not able to create a rollback.'
                    );
                    unknownErrorInDeploy.add('Exception ' + ex.getMessage());
                }
            } else if (deploymentType == 'DEPLOY') {
                List<Metadata_Log__c> logListForOptions = [
                    SELECT
                        Id,
                        Async_Request_Id__c,
                        Status__c,
                        Job_Completed__c,
                        Process_Log__c,
                        Run_Test_Param__c,
                        Succeed__c,
                        Code_Coverage__c
                    FROM Metadata_Log__c
                    WHERE Id = :logRecordId
                    WITH SECURITY_ENFORCED
                ];

                if (logListForOptions.size() == 1) {
                    List<Attachment> attList = new List<Attachment>();
                    attList = (List<Attachment>) scope;
                    if (attList.size() > 0) {
                        try {
                            List<String> runTestList = new List<String>();
                            if (
                                logListForOptions[0].Run_Test_Param__c == FlosumConstants.RUN_SPECIFIC_TEST &&
                                logListForOptions[0].Process_Log__c != null
                            ) {
                                for (String opt : logListForOptions[0].Process_Log__c.split('\n')) {
                                    runTestList.add(opt.trim());
                                }
                            }
                            // Deploy zip file posted back from the page action function
                            MetadataService.MetadataPort service = MetadataUtils.createService(
                                authDetails.details.AccessToken__c,
                                authDetails.details.InstanceURL__c
                            );
                            MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
                            deployOptions.allowMissingFiles = true;
                            deployOptions.autoUpdatePackage = false;

                            List<Deployment_Settings__c> deploySetting = [
                                SELECT Id, isEnabled__c, Code_Coverage__c
                                FROM Deployment_Settings__c
                                WHERE Organisation__c = :targetOrgId AND isEnabled__c = TRUE
                                WITH SECURITY_ENFORCED
                                LIMIT 1
                            ];

                            deployOptions.checkOnly = false;

                            if (!deploySetting.isEmpty() && logListForOptions[0].Code_Coverage__c == 0) {
                                deployOptions.checkOnly = true;
                                logListForOptions[0].Process_Type__c = FlosumConstants.PROCESS_VALIDATE;
                            }

                            deployOptions.ignoreWarnings = MetadataUtils.getIgnoreWarningState();
                            deployOptions.performRetrieve = false;
                            deployOptions.purgeOnDelete = false;
                            deployOptions.rollbackOnError = true;

                            if (logListForOptions[0].Run_Test_Param__c != FlosumConstants.Default_TEST) {
                                deployOptions.testLevel = logListForOptions[0].Run_Test_Param__c;
                                deployOptions.runTests = runTestList;
                            }

                            deployOptions.singlePackage = true;
                            MetadataService.AsyncResult AsyncResult = service.deploy(
                                EncodingUtil.base64Encode(attList[0].Body),
                                DeployOptions
                            );
                            if (AsyncResult.Id != null) {
                                logListForOptions[0].Async_Request_Id__c = AsyncResult.Id;
                                logListForOptions[0].Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                                logListForOptions[0].Job_Completed__c = false;
                                logListForOptions[0].Attachment_Id__c = attList[0].Id;

                                DatabaseUtils.updateRecords(
                                    logListForOptions,
                                    new List<Schema.DescribeFieldResult>{
                                        Metadata_Log__c.Job_Completed__c.getDescribe(),
                                        Metadata_Log__c.Status__c.getDescribe(),
                                        Metadata_Log__c.Async_Request_Id__c.getDescribe(),
                                        Metadata_Log__c.Code_Coverage__c.getDescribe(),
                                        Metadata_Log__c.Process_Type__c.getDescribe()
                                    }
                                );
                            } else {
                                logger.log('The async request ID was not received.');
                                logger.updateLog('Logs');
                            }
                        } catch (Exception ex) {
                            unknownErrorInDeploy.add('Exception ' + ex.getMessage());
                            makeDeploymentLog(null, this.logRecordId);
                        }
                    }
                }
            } else if (deploymentType == 'CHECK STATUS') {
                List<Metadata_Log__c> logRecordList = new List<Metadata_Log__c>();
                logRecordList = (List<Metadata_Log__c>) scope;
                if (logRecordList.size() > 0) {
                    try {
                        MetadataService.MetadataPort service = MetadataUtils.createService(
                            authDetails.details.AccessToken__c,
                            authDetails.details.InstanceURL__c
                        );
                        MetadataService.DeployResult deployResult;

                        if (Test.isRunningTest()) {
                            deployResult = new MetadataService.DeployResult();
                            deployResult.done = true;
                            deployResult.success = true;
                            deployResult.checkOnly = true;
                            deployResult.errorMessage = 'UnknownErrorInDeploy';
                            deployResult.details = new MetadataService.DeployDetails();
                            deployResult.details.runTestResult = new MetadataService.RunTestsResult();

                            List<MetadataService.CodeCoverageWarning> warningLi = new List<MetadataService.CodeCoverageWarning>();
                            MetadataService.CodeCoverageWarning warning = new MetadataService.CodeCoverageWarning();
                            warning.message = 'message';
                            warning.name = 'name';
                            warning.namespace = 'namespace';
                            warningLi.add(warning);
                            deployResult.details.runTestResult.codeCoverageWarnings = warningLi;

                            List<MetadataService.FlowCoverageWarning> flowWarningLi = new List<MetadataService.FlowCoverageWarning>();
                            MetadataService.FlowCoverageWarning flowWarning = new MetadataService.FlowCoverageWarning();
                            flowWarning.message = 'message';
                            flowWarning.flowName = 'name';
                            flowWarning.flowNamespace = 'namespace';
                            flowWarningLi.add(flowWarning);
                            deployResult.details.runTestResult.flowCoverageWarnings = flowWarningLi;

                            List<MetadataService.RunTestFailure> testResultLi = new List<MetadataService.RunTestFailure>();
                            MetadataService.RunTestFailure testResult = new MetadataService.RunTestFailure();
                            testResult.name = 'name';
                            testResult.methodName = 'methodName';
                            testResult.message = 'message';
                            testResult.stackTrace = 'stackTrace';
                            testResultLi.add(testResult);
                            deployResult.details.runTestResult.failures = testResultLi;

                            List<MetadataService.RunTestSuccess> testSuccessLi = new List<MetadataService.RunTestSuccess>();
                            MetadataService.RunTestSuccess testSuccess = new MetadataService.RunTestSuccess();
                            testSuccess.name = 'name';
                            testSuccess.methodName = 'methodName';
                            testSuccessLi.add(testSuccess);
                            deployResult.details.runTestResult.successes = testSuccessLi;

                            deployResult.details.componentSuccesses = new List<MetadataService.DeployMessage>();
                            MetadataService.DeployMessage dmSuccesses = new MetadataService.DeployMessage();
                            dmSuccesses.id = 'a0D2h000002T0l6EAC';
                            dmSuccesses.problem = '';
                            dmSuccesses.fullName = 'ABC';
                            dmSuccesses.fileName = 'abc.cls';
                            dmSuccesses.componentType = 'ApexClass';
                            dmSuccesses.created = true;

                            deployResult.details.componentSuccesses.add(dmSuccesses);
                            dmSuccesses = new MetadataService.DeployMessage();
                            dmSuccesses.id = 'a0D2h000002T0l7EAC';
                            dmSuccesses.fullName = 'ABC2';
                            dmSuccesses.fileName = 'abc2.cls';
                            dmSuccesses.componentType = 'ApexTrigger';
                            dmSuccesses.changed = true;
                            deployResult.details.componentSuccesses.add(dmSuccesses);

                            deployResult.details.componentFailures = new List<MetadataService.DeployMessage>();
                            MetadataService.DeployMessage dmFailures = new MetadataService.DeployMessage();
                            dmSuccesses.id = 'a0D2h000002T0l6EAC';
                            dmSuccesses.problem = '';
                            dmSuccesses.fullName = 'ABC';
                            dmSuccesses.fileName = 'abc.cls';
                            dmSuccesses.componentType = 'ApexClass';
                            dmSuccesses.lineNumber = 1;
                            dmSuccesses.columnNumber = 2;
                            dmSuccesses.problem = 'Some problem';
                            dmSuccesses.created = true;

                            deployResult.details.componentFailures.add(dmSuccesses);
                            dmFailures = new MetadataService.DeployMessage();
                            dmSuccesses.id = 'a0D2h000002T0l7EAC';
                            dmSuccesses.fullName = 'ABC2';
                            dmSuccesses.fileName = 'abc2.cls';
                            dmSuccesses.componentType = 'ApexTrigger';
                            dmSuccesses.lineNumber = 2;
                            dmSuccesses.columnNumber = 3;
                            dmSuccesses.problem = 'Some problem';
                            dmSuccesses.changed = true;
                            deployResult.details.componentSuccesses.add(dmSuccesses);

                            List<MetadataService.CodeCoverageResult> codeCoverageComps = new List<MetadataService.CodeCoverageResult>();
                            MetadataService.CodeCoverageResult codeCoverageComp = new MetadataService.CodeCoverageResult();
                            codeCoverageComp.id = 'a0D2h000002T0l6EAC';
                            codeCoverageComp.numLocations = 56;
                            codeCoverageComp.numLocationsNotCovered = 5;
                            codeCoverageComp.name = 'ABC';
                            codeCoverageComps.add(codeCoverageComp);
                            codeCoverageComp = new MetadataService.CodeCoverageResult();
                            codeCoverageComp.id = 'a0D2h000002T0l7EAC';
                            codeCoverageComp.name = 'ABC2';
                            codeCoverageComp.numLocations = 56;
                            codeCoverageComp.numLocationsNotCovered = 53;
                            codeCoverageComps.add(codeCoverageComp);
                            deployResult.details.runTestResult.codeCoverage = codeCoverageComps;

                            List<MetadataService.DeployMessage> dmlist = new List<MetadataService.DeployMessage>();
                            MetadataService.DeployMessage dm = new MetadataService.DeployMessage();
                            dm.problem = '';
                            dmlist.add(dm);
                        } else {
                            deployResult = service.checkDeployStatus(logRecordList[0].Async_Request_Id__c, true);
                        }
                        if (deployResult.done) {
                            isDeploymentCompleted = true;
                            makeDeploymentLog(deployResult, this.logRecordId);
                        } else {
                            isDeploymentInProgress = true;
                            if (deployResult.status == 'Pending') {
                                DEPLOYMENT_ON_HOLD = true;
                            }
                        }
                    } catch (Exception ex) {
                        System.debug(ex.getMessage());
                        UnknownErrorInDeploy.add('Exception ' + ex.getMessage());
                        Integer countOfTimeOutErrors = 0;
                        for (String errorMessage : UnknownErrorInDeploy) {
                            if (errorMessage.containsIgnoreCase('Read timed out')) {
                                countOfTimeOutErrors++;
                            }
                        }
                        if (ex.getMessage().containsIgnoreCase('Read timed out') && countOfTimeOutErrors < 4) {
                            isDeploymentInProgress = true;
                        } else {
                            makeDeploymentLog(null, this.logRecordId);
                        }
                    }
                }
            } else if (deploymentType == 'ROLLBACK') {
                List<Attachment> attList = new List<Attachment>();
                attList = (List<Attachment>) scope;
                if (attList.size() > 0) {
                    String listAttacmentIds = '';
                    for (Attachment att : attList) {
                        listAttacmentIds += att.id + ',';
                    }
                    listAttacmentIds = listAttacmentIds.removeEnd(',');
                    MetadataUtils.sentDeployZipToFlosumAgent(logRecordId, listAttacmentIds, this.postDestrChangesId);
                    logger.log('Sent rollback request to Flosum Agent.');
                    logger.updateLog('Logs');
                    List<CronTrigger> jobs = [
                        SELECT Id, CronJobDetail.Name, State
                        FROM CronTrigger
                        WHERE CronJobDetail.Name = :'MetadataLogScheduler' + UserInfo.getUserId()
                    ];

                    Datetime sysTime = System.now().addMinutes(1);
                    String cronExpression = String.format(
                        FlosumConstants.CRON_EXPRESSION_TEMPLATE,
                        new List<Integer>{
                            sysTime.second(),
                            sysTime.minute(),
                            sysTime.hour(),
                            sysTime.day(),
                            sysTime.month(),
                            sysTime.year()
                        }
                    );
                    if (jobs.isEmpty()) {
                        System.schedule(
                            'MetadataLogScheduler' + UserInfo.getUserId(),
                            cronExpression,
                            new MetadataLogScheduler(UserInfo.getUserId())
                        );
                    } else if (jobs[0].State == 'DELETED') {
                        System.abortJob(jobs[0].Id);
                        System.schedule(
                            'MetadataLogScheduler' + UserInfo.getUserId(),
                            cronExpression,
                            new MetadataLogScheduler(UserInfo.getUserId())
                        );
                    } else if (jobs[0].State == 'PAUSED') {
                        System.resumeJobById(jobs[0].Id);
                    }
                } else {
                    completeDeployment(this.logRecordId);
                }
            }
        } else {
            try {
                deploymentType = '';
                unknownErrorInDeploy.add('Exception ' + authDetails.errorMessage);
                makeDeploymentLog(null, this.logRecordId);
                completeDeployment(this.logRecordId);
                System.abortJob(info.getJobId());
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        logger.updateLog('Logs');
    }

    public void finish(Database.BatchableContext BC) {
        Datetime sysTime = System.now().addSeconds(60);
        if (DEPLOYMENT_ON_HOLD) {
            //10 minutes
            sysTime = System.now().addSeconds(60 * 10);
        }

        String chronExpression =
            '' +
            sysTime.second() +
            ' ' +
            sysTime.minute() +
            ' ' +
            sysTime.hour() +
            ' ' +
            sysTime.day() +
            ' ' +
            sysTime.month() +
            ' ? ' +
            sysTime.year();

        if (deploymentType == 'BACKUP' || deploymentType == 'BACKUP CHECK STATUS') {
            if (
                (deploymentType == 'BACKUP' ||
                deploymentType == 'BACKUP CHECK STATUS') &&
                isDeploymentInProgress &&
                backupAsyncId != null &&
                backupAsyncId != ''
            ) {
                List<Id> parameterId = new List<Id>();
                parameterId.add(branchId);
                parameterId.add(targetOrgId);
                parameterId.add(logRecordId);
                if (isPipeline) {
                    System.schedule(
                        'Self MergeDeploymentCheckStatusScheduled ' + sysTime.getTime(),
                        chronExpression,
                        new MetadataDeployController(
                            parameterId,
                            backupAsyncId,
                            unknownErrorInDeploy,
                            idsComp,
                            destrChangJSON,
                            isFullPipe
                        )
                    );
                } else {
                    System.schedule(
                        'Self MergeDeploymentCheckStatusScheduled ' + sysTime.getTime(),
                        chronExpression,
                        new MetadataDeployController(parameterId, backupAsyncId, unknownErrorInDeploy, vlocityParamsMap)
                    );
                }
            } else {
                if (!isPipeline) {
                    Database.executeBatch(
                        new ScheduleBranchDeployBatch(
                            branchId,
                            targetOrgId,
                            logRecordId,
                            unknownErrorInDeploy,
                            vlocityParamsMap
                        ),
                        1
                    );
                }
            }
        } else if (deploymentType == 'DEPLOY' || deploymentType == 'CHECK STATUS') {
            List<Metadata_Log__c> metadataLogList = [
                SELECT Id
                FROM Metadata_Log__c
                WHERE Id = :logRecordId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (!metadataLogList.isEmpty()) {
                if (deploymentType == 'DEPLOY') {
                    System.schedule(
                        'Self MergeDeploymentCheckStatusScheduled ' + sysTime.getTime(),
                        chronExpression,
                        new MetadataDeployController(
                            branchId,
                            targetOrgId,
                            logRecordId,
                            'CHECK STATUS',
                            unknownErrorInDeploy,
                            vlocityParamsMap
                        )
                    );
                } else if (deploymentType == 'CHECK STATUS' && isDeploymentInProgress) {
                    // Check status again
                    System.schedule(
                        'Self MergeDeploymentCheckStatusScheduled ' + sysTime.getTime(),
                        chronExpression,
                        new MetadataDeployController(
                            branchId,
                            targetOrgId,
                            logRecordId,
                            'CHECK STATUS',
                            unknownErrorInDeploy,
                            vlocityParamsMap
                        )
                    );
                } else {
                    List<Metadata_Log__c> metadataLogForOptionList = [
                        SELECT
                            Id,
                            Run_Test_Param__c,
                            Async_Request_Id__c,
                            Organisation__c,
                            Status__c,
                            Process_Type__c,
                            Job_Completed__c
                        FROM Metadata_Log__c
                        WHERE
                            Id = :logRecordId
                            AND Async_Request_Id__c != NULL
                            AND Organisation__c != NULL
                            AND Job_Completed__c = FALSE
                        WITH SECURITY_ENFORCED
                    ];

                    if (!metadataLogForOptionList.isEmpty()) {
                        unknownErrorInDeploy.add('Log size too large.');
                        String checkRole = FlosumConstants.RELEASE_MANAGER;

                        AuthUtils.AuthenticateDetails authDetails = AuthUtils.authenticateAnOrg(
                            metadataLogForOptionList[0].Organisation__c,
                            checkRole
                        );
                        if (authDetails.isSuccess) {
                            MetadataService.MetadataPort service = MetadataUtils.createService(
                                authDetails.details.AccessToken__c,
                                authDetails.details.InstanceURL__c
                            );
                            MetadataService.DeployResult deployResult = service.checkDeployStatus(
                                metadataLogForOptionList[0].Async_Request_Id__c,
                                false
                            );
                            makeDeploymentLog(deployResult, metadataLogForOptionList[0].Id);
                        } else {
                            completeDeployment(logRecordId);
                        }
                    } else {
                        completeDeployment(logRecordId);
                    }
                }
            } else {
                completeDeployment(logRecordId);
            }

            if (isDeploymentCompleted) {
                /**** Enter point for start Vlocity deployment ****/
                if (vlocityParamsMap != null) {
                    Boolean isSeparateMatrixVersions = false;
                    Boolean isSeparateCalculationProcedureVersions = false;
                    Boolean isEnabledApexPostDeploy = false;
                    Boolean isLWCActivation = true;
                    String apexCode = '';

                    if (vlocityParamsMap.containsKey('isSeparateMatrixVersions')) {
                        isSeparateMatrixVersions = (Boolean) vlocityParamsMap.get('isSeparateMatrixVersions');
                    }

                    if (vlocityParamsMap.containsKey('isSeparateCalculationProcedureVersions')) {
                        isSeparateCalculationProcedureVersions = (Boolean) vlocityParamsMap.get(
                            'isSeparateCalculationProcedureVersions'
                        );
                    }

                    if (vlocityParamsMap.containsKey('isEnabledApexPostDeploy')) {
                        isEnabledApexPostDeploy = (Boolean) vlocityParamsMap.get('isEnabledApexPostDeploy');
                    }

                    if (vlocityParamsMap.containsKey('isEnabledApexPostDeploy')) {
                        isLWCActivation = (Boolean) vlocityParamsMap.get('isLWCActivation');
                    }

                    if (vlocityParamsMap.containsKey('apexCode')) {
                        apexCode = (String) vlocityParamsMap.get('apexCode');
                    }

                    Metadata_Log__c vlocityMetadataLog = VlocityService.createMetadataLog(
                        branchId,
                        targetOrgId,
                        VlocityService.VLOCITY_SCHEDULE_DEPLOY_BRANCH
                    );
                    DatabaseUtils.insertRecord(
                        vlocityMetadataLog,
                        new List<Schema.DescribeFieldResult>{
                            Metadata_Log__c.Organisation__c.getDescribe(),
                            Metadata_Log__c.Branch__c.getDescribe(),
                            Metadata_Log__c.Status__c.getDescribe(),
                            Metadata_Log__c.Start_Date__c.getDescribe(),
                            Metadata_Log__c.Is_Vlocity__c.getDescribe(),
                            Metadata_Log__c.PipelineStepId__c.getDescribe(),
                            Metadata_Log__c.Deployment_Name__c.getDescribe(),
                            Metadata_Log__c.Order__c.getDescribe(),
                            Metadata_Log__c.Batch_Job_Id__c.getDescribe(),
                            Metadata_Log__c.Process_Type__c.getDescribe()
                        }
                    );
                    Attachment vlocityAttLog = VlocityService.createAttachmentLog(
                        vlocityMetadataLog.Id,
                        VlocityService.VLOCITY_DEPLOY
                    );
                    VlocityService.deployFromBranch(
                        targetOrgId,
                        branchId,
                        vlocityMetadataLog.Id,
                        vlocityAttLog.Id,
                        new List<String>(),
                        isSeparateMatrixVersions,
                        isSeparateCalculationProcedureVersions,
                        isEnabledApexPostDeploy,
                        isLWCActivation,
                        apexCode
                    );
                }
                /**** End enter point for start Vlocity deployment ****/
            }
        }
    }

    public void completeDeployment(Id logRecordId) {
        List<Metadata_Log__c> logRecordList = new List<Metadata_Log__c>();
        logRecordList = [
            SELECT ID, Succeed__c, Job_Completed__c, Status__c, Async_Request_Id__c
            FROM Metadata_Log__c
            WHERE Id = :logRecordId AND Job_Completed__c = FALSE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (logRecordList.size() == 1) {
            logRecordList[0].Job_Completed__c = true;
            logRecordList[0].Succeed__c = false;
            logRecordList[0].Status__c = FlosumConstants.STATUS_COMPLETED;
            DatabaseUtils.updateRecords(
                logRecordList,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe(),
                    Metadata_Log__c.Succeed__c.getDescribe()
                }
            );
            BranchActivityController.createDeploymentLog(logRecordList[0].Id);
            if (Limits.getQueueableJobs() == 0) {
                if ([SELECT COUNT() FROM User_Story_Rule__mdt WITH SECURITY_ENFORCED LIMIT 1] > 0) {
                    System.enqueueJob(new StoriesRelatedToBranchQueueable(logRecordList[0].Id));
                }
            }
        }
    }

    public void makeDeploymentLog(MetadataService.DeployResult deployResult, Id logRecordId) {
        String successLog = '';
        String errorLog = '';
        String runAllLog = '';
        Boolean isQuickDeploy = false;
        Integer requiredCodeCoverage;
        Integer totalCodeCoverage = 0;
        RollBackInfoWraper updatedInfoWrap = new RollBackInfoWraper();
        updatedInfoWrap.createdSet = new Set<String>();
        updatedInfoWrap.updatedSet = new Set<String>();
        updatedInfoWrap.deletedSet = new Set<String>();

        List<Deployment_Result__c> compResultList = new List<Deployment_Result__c>();
        List<Attachment> logAttachments = new List<Attachment>();

        List<Metadata_Log__c> logRecordList = [
            SELECT
                Id,
                Name,
                Branch__c,
                Organisation__c,
                Code_Coverage__c,
                PipelineStepId__c,
                Process_Log__c,
                Process_Type__c,
                Start_Date__c,
                Completed_Date__c,
                Async_Request_Id__c,
                Succeed__c,
                Job_Completed__c,
                Status__c,
                Run_Test_Param__c,
                Attachment_Id__c
            FROM Metadata_Log__c
            WHERE Id = :logRecordId
            WITH SECURITY_ENFORCED
        ];

        if (logRecordList.size() > 0) {
            String RunTesOption = logRecordList[0].Run_Test_Param__c;
            if (deployResult != null) {
                if (!deployResult.success && deployResult.errorMessage != null) {
                    unknownErrorInDeploy.add(deployResult.errorMessage);
                }
                if (deployResult.status == FlosumConstants.DEPLOY_JOB_CANCELED) {
                    unknownErrorInDeploy.add(Label.Deploy_Canceled_Message);
                }
                logRecordList[0].Succeed__c = deployResult.success;
                logRecordList[0].Start_Date__c = deployResult.startDate;
                logRecordList[0].Completed_Date__c = deployResult.completedDate;
            }
            if (deployResult != null && deployResult.details != null) {
                try {
                    if (deployResult.checkOnly && logRecordList[0].Code_Coverage__c == 0) {
                        isQuickDeploy = true;
                    }

                    if (
                        deployResult.details.runTestResult != null &&
                        (deployResult.details.runTestResult.codeCoverageWarnings != null ||
                        deployResult.details.runTestResult.flowCoverageWarnings != null ||
                        deployResult.details.runTestResult.failures != null ||
                        deployResult.details.runTestResult.successes != null)
                    ) {
                        String runTestLogName = RunTesOption == 'RunSpecifiedTests'
                            ? 'Run Specified Tests Log'
                            : RunTesOption == 'RunLocalTests' ? 'Run Local Tests Log' : 'Run All Tests Log';
                        runAllLog = '\n---------- ' + runTestLogName + ' Begin ----------------\n';
                        runAllLog +=
                            'No. of Test Run: ' +
                            deployResult.details.runTestResult.numTestsRun +
                            '  Failures: ' +
                            deployResult.details.runTestResult.numFailures +
                            ' Total Time: ' +
                            deployResult.details.runTestResult.totalTime +
                            '\n\n';
                        if (deployResult.details.runTestResult.codeCoverageWarnings != null) {
                            for (
                                MetadataService.CodeCoverageWarning warning : deployResult.details.runTestResult.codeCoverageWarnings
                            ) {
                                String error = '\n Coverage Warning: ' + '\n Message: ' + warning.message;
                                if (warning.name != null)
                                    error +=
                                        (warning.namespace == null ? '\n ' : '\n ' + warning.namespace + '.') +
                                        warning.name;
                                // add item to run test log.
                                runAllLog += error;
                                runAllLog += '\n';
                            }
                        }
                        if (deployResult.details.runTestResult.flowCoverageWarnings != null) {
                            for (
                                MetadataService.FlowCoverageWarning warning : deployResult.details.runTestResult.flowCoverageWarnings
                            ) {
                                String error = '\n Coverage Warning: ' + '\n Message: ' + warning.message;
                                if (warning.flowName != null)
                                    error +=
                                        (warning.flowNamespace == null ? '\n ' : '\n ' + warning.flowNamespace + '.') +
                                        warning.flowName;
                                // add item to run test log.
                                runAllLog += error;
                                runAllLog += '\n';
                            }
                        }
                        if (deployResult.details.runTestResult.failures != null) {
                            for (MetadataService.RunTestFailure rtf : deployResult.details.runTestResult.failures) {
                                String error;
                                if (rtf.namespace != null && rtf.namespace != null) {
                                    error = '\n Component Fail name: ' + rtf.namespace + '.' + rtf.name;
                                } else {
                                    error = '\n Component Fail name: ' + rtf.name;
                                }
                                if (rtf.methodName != null && rtf.methodName != '')
                                    error += '\n Method Name: ' + rtf.methodName;
                                error += '\n Message: ' + rtf.message;
                                if (rtf.stackTrace != null && rtf.stackTrace != '')
                                    error += '\n Stack Trace: ' + rtf.stackTrace;
                                // add item to run test log.
                                runAllLog += error;
                                runAllLog += '\n';
                            }
                        }
                        if (deployResult.details.runTestResult.successes != null) {
                            totalCodeCoverage = MetadataQuickDeployController.calculateCodeCoverage(
                                deployResult,
                                RunTesOption
                            );
                            logRecordList[0].Code_Coverage__c = totalCodeCoverage;
                            AnalyticsService.trackDetails(
                                    new Map<String, String>{ 'eventType' => 'Code Coverage', 'orgId' => logRecordList[0].Organisation__c },
                                    new Map<String, String>{
                                            'code_coverage' => String.valueOf(totalCodeCoverage)
                                    }
                            );
                            for (MetadataService.RunTestSuccess rtf : deployResult.details.runTestResult.successes) {
                                String scc;
                                if (rtf.namespace != null && rtf.namespace != null) {
                                    scc =
                                        '\n Component Pass name: ' +
                                        rtf.namespace +
                                        '.' +
                                        rtf.name +
                                        '\n Method Name: ' +
                                        rtf.methodName;
                                } else {
                                    scc = '\n Component Pass name: ' + rtf.name + '\n Method Name: ' + rtf.methodName;
                                }
                                // add item to run test log.
                                runAllLog += scc;
                                runAllLog += '\n';
                            }
                        }
                        runAllLog += '\n\n---------- ' + runTestLogName + ' Finished ----------------\n';

                        ScheduleTestExecution.createTestLogByDeployResult(logRecordList[0].Id, deployResult);
                        deployResult.details.runTestResult = null;

                        Attachment attRunAllTest = new Attachment(ParentId = logRecordList[0].Id);
                        attRunAllTest.Name = runTestLogName;
                        attRunAllTest.Body = Blob.valueOf(runAllLog);
                        attRunAllTest.ContentType = 'text/plain';
                        logAttachments.add(attRunAllTest);
                    }

                    if (deployResult.details.componentFailures != null) {
                        Map<String, List<String>> tempMap = new Map<String, List<String>>();
                        for (MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures) {
                            deployMessage = FlosumConstants.fixNamesOfComponents(deployMessage);
                            deployMessage.componentType = deployMessage.componentType ==
                                deployMessage.fullName + 'Settings'
                                ? 'Settings'
                                : deployMessage.componentType;
                            if (deployMessage.problem != null) {
                                String error =
                                    '\n File name: ' +
                                    deployMessage.fileName +
                                    ', Component name: ' +
                                    deployMessage.fullName +
                                    ' (Line: ' +
                                    deployMessage.lineNumber +
                                    ': Column:' +
                                    deployMessage.columnNumber +
                                    ') : ' +
                                    '\n Message: ' +
                                    deployMessage.problem;
                                List<String> errorsLi = new List<String>();
                                if (tempMap.containskey(deployMessage.componentType)) {
                                    errorsLi = tempMap.get(deployMessage.componentType);
                                }
                                errorsLi.add(error);
                                tempMap.put(deployMessage.componentType, errorsLi);

                                if (
                                    compResultList.size() < 9000 &&
                                    (logRecordList[0].Process_Type__c == 'Deployment' ||
                                    logRecordList[0].Process_Type__c == 'Schedule Deployment')
                                ) {
                                    Deployment_Result__c rs = new Deployment_Result__c();
                                    rs.Component_Type__c = deployMessage.componentType;
                                    rs.Component_Name__c = deployMessage.fullName;
                                    rs.Error_Message__c = deployMessage.problem;
                                    rs.Status__c = 'Failure';
                                    rs.Type__c = 'Deployment Result';
                                    rs.Metadata_Log__c = logRecordList[0].Id;
                                    rs.Org__c = logRecordList[0].Organisation__c;
                                    compResultList.add(rs);
                                }
                            }
                        }
                        deployResult.details.componentFailures = null;
                        //Process error log.
                        for (String key : tempMap.keySet()) {
                            if (logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE)
                                errorLog += '\n\n---------- Validate ' + key + ' ----------------\n';
                            else
                                errorLog += '\n\n---------- Deployed ' + key + ' ----------------\n';
                            for (String err : tempMap.get(key))
                                errorLog += err;
                        }
                    }
                    if (deployResult.details.componentSuccesses != null) {
                        Map<String, List<String>> tempMap = new Map<String, List<String>>();
                        if (deployResult.success) {
                            for (
                                MetadataService.DeployMessage deployMessage : deployResult.details.componentSuccesses
                            ) {
                                deployMessage = FlosumConstants.fixNamesOfComponents(deployMessage);
                                deployMessage.componentType = deployMessage.componentType ==
                                    deployMessage.fullName + 'Settings'
                                    ? 'Settings'
                                    : deployMessage.componentType;
                                if (deployMessage.problemType != null || deployMessage.problem != null) {
                                    String error =
                                        '\n Problem Type: ' +
                                        deployMessage.problemType +
                                        ', File name: ' +
                                        deployMessage.fileName +
                                        ', Component name: ' +
                                        deployMessage.fullName +
                                        '\n Message: ' +
                                        deployMessage.problem;

                                    UnknownErrorInDeploy.add(error);
                                } else if (!FlosumConstants.logFilterSet.contains(deployMessage.fullName)) {
                                    String componentStatus = (deployMessage.created
                                        ? FlosumConstants.CREATED
                                        : deployMessage.changed
                                              ? FlosumConstants.UPDATED
                                              : deployMessage.deleted ? FlosumConstants.DELETED : FlosumConstants.NA);

                                    String successMessage =
                                        '\n Component ' +
                                        deployMessage.fullName +
                                        ' is ' +
                                        componentStatus;
                                    if (componentStatus != FlosumConstants.NA) {
                                        if (componentStatus == 'CREATED ')
                                            updatedInfoWrap.createdSet.add(
                                                deployMessage.componentType + ':' + deployMessage.fullName
                                            );
                                        else if (componentStatus == 'UPDATED ')
                                            updatedInfoWrap.updatedSet.add(
                                                deployMessage.componentType + ':' + deployMessage.fullName
                                            );
                                        else if (componentStatus == 'DELETED ')
                                            updatedInfoWrap.deletedSet.add(
                                                deployMessage.componentType + ':' + deployMessage.fullName
                                            );
                                    } else {
                                        //if item status in N/A.
                                        successMessage = '\n Component ' + deployMessage.fullName + '  NO CHANGE';
                                    }
                                    List<String> successLi = new List<String>();
                                    if (tempMap.containskey(deployMessage.componentType)) {
                                        successLi = tempMap.get(deployMessage.componentType);
                                    }
                                    successLi.add(successMessage);
                                    tempMap.put(deployMessage.componentType, successLi);

                                    String resultStatus = (deployMessage.created
                                        ? 'CREATED'
                                        : deployMessage.changed
                                              ? 'UPDATED'
                                              : deployMessage.deleted ? 'DELETED' : 'NO CHANGE');
                                    if (
                                        compResultList.size() < 9000 &&
                                        (logRecordList[0].Process_Type__c == 'Deployment' ||
                                        logRecordList[0].Process_Type__c == 'Schedule Deployment')
                                    ) {
                                        Deployment_Result__c rs = new Deployment_Result__c();
                                        rs.Component_Type__c = deployMessage.componentType;
                                        rs.Component_Name__c = deployMessage.fullName;
                                        //rs.Error_Message__c = deployMessage.problem;
                                        rs.Status__c = 'Success';
                                        rs.Type__c = 'Deployment Result';
                                        rs.Result__c = resultStatus;
                                        rs.Metadata_Log__c = logRecordList[0].Id;
                                        rs.Org__c = logRecordList[0].Organisation__c;
                                        compResultList.add(rs);
                                    }
                                }
                            }
                        }
                        deployResult.details.componentSuccesses = null;
                        // Success Log
                        for (String key : tempMap.keySet()) {
                            if (logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE)
                                successLog += '\n\n---------- Validate ' + key + ' ----------------\n';
                            else
                                successLog += '\n\n---------- Deployed ' + key + ' ----------------\n';
                            for (String su : tempMap.get(key))
                                successLog += su;
                        }
                        tempMap.clear();
                    }

                    if (deployResult.checkOnly && isQuickDeploy && logRecordList[0].PipelineStepId__c == null) {
                        List<Deployment_Settings__c> settingsList = [
                            SELECT isEnabled__c, Code_Coverage__c
                            FROM Deployment_Settings__c
                            WHERE Organisation__c = :logRecordList[0].Organisation__c AND isEnabled__c = TRUE
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                        ];

                        if (!settingsList.isEmpty()) {
                            Boolean isOverrideCodeCoverageCheck = MetadataQuickDeployController.isCodeCoverageCheckOverrideNeeded(
                                logRecordList[0].Id
                            );
                            requiredCodeCoverage = isOverrideCodeCoverageCheck
                                ? 0
                                : MetadataQuickDeployController.getRequiredCodeCoverage(
                                      Integer.valueof(settingsList[0].Code_Coverage__c),
                                      logRecordList[0].Branch__c,
                                      null
                                  );

                            Datetime sysTime = System.now().addSeconds(25);
                            String cronExpression = String.format(
                                FlosumConstants.CRON_EXPRESSION_TEMPLATE,
                                new List<Integer>{
                                    sysTime.second(),
                                    sysTime.minute(),
                                    sysTime.hour(),
                                    sysTime.day(),
                                    sysTime.month(),
                                    sysTime.year()
                                }
                            );

                            System.schedule(
                                'Start QuickDeployForScheduleDeploy ' + sysTime.getTime(),
                                cronExpression,
                                new MetadataQuickDeployController(
                                    logRecordList[0],
                                    FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT,
                                    requiredCodeCoverage
                                )
                            );

                            if (totalCodeCoverage < requiredCodeCoverage) {
                                unknownErrorInDeploy.add(
                                    String.format(
                                        FlosumConstants.CODE_COVERAGE_CHECK_FAILED_TEMPLATE,
                                        new List<Integer>{ totalCodeCoverage, requiredCodeCoverage }
                                    )
                                );
                                logRecordList[0].Succeed__c = false;
                            }
                        }
                    }
                } catch (Exception e) {
                    unknownErrorInDeploy.add('Exception ' + e.getMessage());
                }
            } else {
                String temp = '\nUnexpected Issue While Deployment. Please check target org has valid dependency or features.';
                logRecordList[0].Succeed__c = false;
                this.unknownErrorInDeploy.add(temp);
            }
            logRecordList[0].Job_Completed__c = true;
            logRecordList[0].Status__c = FlosumConstants.STATUS_COMPLETED;

            //Process error log.
            String unExpectedErrorLog = '\n---------- Error Log Begin ----------------\n';
            for (String err : unknownErrorInDeploy) {
                unExpectedErrorLog += err;
                unExpectedErrorLog += '\n';
            }
            errorLog = unExpectedErrorLog + errorLog;
            errorLog += '\n\n---------- Error Log Finished ----------------\n';
            Attachment attError = new Attachment(ParentId = logRecordList[0].Id);
            attError.Name = logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE
                ? 'Validate Error Log'
                : 'Deployment Error Log';
            attError.Body = Blob.valueOf(errorLog);
            attError.ContentType = 'text/plain';
            logAttachments.add(attError);
            errorLog = '';

            //Process success log.
            String fullSuccessLog = '\n---------- Success Log Begin ----------------\n';
            successLog = fullSuccessLog + successLog;
            successLog += '\n\n---------- Success Log Finished ----------------\n';

            // Save Success Log
            Attachment attSuccess = new Attachment(ParentId = logRecordList[0].Id);
            attSuccess.Name = logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE
                ? 'Validate Success Log'
                : 'Deployment Success Log';
            attSuccess.Body = Blob.valueOf(successLog);
            attSuccess.ContentType = 'text/plain';
            logAttachments.add(attSuccess);
            successLog = '';

            if (
                logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_DEPLOYMENT ||
                logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT
            ) {
                if (
                    [
                        SELECT Id
                        FROM Attachment
                        WHERE
                            ParentId = :logRecordList[0].Id
                            AND Description = :FlosumConstants.ROLL_BACK_ZIP_DESCRIPTION
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ]
                    .size() == 0
                ) {
                    updatedInfoWrap.message = 'The rollback was not created since Flosum did not receive a response on which components were altered. The older versions of the components are available in the backup.zip. The components altered in the target organization can be seen by the system administrator in the Setup Audit Trail.';
                } else if (
                    updatedInfoWrap.createdSet.size() == 0 &&
                    updatedInfoWrap.updatedSet.size() == 0 &&
                    updatedInfoWrap.deletedSet.size() == 0
                ) {
                    updatedInfoWrap.message = 'No components have changed, hence the rollback file is empty.';
                }
                Attachment updateInfo = new Attachment(ParentId = logRecordList[0].Id);
                updateInfo.Name = FlosumConstants.ROLL_BACK_FILE_DESCRIPTION;
                updateInfo.Body = Blob.valueOf(JSON.serialize(updatedInfoWrap));
                updateInfo.ContentType = 'text/plain';
                updateInfo.Description = FlosumConstants.ROLL_BACK_FILE_DESCRIPTION;
                logAttachments.add(updateInfo);
            }
            if (logAttachments.size() > 0) {
                DatabaseUtils.insertRecords(
                    logAttachments,
                    new List<Schema.DescribeFieldResult>{
                        Attachment.Body.getDescribe(),
                        Attachment.Name.getDescribe(),
                        Attachment.Description.getDescribe(),
                        Attachment.ContentType.getDescribe(),
                        Attachment.ParentId.getDescribe()
                    }
                );
            }

            DatabaseUtils.updateRecord(
                logRecordList[0],
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe(),
                    Metadata_Log__c.Succeed__c.getDescribe(),
                    Metadata_Log__c.Start_Date__c.getDescribe(),
                    Metadata_Log__c.Code_Coverage__c.getDescribe(),
                    Metadata_Log__c.Completed_Date__c.getDescribe()
                }
            );

            Patch_Application__c patchApp = new Patch_Application__c();
            patchApp.Org__c = logRecordList[0].Organisation__c;
            patchApp.Branch__c = logRecordList[0].Branch__c;
            patchApp.User__c = UserInfo.getUserId();
            patchApp.Deployment_URL__c = Url.getSalesforceBaseUrl().toExternalForm() + '/' + logRecordList[0].Id;
            patchApp.Deployment_Log__c = logRecordList[0].Name;
            if (
                (logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_DEPLOYMENT ||
                logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT)
            ) {
                DatabaseUtils.insertRecord(
                    patchApp,
                    new List<Schema.DescribeFieldResult>{
                        Patch_Application__c.Org__c.getDescribe(),
                        Patch_Application__c.Branch__c.getDescribe(),
                        Patch_Application__c.User__c.getDescribe(),
                        Patch_Application__c.Deployment_URL__c.getDescribe(),
                        Patch_Application__c.Deployment_Log__c.getDescribe()
                    }
                );
            }
            MetadataUtils.processDeploymentResultsApex(compResultList, logRecordList[0].Branch__c);
        }
        BranchActivityController.createDeploymentLog(logRecordId);
        if (Limits.getQueueableJobs() == 0) {
            if ([SELECT COUNT() FROM User_Story_Rule__mdt WITH SECURITY_ENFORCED LIMIT 1] > 0) {
                System.enqueueJob(new StoriesRelatedToBranchQueueable(logRecordList[0].Id));
            }
        }
    }

    public Map<String, Set<String>> collectBackupInfo(String branchId, String idsComp, String destrChangJSON) {
        Map<String, Set<String>> retrieveMap = new Map<String, Set<String>>();
        List<Branch__c> branchList = new List<Branch__c>();
        branchList = [SELECT Id FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];
        if (branchList.size() == 1) {
            List<String> desChList = new List<String>();
            if (destrChangJSON != '' && destrChangJSON != null) {
                desChList = (List<String>) JSON.deserialize(destrChangJSON, List<String>.class);
            }
            for (Destructive_Changes__c dm : [
                SELECT Id, Component_Type__c, Component_Name__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchList[0].Id AND Id IN :desChList
                WITH SECURITY_ENFORCED
            ]) {
                String compType = dm.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                    compType = FlosumConstants.metadataFolderMap.get(compType);
                }
                Set<String> temp = new Set<String>();
                if (retrieveMap.containsKey(compType)) {
                    temp = retrieveMap.get(compType);
                }
                temp.add(dm.Component_Name__c);
                retrieveMap.put(compType, temp);
            }

            Set<String> ids = new Set<String>();
            if (idsComp != '' && idsComp != null) {
                ids = (Set<String>) JSON.deserialize(idsComp, Set<String>.class);
            }
            for (Component__c repo : [
                SELECT Id, File_Name__c, Component_Name__c, Component_Type__c
                FROM Component__c
                WHERE Id IN :ids
                WITH SECURITY_ENFORCED
            ]) {
                String compType = repo.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                    compType = FlosumConstants.metadataFolderMap.get(compType);
                }
                Set<String> temp = new Set<String>();
                if (retrieveMap.containsKey(compType)) {
                    temp = retrieveMap.get(compType);
                }
                temp.add(repo.Component_Name__c);
                retrieveMap.put(compType, temp);
            }
        }
        return retrieveMap;
    }

    public class RollBackInfoWraper {
        public Set<String> createdSet;
        public Set<String> updatedSet;
        public Set<String> deletedSet;
        public String message;
    }
}