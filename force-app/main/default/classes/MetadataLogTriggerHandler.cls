public with sharing class MetadataLogTriggerHandler {
    public void collectSnapRecordIds(List<Metadata_Log__c> logLi) {
        Set<String> snapIds = new Set<String>();
        for (Metadata_Log__c log : logLi) {
            snapIds.add(log.Snapshot__c);
        }
        if (snapIds.size() > 0) {
            Set<String> snapIdSet = new Set<String>();

            for (Snapshot__c snap : [
                SELECT
                    Id,
                    (
                        SELECT Id
                        FROM Metadata_Logs__r
                        WHERE
                            Job_Completed__c = TRUE
                            AND (Process_Type__c = :FlosumConstants.PROCESS_SNAPSHOT_LOG_APEX
                            OR Process_Type__c = :FlosumConstants.PROCESS_SNAPSHOT_LOG_JS)
                        LIMIT 2
                    )
                FROM Snapshot__c
                WHERE Id IN :snapIds
                WITH SECURITY_ENFORCED
            ]) {
                if (snap.Metadata_Logs__r != null && snap.Metadata_Logs__r.size() == 2) {
                    snapIdSet.add(snap.Id);
                }
            }
            if (snapIdSet.size() > 0)
                updateSnapRecord(snapIdSet);
        }
    }

    //@future
    public void updateSnapRecord(Set<String> snapIdSet) {
        List<Snapshot__c> snapLi = new List<Snapshot__c>();

        for (Snapshot__c snap : [
            SELECT Id, Apex_Is_Completed__c, JS_Is_Completed__c
            FROM Snapshot__c
            WHERE Id IN :snapIdSet
            WITH SECURITY_ENFORCED
        ]) {
            snap.Apex_Is_Completed__c = true;
            snap.JS_Is_Completed__c = true;
            snapLi.add(snap);
        }
        if (snapLi.size() > 0) {
            DatabaseUtils.updateRecords(
                snapLi,
                new List<Schema.DescribeFieldResult>{
                    Snapshot__c.Apex_Is_Completed__c.getDescribe(),
                    Snapshot__c.JS_Is_Completed__c.getDescribe()
                }
            );
        }
    }

    public void updateDeploymentHistory(List<Metadata_Log__c> logLi) {
        Set<String> orgSet = new Set<String>();
        Set<String> patchSet = new Set<String>();
        Map<String, Metadata_Log__c> logMap = new Map<String, Metadata_Log__c>();
        for (Metadata_Log__c log : logLi) {
            orgSet.add(log.Organisation__c);
            patchSet.add(log.Patch__c);
            logMap.put(log.Id, log);
        }
        List<Patch_Application__c> updateList = new List<Patch_Application__c>();

        for (Patch_Application__c app : [
            SELECT ID, Deployment_URL__c, Patch__c, Succeed__c
            FROM Patch_Application__c
            WHERE Patch__c IN :patchSet AND Org__c IN :orgSet
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 10000
        ]) {
            for (String logId : logMap.keySet()) {
                if (app.Deployment_URL__c != null && app.Deployment_URL__c.indexOf(logId) > -1) {
                    app.Succeed__c = logMap.get(logId).Succeed__c;
                    app.Job_Completed__c = true;
                    updateList.add(app);
                }
            }
        }
        if (updateList.size() > 0) {
            DatabaseUtils.updateRecords(
                updateList,
                new List<Schema.DescribeFieldResult>{
                    Patch_Application__c.Succeed__c.getDescribe(),
                    Patch_Application__c.Job_Completed__c.getDescribe()
                }
            );
        }
    }

    public class Options {
        public String CIStyle;
        public String targetId;
        public String pipeExec;
        public String mergeSetName;
        public String manualStepId;
        public String branchRecordType;
        public Boolean isAgentPipeline;
    }

    public void analyticsTrack(List<Metadata_Log__c> newList, Map<Id, Metadata_Log__c> oldMap) {
        try {
            List<AnalyticsService.AnalyticsEvent> events = new List<AnalyticsService.AnalyticsEvent>();
            List<Id> completedMdlIds = new List<Id>();
            Set<String> excludeAnalytics = new Set<String>{
                'Retrieval Log(JS)',
                'Retrieval Log(Apex)',
                'PreDeploy Fix',
                'Tracking Organization - Retrieve',
                'Overwrite Protection'
            };
            for (Metadata_Log__c mdl : newList) {
                Metadata_Log__c oldLog = oldMap.get(mdl.Id);
                if (
                    (oldLog.Job_Completed__c != mdl.Job_Completed__c ||
                    mdl.Process_Type__c == 'Test Execution Job') &&
                    mdl.Job_Completed__c == true &&
                    mdl.Status__c != FlosumConstants.STATUS_DID_NOT_RUN &&
                    mdl.Status__c != FlosumConstants.STATUS_IN_PROGRESS &&
                    !excludeAnalytics.contains(mdl.Process_Type__c)
                ) {
                    completedMdlIds.add(mdl.Id);
                }
            }

            Map<Id, Metadata_Log__c> logMap = new Map<Id, Metadata_Log__c>(
                [
                    SELECT
                        Branch__c,
                        Branch__r.Branch_Name__c,
                        Branch__r.Repository_Type__c,
                        Branch__r.Repository__c,
                        Branch__r.Repository__r.Name,
                        Total_Items__c,
                        Organisation__r.Organisation_ID__c,
                        Organisation__r.Name,
                        Organisation__r.Organisation_Type__c,
                        Process_Type__c,
                        PipelineStepId__r.Automation_Type__c,
                        Status__c,
                        Is_Error__c,
                        Succeed__c
                    FROM Metadata_Log__c
                    WHERE Id IN :completedMdlIds
                    WITH SECURITY_ENFORCED
                ]
            );

            List<Deployment_Result__c> deploymentResults = [
                SELECT Id, Type__c, Status__c, Metadata_Log__c
                FROM Deployment_Result__c
                WHERE
                    Metadata_Log__c IN :logMap.keySet()
                    AND (Type__c IN ('Component', 'Descriptive Changes', 'Destructive Changes')
                    OR (Type__c = 'Deployment Result'
                    AND Status__c = 'Failure'))
                WITH SECURITY_ENFORCED
                LIMIT 49500
            ];

            Map<Id, Map<String, Integer>> countsByLog = new Map<Id, Map<String, Integer>>();
            for (Id logId : logMap.keySet()) {
                countsByLog.put(
                    logId,
                    new Map<String, Integer>{ 'components' => 0, 'destructiveChanges' => 0, 'failed' => 0 }
                );
            }
            for (Deployment_Result__c dr : deploymentResults) {
                Id logId = dr.Metadata_Log__c;
                if (!countsByLog.containsKey(logId)) {
                    countsByLog.put(
                        logId,
                        new Map<String, Integer>{ 'components' => 0, 'destructiveChanges' => 0, 'failed' => 0 }
                    );
                }

                Map<String, Integer> counters = countsByLog.get(logId);

                if (dr.Type__c == 'Component') {
                    counters.put('components', counters.get('components') + 1);
                } else if (dr.Type__c == 'Destructive Changes') {
                    counters.put('destructiveChanges', counters.get('destructiveChanges') + 1);
                } else if (dr.Type__c == 'Deployment Result' && dr.Status__c == 'Failure') {
                    counters.put('failed', counters.get('failed') + 1);
                }
            }

            for (Id logId : logMap.keySet()) {
                Metadata_Log__c mdl = logMap.get(logId);
                String eventName = mdl.Process_Type__c;
                Map<String, String> properties = new Map<String, String>();
                switch on mdl.Process_Type__c {
                    when 'Automation Step' {
                        if (
                            mdl.PipelineStepId__r.Automation_Type__c != 'ApexPMD' &&
                            mdl.PipelineStepId__r.Automation_Type__c != 'Flosum Scan'
                        ) {
                            String status = mdl.Succeed__c ? 'Success' : 'Failed';
                            properties = new Map<String, String>{
                                'automation_type' => mdl.PipelineStepId__r.Automation_Type__c,
                                'status' => status
                            };
                            AnalyticsService.AnalyticsEvent event = new AnalyticsService.AnalyticsEvent(
                                eventName,
                                properties
                            );
                            events.add(event);
                        }
                    }
                    when 'Execute Apex',
                        'WebHook',
                        'Manual Step',
                        'Lock Branch',
                        'Unlock Branch',
                        'Change Branch Record Type',
                        'Pause' {
                        String status = mdl.Succeed__c ? 'Success' : 'Failed';
                        properties = new Map<String, String>{ 'status' => status };
                        AnalyticsService.AnalyticsEvent event = new AnalyticsService.AnalyticsEvent(
                            eventName,
                            properties
                        );
                        events.add(event);
                    }
                    when 'Deployment',
                        'Validate',
                        'Rollback',
                        'Schedule Deployment',
                        'Deploy B2C',
                        'Validate B2C',
                        'Rollback (Validate)',
                        'Rollback (Deployment)',
                        'Veeva Rollback (Deployment)',
                        'Veeva Deployment',
                        'Deployment (SFI)',
                        'Rollback (Deployment SFI)',
                        'Schedule Deployment (SFI)',
                        'MC Deploy',
                        'Commerce Cloud Deployment' {
                        switch on mdl.Process_Type__c {
                            when 'Deployment',
                                'Schedule Deployment',
                                'Deploy B2C',
                                'Veeva Deployment',
                                'Deployment (SFI)',
                                'Schedule Deployment (SFI)',
                                'MC Deploy',
                                'Commerce Cloud Deployment' {
                                eventName = 'Deploy';
                            }
                            when 'Validate', 'Validate B2C' {
                                eventName = 'Validate';
                            }
                            when 'Rollback',
                                'Rollback (Validate)',
                                'Rollback (Deployment)',
                                'Veeva Rollback (Deployment)',
                                'Rollback (Deployment SFI)' {
                                eventName = 'Rollback';
                            }
                        }

                        String status = !mdl.Succeed__c ? 'Failed' : (mdl.Is_Error__c ? 'Partial' : 'Success');
                        String triggerSource = String.isNotBlank(mdl.PipelineStepId__c)
                            ? 'Pipeline'
                            : (mdl.Process_Type__c.contains('Schedule') ? 'Scheduled' : 'Manual');
                        properties = new Map<String, String>{
                            'type' => mdl.Process_Type__c,
                            'trigger_source' => triggerSource,
                            'count_components' => String.valueOf(countsByLog.get(mdl.Id).get('components')),
                            'count_destructive_changes' => String.valueOf(
                                countsByLog.get(mdl.Id).get('destructiveChanges')
                            ),
                            //'count_failed_components' => String.valueOf(countsByLog.get(mdl.Id).get('failed')),
                            'status' => status,
                            'branch_id' => mdl.Branch__c,
                            'branch_name' => mdl.Branch__r.Branch_Name__c,
                            'repository_id' => mdl.Branch__r.Repository__c,
                            'repository_name' => mdl.Branch__r.Repository__r.Name,
                            'repository_type' => String.isNotBlank(mdl.Branch__r.Repository_Type__c)
                                ? mdl.Branch__r.Repository_Type__c
                                : 'Metadata',
                            'organization_id' => mdl.Organisation__r.Organisation_ID__c,
                            'organization_name' => mdl.Organisation__r.Name,
                            'organization_type' => mdl.Organisation__r.Organisation_Type__c
                        };

                        AnalyticsService.AnalyticsEvent event = new AnalyticsService.AnalyticsEvent(
                            eventName,
                            properties
                        );
                        events.add(event);
                    }
                }
            }

            if (!events.isEmpty()) {
                if (Limits.getQueueableJobs() >= 1) {
                    AnalyticsService.scheduleAnalytics(events);
                } else {
                    System.enqueueJob(new AnalyticsQueueable(events));
                }
            }
        } catch (Exception e) {
        }
    }

    public void checkUpdateStatus(List<Metadata_Log__c> logLi, Map<Id, Metadata_Log__c> logLiOldMap) {
        List<PipelineStepsResult__c> listResults = new List<PipelineStepsResult__c>();
        for (Metadata_Log__c mdl : logLi) {
            Metadata_Log__c oldLog = logLiOldMap.get(mdl.Id);
            Boolean isMetadataLogCompletedAndHasPipeline =
                oldLog.Job_Completed__c != mdl.Job_Completed__c &&
                mdl.Job_Completed__c == true &&
                (mdl.Status__c == FlosumConstants.STATUS_COMPLETED ||
                mdl.Status__c == FlosumConstants.STATUS_EXCEPTION) &&
                mdl.PipelineStepId__c != null;

            Boolean isMetadataLogStartedAndHasPipeline =
                mdl.Job_Completed__c == false &&
                mdl.Status__c == FlosumConstants.STATUS_IN_PROGRESS &&
                oldLog.Status__c == FlosumConstants.STATUS_NOT_STARTED &&
                mdl.PipelineStepId__c != null &&
                mdl.Order__c == 0;

            Boolean isMetadataLogExceptionAndHasPipeline =
                mdl.Job_Completed__c == true &&
                mdl.Succeed__c == false &&
                mdl.Status__c == FlosumConstants.STATUS_IN_PROGRESS &&
                oldLog.Status__c == FlosumConstants.STATUS_EXCEPTION &&
                mdl.PipelineStepId__c != null;

            if (isMetadataLogCompletedAndHasPipeline) {
                if (
                    oldLog.Code_Coverage__c == 0 &&
                    oldLog.Process_Type__c == FlosumConstants.PROCESS_VALIDATE &&
                    mdl.Process_Type__c == FlosumConstants.PROCESS_VALIDATE
                ) {
                    quickDeployForPipeline(mdl);
                    continue;
                }

                String pipeExecId = '';
                String mergeSetName = '';
                String manualStepId = '';
                Datetime metaLogDatetime = mdl.CreatedDate.addDays(-2);
                if (mdl.Options__c != null) {
                    Options opt = (Options) System.JSON.deserialize(mdl.Options__c, Options.class);
                    if (opt != null && opt.pipeExec != null) {
                        pipeExecId = opt.pipeExec;
                        mergeSetName = opt.mergeSetName;
                        manualStepId = opt.manualStepId;
                    }
                }
                List<PipelineStepsResult__c> stepRes = new List<PipelineStepsResult__c>();
                List<PipelineStep__c> stepList = new List<PipelineStep__c>();

                stepList = [
                    SELECT
                        Id,
                        Step__c,
                        Pipeline__r.Delta_Deployment__c,
                        Next_Step_Id_On_Fail__c,
                        Next_Step_Id_On_Pass__c,
                        Vlocity_Settings_JSON__c
                    FROM PipelineStep__c
                    WHERE Id = :mdl.PipelineStepId__c
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                stepRes = [
                    SELECT Id, Result__c, Pipeline_Id__c, Description__c, Pipeline_Execution__c
                    FROM PipelineStepsResult__c
                    WHERE
                        PipelineSteps__c = :mdl.PipelineStepId__c
                        AND Pipeline_Execution__c = :pipeExecId
                        AND (Deployment_Id__c = :mdl.Patch__c
                        OR Branch_Id__c = :mdl.Branch__c)
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (stepRes.size() == 1 && stepList.size() == 1) {
                    /** Check Manual Step**/
                    if (mdl.Process_Type__c == FlosumConstants.PROCESS_MANUAL_STEP) {
                        List<Metadata_Log__c> nextStepLogs = [
                            SELECT Id, Status__c, Job_Completed__c, Async_Request_Id__c, Suborder__c
                            FROM Metadata_Log__c
                            WHERE
                                PipelineStepId__c = :mdl.PipelineStepId__c
                                AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                                AND Status__c = :FlosumConstants.STATUS_NOT_STARTED
                            WITH SECURITY_ENFORCED
                            ORDER BY Suborder__c ASC
                        ];
                        if (!nextStepLogs.isEmpty()) {
                            if (!mdl.Succeed__c) {
                                /** Skipped all next manual steps**/
                                for (Metadata_Log__c log : nextStepLogs) {
                                    log.Status__c = FlosumConstants.STATUS_DID_NOT_RUN;
                                    log.Job_Completed__c = true;
                                }
                                DatabaseUtils.updateRecords(
                                    nextStepLogs,
                                    new List<Schema.DescribeFieldResult>{
                                        Metadata_Log__c.Job_Completed__c.getDescribe(),
                                        Metadata_Log__c.Status__c.getDescribe()
                                    }
                                );
                            } else {
                                /**Set status In progress to the next manual step**/
                                nextStepLogs[0].Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                                DatabaseUtils.updateRecord(
                                    nextStepLogs[0],
                                    new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Status__c.getDescribe() }
                                );
                                continue;
                            }
                        }
                    }
                    /** End Check Manual Step**/

                    if (stepRes[0].Result__c != 'Skipped') {
                        /** If Step completed Succeed **/
                        if (mdl.Succeed__c) {
                            stepRes[0].Result__c = 'Passed';

                            //-----------Vlocity Deploy Point-----------------------------------
                            if (!vlocityDeployForPipeline(mdl, mergeSetName, stepList[0].Vlocity_Settings_JSON__c)) {
                                continue;
                            }
                            //-----------End Vlocity Deploy Point-----------------------------------

                            //if Next step STOP
                            if (stepList[0].Next_Step_Id_On_Pass__c == null) {
                                setNextStepDidNotRun(mdl, stepRes[0]);
                            } else {
                                List<Metadata_Log__c> metaLogNext = [
                                    SELECT
                                        Id,
                                        Patch__c,
                                        Branch__c,
                                        Organisation__c,
                                        Status__c,
                                        PipelineStepId__c,
                                        Process_Type__c,
                                        Is_Vlocity__c,
                                        Deployment_Name__c,
                                        Order__c,
                                        Batch_Job_Id__c,
                                        Options__c,
                                        PipelineStepId__r.Pipeline__r.Full_Deploy__c,
                                        PipelineStepId__r.Pipeline__r.Code_Version_Name__c,
                                        PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                                        PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                                        PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                                        Run_Test_Param__c,
                                        Process_Log__c,
                                        Attachment_Id__c,
                                        PipelineStepId__r.Automation_Type__c,
                                        PipelineStepId__r.Options__c
                                    FROM Metadata_Log__c
                                    WHERE
                                        Branch__c = :mdl.Branch__c
                                        AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                                        AND PipelineStepId__c = :stepList[0].Next_Step_Id_On_Pass__c
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1
                                ];

                                List<PipelineStep__c> nextStep = [
                                    SELECT
                                        Id,
                                        Step__c,
                                        Next_Step_Id_On_Fail__c,
                                        Next_Step_Id_On_Pass__c,
                                        Vlocity_Settings_JSON__c
                                    FROM PipelineStep__c
                                    WHERE Id = :stepList[0].Next_Step_Id_On_Pass__c
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1
                                ];
                                if (nextStep.size() == 1 && metaLogNext.size() == 1) {
                                    if (metaLogNext[0].Status__c == FlosumConstants.STATUS_EXCEPTION) {
                                        if (nextStep[0].Next_Step_Id_On_Fail__c == null) {
                                            setNextStepDidNotRun(mdl, stepRes[0]);
                                            DatabaseUtils.updateRecord(
                                                stepRes[0],
                                                new List<Schema.DescribeFieldResult>{
                                                    PipelineStepsResult__c.Result__c.getDescribe()
                                                }
                                            );
                                            continue;
                                        }

                                        metaLogNext = [
                                            SELECT
                                                Id,
                                                Patch__c,
                                                Branch__c,
                                                Organisation__c,
                                                Status__c,
                                                PipelineStepId__c,
                                                Process_Type__c,
                                                Is_Vlocity__c,
                                                Deployment_Name__c,
                                                Order__c,
                                                Batch_Job_Id__c,
                                                Options__c,
                                                PipelineStepId__r.Pipeline__r.Full_Deploy__c,
                                                PipelineStepId__r.Pipeline__r.Code_Version_Name__c,
                                                PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                                                PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                                                PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                                                Run_Test_Param__c,
                                                Process_Log__c,
                                                Attachment_Id__c,
                                                PipelineStepId__r.Automation_Type__c,
                                                PipelineStepId__r.Options__c
                                            FROM Metadata_Log__c
                                            WHERE
                                                Branch__c = :mdl.Branch__c
                                                AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                                                AND PipelineStepId__c = :nextStep[0].Next_Step_Id_On_Fail__c
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];

                                        nextStep = [
                                            SELECT
                                                Id,
                                                Step__c,
                                                Next_Step_Id_On_Fail__c,
                                                Next_Step_Id_On_Pass__c,
                                                Vlocity_Settings_JSON__c
                                            FROM PipelineStep__c
                                            WHERE Id = :nextStep[0].Next_Step_Id_On_Fail__c
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];
                                    }
                                    if (nextStep.size() == 1 && metaLogNext.size() == 1) {
                                        if (nextStep[0].Step__c == 'Deploy' || nextStep[0].Step__c == 'Validate') {
                                            if (
                                                !processDeployValidate(
                                                    nextStep[0].Step__c == 'Deploy',
                                                    mdl,
                                                    metaLogNext[0],
                                                    mergeSetName,
                                                    nextStep[0].Vlocity_Settings_JSON__c,
                                                    stepList[0].Pipeline__r.Delta_Deployment__c
                                                )
                                            ) {
                                                continue;
                                            }
                                        } else if (nextStep[0].Step__c == 'Rollback') {
                                            if (!processRollback(mdl, metaLogNext[0], metaLogDatetime)) {
                                                continue;
                                            }
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_WEBHOOK) {
                                            scheduleWebHookJob(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_BACKUP) {
                                            scheduleBackupJob(
                                                FlosumConstants.BACKUP_START_PROCESS_SEC,
                                                metaLogNext[0].Id
                                            );
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_EXECUTE_APEX) {
                                            scheduleApexExecuteJob(15, metaLogNext[0].Id);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_ACCELQ) {
                                            AccelqRunScheduler.runAfterDelay(
                                                60,
                                                new AccelqRunScheduler(
                                                    metaLogNext[0].Process_Log__c,
                                                    metaLogNext[0].Branch__c,
                                                    metaLogNext[0].Id
                                                )
                                            );
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PEER_REVIEW) {
                                            schedulePeerReviewJob(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_MANUAL_STEP) {
                                            processManualStep(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PAUSE) {
                                            processPause(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_LOCK_BRANCH) {
                                            lockBranchRecordType(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_UNLOCK_BRANCH) {
                                            unlockBranchRecordType(metaLogNext[0]);
                                        } else if (
                                            nextStep[0].Step__c == FlosumConstants.PROCESS_CHANGE_BRANCH_RECORD_TYPE
                                        ) {
                                            changeBranchRecordType(metaLogNext[0]);
                                        } else if (
                                            nextStep[0].Step__c == FlosumConstants.PROCESS_OVERWRITE_PROTECTION
                                        ) {
                                            processOverwriteProtection(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_AUTOMATION_STEP) {
                                            scheduleAutomationStep(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PRE_DEPLOY_FIX) {
                                            processPreDeployFix(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_COMMIT_TO_SOURCE) {
                                            scheduleCommitToSource(15, metaLogNext[0]);
                                        }
                                    }
                                }
                            }

                            //if step result = Failed
                        } else {
                            stepRes[0].Result__c = 'Failed';

                            if (stepList[0].Next_Step_Id_On_Fail__c == null) {
                                setNextStepDidNotRun(mdl, stepRes[0]);
                            } else {
                                List<Metadata_Log__c> metaLogNext = [
                                    SELECT
                                        Id,
                                        Patch__c,
                                        Branch__c,
                                        Organisation__c,
                                        Status__c,
                                        PipelineStepId__c,
                                        Process_Type__c,
                                        Is_Vlocity__c,
                                        Deployment_Name__c,
                                        Order__c,
                                        Batch_Job_Id__c,
                                        Options__c,
                                        PipelineStepId__r.Pipeline__r.Full_Deploy__c,
                                        PipelineStepId__r.Pipeline__r.Code_Version_Name__c,
                                        PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                                        PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                                        PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                                        Run_Test_Param__c,
                                        Process_Log__c,
                                        Attachment_Id__c,
                                        PipelineStepId__r.Automation_Type__c,
                                        PipelineStepId__r.Options__c
                                    FROM Metadata_Log__c
                                    WHERE
                                        Branch__c = :mdl.Branch__c
                                        AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                                        AND PipelineStepId__c = :stepList[0].Next_Step_Id_On_Fail__c
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1
                                ];

                                List<PipelineStep__c> nextStep = [
                                    SELECT
                                        Id,
                                        Step__c,
                                        Next_Step_Id_On_Fail__c,
                                        Next_Step_Id_On_Pass__c,
                                        Vlocity_Settings_JSON__c
                                    FROM PipelineStep__c
                                    WHERE Id = :stepList[0].Next_Step_Id_On_Fail__c
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1
                                ];

                                if (nextStep.size() == 1 && metaLogNext.size() == 1) {
                                    if (metaLogNext[0].Status__c == FlosumConstants.STATUS_EXCEPTION) {
                                        if (nextStep[0].Next_Step_Id_On_Fail__c == null) {
                                            setNextStepDidNotRun(mdl, stepRes[0]);
                                            DatabaseUtils.updateRecord(
                                                stepRes[0],
                                                new List<Schema.DescribeFieldResult>{
                                                    PipelineStepsResult__c.Result__c.getDescribe()
                                                }
                                            );
                                            continue;
                                        }

                                        metaLogNext = [
                                            SELECT
                                                Id,
                                                Patch__c,
                                                Branch__c,
                                                Organisation__c,
                                                Status__c,
                                                PipelineStepId__c,
                                                Process_Type__c,
                                                Is_Vlocity__c,
                                                Deployment_Name__c,
                                                Order__c,
                                                Batch_Job_Id__c,
                                                Options__c,
                                                PipelineStepId__r.Pipeline__r.Full_Deploy__c,
                                                PipelineStepId__r.Pipeline__r.Code_Version_Name__c,
                                                PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                                                PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                                                PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                                                Run_Test_Param__c,
                                                Process_Log__c,
                                                Attachment_Id__c,
                                                PipelineStepId__r.Automation_Type__c,
                                                PipelineStepId__r.Options__c
                                            FROM Metadata_Log__c
                                            WHERE
                                                Branch__c = :mdl.Branch__c
                                                AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                                                AND PipelineStepId__c = :nextStep[0].Next_Step_Id_On_Fail__c
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];

                                        nextStep = [
                                            SELECT
                                                Id,
                                                Step__c,
                                                Next_Step_Id_On_Fail__c,
                                                Next_Step_Id_On_Pass__c,
                                                Vlocity_Settings_JSON__c
                                            FROM PipelineStep__c
                                            WHERE Id = :nextStep[0].Next_Step_Id_On_Fail__c
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];
                                    }
                                    if (nextStep.size() == 1 && metaLogNext.size() == 1) {
                                        if (nextStep[0].Step__c == 'Deploy' || nextStep[0].Step__c == 'Validate') {
                                            if (
                                                !processDeployValidate(
                                                    nextStep[0].Step__c == 'Deploy',
                                                    mdl,
                                                    metaLogNext[0],
                                                    mergeSetName,
                                                    nextStep[0].Vlocity_Settings_JSON__c,
                                                    stepList[0].Pipeline__r.Delta_Deployment__c
                                                )
                                            ) {
                                                continue;
                                            }
                                        } else if (nextStep[0].Step__c == 'Rollback') {
                                            if (!processRollback(mdl, metaLogNext[0], metaLogDatetime)) {
                                                continue;
                                            }
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_WEBHOOK) {
                                            scheduleWebHookJob(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_BACKUP) {
                                            scheduleBackupJob(
                                                FlosumConstants.BACKUP_START_PROCESS_SEC,
                                                metaLogNext[0].Id
                                            );
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_EXECUTE_APEX) {
                                            scheduleApexExecuteJob(15, metaLogNext[0].Id);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_ACCELQ) {
                                            AccelqRunScheduler.runAfterDelay(
                                                60,
                                                new AccelqRunScheduler(
                                                    metaLogNext[0].Process_Log__c,
                                                    metaLogNext[0].Branch__c,
                                                    metaLogNext[0].Id
                                                )
                                            );
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PEER_REVIEW) {
                                            schedulePeerReviewJob(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_MANUAL_STEP) {
                                            processManualStep(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PAUSE) {
                                            processPause(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_LOCK_BRANCH) {
                                            lockBranchRecordType(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_UNLOCK_BRANCH) {
                                            unlockBranchRecordType(metaLogNext[0]);
                                        } else if (
                                            nextStep[0].Step__c == FlosumConstants.PROCESS_CHANGE_BRANCH_RECORD_TYPE
                                        ) {
                                            changeBranchRecordType(metaLogNext[0]);
                                        } else if (
                                            nextStep[0].Step__c == FlosumConstants.PROCESS_OVERWRITE_PROTECTION
                                        ) {
                                            processOverwriteProtection(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_AUTOMATION_STEP) {
                                            scheduleAutomationStep(15, metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_PRE_DEPLOY_FIX) {
                                            processPreDeployFix(metaLogNext[0]);
                                        } else if (nextStep[0].Step__c == FlosumConstants.PROCESS_COMMIT_TO_SOURCE) {
                                            scheduleCommitToSource(15, metaLogNext[0]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    listResults.add(stepRes[0]);
                }
            } else if (isMetadataLogStartedAndHasPipeline) {
                String pipeExecId = '';
                String mergeSetName = '';
                String manualStepId = '';

                Datetime metaLogDatetime = mdl.CreatedDate.addDays(-2);
                if (mdl.Options__c != null) {
                    Options opt = (Options) System.JSON.deserialize(mdl.Options__c, Options.class);
                    if (opt != null && opt.pipeExec != null) {
                        pipeExecId = opt.pipeExec;
                        mergeSetName = opt.mergeSetName;
                        manualStepId = opt.manualStepId;
                    }
                }

                Integer countOfStartLogs = [
                    SELECT COUNT()
                    FROM Metadata_Log__c
                    WHERE Branch__c = :mdl.Branch__c AND CreatedDate = :mdl.CreatedDate AND Order__c = 0
                    WITH SECURITY_ENFORCED
                ];
                Boolean isCodeCoverageCheckEnabled = false;
                List<Deployment_Settings__c> deploymentSettingsList = [
                    SELECT isEnabled__c
                    FROM Deployment_Settings__c
                    WHERE Organisation__c = :mdl.Organisation__c
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (!deploymentSettingsList.isEmpty()) {
                    isCodeCoverageCheckEnabled = deploymentSettingsList.get(0).isEnabled__c;
                }
                if (
                    mdl.Process_Type__c == FlosumConstants.PROCESS_DEPLOYMENT &&
                    countOfStartLogs == 2 &&
                    isCodeCoverageCheckEnabled
                ) {
                    // 12375: skip if Metadata Log with order 0 is Deployment and the part of Code Coverage Check.
                    continue;
                }

                List<PipelineStepsResult__c> stepRes = new List<PipelineStepsResult__c>();
                List<PipelineStep__c> firstStep = new List<PipelineStep__c>();

                List<Metadata_Log__c> metaLogFirst = [
                    SELECT
                        Id,
                        Patch__c,
                        Branch__c,
                        Organisation__c,
                        Status__c,
                        PipelineStepId__c,
                        Process_Type__c,
                        Is_Vlocity__c,
                        Deployment_Name__c,
                        Order__c,
                        Batch_Job_Id__c,
                        Options__c,
                        PipelineStepId__r.Pipeline__r.Full_Deploy__c,
                        PipelineStepId__r.Pipeline__r.Code_Version_Name__c,
                        PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                        PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                        PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                        Run_Test_Param__c,
                        Process_Log__c,
                        Attachment_Id__c,
                        PipelineStepId__r.Automation_Type__c,
                        PipelineStepId__r.Options__c
                    FROM Metadata_Log__c
                    WHERE Id = :mdl.Id
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                firstStep = [
                    SELECT
                        Id,
                        Step__c,
                        Pipeline__r.Delta_Deployment__c,
                        Next_Step_Id_On_Fail__c,
                        Next_Step_Id_On_Pass__c,
                        Vlocity_Settings_JSON__c
                    FROM PipelineStep__c
                    WHERE Id = :mdl.PipelineStepId__c
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                stepRes = [
                    SELECT Id, Result__c, Pipeline_Id__c, Description__c, Pipeline_Execution__c
                    FROM PipelineStepsResult__c
                    WHERE
                        PipelineSteps__c = :mdl.PipelineStepId__c
                        AND Pipeline_Execution__c = :pipeExecId
                        AND (Deployment_Id__c = :mdl.Patch__c
                        OR Branch_Id__c = :mdl.Branch__c)
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                if (!stepRes.isEmpty() && !firstStep.isEmpty() && !metaLogFirst.isEmpty()) {
                    if (firstStep[0].Step__c == 'Deploy' || firstStep[0].Step__c == 'Validate') {
                        if (
                            !processDeployValidate(
                                firstStep[0].Step__c == 'Deploy',
                                mdl,
                                metaLogFirst[0],
                                mergeSetName,
                                firstStep[0].Vlocity_Settings_JSON__c,
                                firstStep[0].Pipeline__r.Delta_Deployment__c
                            )
                        ) {
                            continue;
                        }
                    } else if (firstStep[0].Step__c == 'Rollback') {
                        if (!processRollback(mdl, metaLogFirst[0], metaLogDatetime)) {
                            continue;
                        }
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_WEBHOOK) {
                        scheduleWebHookJob(15, metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_BACKUP) {
                        scheduleBackupJob(FlosumConstants.BACKUP_START_PROCESS_SEC, metaLogFirst[0].Id);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_EXECUTE_APEX) {
                        scheduleApexExecuteJob(15, metaLogFirst[0].Id);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_ACCELQ) {
                        AccelqRunScheduler.runAfterDelay(
                            60,
                            new AccelqRunScheduler(
                                metaLogFirst[0].Process_Log__c,
                                metaLogFirst[0].Branch__c,
                                metaLogFirst[0].Id
                            )
                        );
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_PEER_REVIEW) {
                        schedulePeerReviewJob(15, metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_MANUAL_STEP) {
                        processManualStep(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_PAUSE) {
                        processPause(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_LOCK_BRANCH) {
                        lockBranchRecordType(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_UNLOCK_BRANCH) {
                        unlockBranchRecordType(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_CHANGE_BRANCH_RECORD_TYPE) {
                        changeBranchRecordType(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_OVERWRITE_PROTECTION) {
                        processOverwriteProtection(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_AUTOMATION_STEP) {
                        scheduleAutomationStep(15, metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_PRE_DEPLOY_FIX) {
                        processPreDeployFix(metaLogFirst[0]);
                    } else if (firstStep[0].Step__c == FlosumConstants.PROCESS_COMMIT_TO_SOURCE) {
                        scheduleCommitToSource(15, metaLogFirst[0]);
                    }
                }
            } else if (isMetadataLogExceptionAndHasPipeline) {
                String pipeExecId = '';
                String mergeSetName = '';
                String manualStepId = '';
                if (mdl.Options__c != null) {
                    Options opt = (Options) System.JSON.deserialize(mdl.Options__c, Options.class);
                    if (opt != null && opt.pipeExec != null) {
                        pipeExecId = opt.pipeExec;
                    }
                }
                List<PipelineStepsResult__c> stepResult = new List<PipelineStepsResult__c>();
                List<PipelineStep__c> firstStep = new List<PipelineStep__c>();

                List<Metadata_Log__c> metaLogFirst = [
                    SELECT Id, Status__c
                    FROM Metadata_Log__c
                    WHERE Id = :mdl.Id
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                firstStep = [
                    SELECT Id, Step__c, Next_Step_Id_On_Fail__c, Next_Step_Id_On_Pass__c, Vlocity_Settings_JSON__c
                    FROM PipelineStep__c
                    WHERE Id = :mdl.PipelineStepId__c
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                stepResult = [
                    SELECT Id, Result__c, Pipeline_Id__c, Description__c, Pipeline_Execution__c
                    FROM PipelineStepsResult__c
                    WHERE
                        PipelineSteps__c = :mdl.PipelineStepId__c
                        AND Pipeline_Execution__c = :pipeExecId
                        AND (Deployment_Id__c = :mdl.Patch__c
                        OR Branch_Id__c = :mdl.Branch__c)
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (!firstStep.isEmpty() && !stepResult.isEmpty() && firstStep[0].Next_Step_Id_On_Fail__c == null) {
                    setNextStepDidNotRun(mdl, stepResult[0]);
                    stepResult[0].Result__c = 'Failed';
                    DatabaseUtils.updateRecord(
                        stepResult[0],
                        new List<Schema.DescribeFieldResult>{ PipelineStepsResult__c.Result__c.getDescribe() }
                    );
                }
                List<Metadata_Log__c> listToUpdate = new List<Metadata_Log__c>();

                if (!metaLogFirst.isEmpty()) {
                    metaLogFirst[0].Status__c = FlosumConstants.STATUS_COMPLETED;
                    listToUpdate.add(metaLogFirst[0]);
                }
                List<Metadata_Log__c> metaLogNext = [
                    SELECT Id, Status__c
                    FROM Metadata_Log__c
                    WHERE
                        Branch__c = :mdl.Branch__c
                        AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                        AND PipelineStepId__c = :firstStep[0].Next_Step_Id_On_Fail__c
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (!metaLogNext.isEmpty()) {
                    metaLogNext[0].Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                    listToUpdate.add(metaLogNext[0]);
                }
                if (!listToUpdate.isEmpty()) {
                    DatabaseUtils.updateRecords(
                        listToUpdate,
                        new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Status__c.getDescribe() }
                    );
                }
            }
        }

        if (!listResults.isEmpty()) {
            DatabaseUtils.updateRecords(
                listResults,
                new List<Schema.DescribeFieldResult>{ PipelineStepsResult__c.Result__c.getDescribe() }
            );
        }
    }

    public void quickDeployForPipeline(Metadata_Log__c mdl) {
        List<Deployment_Settings__c> settingsList = [
            SELECT isEnabled__c, Code_Coverage__c
            FROM Deployment_Settings__c
            WHERE Organisation__c = :mdl.Organisation__c AND isEnabled__c = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        String listComp = '[]';
        String listDest = '[]';
        List<Attachment> attComp = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :mdl.Id AND Name = 'List Components'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!attComp.isEmpty()) {
            listComp = attComp[0].Body.toString();
        }

        List<Attachment> attDest = [
            SELECT Id, Body
            FROM Attachment
            WHERE ParentId = :mdl.Id AND Name = 'List Destructive Changes'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!attDest.isEmpty()) {
            listDest = attDest[0].Body.toString();
        }
        List<PipelineStep__c> pipelineSteps = [
            SELECT Pipeline__r.Delta_Deployment__c
            FROM PipelineStep__c
            WHERE Id = :mdl.PipelineStepId__c
            WITH SECURITY_ENFORCED
        ];
        if (
            !pipelineSteps.isEmpty() &&
            pipelineSteps[0].Pipeline__r.Delta_Deployment__c &&
            listComp == '[]' &&
            listDest == '[]'
        ) {
            List<Metadata_Log__c> deployPipelineLogList = [
                SELECT Id, Name, Branch__c, Organisation__c, Process_Type__c
                FROM Metadata_Log__c
                WHERE
                    Branch__c = :mdl.Branch__c
                    AND Status__c = :FlosumConstants.STATUS_NOT_STARTED
                    AND Order__c = :mdl.Order__c
                    AND Organisation__c = :mdl.Organisation__c
                    AND Process_Type__c = :FlosumConstants.PROCESS_DEPLOYMENT
                    AND CreatedDate >= :mdl.CreatedDate
                WITH SECURITY_ENFORCED
            ];
            if (!deployPipelineLogList.isEmpty()) {
                Model.Logger logger = new Model.Logger('Logs', deployPipelineLogList[0].Id, 2000000, false);
                logger.log('All components are already deployed in the target organization for Delta deployment.');
                logger.updateLog('Logs');
                completeMetadataLog(deployPipelineLogList[0], FlosumConstants.STATUS_COMPLETED, true);
            }
        } else if (!settingsList.isEmpty()) {
            Boolean isOverrideCodeCoverageCheck = MetadataQuickDeployController.isCodeCoverageCheckOverrideNeeded(
                mdl.Id
            );
            Integer requiredCodeCoverage = isOverrideCodeCoverageCheck
                ? 0
                : MetadataQuickDeployController.getRequiredCodeCoverage(
                      Integer.valueof(settingsList[0].Code_Coverage__c),
                      mdl.Branch__c,
                      mdl.PipelineStepId__c
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

            Model.Logger logger = new Model.Logger('Logs', mdl.Id, 2000000, false);
            logger.log('Schedule Quick Deploy For Pipeline.');
            logger.updateLog('Logs');
            System.schedule(
                'QuickDeployForPipeline ' + sysTime.getTime(),
                cronExpression,
                new MetadataQuickDeployController(mdl, FlosumConstants.PROCESS_DEPLOYMENT, requiredCodeCoverage)
            );
        }
    }

    public Boolean vlocityDeployForPipeline(Metadata_Log__c mdl, String mergeSetName, String vlocitySettingsJSON) {
        List<Attachment> mergeSetAtt = [
            SELECT Body, BodyLength
            FROM Attachment
            WHERE ParentId = :mdl.Branch__c AND Name = :mergeSetName
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        Set<Id> idsSet = new Set<Id>();
        if (mergeSetAtt.size() == 1 && mergeSetAtt[0].BodyLength != 0) {
            idsSet = (Set<Id>) JSON.deserialize(mergeSetAtt[0].Body.toString(), Set<Id>.class);
        }
        List<Component__c> listVlocityComponents = [
            SELECT Id
            FROM Component__c
            WHERE Id IN :idsSet AND Vlocity_Component__c = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 49500
        ];
        if (
            listVlocityComponents.size() > 0 &&
            !mdl.Is_Vlocity__c &&
            mdl.Process_Type__c == FlosumConstants.PROCESS_DEPLOYMENT
        ) {
            List<String> vlocityComponentsIds = new List<String>();
            for (Component__c comp : listVlocityComponents) {
                vlocityComponentsIds.add(comp.id);
            }
            Metadata_Log__c vlocityMetadataLog = VlocityService.createMetadataLog(
                mdl.Branch__c,
                mdl.Organisation__c,
                VlocityService.VLOCITY_DEPLOY_BRANCH
            );
            vlocityMetadataLog.PipelineStepId__c = mdl.PipelineStepId__c;
            vlocityMetadataLog.Deployment_Name__c = mdl.Deployment_Name__c + ' (SFI)';
            vlocityMetadataLog.Order__c = mdl.Order__c;
            vlocityMetadataLog.Options__c = mdl.Options__c;
            vlocityMetadataLog.Batch_Job_Id__c = mdl.Batch_Job_Id__c;
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

            Map<String, Object> vlocitySettingsMap = new Map<String, Object>();
            Boolean isSeparateMatrixVersions = false;
            Boolean isSeparateCalculationProcedureVersions = false;
            Boolean isEnabledApexPostDeploy = false;
            Boolean isLWCActivation = true;
            String apexCode = '';
            if (String.isNotBlank(vlocitySettingsJSON)) {
                try {
                    vlocitySettingsMap = (Map<String, Object>) JSON.deserializeUntyped(vlocitySettingsJSON);
                    isSeparateMatrixVersions = (Boolean) vlocitySettingsMap.get('isSeparateMatrixVersions');
                    isSeparateCalculationProcedureVersions = (Boolean) vlocitySettingsMap.get(
                        'isSeparateCalculationProcedureVersions'
                    );
                    isLWCActivation = (Boolean) vlocitySettingsMap.get('isLWCActivation');
                    apexCode = (String) vlocitySettingsMap.get('apexCode');
                    isEnabledApexPostDeploy = String.isNotBlank(apexCode);
                } catch (Exception e) {
                }
            }
            Model.Logger logger = new Model.Logger('Logs', mdl.Id, 2000000, false);
            logger.log('Created Vlocity Deployment.');
            logger.updateLog('Logs');
            VlocityService.deployFromBranch(
                mdl.Organisation__c,
                mdl.Branch__c,
                vlocityMetadataLog.Id,
                vlocityAttLog.Id,
                vlocityComponentsIds,
                isSeparateMatrixVersions,
                isSeparateCalculationProcedureVersions,
                isEnabledApexPostDeploy,
                isLWCActivation,
                apexCode
            );
            return false;
        }
        return true;
    }

    public void setNextStepDidNotRun(Metadata_Log__c mdl, PipelineStepsResult__c stepRes) {
        List<PipelineStepsResult__c> stepResListAbort = new List<PipelineStepsResult__c>();

        List<Metadata_Log__c> metaLogNextAbort = [
            SELECT Id, Status__c, Job_Completed__c
            FROM Metadata_Log__c
            WHERE
                Branch__c = :mdl.Branch__c
                AND Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                AND Status__c = :FlosumConstants.STATUS_NOT_STARTED
            WITH SECURITY_ENFORCED
        ];
        if (metaLogNextAbort.size() > 0) {
            for (Metadata_Log__c log : metaLogNextAbort) {
                log.Status__c = FlosumConstants.STATUS_DID_NOT_RUN;
                log.Job_Completed__c = true;
            }

            stepResListAbort = [
                SELECT Id, Result__c
                FROM PipelineStepsResult__c
                WHERE
                    Pipeline_Execution__c = :stepRes.Pipeline_Execution__c
                    AND Result__c = 'WAIT'
                    AND Id != :stepRes.Id
                WITH SECURITY_ENFORCED
            ];
            if (stepResListAbort.size() > 0) {
                for (PipelineStepsResult__c res : stepResListAbort) {
                    res.Result__c = 'Skipped';
                }
                DatabaseUtils.updateRecords(
                    stepResListAbort,
                    new List<Schema.DescribeFieldResult>{ PipelineStepsResult__c.Result__c.getDescribe() }
                );
            }
            List<Attachment> logs = [
                SELECT Id, Body
                FROM Attachment
                WHERE ParentId IN :metaLogNextAbort AND Name = 'Logs'
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 200
            ];
            for (Attachment att : logs) {
                String log =
                    att.Body.toString() +
                    '\n' +
                    MetadataUtils.getTimeForLog() +
                    ': ' +
                    ' This step did not run.';
                att.Body = Blob.valueOf(log);
            }
            DatabaseUtils.updateRecords(logs, new List<Schema.DescribeFieldResult>{ Attachment.Body.getDescribe() });
            DatabaseUtils.updateRecords(
                metaLogNextAbort,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe()
                }
            );
        }
    }

    public static void scheduleBackupJob(Integer seconds, Id metadataLogId) {
        Datetime sysTime = System.now().addSeconds(seconds);
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
        Model.Logger logger = new Model.Logger('Logs', metadataLogId, 2000000, false);
        logger.log('Schedule Backup.');
        logger.updateLog('Logs');
        System.schedule(
            FlosumConstants.BACKUP_SERVICE_SCHEDULED_JOB_NAME + sysTime.getTime(),
            chronExpression,
            new BackupServiceScheduled(metadataLogId)
        );
    }

    public static void scheduleApexExecuteJob(Integer seconds, Id metadataLogId) {
        Datetime sysTime = System.now().addSeconds(seconds);
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
        Model.Logger logger = new Model.Logger('Logs', metadataLogId, 2000000, false);
        logger.log('Schedule Apex Execute.');
        logger.updateLog('Logs');
        System.schedule(
            'ApexExecuteScheduler_' + sysTime.getTime(),
            chronExpression,
            new ApexExecuteScheduler(metadataLogId)
        );
    }

    public static void scheduleWebHookJob(Integer seconds, Metadata_Log__c metadataLog) {
        List<PipelineStep__c> stepNext = new List<PipelineStep__c>();
        stepNext = [
            SELECT Id, Destination__c
            FROM PipelineStep__c
            WHERE Id = :metadataLog.PipelineStepId__c AND Step__c = :FlosumConstants.PROCESS_WEBHOOK
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!stepNext.isEmpty()) {
            Datetime sysTime = System.now().addSeconds(seconds);
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
            Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
            logger.log('Schedule WebHook.');
            logger.updateLog('Logs');
            System.schedule(
                'WebHookScheduled ' + sysTime.getTime(),
                chronExpression,
                new WebHookSchedule(metadataLog.Branch__c, metadataLog.Id, stepNext.get(0).Destination__c)
            );
        } else {
            MetadataUtils.completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            MetadataUtils.createErrorLog(metadataLog, 'WebHook Error Log', 'Pipeline step not configured.');
        }
    }

    public static void schedulePeerReviewJob(Integer seconds, Metadata_Log__c metadataLog) {
        Datetime sysTime = System.now().addSeconds(seconds);
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
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Schedule Peer Review.');
        logger.updateLog('Logs');
        System.schedule(
            'PeerReviewScheduled ' + sysTime.getTime(),
            chronExpression,
            new SchedulePeerReview(metadataLog.Id)
        );
    }

    public static void scheduleCommitToSource(Integer seconds, Metadata_Log__c metadataLog) {
        Datetime sysTime = System.now().addSeconds(seconds);
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
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Schedule Commit to Source.');
        logger.updateLog('Logs');
        System.schedule(
            'CommitToSourceScheduler ' + sysTime.getTime(),
            chronExpression,
            new ScheduleCommit(metadataLog.Id)
        );
    }

    public void scheduleAutomationStep(Integer seconds, Metadata_Log__c metadataLog) {
        Boolean isRunScheduler = true;
        metadataLog.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
        metadataLog.Start_Date__c = Datetime.now();
        DatabaseUtils.updateRecord(
            metadataLog,
            new List<Schema.DescribeFieldResult>{
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Start_Date__c.getDescribe()
            }
        );
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Schedule Automation Step: ' + metadataLog.PipelineStepId__r.Automation_Type__c);
        logger.updateLog('Logs');
        if (metadataLog.PipelineStepId__r.Automation_Type__c == 'ApexPMD') {
            HerokuCredentials__c hc = HTTPService.getCredentials();
            if (hc != null && hc.Rules__c != '' && hc.Settings__c != '') {
                Datetime sysTime = System.now().addSeconds(seconds);
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
                String jobName = 'ScheduleApexPMD' + System.now().getTime();
                String jobId = System.schedule(
                    jobName,
                    cronExpression,
                    new ScheduleApexPMD(metadataLog.Branch__c, metadataLog.Id)
                );
            } else {
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLog, 'ApexPMD Error Log', 'Apex PMD is not configured.');
                isRunScheduler = false;
            }
        } else if (metadataLog.PipelineStepId__r.Automation_Type__c == 'Flosum Scan') {
            String message;
            if (AbstractAuthentication.isActiveLicense(AbstractAuthentication.FLOSUM_SCAN_PACKAGE_PREFIX)) {
                try {
                    if (String.isNotBlank(metadataLog.PipelineStepId__r.Options__c)) {
                        Model.AutomationOptions automationObj = new Model.AutomationOptions();
                        automationObj = (Model.AutomationOptions) JSON.deserialize(
                            metadataLog.PipelineStepId__r.Options__c,
                            Model.AutomationOptions.class
                        );
                        if (automationObj.isTakeResultFlosumScan == null || !automationObj.isTakeResultFlosumScan) {
                            BaseIntegration integration = (BaseIntegration) Type.forName(
                                    AbstractAuthentication.FLOSUM_SCAN_PACKAGE_PREFIX,
                                    'AnalyseBranchIntegration'
                                )
                                .newInstance();
                            String result = (String) integration.execute(metadataLog.Branch__c);
                            if (
                                result == FlosumConstants.NOT_SELECTED_TYPES ||
                                result == FlosumConstants.NOT_COMPONENTS_IN_BRANCH
                            ) {
                                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                                createSuccessLog(metadataLog, 'Flosum Scan Log', result);
                                isRunScheduler = false;
                            } else if (result == FlosumConstants.BRANCH_NOT_FOUND) {
                                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                                createErrorLog(metadataLog, 'Flosum Scan Error Log', result);
                                isRunScheduler = false;
                            }
                        }
                    } else {
                        completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                        createErrorLog(
                            metadataLog,
                            'Flosum Scan Error Log',
                            'This Automation Step does not have options.'
                        );
                        isRunScheduler = false;
                    }
                } catch (Exception e) {
                    message = e.getMessage();
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                    createErrorLog(metadataLog, 'Flosum Scan Error Log', message);
                    isRunScheduler = false;
                }
            } else {
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(
                    metadataLog,
                    'Flosum Scan Error Log',
                    AbstractAuthentication.PACKAGE_LICENSE_EXCEPTION_MESSAGE
                );
                isRunScheduler = false;
            }
        }

        if (isRunScheduler) {
            List<CronTrigger> jobs = [
                SELECT Id, CronJobDetail.Name, State
                FROM CronTrigger
                WHERE CronJobDetail.Name = :'MetadataLogScheduler' + UserInfo.getUserId()
            ];
            Datetime sysTime = System.now().addSeconds(seconds);
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
        }
    }

    public void changeBranchRecordType(Metadata_Log__c metadataLog) {
        try {
            List<Branch__c> branches = [
                SELECT Id, RecordTypeId
                FROM Branch__c
                WHERE Id = :metadataLog.Branch__c
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (metadataLog.Options__c != null) {
                Options opt = (Options) System.JSON.deserialize(metadataLog.Options__c, Options.class);
                if (opt != null && !String.isEmpty(opt.branchRecordType)) {
                    Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
                    logger.log('Change Branch Record Type to' + opt.branchRecordType);
                    logger.updateLog('Logs');
                    branches[0].RecordTypeId = opt.branchRecordType;
                    DatabaseUtils.updateRecord(
                        branches[0],
                        new List<Schema.DescribeFieldResult>{ Branch__c.RecordTypeId.getDescribe() }
                    );
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                } else {
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                    createErrorLog(metadataLog, 'Change Branch Record Type Error Log', 'Record Type Not Found.');
                }
            } else {
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLog, 'Change Branch Record Type Error Log', 'Record Type Not Found.');
            }
        } catch (Exception ex) {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            createErrorLog(metadataLog, 'Change Branch Record Type Error Log', ex.getMessage());
        }
    }

    public void unlockBranchRecordType(Metadata_Log__c metadataLog) {
        try {
            List<Branch__c> branches = [
                SELECT Id, RecordTypeId
                FROM Branch__c
                WHERE Id = :metadataLog.Branch__c
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
            logger.log('Change Branch Record Type to Unlock');
            logger.updateLog('Logs');
            if (metadataLog.Options__c != null) {
                Options opt = (Options) System.JSON.deserialize(metadataLog.Options__c, Options.class);
                if (opt != null && !String.isEmpty(opt.branchRecordType)) {
                    branches[0].RecordTypeId = opt.branchRecordType;
                    DatabaseUtils.updateRecord(
                        branches[0],
                        new List<Schema.DescribeFieldResult>{ Branch__c.RecordTypeId.getDescribe() }
                    );
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                } else {
                    List<RecordType> recordTypes = new List<RecordType>();
                    RecordType defaultRecordType = MetadataUtils.addRecordTypes(
                        Schema.sObjectType.Branch__c.getName(),
                        'Default'
                    );
                    recordTypes.add(defaultRecordType);
                    if (!recordTypes.isEmpty()) {
                        branches[0].RecordTypeId = defaultRecordType.Id;
                        DatabaseUtils.updateRecord(
                            branches[0],
                            new List<Schema.DescribeFieldResult>{ Branch__c.RecordTypeId.getDescribe() }
                        );
                        completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                    } else {
                        completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                        createErrorLog(metadataLog, 'Unlock Branch Error Log', 'Default Record Type Not Found.');
                    }
                }
            } else {
                List<RecordType> recordTypes = new List<RecordType>();
                RecordType defaultRecordType = MetadataUtils.addRecordTypes(
                    Schema.sObjectType.Branch__c.getName(),
                    'Default'
                );
                recordTypes.add(defaultRecordType);
                if (!recordTypes.isEmpty()) {
                    branches[0].RecordTypeId = defaultRecordType.Id;
                    DatabaseUtils.updateRecord(
                        branches[0],
                        new List<Schema.DescribeFieldResult>{ Branch__c.RecordTypeId.getDescribe() }
                    );
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
                } else {
                    completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                    createErrorLog(metadataLog, 'Unlock Branch Error Log', 'Default Record Type Not Found.');
                }
            }
        } catch (Exception ex) {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            createErrorLog(metadataLog, 'Unlock Branch Error Log', ex.getMessage());
        }
    }

    public void lockBranchRecordType(Metadata_Log__c metadataLog) {
        try {
            List<RecordType> recordTypes = new List<RecordType>();
            RecordType lock = MetadataUtils.addRecordTypes(Schema.SObjectType.Branch__c.getName(), 'Locked');
            recordTypes.add(lock);
            List<Branch__c> branches = [
                SELECT Id, RecordTypeId
                FROM Branch__c
                WHERE Id = :metadataLog.Branch__c
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
            logger.log('Change Branch Record Type to Locked');
            logger.updateLog('Logs');
            if (!recordTypes.isEmpty() && !branches.isEmpty()) {
                branches[0].RecordTypeId = recordTypes[0].Id;
                DatabaseUtils.updateRecord(
                    branches[0],
                    new List<Schema.DescribeFieldResult>{ Branch__c.RecordTypeId.getDescribe() }
                );
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
            } else {
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLog, 'Lock Branch Error Log', 'Locked Record Type Not Found.');
            }
        } catch (Exception ex) {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            createErrorLog(metadataLog, 'Lock Branch Error Log', ex.getMessage());
        }
    }

    public void processPause(Metadata_Log__c metadataLog) {
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Start Pause');
        logger.updateLog('Logs');

        if (metadataLog.Status__c == FlosumConstants.STATUS_COMPLETED) {
            return;
        }

        metadataLog.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
        metadataLog.Start_Date__c = Datetime.now();
        DatabaseUtils.updateRecord(
            metadataLog,
            new List<Schema.DescribeFieldResult>{
                Metadata_Log__c.Start_Date__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe()
            }
        );
    }

    public void processManualStep(Metadata_Log__c metadataLog) {
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Start Manual Step');
        logger.updateLog('Logs');
        if (metadataLog.Options__c != null) {
            Options opt = (Options) System.JSON.deserialize(metadataLog.Options__c, Options.class);
            if (opt == null || String.isEmpty(opt.manualStepId)) {
                completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
            } else {
                metadataLog.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                metadataLog.Start_Date__c = Datetime.now();
                DatabaseUtils.updateRecord(
                    metadataLog,
                    new List<Schema.DescribeFieldResult>{
                        Metadata_Log__c.Start_Date__c.getDescribe(),
                        Metadata_Log__c.Status__c.getDescribe()
                    }
                );
            }
        } else {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, true);
        }
    }

    public void processOverwriteProtection(Metadata_Log__c metadataLog) {
        List<Attachment> attList = new List<Attachment>();

        attList = [
            SELECT Id
            FROM Attachment
            WHERE
                ParentId = :metadataLog.Branch__c
                AND Description = :'Build' + metadataLog.Batch_Job_Id__c
                AND Name = :('Build' + metadataLog.Organisation__c).substring(0, 20)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!attList.isEmpty()) {
            metadataLog.Attachment_Id__c = attList[0].Id;
        }
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Start Overwrite Protection Step');
        logger.updateLog('Logs');
        if (FlosumSecurity.checkRetrievePermission(metadataLog.Organisation__c)) {
            metadataLog.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
            metadataLog.Start_Date__c = Datetime.now();
            DatabaseUtils.updateRecord(
                metadataLog,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Start_Date__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe()
                }
            );
        } else {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            createErrorLog(metadataLog, 'Overwrite Protection Error Log', FlosumConstants.RETRIEVE_PERMISSION_DENIED);
        }
    }

    public void processPreDeployFix(Metadata_Log__c metadataLog) {
        List<Attachment> attList = new List<Attachment>();

        attList = [
            SELECT Id
            FROM Attachment
            WHERE
                ParentId = :metadataLog.Branch__c
                AND Description = :'Build' + metadataLog.Batch_Job_Id__c
                AND Name = :('Build' + metadataLog.Organisation__c).substring(0, 20)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!attList.isEmpty()) {
            metadataLog.Attachment_Id__c = attList[0].Id;
        }
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        logger.log('Start PreDeploy Fix Step');
        logger.updateLog('Logs');
        if (FlosumSecurity.checkRetrievePermission(metadataLog.Organisation__c)) {
            metadataLog.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
            metadataLog.Start_Date__c = Datetime.now();
            DatabaseUtils.updateRecord(
                metadataLog,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Start_Date__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe()
                }
            );
        } else {
            completeMetadataLog(metadataLog, FlosumConstants.STATUS_COMPLETED, false);
            createErrorLog(metadataLog, 'PreDeploy Fix Error Log', FlosumConstants.RETRIEVE_PERMISSION_DENIED);
        }
    }

    public Boolean processRollback(Metadata_Log__c mdl, Metadata_Log__c metadataLogNext, Datetime metaLogDatetime) {
        try {
            Deployment_Approval__c depApp = new Deployment_Approval__c(
                Org__c = metadataLogNext.Organisation__c,
                Branch__c = metadataLogNext.Branch__c,
                Run_Test_Param__c = metadataLogNext.Run_Test_Param__c,
                Specified_Tests__c = metadataLogNext.Process_Log__c,
                User__c = UserInfo.getUserId(),
                Process_Type__c = metadataLogNext.Process_Type__c
            );
            DatabaseUtils.insertRecord(
                depApp,
                new List<Schema.DescribeFieldResult>{
                    Deployment_Approval__c.Org__c.getDescribe(),
                    Deployment_Approval__c.Branch__c.getDescribe(),
                    Deployment_Approval__c.Run_Test_Param__c.getDescribe(),
                    Deployment_Approval__c.Process_Type__c.getDescribe(),
                    Deployment_Approval__c.Specified_Tests__c.getDescribe(),
                    Deployment_Approval__c.User__c.getDescribe()
                }
            );
        } catch (Exception e) {
            String message = e.getMessage();
            Attachment att = new Attachment();
            att.Name = 'Deployment Approval Error';
            att.Description = 'Deployment Approval Error';
            att.Body = Blob.valueOf(message);
            att.ParentId = metadataLogNext.Id;
            att.ContentType = 'text/plain';
            DatabaseUtils.insertRecord(
                att,
                new List<Schema.DescribeFieldResult>{
                    Attachment.Body.getDescribe(),
                    Attachment.Name.getDescribe(),
                    Attachment.Description.getDescribe(),
                    Attachment.ParentId.getDescribe()
                }
            );
            completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
            return false;
        }
        Model.Logger logger = new Model.Logger('Logs', metadataLogNext.Id, 2000000, false);
        logger.log('Start Rollback Step');
        logger.updateLog('Logs');
        List<Attachment> attListM = new List<Attachment>();
        List<Attachment> attListPost = new List<Attachment>();

        attListM = [
            SELECT Body, ParentId
            FROM Attachment
            WHERE ParentId = :metadataLogNext.Id AND Description = :FlosumConstants.ROLL_BACK_ZIP_DESCRIPTION
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<Metadata_Log__c> lastDep = new List<Metadata_Log__c>();

        lastDep = [
            SELECT Id
            FROM Metadata_Log__c
            WHERE
                Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                AND Process_Type__c = 'Deployment (SFI)'
                AND Organisation__c = :metadataLogNext.Organisation__c
                AND Succeed__c = TRUE
                AND CreatedDate >= :metaLogDatetime
            WITH SECURITY_ENFORCED
            ORDER BY Name DESC
            LIMIT 1
        ];

        if (lastDep.size() == 1 && metadataLogNext.Process_Type__c == VlocityService.VLOCITY_ROLLBACK) {
            List<Attachment> attLogsList = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :metadataLogNext.Id AND Name = 'Logs'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            List<Attachment> attIdBackupList = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :lastDep[0].Id AND Name = 'VLOCITY BACKUP ZIP'
                WITH SECURITY_ENFORCED
                LIMIT 100
            ]; //VLOCITY BACKUP ZIP

            if (attLogsList.size() > 0 && attIdBackupList.size() > 0) {
                List<String> attachmentIdList = new List<String>();
                for (Attachment att : attIdBackupList) {
                    attachmentIdList.add(att.Id);
                }
                VlocityService.rollback(
                    metadataLogNext.Organisation__c,
                    metadataLogNext.Branch__c,
                    metadataLogNext.Id,
                    attLogsList[0].Id,
                    attachmentIdList
                );
            } else {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
            }
        } else if (lastDep.size() == 1 && mdl.Process_Type__c != VlocityService.VLOCITY_ROLLBACK) {
            List<Attachment> attIdBackupList = [
                SELECT Id
                FROM Attachment
                WHERE ParentId = :lastDep[0].Id AND Name = 'VLOCITY BACKUP ZIP'
                WITH SECURITY_ENFORCED
                LIMIT 100
            ]; //VLOCITY BACKUP ZIP

            if (attIdBackupList.size() > 0) {
                List<String> attachmentIdList = new List<String>();
                for (Attachment att : attIdBackupList) {
                    attachmentIdList.add(att.Id);
                }

                Metadata_Log__c logRecord = VlocityService.createMetadataLog(
                    metadataLogNext.Branch__c,
                    metadataLogNext.Organisation__c,
                    VlocityService.VLOCITY_ROLLBACK
                );
                logRecord.Deployment_Name__c = metadataLogNext.Deployment_Name__c + ' (SFI)';
                logRecord.PipelineStepId__c = mdl.PipelineStepId__c;
                logRecord.Order__c = metadataLogNext.Order__c;
                logRecord.Options__c = metadataLogNext.Options__c;
                logRecord.Batch_Job_Id__c = metadataLogNext.Batch_Job_Id__c;
                DatabaseUtils.insertRecord(
                    logRecord,
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
                Attachment vlocityLogAttachment = VlocityService.createAttachmentLog(
                    logRecord.Id,
                    VlocityService.VLOCITY_ROLLBACK
                );
                VlocityService.rollback(
                    metadataLogNext.Organisation__c,
                    metadataLogNext.Branch__c,
                    logRecord.Id,
                    vlocityLogAttachment.Id,
                    attachmentIdList
                );
                return false;
            } else {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
            }
        } else if (mdl.Process_Type__c == VlocityService.VLOCITY_ROLLBACK) {
            completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
        } else {
            lastDep = [
                SELECT Id
                FROM Metadata_Log__c
                WHERE
                    Batch_Job_Id__c = :mdl.Batch_Job_Id__c
                    AND Process_Type__c = 'Deployment'
                    AND Organisation__c = :metadataLogNext.Organisation__c
                    AND Succeed__c = TRUE
                    AND CreatedDate >= :metaLogDatetime
                WITH SECURITY_ENFORCED
                ORDER BY Name DESC
                LIMIT 1
            ];
            if (lastDep.size() == 1) {
                Boolean isAgentPipeline = false;
                if (metadataLogNext.Options__c != null) {
                    Options opt = (Options) System.JSON.deserialize(mdl.Options__c, Options.class);
                    if (opt != null && opt.isAgentPipeline != null && opt.isAgentPipeline) {
                        isAgentPipeline = true;
                    }
                }

                if (!String.isBlank(FlosumUtils.getAgentAppURL()) && isAgentPipeline) {
                    attListPost = [
                        SELECT ID, Body, ParentId
                        FROM Attachment
                        WHERE ParentId = :lastDep[0].Id AND Description = :FlosumConstants.ROLL_BACK_FILE_DESCRIPTION
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (attListPost.size() == 1) {
                        metadataLogNext.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                        DatabaseUtils.updateRecord(
                            metadataLogNext,
                            new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Status__c.getDescribe() }
                        );
                        DestrChanges objJSON2Apex = new DestrChanges(
                            System.JSON.createParser(attListPost[0].Body.toString())
                        );
                        Map<String, List<String>> tempMap = new Map<String, List<String>>();
                        for (String key : objJSON2Apex.createdSet) {
                            List<String> crList = new List<String>();
                            List<String> temp = key.split(':');
                            String mType = 'Unknown';
                            if (temp.size() > 0) {
                                mType = temp[0];
                            }
                            if (tempMap.containsKey(mType)) {
                                crList = tempMap.get(mType);
                            }
                            crList.add(temp[1]);
                            tempMap.put(mType, crList);
                        }
                        String xml = '<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata">';
                        for (String mType : tempMap.keySet()) {
                            List<String> packageXmlLi = new List<String>();
                            packageXmlLi = tempMap.get(mType);
                            xml = xml + '<types>';
                            for (String member : packageXmlLi) {
                                xml = xml + '<members>';
                                xml = xml + member;
                                xml = xml + '</members>';
                            }
                            xml = xml + '<name>' + mType + '</name></types>';
                        }
                        xml = xml + '<version>' + FlosumConstants.apiVersion + '</version></Package>';

                        Attachment att = new Attachment();
                        att.Name = 'XML Post Destructive Changes';
                        att.Description = 'XML Post Destructive Changes';
                        att.Body = Blob.valueOf(xml);
                        att.ParentId = metadataLogNext.Id;
                        DatabaseUtils.insertRecord(
                            att,
                            new List<Schema.DescribeFieldResult>{
                                Attachment.Body.getDescribe(),
                                Attachment.Name.getDescribe(),
                                Attachment.Description.getDescribe(),
                                Attachment.ParentId.getDescribe()
                            }
                        );

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

                        System.schedule(
                            'MetadataDeployControllerRollback ' + sysTime.getTime(),
                            chronExpression,
                            new MetadataDeployController(
                                metadataLogNext.Branch__c,
                                metadataLogNext.Organisation__c,
                                metadataLogNext.Id,
                                lastDep[0].Id,
                                att.Id
                            )
                        );
                    }
                } else {
                    attListPost = [
                        SELECT Body, ParentId
                        FROM Attachment
                        WHERE ParentId = :lastDep[0].Id AND Description = :FlosumConstants.ROLL_BACK_FILE_DESCRIPTION
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];

                    if (attListPost.size() == 1) {
                        DestrChanges objJSON2Apex = new DestrChanges(
                            System.JSON.createParser(attListPost[0].Body.toString())
                        );

                        Map<String, List<String>> tempMap = new Map<String, List<String>>();
                        for (String key : objJSON2Apex.createdSet) {
                            List<String> crList = new List<String>();
                            List<String> temp = key.split(':');
                            String mType = 'Unknown';
                            if (temp.size() > 0) {
                                mType = temp[0];
                            }
                            if (tempMap.containsKey(mType)) {
                                crList = tempMap.get(mType);
                            }
                            crList.add(temp[1]);
                            tempMap.put(mType, crList);
                        }

                        String xml = '<?xml version="1.0" encoding="UTF-8"?><Package xmlns="http://soap.sforce.com/2006/04/metadata">';
                        for (String mType : tempMap.keySet()) {
                            List<String> packageXmlLi = new List<String>();
                            packageXmlLi = tempMap.get(mType);
                            xml = xml + '<types>';
                            for (String member : packageXmlLi) {
                                xml = xml + '<members>';
                                xml = xml + member;
                                xml = xml + '</members>';
                            }
                            xml = xml + '<name>' + mType + '</name></types>';
                        }
                        xml = xml + '<version>' + FlosumConstants.apiVersion + '</version></Package>';

                        Zippex sampleZip = new Zippex(attListM[0].Body);
                        Blob fileData = Blob.valueOf(xml);
                        sampleZip.addFile('destructiveChangesPost.xml', fileData, null);
                        Blob zipData = sampleZip.getZipArchive();

                        Attachment att = new Attachment();
                        if (attListM.size() == 1) {
                            att.Name = FlosumConstants.ROLL_BACK_FILE_DESCRIPTION;
                            att.Description = FlosumConstants.ROLL_BACK_FILE_DESCRIPTION;
                            att.Body = zipData;
                            att.ParentId = metadataLogNext.Branch__c;
                            DatabaseUtils.insertRecord(
                                att,
                                new List<Schema.DescribeFieldResult>{
                                    Attachment.Body.getDescribe(),
                                    Attachment.Name.getDescribe(),
                                    Attachment.Description.getDescribe(),
                                    Attachment.ParentId.getDescribe()
                                }
                            );

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

                            System.schedule(
                                'ApexDeploymentScheduleForBranch ' + sysTime.getTime(),
                                chronExpression,
                                new ApexDeploymentScheduleForBranch(
                                    metadataLogNext.Branch__c,
                                    metadataLogNext.Organisation__c,
                                    metadataLogNext.Id,
                                    att.Id
                                )
                            );
                        } else {
                            completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                        }
                    } else {
                        completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                    }
                }
            } else {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
            }
        }
        return true;
    }

    public Boolean processDeployValidate(
        Boolean isDeploy,
        Metadata_Log__c mdl,
        Metadata_Log__c metadataLogNext,
        String mergeSetName,
        String vlocitySettingsJSON,
        Boolean isDeltaDeploy
    ) {
        Model.Logger logger = new Model.Logger('Logs', metadataLogNext.Id, 2000000, false);

        if (isDeploy) {
            logger.log('Start Deployment Step');
            if (!FlosumSecurity.checkDeployPermission(metadataLogNext.Organisation__c)) {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLogNext, 'Deployment Error Log', FlosumConstants.DEPLOY_PERMISSION_DENIED);
                return false;
            }
            MetadataUtils.MoveForwardPermission MFP = MetadataUtils.allowUserToMoveForwardFromBranch(
                metadataLogNext.Branch__c,
                FlosumConstants.PullRequestAddToDeploymentType
            );
            if (!MFP.isSuccess) {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLogNext, 'Deployment Error Log', MFP.errorMessage);
                return false;
            }
        } else {
            logger.log('Start Validate Step');
            if (!FlosumSecurity.checkValidatePermission(metadataLogNext.Organisation__c)) {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                createErrorLog(metadataLogNext, 'Deployment Error Log', FlosumConstants.DEPLOY_PERMISSION_DENIED);
                return false;
            }
        }
        logger.updateLog('Logs');
        try {
            Deployment_Approval__c depApp = new Deployment_Approval__c(
                Org__c = metadataLogNext.Organisation__c,
                Branch__c = metadataLogNext.Branch__c,
                Run_Test_Param__c = metadataLogNext.Run_Test_Param__c,
                Specified_Tests__c = metadataLogNext.Process_Log__c,
                User__c = UserInfo.getUserId(),
                Process_Type__c = metadataLogNext.Process_Type__c
            );
            DatabaseUtils.insertRecord(
                depApp,
                new List<Schema.DescribeFieldResult>{
                    Deployment_Approval__c.Org__c.getDescribe(),
                    Deployment_Approval__c.Branch__c.getDescribe(),
                    Deployment_Approval__c.Run_Test_Param__c.getDescribe(),
                    Deployment_Approval__c.Process_Type__c.getDescribe(),
                    Deployment_Approval__c.Specified_Tests__c.getDescribe(),
                    Deployment_Approval__c.User__c.getDescribe()
                }
            );
        } catch (Exception e) {
            String message = e.getMessage();
            Attachment att = new Attachment();
            att.Name = 'Deployment Approval Error';
            att.Description = 'Deployment Approval Error';
            att.Body = Blob.valueOf(message);
            att.ParentId = metadataLogNext.Id;
            att.ContentType = 'text/plain';
            DatabaseUtils.insertRecord(
                att,
                new List<Schema.DescribeFieldResult>{
                    Attachment.Body.getDescribe(),
                    Attachment.Name.getDescribe(),
                    Attachment.Description.getDescribe(),
                    Attachment.ParentId.getDescribe()
                }
            );
            completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
            return false;
        }

        if (metadataLogNext.Process_Type__c == 'Deployment (SFI)') {
            List<Attachment> mergeSetAtt = [
                SELECT Body, BodyLength
                FROM Attachment
                WHERE ParentId = :mdl.Branch__c AND Name = :mergeSetName
                WITH SECURITY_ENFORCED
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];
            Set<Id> idsSet = new Set<Id>();
            if (mergeSetAtt.size() == 1 && mergeSetAtt[0].BodyLength != 0) {
                idsSet = (Set<Id>) JSON.deserialize(mergeSetAtt[0].Body.toString(), Set<Id>.class);
            }
            List<Component__c> listVlocityComponents = [
                SELECT Id
                FROM Component__c
                WHERE Id IN :idsSet AND Vlocity_Component__c = TRUE
                WITH SECURITY_ENFORCED
                LIMIT 49500
            ];
            if (listVlocityComponents.size() > 0) {
                List<String> vlocityComponentsIds = new List<String>();
                for (Component__c comp : listVlocityComponents) {
                    vlocityComponentsIds.add(comp.Id);
                }
                List<Attachment> attLogsList = [
                    SELECT Id
                    FROM Attachment
                    WHERE ParentId = :metadataLogNext.Id AND Name = 'Logs'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (attLogsList.size() > 0) {
                    Map<String, Object> vlocitySettingsMap = new Map<String, Object>();
                    Boolean isSeparateMatrixVersions = false;
                    Boolean isSeparateCalculationProcedureVersions = false;
                    Boolean isEnabledApexPostDeploy = false;
                    Boolean isLWCActivation = true;
                    String apexCode = '';
                    if (String.isNotBlank(vlocitySettingsJSON)) {
                        try {
                            vlocitySettingsMap = (Map<String, Object>) JSON.deserializeUntyped(vlocitySettingsJSON);
                            isSeparateMatrixVersions = (Boolean) vlocitySettingsMap.get('isSeparateMatrixVersions');
                            isSeparateCalculationProcedureVersions = (Boolean) vlocitySettingsMap.get(
                                'isSeparateCalculationProcedureVersions'
                            );
                            isLWCActivation = (Boolean) vlocitySettingsMap.get('isLWCActivation');
                            apexCode = (String) vlocitySettingsMap.get('apexCode');
                            isEnabledApexPostDeploy = String.isNotBlank(apexCode);
                        } catch (Exception e) {
                        }
                    }
                    VlocityService.deployFromBranch(
                        metadataLogNext.Organisation__c,
                        metadataLogNext.Branch__c,
                        metadataLogNext.Id,
                        attLogsList[0].Id,
                        vlocityComponentsIds,
                        isSeparateMatrixVersions,
                        isSeparateCalculationProcedureVersions,
                        isEnabledApexPostDeploy,
                        isLWCActivation,
                        apexCode
                    );
                } else {
                    completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                }
            } else {
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, true);
            }
        } else if (!isDeploy && metadataLogNext.Is_Vlocity__c) {
            completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, true);
        } else if (
            metadataLogNext.Process_Type__c == B2CConstants.PROCESS_STRING_MAP.get(B2CConstants.Process.DEPLOY_BRANCH)
        ) {
            List<Attachment> attComp = [
                SELECT Body, BodyLength
                FROM Attachment
                WHERE ParentId = :metadataLogNext.Id AND Name = 'List Components'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            String listComp = !attComp.isEmpty() ? attComp[0].Body.toString() : '[]';

            if (isDeltaDeploy && listComp == '[]') {
                logger.log('All components are already deployed in the target organization for Delta deployment.');
                logger.updateLog('Logs');
                completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, true);
            } else {
                Set<Id> idsSet = (Set<Id>) JSON.deserialize(listComp, Set<Id>.class);

                List<Component__c> listB2CComponents = [
                    SELECT Id
                    FROM Component__c
                    WHERE Id IN :idsSet
                    WITH SECURITY_ENFORCED
                    LIMIT 49500
                ];
                if (!listB2CComponents.isEmpty()) {
                    List<Id> B2CComponentsIds = new List<Id>();
                    for (Component__c comp : listB2CComponents) {
                        B2CComponentsIds.add(comp.Id);
                    }

                    String codeVersionName = String.isBlank(
                            metadataLogNext.PipelineStepId__r.Pipeline__r.Code_Version_Name__c
                        )
                        ? B2CController.getNewCodeVersionName()
                        : metadataLogNext.PipelineStepId__r.Pipeline__r.Code_Version_Name__c;

                    B2CController.deployBranch(
                        metadataLogNext.Organisation__c,
                        metadataLogNext.Branch__c,
                        metadataLogNext.Deployment_Name__c,
                        B2CComponentsIds,
                        codeVersionName,
                        metadataLogNext.PipelineStepId__r.Pipeline__r.Use_Certificate__c,
                        metadataLogNext.PipelineStepId__r.Pipeline__r.Compile_Cartridges__c,
                        metadataLogNext.PipelineStepId__r.Pipeline__r.Activate_Code_Version__c,
                        String.isNotBlank(B2CService.getAgentUrl()),
                        metadataLogNext.Id
                    );
                }
            }
        } else if (
            metadataLogNext.Process_Type__c == B2CConstants.PROCESS_STRING_MAP.get(B2CConstants.Process.VALIDATE_BRANCH)
        ) {
            List<Attachment> attComp = [
                SELECT Body, BodyLength
                FROM Attachment
                WHERE ParentId = :metadataLogNext.Id AND Name = 'List Components'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            String componentsJson = !attComp.isEmpty() ? attComp[0].Body.toString() : '[]';
            List<Id> componentIds = (List<Id>) JSON.deserialize(componentsJson, List<Id>.class);

            List<Component__c> components = B2CService.getComponents(componentIds);
            List<Id> cartridgeComponentIds = new List<Id>();
            Boolean isContainedPackageJson = false;

            for (Component__c component : components) {
                if (component.Component_Type__c == B2CConstants.CARTRIDGE_TYPE) {
                    cartridgeComponentIds.add(component.Id);
                    if (component.Component_Name__c?.toLowerCase() == 'package.json') {
                        isContainedPackageJson = true;
                    }
                }
            }

            if (!cartridgeComponentIds.isEmpty()) {
                if (isContainedPackageJson) {
                    logger.log('Start Lint validation in Agent.');
                    logger.updateLog('Logs');
                    B2CController.agentLintValidation(
                        metadataLogNext.Id,
                        metadataLogNext.Branch__c,
                        cartridgeComponentIds,
                        true
                    );
                } else {
                    logger.log('Lint failed to start, package.json not found.');
                    logger.updateLog('Logs');
                    B2CService.setMetadataLogValidateStatus(metadataLogNext.Id, false);
                }
            } else {
                logger.log('Lint failed to start and was skipped, cartridge files not found.');
                logger.updateLog('Logs');
                B2CService.setMetadataLogValidateStatus(metadataLogNext.Id, true);
            }
        } else {
            List<Attachment> attList = new List<Attachment>();

            attList = [
                SELECT Body, ParentId
                FROM Attachment
                WHERE
                    ParentId = :metadataLogNext.Branch__c
                    AND Description = :'Build' + metadataLogNext.Batch_Job_Id__c
                    AND Name = :('Build' + metadataLogNext.Organisation__c).substring(0, 20)
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Boolean isAgentPipeline = false;
            if (metadataLogNext.Options__c != null) {
                Options opt = (Options) System.JSON.deserialize(mdl.Options__c, Options.class);
                if (opt != null && opt.isAgentPipeline != null && opt.isAgentPipeline) {
                    isAgentPipeline = true;
                }
            }

            String listComp = '[]';
            String listDest = '[]';
            List<Attachment> attComp = [
                SELECT Id, Body
                FROM Attachment
                WHERE ParentId = :metadataLogNext.Id AND Name = 'List Components'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (!attComp.isEmpty()) {
                listComp = attComp[0].Body.toString();
            }
            List<Attachment> attDest = [
                SELECT Id, Body
                FROM Attachment
                WHERE ParentId = :metadataLogNext.Id AND Name = 'List Destructive Changes'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (!attDest.isEmpty()) {
                listDest = attDest[0].Body.toString();
            }

            if (!String.isBlank(FlosumUtils.getAgentAppURL()) && isAgentPipeline) {
                metadataLogNext.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                DatabaseUtils.updateRecord(
                    metadataLogNext,
                    new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Status__c.getDescribe() }
                );
                Boolean isFullBranchDeploy = false;

                isFullBranchDeploy = metadataLogNext.PipelineStepId__r.Pipeline__r.Full_Deploy__c;

                if (isDeltaDeploy && listComp == '[]' && listDest == '[]') {
                    logger.log('All components are already deployed in the target organization for Delta deployment.');
                    logger.updateLog('Logs');
                    completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, true);
                } else {
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
                    System.schedule(
                        'MetadataDeployControllerBackup ' + sysTime.getTime(),
                        chronExpression,
                        new MetadataDeployController(
                            metadataLogNext.Branch__c,
                            metadataLogNext.Organisation__c,
                            metadataLogNext.Id,
                            listComp,
                            listDest,
                            isFullBranchDeploy
                        )
                    );
                }
            } else {
                if (attList.size() == 1) {
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
                    System.schedule(
                        'ApexDeploymentScheduleForBranch ' + sysTime.getTime(),
                        chronExpression,
                        new ApexDeploymentScheduleForBranch(
                            metadataLogNext.Branch__c,
                            metadataLogNext.Organisation__c,
                            metadataLogNext.Id,
                            attList[0].Id
                        )
                    );
                } else if (isDeltaDeploy && listComp == '[]' && listDest == '[]') {
                    logger.log('All components are already deployed in the target organization for Delta deployment.');
                    logger.updateLog('Logs');
                    completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, true);
                } else {
                    completeMetadataLog(metadataLogNext, FlosumConstants.STATUS_COMPLETED, false);
                }
            }
        }
        return true;
    }

    public void completeMetadataLog(Metadata_Log__c metadataLog, String status, Boolean isSucceed) {
        metadataLog.Job_Completed__c = true;
        metadataLog.Succeed__c = isSucceed;
        metadataLog.Status__c = status;
        metadataLog.Completed_Date__c = Datetime.now();
        DatabaseUtils.updateRecord(
            metadataLog,
            new List<Schema.DescribeFieldResult>{
                Metadata_Log__c.Job_Completed__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Completed_Date__c.getDescribe(),
                Metadata_Log__c.Succeed__c.getDescribe()
            }
        );
        Model.Logger logger = new Model.Logger('Logs', metadataLog.Id, 2000000, false);
        String result = isSucceed ? 'Successfully' : 'Unsuccessfully';
        logger.log('Step Completed ' + result);
        logger.updateLog('Logs');
    }

    public void createErrorLog(Metadata_Log__c metadataLog, String name, String errorMessage) {
        Attachment attError = new Attachment(
            ParentId = metadataLog.Id, // attach error log to metadata log
            Name = name,
            Body = Blob.valueOf('ERROR: ' + errorMessage),
            ContentType = 'text/plain'
        );
        DatabaseUtils.insertRecord(
            attError,
            new List<Schema.DescribeFieldResult>{
                Attachment.ParentId.getDescribe(),
                Attachment.Name.getDescribe(),
                Attachment.Body.getDescribe(),
                Attachment.ContentType.getDescribe()
            }
        );
    }

    public void createSuccessLog(Metadata_Log__c metadataLog, String name, String message) {
        Attachment att = new Attachment(
            ParentId = metadataLog.Id, // attach log to metadata log
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

    public class DestrChanges {
        public String message { get; set; }
        public List<String> deletedSet { get; set; }
        public List<String> updatedSet { get; set; }
        public List<String> createdSet { get; set; }

        public DestrChanges(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'message') {
                            message = parser.getText();
                        } else if (text == 'deletedSet') {
                            deletedSet = arrayOfString(parser);
                        } else if (text == 'updatedSet') {
                            updatedSet = arrayOfString(parser);
                        } else if (text == 'createdSet') {
                            createdSet = arrayOfString(parser);
                        }
                    }
                }
            }
        }

        private List<String> arrayOfString(System.JSONParser p) {
            List<String> res = new List<String>();
            if (p.getCurrentToken() == null) {
                p.nextToken();
            }
            while (p.nextToken() != System.JSONToken.END_ARRAY) {
                res.add(p.getText());
            }
            return res;
        }
    }
}