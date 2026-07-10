public with sharing class MetadataLogScheduler implements Schedulable, Database.AllowsCallouts {
    private Id userId;
    private String lastMetadataLogId;
    private Boolean isContinue;
    private Set<String> supportedProcessType = new Set<String>{
        FlosumConstants.PROCESS_AUTOMATION_STEP,
        FlosumConstants.PROCESS_PEER_REVIEW,
        FlosumConstants.PROCESS_DEPLOYMENT,
        FlosumConstants.PROCESS_ROLLBACK,
        FlosumConstants.PROCESS_VALIDATE
    };
    private Set<String> agentProcessType = new Set<String>{
        FlosumConstants.PROCESS_DEPLOYMENT,
        FlosumConstants.PROCESS_ROLLBACK,
        FlosumConstants.PROCESS_VALIDATE
    };

    private List<MetadataLogWrapper> metadataLogsList = new List<MetadataLogWrapper>();

    private static final String SAVE_BACKUP_ZIP = 'SAVE_BACKUP_ZIP';
    private static final String GET_TESTS = 'GET_TESTS';
    private static final String ERROR = 'ERROR';
    private static final String SAVE_DEPLOY_ZIP = 'SAVE_DEPLOY_ZIP';
    private static final String DEPLOY = 'DEPLOY';

    public MetadataLogScheduler(Id userId) {
        this.userId = userId;
        this.lastMetadataLogId = null;
        this.isContinue = false;
    }

    public MetadataLogScheduler(Id userId, String lastMetadataLogId, Boolean isContinue) {
        this.userId = userId;
        this.lastMetadataLogId = lastMetadataLogId;
        this.isContinue = isContinue;
    }
    public void execute(SchedulableContext sc) {
        Boolean isContinueProcessing = false;
        List<Metadata_Log__c> metadataLogRecords = new List<Metadata_Log__c>();
        if (this.lastMetadataLogId != null) {
            metadataLogRecords = [
                SELECT
                    Id,
                    Job_Completed__c,
                    Succeed__c,
                    Status__c,
                    Branch__c,
                    Start_Date__c,
                    PipelineStepId__c,
                    CreatedDate,
                    Metadata_Types__c,
                    Automation_Completed__c,
                    CreatedById,
                    Process_Type__c,
                    Options__c,
                    Async_Request_Id__c,
                    Organisation__c,
                    Success_Log__c,
                    Error_Log__c,
                    PipelineStepId__r.Peer_Review_Options__c,
                    PipelineStepId__r.Options__c,
                    PipelineStepId__r.Automation_Type__c
                FROM Metadata_Log__c
                WHERE
                    CreatedById = :userId
                    AND Process_Type__c IN :supportedProcessType
                    AND PipelineStepId__c != NULL
                    AND Job_Completed__c = FALSE
                    AND Status__c = :FlosumConstants.STATUS_IN_PROGRESS
                    AND Id > :this.lastMetadataLogId
                WITH SECURITY_ENFORCED
                ORDER BY Id
                LIMIT 4
            ];
        } else {
            metadataLogRecords = [
                SELECT
                    Id,
                    Job_Completed__c,
                    Succeed__c,
                    Status__c,
                    Branch__c,
                    Start_Date__c,
                    PipelineStepId__c,
                    CreatedDate,
                    Metadata_Types__c,
                    Automation_Completed__c,
                    CreatedById,
                    Process_Type__c,
                    Options__c,
                    Async_Request_Id__c,
                    Organisation__c,
                    Success_Log__c,
                    Error_Log__c,
                    PipelineStepId__r.Peer_Review_Options__c,
                    PipelineStepId__r.Options__c,
                    PipelineStepId__r.Automation_Type__c
                FROM Metadata_Log__c
                WHERE
                    CreatedById = :userId
                    AND Process_Type__c IN :supportedProcessType
                    AND PipelineStepId__c != NULL
                    AND Job_Completed__c = FALSE
                    AND Status__c = :FlosumConstants.STATUS_IN_PROGRESS
                WITH SECURITY_ENFORCED
                ORDER BY Id
                LIMIT 4
            ];
        }

        if (metadataLogRecords.size() == 4) {
            isContinueProcessing = true;
            this.lastMetadataLogId = metadataLogRecords.get(3).Id;
        }

        Map<Id, List<Pull_Request_Reviewer__c>> pullRequestReviewerMap = new Map<Id, List<Pull_Request_Reviewer__c>>();
        Map<Id, Boolean> moveForwardPermissionMap = new Map<Id, Boolean>();
        Set<String> pullRequestIds = new Set<String>();
        Set<String> branchIds = new Set<String>();
        List<Metadata_Log__c> agentUpdateMetadataLogs = new List<Metadata_Log__c>();

        if (!metadataLogRecords.isEmpty()) {
            for (Metadata_Log__c metadataLog : metadataLogRecords) {
                if (metadataLog.Process_Type__c == FlosumConstants.PROCESS_PEER_REVIEW) {
                    branchIds.add(metadataLog.Branch__c);
                    pullRequestIds.add(metadataLog.Metadata_Types__c);
                }
            }
            for (Pull_Request_Reviewer__c pullRequestReviewer : [
                SELECT Id, Status__c, Pull_Request__c
                FROM Pull_Request_Reviewer__c
                WHERE Pull_Request__c IN :pullRequestIds AND (Status__c = 'Reject' OR Status__c = 'Approved')
                WITH SECURITY_ENFORCED
            ]) {
                if (pullRequestReviewerMap.containsKey(pullRequestReviewer.Pull_Request__c)) {
                    pullRequestReviewerMap.get(pullRequestReviewer.Pull_Request__c).add(pullRequestReviewer);
                } else {
                    List<Pull_Request_Reviewer__c> newListRequestReviewers = new List<Pull_Request_Reviewer__c>();
                    newListRequestReviewers.add(pullRequestReviewer);
                    pullRequestReviewerMap.put(pullRequestReviewer.Pull_Request__c, newListRequestReviewers);
                }
            }
            for (String branch : branchIds) {
                moveForwardPermissionMap.put(
                    branch,
                    MetadataUtils.allowUserToMoveForwardFromBranch(
                            branch,
                            FlosumConstants.PullRequestAddToDeploymentType
                        )
                        .isSuccess
                );
            }
            for (Metadata_Log__c metadataLog : metadataLogRecords) {
                Datetime startDateTime = metadataLog.Start_Date__c != null
                    ? metadataLog.Start_Date__c
                    : metadataLog.CreatedDate;
                if (metadataLog.Process_Type__c == FlosumConstants.PROCESS_PEER_REVIEW) {
                    List<Pull_Request_Reviewer__c> listReviewers = pullRequestReviewerMap.get(
                        metadataLog.Metadata_Types__c
                    );
                    Boolean isRejectReview = false;
                    Boolean isApproveReview = false;
                    if (pullRequestReviewerMap.get(metadataLog.Metadata_Types__c) != null) {
                        for (Pull_Request_Reviewer__c pullRequestReviewer : listReviewers) {
                            if (pullRequestReviewer.Status__c == 'Reject') {
                                isRejectReview = true;
                            }
                            if (pullRequestReviewer.Status__c == 'Approved') {
                                isApproveReview = true;
                            }
                        }
                    }

                    if (isRejectReview) {
                        this.metadataLogsList.add(
                            new MetadataLogWrapper(
                                metadataLog,
                                false,
                                'Selected user has rejected the peer review for this branch. Please address any issues raised and submit for peer review again.'
                            )
                        );
                    } else {
                        if (moveForwardPermissionMap.get(metadataLog.Branch__c) && isApproveReview) {
                            this.metadataLogsList.add(new MetadataLogWrapper(metadataLog, true, ''));
                        } else {
                            if (String.isNotBlank(metadataLog.PipelineStepId__r.Peer_Review_Options__c)) {
                                Model.PeerReviewOptions peerReviewOptionsObj = new Model.PeerReviewOptions();
                                peerReviewOptionsObj = (Model.PeerReviewOptions) JSON.deserialize(
                                    metadataLog.PipelineStepId__r.Peer_Review_Options__c,
                                    Model.PeerReviewOptions.class
                                );
                                if (
                                    System.now() >
                                    startDateTime.addDays(Integer.valueOf(peerReviewOptionsObj.estimateDays))
                                ) {
                                    this.metadataLogsList.add(
                                        new MetadataLogWrapper(
                                            metadataLog,
                                            false,
                                            'This Peer Review took more than ' +
                                                peerReviewOptionsObj.estimateDays +
                                                ' days.'
                                        )
                                    );
                                } else {
                                    this.isContinue = true;
                                }
                            } else {
                                this.metadataLogsList.add(
                                    new MetadataLogWrapper(
                                        metadataLog,
                                        false,
                                        'This Peer Review does not have estimate options.'
                                    )
                                );
                            }
                        }
                    }
                } else if (metadataLog.Process_Type__c == FlosumConstants.PROCESS_AUTOMATION_STEP) {
                    if (metadataLog.Automation_Completed__c) {
                        this.metadataLogsList.add(new MetadataLogWrapper(metadataLog, metadataLog.Succeed__c, ''));
                    } else {
                        if (String.isNotBlank(metadataLog.PipelineStepId__r.Options__c)) {
                            Model.AutomationOptions automationObj = new Model.AutomationOptions();
                            automationObj = (Model.AutomationOptions) JSON.deserialize(
                                metadataLog.PipelineStepId__r.Options__c,
                                Model.AutomationOptions.class
                            );
                            if (metadataLog.PipelineStepId__r.Automation_Type__c == 'Flosum Scan') {
                                startCheckingStatusFlosumScan(
                                    metadataLog.Branch__c,
                                    metadataLog.Id,
                                    automationObj.isQualityGate,
                                    automationObj.isTakeResultFlosumScan == null
                                        ? false
                                        : automationObj.isTakeResultFlosumScan,
                                    automationObj.flosumScanBugs,
                                    automationObj.flosumScanVulnerabilities,
                                    automationObj.flosumScanCodeSmells,
                                    automationObj.flosumScanBugsSeverity,
                                    automationObj.flosumScanVulnerabilitiesSeverity,
                                    automationObj.flosumScanCodeSmellsSeverity
                                );
                            }
                            Integer countPeriod = Integer.valueOf(automationObj.estimate.substringBefore(' '));
                            String typePeriod = automationObj.estimate.substringAfter(' ');
                            if (typePeriod.startsWith('day')) {
                                if (System.now() > startDateTime.addDays(countPeriod)) {
                                    this.metadataLogsList.add(
                                        new MetadataLogWrapper(
                                            metadataLog,
                                            false,
                                            'This Automation Step took more than ' +
                                                countPeriod +
                                                ' ' +
                                                typePeriod +
                                                '.'
                                        )
                                    );
                                } else {
                                    this.isContinue = true;
                                }
                            } else {
                                if (System.now() > startDateTime.addHours(countPeriod)) {
                                    this.metadataLogsList.add(
                                        new MetadataLogWrapper(
                                            metadataLog,
                                            false,
                                            'This Automation Step took more than ' +
                                                countPeriod +
                                                ' ' +
                                                typePeriod +
                                                '.'
                                        )
                                    );
                                } else {
                                    this.isContinue = true;
                                }
                            }
                        } else {
                            this.metadataLogsList.add(
                                new MetadataLogWrapper(
                                    metadataLog,
                                    false,
                                    'This Automation Step does not have estimate options.'
                                )
                            );
                        }
                    }
                } else if (
                    agentProcessType.contains(metadataLog.Process_Type__c) &&
                    metadataLog.Automation_Completed__c == false
                ) {
                    if (System.now() > startDateTime.addDays(2)) {
                        this.metadataLogsList.add(
                            new MetadataLogWrapper(
                                metadataLog,
                                false,
                                'This ' + metadataLog.Process_Type__c + ' took more than 2 days.'
                            )
                        );
                    } else {
                        MetadataUtils.Options opt = (MetadataUtils.Options) System.JSON.deserialize(
                            metadataLog.Options__c,
                            MetadataUtils.Options.class
                        );
                        if (opt != null && opt.isAgentPipeline != null && opt.isAgentPipeline == true) {
                            if (metadataLog.Success_Log__c == SAVE_BACKUP_ZIP) {
                                metadataLog.Success_Log__c = '';
                                agentUpdateMetadataLogs.add(metadataLog);
                                startSentToFlosumAgent(SAVE_BACKUP_ZIP, metadataLog.Id, '');
                                this.isContinue = true;
                            } else if (metadataLog.Success_Log__c == GET_TESTS) {
                                metadataLog.Success_Log__c = '';
                                agentUpdateMetadataLogs.add(metadataLog);
                                startSentToFlosumAgent(GET_TESTS, metadataLog.Id, '');
                                this.isContinue = true;
                            } else if (metadataLog.Success_Log__c == SAVE_DEPLOY_ZIP) {
                                if (opt.ids != null) {
                                    startSentToFlosumAgent(SAVE_DEPLOY_ZIP, metadataLog.Id, opt.ids);
                                    this.isContinue = true;
                                } else {
                                    this.metadataLogsList.add(
                                        new MetadataLogWrapper(
                                            metadataLog,
                                            false,
                                            'The Agent did not return the attachment deployment Id.'
                                        )
                                    );
                                }
                                metadataLog.Success_Log__c = '';
                                agentUpdateMetadataLogs.add(metadataLog);
                            } else if (metadataLog.Success_Log__c == DEPLOY) {
                                if (metadataLog.Async_Request_Id__c != null) {
                                    Datetime sysTime = System.now().addSeconds(25);
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
                                    List<String> unknownErrorInDeploy = new List<String>();
                                    System.schedule(
                                        'Self MergeDeploymentCheckStatusScheduled ' + sysTime.getTime(),
                                        chronExpression,
                                        new MetadataDeployController(
                                            metadataLog.Branch__c,
                                            metadataLog.Organisation__c,
                                            metadataLog.Id,
                                            'CHECK STATUS',
                                            unknownErrorInDeploy,
                                            null
                                        )
                                    );
                                    metadataLog.Automation_Completed__c = true;
                                    metadataLog.Success_Log__c = '';
                                    agentUpdateMetadataLogs.add(metadataLog);
                                } else {
                                    this.metadataLogsList.add(
                                        new MetadataLogWrapper(
                                            metadataLog,
                                            false,
                                            'The Agent did not return the deployment request Id.'
                                        )
                                    );
                                }
                            } else if (metadataLog.Success_Log__c == ERROR) {
                                metadataLog.Success_Log__c = '';
                                agentUpdateMetadataLogs.add(metadataLog);
                                this.metadataLogsList.add(
                                    new MetadataLogWrapper(metadataLog, false, metadataLog.Error_Log__c)
                                );
                            } else {
                                this.isContinue = true;
                            }
                        }
                    }
                }
            }
        }

        List<Metadata_Log__c> logsForUpdate = new List<Metadata_Log__c>();
        List<Attachment> errorAttachments = new List<Attachment>();
        for (MetadataLogWrapper metaWrapper : this.metadataLogsList) {
            metaWrapper.metadataLog.Job_Completed__c = true;
            metaWrapper.metadataLog.Succeed__c = metaWrapper.isSuccess;
            metaWrapper.metadataLog.Status__c = FlosumConstants.STATUS_COMPLETED;
            metaWrapper.metadataLog.Completed_Date__c = Datetime.now();
            logsForUpdate.add(metaWrapper.metadataLog);
            if (!metaWrapper.isSuccess && metaWrapper.message != '') {
                Attachment attError = new Attachment(
                    ParentId = metaWrapper.metadataLog.Id, // attach error log to metadata log
                    Name = metaWrapper.metadataLog.Process_Type__c + ' Error Log',
                    Body = Blob.valueOf('ERROR: ' + metaWrapper.message),
                    ContentType = 'text/plain'
                );
                errorAttachments.add(attError);
            }
        }
        if (!logsForUpdate.isEmpty()) {
            DatabaseUtils.updateRecords(
                logsForUpdate,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe(),
                    Metadata_Log__c.Completed_Date__c.getDescribe(),
                    Metadata_Log__c.Succeed__c.getDescribe()
                }
            );
        }
        if (!agentUpdateMetadataLogs.isEmpty()) {
            DatabaseUtils.updateRecords(
                agentUpdateMetadataLogs,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Automation_Completed__c.getDescribe(),
                    Metadata_Log__c.Success_Log__c.getDescribe()
                }
            );
        }
        if (!errorAttachments.isEmpty()) {
            DatabaseUtils.insertRecords(
                errorAttachments,
                new List<Schema.DescribeFieldResult>{
                    Attachment.ParentId.getDescribe(),
                    Attachment.Name.getDescribe(),
                    Attachment.Body.getDescribe(),
                    Attachment.ContentType.getDescribe()
                }
            );
        }

        System.abortJob(sc.getTriggerId());
        if (isContinueProcessing) {
            Datetime sysTime = System.now().addSeconds(20);
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
                'MetadataLogScheduler' + this.userId,
                cronExpression,
                new MetadataLogScheduler(this.userId, this.lastMetadataLogId, this.isContinue)
            );
        } else if (this.isContinue) {
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
            System.schedule(
                'MetadataLogScheduler' + this.userId,
                cronExpression,
                new MetadataLogScheduler(this.userId)
            );
        }
    }
    @future(callout=true)
    public static void startSentToFlosumAgent(String operation, String metadataLogId, String attachmentId) {
        if (operation == SAVE_BACKUP_ZIP) {
            MetadataUtils.checkTestClassesPipeline(metadataLogId);
        } else if (operation == GET_TESTS) {
            MetadataUtils.checkEnvVarPipeline(metadataLogId);
        } else if (operation == SAVE_DEPLOY_ZIP) {
            MetadataUtils.sentDeployZipToFlosumAgent(metadataLogId, attachmentId, '');
        }
    }

    @future(callout=true)
    public static void startCheckingStatusFlosumScan(
        Id branchId,
        Id metadataLogId,
        Boolean isQualityGate,
        Boolean isTakeResultFlosumScan,
        String flosumScanBugs,
        String flosumScanVulnerabilities,
        String flosumScanCodeSmells,
        String flosumScanBugsSeverity,
        String flosumScanVulnerabilitiesSeverity,
        String flosumScanCodeSmellsSeverity
    ) {
        Map<String, String> result = new Map<String, String>();

        try {
            BaseIntegration integration = (BaseIntegration) Type.forName(
                    AbstractAuthentication.FLOSUM_SCAN_PACKAGE_PREFIX,
                    'AnalyseBranchIntegration'
                )
                .newInstance();
            Map<String, Object> parameters = new Map<String, Object>{
                'branchId' => branchId,
                'metadataLogId' => metadataLogId,
                'bugs' => getSeverityList(flosumScanBugsSeverity),
                'vulnerabilities' => getSeverityList(flosumScanVulnerabilitiesSeverity),
                'codeSmells' => getSeverityList(flosumScanCodeSmellsSeverity)
            };
            result = (Map<String, String>) integration.getResult(parameters);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        if (result != null) {
            List<Metadata_Log__c> metadataLogRecord = [
                SELECT Id, Branch__c, Succeed__c, Automation_Completed__c
                FROM Metadata_Log__c
                WHERE Id = :metadataLogId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (isTakeResultFlosumScan) {
                if (result.isEmpty() || result.get('resultBugs') == 'null' || result.get('resultBugs') == null) {
                    String resultExecute;
                    try {
                        BaseIntegration integrationExecute = (BaseIntegration) Type.forName(
                                AbstractAuthentication.FLOSUM_SCAN_PACKAGE_PREFIX,
                                'AnalyseBranchIntegration'
                            )
                            .newInstance();
                        resultExecute = (String) integrationExecute.execute(branchId);
                        if (
                            resultExecute == FlosumConstants.NOT_SELECTED_TYPES ||
                            resultExecute == FlosumConstants.NOT_COMPONENTS_IN_BRANCH
                        ) {
                            metadataLogRecord[0].Succeed__c = true;
                            metadataLogRecord[0].Automation_Completed__c = true;
                            DatabaseUtils.updateRecord(
                                metadataLogRecord[0],
                                new List<Schema.DescribeFieldResult>{
                                    Metadata_Log__c.Automation_Completed__c.getDescribe(),
                                    Metadata_Log__c.Succeed__c.getDescribe()
                                }
                            );
                            createLog(metadataLogRecord[0].Id, 'Flosum Scan Log', resultExecute);
                        }
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                        metadataLogRecord[0].Succeed__c = false;
                        metadataLogRecord[0].Automation_Completed__c = true;
                        DatabaseUtils.updateRecord(
                            metadataLogRecord[0],
                            new List<Schema.DescribeFieldResult>{
                                Metadata_Log__c.Automation_Completed__c.getDescribe(),
                                Metadata_Log__c.Succeed__c.getDescribe()
                            }
                        );
                        createLog(metadataLogRecord[0].Id, 'Flosum Scan Error Log', 'Error: ' + e.getMessage());
                    }
                } else {
                    processResult(
                        result,
                        metadataLogRecord[0],
                        isQualityGate,
                        flosumScanBugs,
                        flosumScanVulnerabilities,
                        flosumScanCodeSmells
                    );
                }
            } else {
                processResult(
                    result,
                    metadataLogRecord[0],
                    isQualityGate,
                    flosumScanBugs,
                    flosumScanVulnerabilities,
                    flosumScanCodeSmells
                );
            }
        }
    }

    public static void processResult(
        Map<String, String> result,
        Metadata_Log__c metadataLog,
        Boolean isQualityGate,
        String flosumScanBugs,
        String flosumScanVulnerabilities,
        String flosumScanCodeSmells
    ) {
        Boolean isSuccess = false;
        String message = '';
        if (isQualityGate) {
            String resultQualityGate = result.get('qualityGateStatus');
            if (String.isNotEmpty(resultQualityGate) && resultQualityGate != 'ERROR') {
                isSuccess = true;
                message = 'The Flosum Scan Quality Gate result: ' + result.get('qualityGateStatus');
            } else {
                String newReliability = result.get('new_reliability_rating') != null
                    ? '\nReliability rating: ' + result.get('new_reliability_rating')
                    : '';
                String newSecurity = result.get('new_security_rating') != null
                    ? '\nSecurity rating: ' + result.get('new_security_rating')
                    : '';
                String newMaintainability = result.get('new_maintainability_rating') != null
                    ? '\nMaintainability rating: ' + result.get('new_maintainability_rating')
                    : '';
                String newCoverage = result.get('new_coverage') != null
                    ? '\nCoverage: ' + result.get('new_coverage')
                    : '';
                String newDuplicated = result.get('new_duplicated_lines_density') != null
                    ? '\nDuplicated lines density: ' + result.get('new_duplicated_lines_density')
                    : '';
                String newSecurityHotspots = result.get('new_security_hotspots_reviewed') != null
                    ? '\nSecurity hotspots reviewed: ' + result.get('new_security_hotspots_reviewed')
                    : '';
                message =
                    'The Flosum Scan result does not match the Quality Gate.' +
                    '\nQuality Gate Status: ' +
                    result.get('qualityGateStatus') +
                    newReliability +
                    newSecurity +
                    newMaintainability +
                    newCoverage +
                    newDuplicated +
                    newSecurityHotspots;
            }
        } else {
            isSuccess =
                isSuccessResult(flosumScanBugs, result.get('resultBugs')) &&
                isSuccessResult(flosumScanVulnerabilities, result.get('resultVulnerability')) &&
                isSuccessResult(flosumScanCodeSmells, result.get('resultCodeSmell'));
            if (!isSuccess) {
                message =
                    'The Flosum Scan result does not match the specified parameters:\n' +
                    'Bugs: ' +
                    result.get('resultBugs') +
                    '.\nVulnerabilities: ' +
                    result.get('resultVulnerability') +
                    '.\nCode Smells: ' +
                    result.get('resultCodeSmell');
            } else {
                message =
                    'The Flosum Scan result:\n' +
                    'Bugs: ' +
                    result.get('resultBugs') +
                    '.\nVulnerabilities: ' +
                    result.get('resultVulnerability') +
                    '.\nCode Smells: ' +
                    result.get('resultCodeSmell');
            }
        }
        try {
            Integer countIssues = 0;
            if (String.isNotBlank(result.get('resultBugs'))) {
                countIssues += Integer.valueOf(result.get('resultBugs'));
            }
            if (String.isNotBlank(result.get('resultVulnerability'))) {
                countIssues += Integer.valueOf(result.get('resultVulnerability'));
            }
            if (String.isNotBlank(result.get('resultCodeSmell'))) {
                countIssues += Integer.valueOf(result.get('resultCodeSmell'));
            }
            List<Branch__c> branches = [
                SELECT Id, Branch_Name__c, Repository__c, Repository_Type__c, Repository__r.Name
                FROM Branch__c
                WHERE Id = :metadataLog.Branch__c
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            Map<String, String> properties = new Map<String, String>{
                'type' => 'Flosum Scan',
                'trigger_source' => 'Pipeline',
                'count_issues' => !isQualityGate ? String.valueOf(countIssues) : '',
                'result' => isSuccess ? 'Success' : 'Failed',
                'branch_id' => branches.get(0).Id,
                'branch_name' => branches.get(0).Branch_Name__c,
                'repository_id' => branches.get(0).Repository__c,
                'repository_name' => branches.get(0).Repository__r.Name,
                'repository_type' => String.isNotBlank(branches.get(0).Repository_Type__c)
                    ? branches.get(0).Repository_Type__c
                    : 'Metadata'
            };

            List<AnalyticsService.AnalyticsEvent> events = new List<AnalyticsService.AnalyticsEvent>();
            AnalyticsService.AnalyticsEvent event = new AnalyticsService.AnalyticsEvent('Code Scan', properties);
            events.add(event);
            AnalyticsService.scheduleAnalytics(events);
        } catch (Exception e) {
        }

        metadataLog.Succeed__c = isSuccess;
        metadataLog.Automation_Completed__c = true;
        DatabaseUtils.updateRecord(
            metadataLog,
            new List<Schema.DescribeFieldResult>{
                Metadata_Log__c.Automation_Completed__c.getDescribe(),
                Metadata_Log__c.Succeed__c.getDescribe()
            }
        );
        if (!isSuccess) {
            createLog(metadataLog.Id, 'Flosum Scan Error Log', message);
        } else {
            createLog(metadataLog.Id, 'Flosum Scan Log', message);
        }
    }

    public static String getSeverityList(String severity) {
        List<String> severityList = new List<String>();
        if (String.isNotBlank(severity)) {
            List<String> severityTypeList = new List<String>{ 'Info', 'Minor', 'Major', 'Critical', 'Blocker' };
            Integer indexSeverity = severityTypeList.indexOf(severity);
            for (Integer indexKey = indexSeverity; indexKey < severityTypeList.size(); indexKey++) {
                severityList.add(severityTypeList.get(indexKey).toUpperCase());
            }
        } else {
            severityList.add('INFO');
        }

        return String.join(severityList, ',');
    }

    public static Boolean isSuccessResult(String limitValue, String resultValue) {
        if (String.isBlank(limitValue)) {
            return true;
        }
        if (
            String.isNotBlank(resultValue) &&
            String.isNotBlank(limitValue) &&
            Integer.valueOf(resultValue) <= Integer.valueOf(limitValue)
        ) {
            return true;
        }
        return false;
    }

    public static void createLog(Id metadataLogId, String name, String message) {
        Attachment att = new Attachment(
            ParentId = metadataLogId, // attach error log to metadata log
            Name = name,
            Body = Blob.valueOf(message),
            ContentType = 'text/plain'
        );
        DatabaseUtils.insertRecord(
            att,
            new List<Schema.DescribeFieldResult>{
                Attachment.ParentId.getDescribe(),
                Attachment.Name.getDescribe(),
                Attachment.Body.getDescribe(),
                Attachment.ContentType.getDescribe()
            }
        );
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class MetadataLogWrapper {
        public Metadata_Log__c metadataLog;
        public String message;
        public Boolean isSuccess;

        public MetadataLogWrapper(Metadata_Log__c metadataLog, Boolean isSuccess, String msg) {
            this.metadataLog = metadataLog;
            this.message = msg;
            this.isSuccess = isSuccess;
        }
    }
}