public with sharing class VlocityService {
    public static String EMPTY_ACCESS_TOKEN = '123';
    public static String VLOCITY_RETRIEVE = 'Retrieve';
    public static String VLOCITY_LWC_OMNI_OUT = 'LWCOmniOut';
    public static String VLOCITY_DEPLOY = 'Deploy';
    public static String VLOCITY_DEPLOY_BRANCH = 'DeployFromBranch';
    public static String VLOCITY_SCHEDULE_DEPLOY_BRANCH = 'ScheduleDeployFromBranch';
    public static String VLOCITY_CLEAN_ORG_DATA = 'CleanOrgData';
    public static String VLOCITY_DEPLOY_DEPLOYMENT = 'DeployFromDeployment';
    public static String UNLOCKED_PACKAGE_CREATE_SNAPSHOT = 'Create Snapshot From Unlocked Package';
    public static String VLOCITY_INSTALL_VLOCITY_INITIAL = 'InstallVlocityInitial';
    public static String VLOCITY_PACK_RETRY = 'PackRetry';
    public static String VLOCITY_ROLLBACK = 'Rollback (Deployment SFI)';
    public static String VLOCITY_DEPLOY_BRANCH_URL = '/vlocity/deploy-from-branch';
    public static String VLOCITY_DEPLOY_DEPLOYMENT_URL = '/vlocity/deploy-from-deployment';
    public static String VLOCITY_DEPLOY_RETRIEVE_URL = '/vlocity/retrieve';
    public static String VLOCITY_LWC_OMNI_OUT_URL = '/vlocity/lwc-omni-out-retrieve';
    public static String VLOCITY_DEPLOY_CLEAN_ORG_DATA_URL = '/vlocity/clean-org-data';
    public static String VLOCITY_INSTALL_VLOCITY_INITIAL_URL = '/vlocity/install-vlocity-initial';
    public static String VLOCITY_PACK_RETRY_URL = '/vlocity/pack-retry';
    public static String PROCESS_ROLLBACK_VLOCITY_URL = '/vlocity/rollback';
    public static String AVAILABLE_TO_EXPORT_VLOCITY_URL = '/vlocity/available-to-export';
    public static String AVAILABLE_TO_EXPORT_VLOCITY_JOB_URL = '/vlocity/available-to-export/job';
    public static String OVERWRITE_PROTECTION_VLOCITY_URL = '/vlocity/overwrite-protection';
    public static String OVERWRITE_PROTECTION_VLOCITY_JOB_URL = '/vlocity/overwrite-protection/job';
    public static String DEFAULT_URL = '/vlocity';

    public static Map<String, String> PROCESS_LABEL_MAP = new Map<String, String>{
        VLOCITY_CLEAN_ORG_DATA => 'Clean Org Data',
        VLOCITY_INSTALL_VLOCITY_INITIAL => 'Install Vlocity Initial',
        VLOCITY_RETRIEVE => 'Retrieval (SFI)',
        VLOCITY_LWC_OMNI_OUT => 'LWC OmniOut (SFI)',
        VLOCITY_DEPLOY => 'Deployment (SFI)',
        VLOCITY_DEPLOY_BRANCH => 'Deployment (SFI)',
        VLOCITY_SCHEDULE_DEPLOY_BRANCH => 'Schedule Deployment (SFI)',
        VLOCITY_PACK_RETRY => 'Pack Retry (SFI)',
        UNLOCKED_PACKAGE_CREATE_SNAPSHOT => UNLOCKED_PACKAGE_CREATE_SNAPSHOT,
        VLOCITY_ROLLBACK => VLOCITY_ROLLBACK
    };

    public static Map<String, String> SUPPORTED_PROCESS_TYPES_URL = new Map<String, String>{
        VlocityService.VLOCITY_CLEAN_ORG_DATA => VlocityService.VLOCITY_DEPLOY_CLEAN_ORG_DATA_URL,
        VlocityService.VLOCITY_INSTALL_VLOCITY_INITIAL => VlocityService.VLOCITY_INSTALL_VLOCITY_INITIAL_URL,
        VlocityService.VLOCITY_ROLLBACK => VlocityService.PROCESS_ROLLBACK_VLOCITY_URL,
        VlocityService.VLOCITY_PACK_RETRY => VlocityService.VLOCITY_PACK_RETRY_URL
    };

    private static Map<String, IVlocityCommand> vlocityCommandMap;

    private static void initVlocityCommandsMap() {
        if (vlocityCommandMap == null) {
            vlocityCommandMap = new Map<String, IVlocityCommand>();
            vlocityCommandMap.put(VLOCITY_PACK_RETRY, new PackRetryCommand());
            vlocityCommandMap.put(VLOCITY_INSTALL_VLOCITY_INITIAL, new InstallVlocityInitialCommand());
            vlocityCommandMap.put(VLOCITY_CLEAN_ORG_DATA, new InstallVlocityInitialCommand());
        }
    }

    public static String deployFromBranch(
        String orgId,
        String branchId,
        String metadataLogId,
        String logAttachmentId,
        List<String> vlocityComponentIdList,
        Boolean isSeparateMatrixVersions,
        Boolean isSeparateCalculationProcedureVersions,
        Boolean isEnabledApexPostDeploy,
        Boolean isLWCActivation,
        String apexCode
    ) {
        return privateDeployFromBranch(
            orgId,
            branchId,
            metadataLogId,
            logAttachmentId,
            vlocityComponentIdList,
            isSeparateMatrixVersions,
            isSeparateCalculationProcedureVersions,
            isEnabledApexPostDeploy,
            isLWCActivation,
            apexCode
        );
    }

    public static String deployFromBranch(
        String orgId,
        String branchId,
        String metadataLogName,
        List<String> vlocityComponentIdList,
        Boolean isSeparateMatrixVersions,
        Boolean isSeparateCalculationProcedureVersions,
        Boolean isEnabledApexPostDeploy,
        Boolean isLWCActivation,
        String apexCode
    ) {
        if (String.isBlank(metadataLogName)) {
            List<Branch__c> branchList = [
                SELECT Branch_Name__c
                FROM Branch__c
                WHERE Id = :branchId
                WITH SECURITY_ENFORCED
            ];
            if (!branchList.isEmpty()) {
                metadataLogName = branchList.get(0).Branch_Name__c + ' ' + System.now().format('MM-dd-yyyy HH:mm:ss');
            }
        }

        VlocityService.VlocityLog vlocityLog = VlocityService.createLog(
            branchId,
            orgId,
            VLOCITY_DEPLOY_BRANCH,
            metadataLogName + ' (SFI)'
        );

        return privateDeployFromBranch(
            orgId,
            branchId,
            vlocityLog.metadataLogId,
            vlocityLog.logAttachmentId,
            vlocityComponentIdList,
            isSeparateMatrixVersions,
            isSeparateCalculationProcedureVersions,
            isEnabledApexPostDeploy,
            isLWCActivation,
            apexCode
        );
    }

    private static String privateDeployFromBranch(
        String orgId,
        String branchId,
        String metadataLogId,
        String logAttachmentId,
        List<String> vlocityComponentIdList,
        Boolean isSeparateMatrixVersions,
        Boolean isSeparateCalculationProcedureVersions,
        Boolean isEnabledApexPostDeploy,
        Boolean isLWCActivation,
        String apexCode
    ) {
        Map<String, Object> paramsMap = new Map<String, Object>();
        if (vlocityComponentIdList != null && !vlocityComponentIdList.isEmpty()) {
            paramsMap.put('vlocityComponentIdListJson', JSON.serialize(vlocityComponentIdList));
            createVlocityDeploymentResultRecords(orgId, vlocityComponentIdList, metadataLogId);
        } else {
            createVlocityDeploymentResultRecords(orgId, branchId, metadataLogId);
        }

        paramsMap.put('isSeparateMatrixVersions', isSeparateMatrixVersions);
        paramsMap.put('isSeparateCalculationProcedureVersions', isSeparateCalculationProcedureVersions);
        paramsMap.put('isEnabledApexPostDeploy', isEnabledApexPostDeploy);
        paramsMap.put('isLWCActivation', isLWCActivation);
        paramsMap.put('apexCode', apexCode);

        System.enqueueJob(
            new VlocityDeployFromBranchQueueable(
                VLOCITY_DEPLOY_BRANCH,
                VLOCITY_DEPLOY_BRANCH_URL,
                orgId,
                branchId,
                metadataLogId,
                logAttachmentId,
                JSON.serialize(paramsMap)
            )
        );

        return metadataLogId;
    }

    public static String rollback(
        String orgId,
        String branchId,
        String parentMetadataLogId,
        List<String> attachmentIdList,
        List<String> componentKeyList
    ) {
        String nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        if (nameSpacePrefix != '') {
            nameSpacePrefix += '__';
        }

        VlocityService.VlocityLog vlocityLog = VlocityService.createRollbackLog(branchId, orgId, parentMetadataLogId);

        System.enqueueJob(
            new VlocityRollbackQueueable(
                orgId,
                vlocityLog.metadataLogId,
                nameSpacePrefix,
                vlocityLog.logAttachmentId,
                JSON.serialize(attachmentIdList),
                JSON.serialize(componentKeyList)
            )
        );

        return vlocityLog.metadataLogId;
    }

    public static String rollback(
        String orgId,
        String branchId,
        String metadataLogId,
        String logAttachmentId,
        List<String> attachmentIdList
    ) {
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('attachmentIdList', JSON.serialize(attachmentIdList));

        String nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        if (nameSpacePrefix != '') {
            nameSpacePrefix += '__';
        }

        System.enqueueJob(
            new VlocityRollbackQueueable(
                orgId,
                metadataLogId,
                nameSpacePrefix,
                logAttachmentId,
                JSON.serialize(attachmentIdList)
            )
        );

        return metadataLogId;
    }

    private static void createVlocityDeploymentResultRecords(
        String orgId,
        List<String> vlocityComponentIdList,
        String metadataLogId
    ) {
        List<Component__c> componentList = [
            SELECT Id, Component_Name__c, Component_Type__c, Last_Modified_Date__c, Last_Updated_By__c
            FROM Component__c
            WHERE Id IN :vlocityComponentIdList
            WITH SECURITY_ENFORCED
        ];
        createDeploymentResultRecords(componentList, orgId, metadataLogId);
        createListOfComponentsAttachment(metadataLogId, componentList);
    }

    private static void createVlocityDeploymentResultRecords(String orgId, String branchId, String metadataLogId) {
        List<Component__c> componentList = [
            SELECT Id, Component_Name__c, Component_Type__c, Last_Modified_Date__c, Last_Updated_By__c
            FROM Component__c
            WHERE Branch__c = :branchId AND Vlocity_Component__c = TRUE
            WITH SECURITY_ENFORCED
        ];
        createDeploymentResultRecords(componentList, orgId, metadataLogId);
        createListOfComponentsAttachment(metadataLogId, componentList);
    }

    public static void createDeploymentResultRecords(
        List<Component__c> componentList,
        String orgId,
        String metadataLogId
    ) {
        List<Deployment_Result__c> deploymentResultList = new List<Deployment_Result__c>();
        for (Component__c component : componentList) {
            Deployment_Result__c deploymentResult = new Deployment_Result__c();
            deploymentResult.Metadata_Log__c = metadataLogId;
            deploymentResult.Org__c = orgId;
            deploymentResult.Component_Name__c = component.Component_Name__c;
            deploymentResult.Component_Type__c = component.Component_Type__c;
            deploymentResult.Last_Modified_Date__c = component.Last_Modified_Date__c;
            deploymentResult.Last_Updated_By__c = component.Last_Updated_By__c;
            deploymentResult.Type__c = 'Component';
            deploymentResult.Post_Deployment_Change__c = false;
            deploymentResultList.add(deploymentResult);
        }

        DatabaseUtils.insertRecords(
            deploymentResultList,
            new List<DescribeFieldResult>{
                Deployment_Result__c.Metadata_Log__c.getDescribe(),
                Deployment_Result__c.Org__c.getDescribe(),
                Deployment_Result__c.Component_Name__c.getDescribe(),
                Deployment_Result__c.Component_Type__c.getDescribe(),
                Deployment_Result__c.Last_Modified_Date__c.getDescribe(),
                Deployment_Result__c.Last_Updated_By__c.getDescribe(),
                Deployment_Result__c.Type__c.getDescribe(),
                Deployment_Result__c.Post_Deployment_Change__c.getDescribe()
            }
        );
    }

    public static void createListOfComponentsAttachment(String metadataLogId, List<Component__c> componentList) {
        Map<Id, Component__c> componentMap = new Map<Id, Component__c>(componentList);

        Attachment attachmentComponents = new Attachment();
        attachmentComponents.Body = Blob.valueOf(JSON.serialize(componentMap.keySet()));
        attachmentComponents.Name = 'List Components';
        attachmentComponents.Description = 'List Components';
        attachmentComponents.ParentId = metadataLogId;
        attachmentComponents.ContentType = 'text/plain';

        DatabaseUtils.insertRecord(
            attachmentComponents,
            new List<DescribeFieldResult>{
                Attachment.Body.getDescribe(),
                Attachment.ParentId.getDescribe(),
                Attachment.ContentType.getDescribe(),
                Attachment.Description.getDescribe()
            }
        );
    }

    @Future(Callout=true)
    public static void deploymentFuture(
        String deployType,
        String vlocityUrl,
        String orgId,
        String currentRecordId,
        String metadataLogId,
        String logAttachmentId,
        String paramsJSON
    ) {
        runDeploy(deployType, vlocityUrl, orgId, currentRecordId, metadataLogId, logAttachmentId, paramsJSON);
    }

    private static void runDeploy(
        String deployType,
        String vlocityUrl,
        String orgId,
        String currentRecordId,
        String metadataLogId,
        String logAttachmentId,
        String paramsJSON
    ) {
        Map<String, Object> paramsMap = (Map<String, Object>) JSON.deserializeUntyped(paramsJSON);
        Boolean isSandbox;

        List<Organization> organizationList = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        if (!organizationList.isEmpty()) {
            isSandbox = organizationList[0].IsSandbox;
        } else {
            isSandbox = false;
        }

        AuthDetails authFlosum = new AuthDetails();
        AuthDetails authVlocityOrg;
        if (Test.isRunningTest()) {
            authVlocityOrg = new AuthDetails('url', 'token');
        } else {
            AuthUtils.AuthenticateDetails auth = AuthUtils.authenticateAnOrg(orgId, FlosumConstants.DEVELOPER);
            if (auth.isSuccess) {
                authVlocityOrg = new AuthDetails(auth.details.InstanceURL__c, auth.details.AccessToken__c);
            } else {
                throw new FlosumException('Error on get vlocity org auth details' + auth.errorMessage);
            }
        }

        String nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        if (nameSpacePrefix != '') {
            nameSpacePrefix += '__';
        }

        String body;
        if (deployType == VLOCITY_DEPLOY_DEPLOYMENT) {
            ComponentVlocityDeploymentController.SnapshotIncomingData snapshotIncomingData = new ComponentVlocityDeploymentController.SnapshotIncomingData();
            snapshotIncomingData.nameSpacePrefix = nameSpacePrefix;
            snapshotIncomingData.deploymentId = currentRecordId;
            snapshotIncomingData.attachLogId = logAttachmentId;
            snapshotIncomingData.snapshotType = deployType;
            snapshotIncomingData.logId = metadataLogId;
            snapshotIncomingData.authFlosum = authFlosum;
            snapshotIncomingData.authVlosityOrg = authVlocityOrg;

            if (paramsMap.containsKey('isSeparateMatrixVersions')) {
                snapshotIncomingData.isSeparateMatrixVersions = (Boolean) paramsMap.get('isSeparateMatrixVersions');
            }

            if (paramsMap.containsKey('isSeparateCalculationProcedureVersions')) {
                snapshotIncomingData.isSeparateCalculationProcedureVersions = (Boolean) paramsMap.get(
                    'isSeparateCalculationProcedureVersions'
                );
            }

            if (paramsMap.containsKey('isLWCActivation')) {
                snapshotIncomingData.isLWCActivation = (Boolean) paramsMap.get('isLWCActivation');
            }

            if (paramsMap.containsKey('isEnabledApexPostDeploy')) {
                snapshotIncomingData.isEnabledApexPostDeploy = (Boolean) paramsMap.get('isEnabledApexPostDeploy');
                if (paramsMap.containsKey('apexCode')) {
                    snapshotIncomingData.apexCode = (String) paramsMap.get('apexCode');
                }
            }
            body = JSON.serialize(snapshotIncomingData);
        } else if (deployType == VLOCITY_DEPLOY_BRANCH) {
            ComponentBranchDeployController.BranchDataWrapper snapshotIncomingData = new ComponentBranchDeployController.BranchDataWrapper();
            snapshotIncomingData.nameSpacePrefix = nameSpacePrefix;
            snapshotIncomingData.branchId = currentRecordId;
            snapshotIncomingData.timestamp = String.valueOf(Datetime.now().getTime());
            snapshotIncomingData.attachLogId = logAttachmentId;
            snapshotIncomingData.snapshotType = deployType;
            snapshotIncomingData.logId = metadataLogId;
            snapshotIncomingData.flosumUrl = authFlosum.instanceUrl;
            snapshotIncomingData.vlocityUrl = authVlocityOrg.instanceUrl;
            snapshotIncomingData.vlocityToken = authVlocityOrg.accessToken;

            FlosumUtils.DevOpsConnectedAppCredentials credentials = FlosumUtils.getDevOpsConnectedAppCredentials();

            if (credentials.isClientCredentialsFlowEnabled) {
                snapshotIncomingData.clientId = credentials.clientId;
                snapshotIncomingData.clientSecret = credentials.clientSecret;
                snapshotIncomingData.flosumToken = EMPTY_ACCESS_TOKEN;
            } else {
                snapshotIncomingData.flosumToken = UserInfo.getSessionId();
            }

            if (paramsMap.containsKey('vlocityComponentIdListJson')) {
                List<String> vlocityComponentIdList = (List<String>) JSON.deserialize(
                    (String) paramsMap.get('vlocityComponentIdListJson'),
                    List<String>.class
                );

                snapshotIncomingData.componentsCount = vlocityComponentIdList.size();
                snapshotIncomingData.componentIdListJson = (String) paramsMap.get('vlocityComponentIdListJson');
            } else {
                Integer count = [
                    SELECT COUNT()
                    FROM Component__c
                    WHERE Branch__c = :currentRecordId AND Vlocity_Component__c = TRUE
                    WITH SECURITY_ENFORCED
                ];

                snapshotIncomingData.componentsCount = count;
            }

            if (paramsMap.containsKey('isSeparateMatrixVersions')) {
                snapshotIncomingData.isSeparateMatrixVersions = (Boolean) paramsMap.get('isSeparateMatrixVersions');
            }

            if (paramsMap.containsKey('isLWCActivation')) {
                snapshotIncomingData.isLWCActivation = (Boolean) paramsMap.get('isLWCActivation');
            }

            if (paramsMap.containsKey('isSeparateCalculationProcedureVersions')) {
                snapshotIncomingData.isSeparateCalculationProcedureVersions = (Boolean) paramsMap.get(
                    'isSeparateCalculationProcedureVersions'
                );
            }

            if (paramsMap.containsKey('isEnabledApexPostDeploy')) {
                snapshotIncomingData.isEnabledApexPostDeploy = (Boolean) paramsMap.get('isEnabledApexPostDeploy');
                if (paramsMap.containsKey('apexCode')) {
                    snapshotIncomingData.apexCode = (String) paramsMap.get('apexCode');
                }
            }
            body = JSON.serialize(snapshotIncomingData);
        }

        herokuRequest(vlocityUrl, body, metadataLogId);

        BranchActivityController.createDeploymentLog(metadataLogId);
    }

    @Future(Callout=true)
    public static void herokuRequestFuture(String url, String snapshotIncomingData, String logId) {
        herokuRequest(url, snapshotIncomingData, logId);
    }

    public static String runSimpleCommand(String currentRecordId, String processType, Map<String, Object> paramsMap) {
        initVlocityCommandsMap();
        if (vlocityCommandMap.containsKey(processType)) {
            return vlocityCommandMap.get(processType).runCommand(currentRecordId, processType, paramsMap);
        } else {
            throw new FlosumException('Command ' + processType + ' is not supported!');
        }
    }

    public static VlocitySimpleCommandsWrapper createVlocitySimpleCommandWrapper(
        String targetOrgId,
        String currentRecordId,
        String processType
    ) {
        VlocitySimpleCommandsWrapper simpleCommandsWrapper = new VlocitySimpleCommandsWrapper();

        AuthUtils.AuthenticateDetails auth = AuthUtils.authenticateAnOrg(targetOrgId, FlosumConstants.DEVELOPER);
        if (auth.isSuccess || Test.isRunningTest()) {
            simpleCommandsWrapper.vlocityUrl = auth.details.InstanceURL__c;
            simpleCommandsWrapper.vlocityToken = auth.details.AccessToken__c;
        } else {
            throw new FlosumException('Connect to Vlocity Org: ' + auth.errorMessage);
        }
        VlocityService.VlocityLog vlocityLog = VlocityService.createLog(currentRecordId, targetOrgId, processType);
        simpleCommandsWrapper.logId = vlocityLog.metadataLogId;
        simpleCommandsWrapper.attachLogId = vlocityLog.logAttachmentId;
        simpleCommandsWrapper.timestamp = Datetime.now().getTime() + '';
        simpleCommandsWrapper.flosumUrl = Url.getOrgDomainUrl().toExternalForm();

        simpleCommandsWrapper.nameSpacePrefix = getNamespacePrefix();
        simpleCommandsWrapper.snapshotType = processType;

        FlosumUtils.DevOpsConnectedAppCredentials credentials = FlosumUtils.getDevOpsConnectedAppCredentials();

        if (credentials.isClientCredentialsFlowEnabled) {
            simpleCommandsWrapper.clientId = credentials.clientId;
            simpleCommandsWrapper.clientSecret = credentials.clientSecret;
            simpleCommandsWrapper.flosumToken = EMPTY_ACCESS_TOKEN;
        } else {
            simpleCommandsWrapper.flosumToken = UserInfo.getSessionId();
        }

        return simpleCommandsWrapper;
    }

    public static String createPackRetryWrapper(
        VlocitySimpleCommandsWrapper vlocitySimpleCommandsWrapper,
        String snapshotId
    ) {
        VlocityPackRetryWrapper vlocityPackRetryWrapper = new VlocityPackRetryWrapper(vlocitySimpleCommandsWrapper);

        vlocityPackRetryWrapper.snapshotId = snapshotId;

        List<Attachment> attachmentList = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :snapshotId AND Name = 'Vlocity Temp'
            WITH SECURITY_ENFORCED
        ];

        if (!attachmentList.isEmpty()) {
            vlocityPackRetryWrapper.vlocityTempAttachmentId = attachmentList.get(0).Id;
        } else {
            throw new FlosumException('Vlocity Temp not found!');
        }
        return JSON.serialize(vlocityPackRetryWrapper);
    }

    private static String getNamespacePrefix() {
        String nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        if (nameSpacePrefix != '') {
            nameSpacePrefix += '__';
        }
        return nameSpacePrefix;
    }

    public static HttpRequest prepareRequest(String url, String snapshotIncomingData) {
        Vlocity_Credentials__c vlocityCred = getCredentials();
        return prepareRequest(vlocityCred, url, snapshotIncomingData);
    }

    public static HttpRequest prepareRequest(
        Vlocity_Credentials__c vlocityCred,
        String url,
        String snapshotIncomingData
    ) {
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:Vlocity_Heroku' + url);
        request.setMethod('POST');
        request.setBody(snapshotIncomingData);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(120000);

        if (vlocityCred?.Authorization_Method__c == 'Access Token') {
            Model.AccessTokenInfo accessToken = getAccessToken(vlocityCred);

            if (String.isNotBlank(accessToken?.access_token)) {
                request.setHeader('authorization', accessToken.access_token);
                request.setHeader('x-auth-method', 'AccessToken');
            }
        } else if (
            vlocityCred?.Authorization_Method__c == 'Basic' && String.isNotBlank(vlocityCred?.Salesforce_Token__c)
        ) {
            request.setHeader('authorization', vlocityCred.Salesforce_Token__c);
        }

        return request;
    }

    public static void herokuRequest(String url, String snapshotIncomingData, String logId) {
        try {
            HttpRequest request = prepareRequest(url, snapshotIncomingData);

            Http http = new Http();

            if (!Test.isRunningTest()) {
                HttpResponse response = http.send(request);

                if (response.getStatusCode() != 200) {
                    exceptionLog(response.getStatus(), logId);
                }
            }
        } catch (Exception e) {
            exceptionLog(e.getMessage(), logId);
        }
    }

    public static void exceptionLog(String message, String logId) {
        Metadata_Log__c log = new Metadata_Log__c(
            Job_Completed__c = true,
            Id = logId,
            Status__c = FlosumConstants.STATUS_EXCEPTION
        );

        DatabaseUtils.updateRecord(
            log,
            new List<DescribeFieldResult>{
                Metadata_Log__c.Job_Completed__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe()
            }
        );

        String retrievalLog = MetadataUtils.getTimeForLog() + ':  Error: ' + message + '.\n';

        List<Attachment> attachmentList = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :logId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!attachmentList.isEmpty()) {
            attachmentList[0].Body = Blob.valueOf(attachmentList[0].Body.toString() + retrievalLog);

            DatabaseUtils.updateRecords(attachmentList, new List<DescribeFieldResult>{ Attachment.Body.getDescribe() });
        }
    }

    public static VlocityLog createLog(
        String currentRecordId,
        String orgId,
        String processType,
        String deploymentName
    ) {
        Metadata_Log__c metadataLog = createMetadataLog(currentRecordId, orgId, processType);
        metadataLog.Deployment_Name__c = deploymentName;
        DatabaseUtils.insertRecord(
            metadataLog,
            new List<DescribeFieldResult>{
                Metadata_Log__c.Organisation__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Start_Date__c.getDescribe(),
                Metadata_Log__c.Patch__c.getDescribe(),
                Metadata_Log__c.Snapshot_Vlocity__c.getDescribe(),
                Metadata_Log__c.Process_Type__c.getDescribe()
            }
        );

        Attachment logAttachment = createAttachmentLog(metadataLog.Id, processType);
        return new VlocityLog(metadataLog.Id, logAttachment.Id, processType);
    }

    public static VlocityLog createRollbackLog(String currentRecordId, String orgId, String parentMetadataLogId) {
        String processType = VLOCITY_ROLLBACK;

        Metadata_Log__c metadataLog = createMetadataLog(currentRecordId, orgId, processType);
        metadataLog.Parent_Log__c = parentMetadataLogId;

        DatabaseUtils.insertRecord(
            metadataLog,
            new List<DescribeFieldResult>{
                Metadata_Log__c.Organisation__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Start_Date__c.getDescribe(),
                Metadata_Log__c.Patch__c.getDescribe(),
                Metadata_Log__c.Snapshot_Vlocity__c.getDescribe(),
                Metadata_Log__c.Process_Type__c.getDescribe(),
                Metadata_Log__c.Parent_Log__c.getDescribe()
            }
        );

        Attachment logAttachment = createAttachmentLog(metadataLog.Id, processType);

        return new VlocityLog(metadataLog.Id, logAttachment.Id, processType);
    }

    public static VlocityLog createLog(String currentRecordId, String orgId, String processType) {
        Metadata_Log__c metadataLog = createMetadataLog(currentRecordId, orgId, processType);
        DatabaseUtils.insertRecord(
            metadataLog,
            new List<DescribeFieldResult>{
                Metadata_Log__c.Organisation__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Start_Date__c.getDescribe(),
                Metadata_Log__c.Patch__c.getDescribe(),
                Metadata_Log__c.Snapshot_Vlocity__c.getDescribe(),
                Metadata_Log__c.Process_Type__c.getDescribe()
            }
        );

        Attachment logAttachment = createAttachmentLog(metadataLog.Id, processType);

        return new VlocityLog(metadataLog.Id, logAttachment.Id, processType);
    }

    public static Metadata_Log__c createMetadataLog(String currentRecordId, String orgId, String processType) {
        Metadata_Log__c metadataLog = new Metadata_Log__c(
            Organisation__c = orgId != null
                ? String.valueOf(Id.valueOf(orgId).getSobjectType()) == String.valueOf(Organisation__c.SObjectType)
                      ? orgId
                      : null
                : null,
            Status__c = FlosumConstants.STATUS_IN_PROGRESS,
            Start_Date__c = Datetime.now(),
            Process_Type__c = PROCESS_LABEL_MAP.get(processType)
        );

        if (processType == VLOCITY_DEPLOY) {
            metadataLog.Patch__c = currentRecordId;
        } else if (processType == VLOCITY_RETRIEVE || processType == VLOCITY_PACK_RETRY) {
            metadataLog.Snapshot_Vlocity__c = currentRecordId;
        } else if (
            processType == VLOCITY_DEPLOY_BRANCH ||
            processType == VLOCITY_SCHEDULE_DEPLOY_BRANCH ||
            processType == VLOCITY_ROLLBACK
        ) {
            metadataLog.Branch__c = currentRecordId;
        }
        metadataLog.Is_Vlocity__c = true;

        return metadataLog;
    }

    public static Attachment createAttachmentLog(String metadataLogId, String processType) {
        String retrievalLog = MetadataUtils.getTimeForLog() + ': ' + PROCESS_LABEL_MAP.get(processType) + ' started.\n';

        Attachment logAttachment = new Attachment();
        logAttachment.ContentType = 'text/plain';
        logAttachment.Name = 'Logs';
        logAttachment.Body = Blob.valueOf(retrievalLog);
        logAttachment.ParentId = metadataLogId;

        DatabaseUtils.insertRecord(
            logAttachment,
            new List<DescribeFieldResult>{
                Attachment.ContentType.getDescribe(),
                Attachment.Name.getDescribe(),
                Attachment.Body.getDescribe(),
                Attachment.ParentId.getDescribe()
            }
        );

        return logAttachment;
    }

    public static VlocityLog createLog(String metadataLogId, String processType) {
        List<Metadata_Log__c> metadataLogList = [
            SELECT Id
            FROM Metadata_Log__c
            WHERE Id = :metadataLogId
            WITH SECURITY_ENFORCED
        ];
        if (!metadataLogList.isEmpty()) {
            String retrievalLog;

            if (processType == VLOCITY_DEPLOY) {
                retrievalLog = MetadataUtils.getTimeForLog() + ':  Deploy Vlocity started.\n';
            } else if (processType == VLOCITY_RETRIEVE) {
                retrievalLog = MetadataUtils.getTimeForLog() + ':  Snapshot started.\n';
            }

            Attachment logAttachment = new Attachment();
            logAttachment.ContentType = 'text/plain';
            logAttachment.Name = 'Logs';
            logAttachment.Body = Blob.valueOf(retrievalLog);
            logAttachment.ParentId = metadataLogList.get(0).Id;

            DatabaseUtils.insertRecord(
                logAttachment,
                new List<DescribeFieldResult>{
                    Attachment.ContentType.getDescribe(),
                    Attachment.Name.getDescribe(),
                    Attachment.Body.getDescribe(),
                    Attachment.ParentId.getDescribe()
                }
            );

            return new VlocityLog(metadataLogList.get(0).Id, logAttachment.Id, processType);
        }

        return new VlocityLog();
    }

    public static HttpResponse getAccessTokenFlosumTest() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        Map<String, String> testResponse = new Map<String, String>{
            'instance_url' => 'InstURL',
            'access_token' => 'AccessToken'
        };
        response.setBody(JSON.serialize(testResponse));
        return response;
    }

    public static AuthDetails getAccessTokenFlosum(
        String loginUrl,
        String authCode,
        String consumerKey,
        String consumerSecret,
        String redirectUrl
    ) {
        AuthDetails authDetails;
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setEndpoint(loginUrl + '/services/oauth2/token');
            req.setBody(
                'grant_type=authorization_code&code=' +
                authCode +
                '&client_id=' +
                consumerKey +
                '&client_secret=' +
                consumerSecret +
                '&redirect_uri=' +
                redirectUrl
            );

            Http http = new Http();
            HttpResponse response = !Test.isRunningTest() ? http.send(req) : getAccessTokenFlosumTest();
            if (response.getStatusCode() == 200) {
                Map<String, String> authSettings = new Map<String, String>(
                    (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class)
                );

                authDetails = new AuthDetails(authSettings.get('instance_url'), authSettings.get('access_token'));
                authDetails.status = 'Success';
                return authDetails;
            } else {
                authDetails = new AuthDetails(
                    'Connect to Flosum: ' +
                    new Map<String, String>(
                            (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class)
                        )
                        .get('error_description')
                );

                authDetails.status = 'Error';
            }
            return authDetails;
        } catch (Exception e) {
            authDetails = new AuthDetails('Connect to Flosum: ' + e.getMessage());
            authDetails.status = 'Error';
            return authDetails;
        }
    }

    /**
     *  Returns Vlocity creds
     *  If there are several, returns the latest
     *  If does not exist returns null
     */
    public static Vlocity_Credentials__c getCredentials() {
        List<Vlocity_Credentials__c> vlocityCred = [
            SELECT
                Id,
                Access_Point__c,
                Access_Token__c,
                Authorization_Method__c,
                Certificate_Name__c,
                Access_Token_URL__c,
                Additional_Headers__c,
                Additional_Parameters__c,
                Client_Id__c,
                Client_Secret__c,
                OAuth_Key__c,
                Salesforce_Token__c,
                OAuth_Refresh_Key__c
            FROM Vlocity_Credentials__c
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];

        if (!vlocityCred.isEmpty()) {
            return vlocityCred.get(0);
        }

        return null;
    }

    public static Model.AccessTokenInfo getAccessToken(Vlocity_Credentials__c credentials) {
        HttpRequest request = new HttpRequest();

        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setTimeout(120000);
        request.setEndpoint(credentials.Access_Token_URL__c);
        request.setMethod('POST');

        String additionalParameters = String.isNotBlank(credentials.Additional_Parameters__c)
            ? '&' + credentials.Additional_Parameters__c
            : '';

        request.setBody(
            String.format(
                'grant_type=client_credentials&client_id={0}&client_secret={1}{2}',
                new List<Object>{ credentials.Client_Id__c, credentials.Client_Secret__c, additionalParameters }
            )
        );

        if (String.isNotBlank(credentials.Additional_Headers__c)) {
            HTTPService.addUserDefinedHeaders(request, credentials.Additional_Headers__c);
        }

        if (String.isNotBlank(credentials.Certificate_Name__c) && !Test.isRunningTest()) {
            request.setClientCertificateName(credentials.Certificate_Name__c);
        }

        try {
            HttpResponse httpResponse = HTTPService.serviceCall(request);

            if (httpResponse.getStatusCode() != 200) {
                throw new FlosumException(httpResponse.getBody());
            }

            return (Model.AccessTokenInfo) System.JSON.deserialize(httpResponse.getBody(), Model.AccessTokenInfo.class);
        } catch (Exception e) {
            if (e.getMessage().contains('please check Setup->Security->Remote site settings.')) {
                MetadataUtils.createRemoteSiteSettings(
                    credentials.Access_Token_URL__c,
                    'Vlocity' + Math.abs(credentials.Access_Token_URL__c.hashCode())
                );

                return getAccessToken(credentials);
            }

            throw e;
        }
    }

    public class VlocityLog {
        @AuraEnabled
        public String metadataLogId { get; set; }
        @AuraEnabled
        public String processType { get; set; }
        @AuraEnabled
        public String logAttachmentId { get; set; }

        public VlocityLog(String metadataLogId, String logAttachmentId, String processType) {
            this.metadataLogId = metadataLogId;
            this.logAttachmentId = logAttachmentId;
            this.processType = processType;
        }

        public VlocityLog() {
        }
    }

    public virtual class AuthDetails {
        public String status { get; set; }
        public String errorMessage { get; set; }
        public String instanceUrl { get; set; }
        public String accessToken { get; set; }
        public String clientId { get; set; }
        public String clientSecret { get; set; }

        public AuthDetails() {
            FlosumUtils.DevOpsConnectedAppCredentials credentials = FlosumUtils.getDevOpsConnectedAppCredentials();

            this.instanceUrl = credentials.instanceUrl;

            if (credentials.isClientCredentialsFlowEnabled) {
                this.clientId = credentials.clientId;
                this.clientSecret = credentials.clientSecret;
                this.accessToken = EMPTY_ACCESS_TOKEN;
            } else {
                this.accessToken = UserInfo.getSessionId();
            }
        }

        public AuthDetails(String instanceUrl, String accessToken) {
            this.instanceUrl = instanceUrl;
            this.accessToken = accessToken;
        }

        public AuthDetails(String errorMessage) {
            this.errorMessage = errorMessage;
        }
    }

    public class AvailableToExportBody extends AuthDetails {
        public Integer page { get; set; }

        public AvailableToExportBody(String instanceUrl, String accessToken) {
            super(instanceUrl, accessToken);
            page = 0;
        }

        public AvailableToExportBody(String instanceUrl, String accessToken, Integer page) {
            super(instanceUrl, accessToken);
            this.page = page;
        }
    }

    public class AvailableToExportJobBody extends AuthDetails {
        public String jobId { get; set; }

        public AvailableToExportJobBody(String instanceUrl, String accessToken, String jobId) {
            super(instanceUrl, accessToken);
            this.jobId = jobId;
        }
    }

    public class OverwriteVlocityBody extends AuthDetails {
        public List<String> componentNames;

        public OverwriteVlocityBody(String instanceUrl, String accessToken, List<String> componentNames) {
            super(instanceUrl, accessToken);
            this.componentNames = componentNames;
        }
    }

    public class OverwriteVlocityJobBody extends AuthDetails {
        public String asyncId { get; set; }
        public Integer countChunk { get; set; }

        public OverwriteVlocityJobBody(String instanceUrl, String accessToken, String asyncId) {
            super(instanceUrl, accessToken);
            this.asyncId = asyncId;
            this.countChunk = 0;
        }

        public OverwriteVlocityJobBody(String instanceUrl, String accessToken, String asyncId, Integer countChunk) {
            super(instanceUrl, accessToken);
            this.asyncId = asyncId;
            this.countChunk = countChunk;
        }
    }

    public virtual class VlocitySimpleCommandsWrapper {
        public String vlocityUrl { get; set; }
        public String vlocityToken { get; set; }
        public String attachLogId { get; set; }
        public String logId { get; set; }
        public String timestamp { get; set; }
        public String flosumUrl { get; set; }
        public String flosumToken { get; set; }
        public String clientId { get; set; }
        public String clientSecret { get; set; }
        public String nameSpacePrefix { get; set; }
        public String snapshotType { get; set; }
        public VlocitySimpleCommandsWrapper() {
        }
    }

    public class VlocityRollBackWrapper extends VlocitySimpleCommandsWrapper {
        public String attachmentIdList { get; set; }
        public String componentKeyList { get; set; }
    }

    public class VlocityPackRetryWrapper extends VlocitySimpleCommandsWrapper {
        public VlocityPackRetryWrapper(VlocitySimpleCommandsWrapper vlocitySimpleCommandsWrapper) {
            vlocityUrl = vlocitySimpleCommandsWrapper.vlocityUrl;
            vlocityToken = vlocitySimpleCommandsWrapper.vlocityToken;
            attachLogId = vlocitySimpleCommandsWrapper.attachLogId;
            logId = vlocitySimpleCommandsWrapper.logId;
            timestamp = vlocitySimpleCommandsWrapper.timestamp;
            flosumUrl = vlocitySimpleCommandsWrapper.flosumUrl;
            nameSpacePrefix = vlocitySimpleCommandsWrapper.nameSpacePrefix;
            snapshotType = vlocitySimpleCommandsWrapper.snapshotType;

            FlosumUtils.DevOpsConnectedAppCredentials credentials = FlosumUtils.getDevOpsConnectedAppCredentials();

            if (credentials.isClientCredentialsFlowEnabled) {
                clientId = credentials.clientId;
                clientSecret = credentials.clientSecret;
                flosumToken = EMPTY_ACCESS_TOKEN;
            } else {
                flosumToken = UserInfo.getSessionId();
            }
        }

        public VlocityPackRetryWrapper() {
        }

        public String vlocityTempAttachmentId;
        public String snapshotId;
    }

    interface IVlocityCommand {
        String runCommand(String currentRecordId, String processType, Map<String, Object> paramsMap);
    }

    public with sharing class PackRetryCommand implements IVlocityCommand {
        public String runCommand(String currentRecordId, String processType, Map<String, Object> paramsMap) {
            System.debug('--- currentRecordId ' + currentRecordId);
            System.debug('--- processType ' + processType);
            List<Snapshot_Vlocity__c> snapshotList = [
                SELECT Id, Org__c
                FROM Snapshot_Vlocity__c
                WHERE Id = :currentRecordId
                WITH SECURITY_ENFORCED
            ];

            if (!snapshotList.isEmpty()) {
                VlocitySimpleCommandsWrapper simpleCommandsWrapper = createVlocitySimpleCommandWrapper(
                    snapshotList.get(0).Org__c,
                    currentRecordId,
                    processType
                );
                String body = createPackRetryWrapper(simpleCommandsWrapper, currentRecordId);
                System.debug('--- body ' + body);

                VlocityService.herokuRequestFuture(
                    SUPPORTED_PROCESS_TYPES_URL.get(processType),
                    body,
                    simpleCommandsWrapper.logId
                );
                return simpleCommandsWrapper.logId;
            } else {
                throw new FlosumException('Snapshot not found!');
            }
        }
    }

    public class InstallVlocityInitialCommand implements IVlocityCommand {
        public String runCommand(String currentRecordId, String processType, Map<String, Object> paramsMap) {
            if (paramsMap.containsKey('targetOrgId')) {
                String targetOrgId = (String) paramsMap.get('targetOrgId');
                VlocitySimpleCommandsWrapper simpleCommandsWrapper = createVlocitySimpleCommandWrapper(
                    targetOrgId,
                    currentRecordId,
                    processType
                );

                VlocityService.herokuRequestFuture(
                    SUPPORTED_PROCESS_TYPES_URL.get(processType),
                    JSON.serialize(simpleCommandsWrapper),
                    simpleCommandsWrapper.logId
                );
                return simpleCommandsWrapper.logId;
            } else {
                throw new FlosumException('Target organization Id not found!');
            }
        }
    }

    class VlocityDeployFromBranchQueueable implements Queueable, Database.AllowsCallouts {
        private String deployType;
        private String vlocityUrl;
        private String orgId;
        private String currentRecordId;
        private String metadataLogId;
        private String logAttachmentId;
        private String paramsJSON;

        public VlocityDeployFromBranchQueueable(
            String deployType,
            String vlocityUrl,
            String orgId,
            String currentRecordId,
            String metadataLogId,
            String logAttachmentId,
            String paramsJSON
        ) {
            this.deployType = deployType;
            this.vlocityUrl = vlocityUrl;
            this.orgId = orgId;
            this.currentRecordId = currentRecordId;
            this.metadataLogId = metadataLogId;
            this.logAttachmentId = logAttachmentId;
            this.paramsJSON = paramsJSON;
        }

        public void execute(QueueableContext param1) {
            runDeploy(deployType, vlocityUrl, orgId, currentRecordId, metadataLogId, logAttachmentId, paramsJSON);
        }
    }

    class VlocityRollbackQueueable implements Queueable, Database.AllowsCallouts {
        private String targetOrganizationId;
        private String attachLogId;
        private String metadataLogId;
        private String attachmentIdList;
        private String nameSpacePrefix;
        private String componentKeyList;

        public VlocityRollbackQueueable(
            String targetOrganizationId,
            String metadataLogId,
            String nameSpacePrefix,
            String attachLogId,
            String attachmentIdList
        ) {
            this.targetOrganizationId = targetOrganizationId;
            this.metadataLogId = metadataLogId;
            this.nameSpacePrefix = nameSpacePrefix;
            this.attachLogId = attachLogId;
            this.attachmentIdList = attachmentIdList;
        }

        public VlocityRollbackQueueable(
            String targetOrganizationId,
            String metadataLogId,
            String nameSpacePrefix,
            String attachLogId,
            String attachmentIdList,
            String componentKeyList
        ) {
            this.targetOrganizationId = targetOrganizationId;
            this.metadataLogId = metadataLogId;
            this.nameSpacePrefix = nameSpacePrefix;
            this.attachLogId = attachLogId;
            this.attachmentIdList = attachmentIdList;
            this.componentKeyList = componentKeyList;
        }

        public void execute(QueueableContext param1) {
            AuthDetails authVlocityOrg;
            if (Test.isRunningTest()) {
                authVlocityOrg = new AuthDetails('url', 'token');
            } else {
                AuthUtils.AuthenticateDetails auth = AuthUtils.authenticateAnOrg(
                    targetOrganizationId,
                    FlosumConstants.DEVELOPER
                );

                if (auth.isSuccess) {
                    authVlocityOrg = new AuthDetails(auth.details.InstanceURL__c, auth.details.AccessToken__c);
                } else {
                    exceptionLog('Error on get vlocity org auth details ' + auth.errorMessage, metadataLogId);
                    throw new FlosumException('Error on get vlocity org auth details' + auth.errorMessage);
                }
            }

            VlocityRollBackWrapper vlocityRollBackWrapper = new VlocityRollBackWrapper();

            vlocityRollBackWrapper.componentKeyList = componentKeyList;
            vlocityRollBackWrapper.nameSpacePrefix = nameSpacePrefix;
            vlocityRollBackWrapper.timestamp = String.valueOf(Datetime.now().getTime());
            vlocityRollBackWrapper.attachLogId = attachLogId;
            vlocityRollBackWrapper.snapshotType = VLOCITY_ROLLBACK;
            vlocityRollBackWrapper.logId = metadataLogId;
            vlocityRollBackWrapper.flosumUrl = Url.getSalesforceBaseUrl().toExternalForm();
            vlocityRollBackWrapper.vlocityUrl = authVlocityOrg.instanceUrl;
            vlocityRollBackWrapper.vlocityToken = authVlocityOrg.accessToken;
            vlocityRollBackWrapper.attachmentIdList = attachmentIdList;

            FlosumUtils.DevOpsConnectedAppCredentials credentials = FlosumUtils.getDevOpsConnectedAppCredentials();

            if (credentials.isClientCredentialsFlowEnabled) {
                vlocityRollBackWrapper.clientId = credentials.clientId;
                vlocityRollBackWrapper.clientSecret = credentials.clientSecret;
                vlocityRollBackWrapper.flosumToken = EMPTY_ACCESS_TOKEN;
            } else {
                vlocityRollBackWrapper.flosumToken = UserInfo.getSessionId();
            }

            String body = JSON.serialize(vlocityRollBackWrapper);

            herokuRequest(PROCESS_ROLLBACK_VLOCITY_URL, body, metadataLogId);
        }
    }
}