public with sharing class RunPipelineController {
    public Branch__c branchRec { get; private set; }

    public String selectedBranch { get; set; }
    public String metadataTypeStr { get; private set; }

    public String desChanId { get; set; }
    public String idsList { get; set; }
    public transient String commitChunkJSON { get; set; }
    public List<SelectOption> pipeOptions { get; set; }
    public String selectedPipeline { get; set; }
    public Map<String, String> mapPipeline { get; set; }
    public String delPipelineSchedulerId { get; set; }
    ApexPages.StandardController customApexController = null;

    public String srcBranchName { get; set; }
    public String srcBranchNameEsc { get; set; }
    public String srcRepoName { get; set; }
    public String srcRepoNameEsc { get; set; }
    public String msg { get; set; }
    public Integer errorCode { get; set; }
    public Integer countComponents { get; set; }

    public String patchId { get; set; }
    public String repId { get; set; }
    public String tests { get; set; }
    public String jsonStr { get; set; }
    public String logId { get; set; }
    public String logAttId { get; set; }
    public String patchListJSON { get; set; }
    public String logsListJSON { get; set; }
    public Boolean validateOnly { get; set; }
    public Boolean autoRun { get; set; }
    public Boolean isAgent { get; set; }
    public Boolean isSchedulePipelineAvailable { get; set; }
    public Boolean partRun { get; set; }
    public Boolean repoRun { get; set; }
    public Boolean branchRun { get; set; }
    public String message { get; set; }
    public String mergeSetName { get; set; }
    public Boolean isClosed { get; set; }
    public Boolean isProfileValidation { get; set; }
    public Boolean isPermissionSetValidation { get; set; }
    public Boolean isSkipBackup { get; set; }
    public String buildAttId { get; set; }
    public String locale { get; set; }
    public String timezone { get; set; }
    public Integer localApiVersion { get; private set; }
    public String idsSet { get; set; }
    public String metadataComponentsIdsString { get; set; }
    public String vlocityComponentsIdsString { get; set; }

    public List<SelectOption> frequencyOptions { get; set; }
    public String selectedFrequency { get; set; }

    public List<SelectOption> dayOfWeekOptions { get; set; }
    public List<String> selecteddayOfWeek { get; set; }
    public List<String> typesWithMeta { get; set; }

    public List<SelectOption> monthlyDateOptions { get; set; }
    public String selectedMonthlyDate { get; set; }
    public List<SelectOption> monthOptions { get; set; }
    public String selectedMonth { get; set; }

    public List<SelectOption> preferedTimeOptions { get; set; }
    public String selectedPreferedTime { get; set; }

    public List<SelectOption> preferedTimeMinuteOptions { get; set; }
    public String selectedPreferedMinute { get; set; }
    public String pipeSchedulerName { get; set; }
    public List<CronTrigger> cronTriggers { get; set; }

    public String latestDeployedComponentsJSON { get; set; }
    public String latestDeployedDestructiveChangesJSON { get; set; }

    public Map<String, Set<String>> deployedTestClasses { get; set; }
    public Boolean isDeltaDeployment { get; set; }
    public String branchRecordTypeName { get; set; }
    public Boolean isPipelineSelectListDisabled { get; set; }

    public RunPipelineController(ApexPages.StandardController controller) {
        customApexController = controller;
        locale = UserInfo.getLocale().replace('_', '-');
        timezone = UserInfo.getTimeZone().getID();
        localApiVersion = FlosumConstants.apiversion;
        errorCode = 0;
        countComponents = 0;
        desChanId = '[]';
        idsList = '';
        idsSet = '[]';
        metadataComponentsIdsString = '';
        vlocityComponentsIdsString = '';
        pipeOptions = new List<SelectOption>();
        branchRec = (Branch__c) controller.getRecord();
        srcBranchName = branchRec.Branch_Name__c;
        srcBranchNameEsc = String.escapeSingleQuotes(srcBranchName);
        autoRun = false;
        partRun = false;
        repoRun = false;
        branchRun = false;
        isAgent = false;

        deployedTestClasses = new Map<String, Set<String>>();
        latestDeployedComponentsJSON = '[]';
        latestDeployedDestructiveChangesJSON = '[]';

        isDeltaDeployment = false;
        isPipelineSelectListDisabled = false;

        typesWithMeta = new List<String>{
            'ApexClass',
            'ApexTrigger',
            'ApexComponent',
            'EmailTemplate',
            'StaticResource',
            'Document',
            'ApexPage',
            'WaveComponent'
        };

        branchRecordTypeName = [SELECT RecordType.Name FROM Branch__c WHERE Id = :branchRec.Id WITH SECURITY_ENFORCED]
        .RecordType.Name;

        isSchedulePipelineAvailable =
            (String.isNotBlank(FlosumUtils.getAgentAppURL()) || branchRecordTypeName == B2CConstants.TYPE) &&
            FlosumFeature.hasFeaturePermission(FlosumFeature.FEATURE_SCHEDULE_PIPELINE);

        mergeSetName = 'MERGEBRANCHSET' + Datetime.now().getTime();
        selectedBranch = controller.getId();
        pipeSchedulerName = 'Schedule Pipeline. Branch:' + srcBranchNameEsc + '%';
        cronTriggers = [
            SELECT
                CronJobDetail.Name,
                CreatedBy.Name,
                CreatedDate,
                CronExpression,
                EndTime,
                Id,
                NextFireTime,
                PreviousFireTime,
                StartTime,
                State,
                TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE :pipeSchedulerName
        ];
        mapPipeline = new Map<String, String>();
        delPipelineSchedulerId = '';
        BranchPermissionController.MoveForwardPermission checkResult = BranchPermissionController.allowUserToMoveForwardFromBranch(
            selectedBranch,
            BranchPermissionController.Run_Pipelines
        );
        if (checkResult.isSuccess) {
            listPipelines(selectedBranch);
            initCrone();
            String pId = ApexPages.currentPage().getParameters().get('pipeId') != null
                ? ApexPages.currentPage().getParameters().get('pipeId')
                : null;

            if (pId != null) {
                selectedPipeline = pId;
                autoRun = true;
                String mergeName = ApexPages.currentPage().getParameters().get('mergeSetName') != null
                    ? ApexPages.currentPage().getParameters().get('mergeSetName')
                    : null;
                if (mergeName != null) {
                    mergeSetName = mergeName;
                    partRun = true;
                    // restore IdSet

                    List<Attachment> mergeSetAtt = [
                        SELECT Id, Body, BodyLength
                        FROM Attachment
                        WHERE ParentId = :branchRec.Id AND Name = :mergeSetName
                        WITH SECURITY_ENFORCED
                        ORDER BY LastModifiedDate DESC
                        LIMIT 1
                    ];

                    if (mergeSetAtt.size() == 1 && mergeSetAtt[0].BodyLength != 0) {
                        idsSet = mergeSetAtt[0].Body.toString();
                    }

                    String idsDestructiveChanges = ApexPages.currentPage().getParameters().get('idsDestr') != null
                        ? ApexPages.currentPage().getParameters().get('idsDestr')
                        : null;
                    if (idsDestructiveChanges != null) {
                        desChanId = idsDestructiveChanges;
                    }
                } else {
                    Set<String> ids = new Set<String>();
                    for (Component__c c : [
                        SELECT Id
                        FROM Component__c
                        WHERE Branch__c = :branchRec.Id AND RecordType.Name = 'Branch'
                        WITH SECURITY_ENFORCED
                        LIMIT 40000
                    ]) {
                        ids.add(c.Id);
                    }
                    idsSet = JSON.serialize(ids);

                    Map<Id, Destructive_Changes__c> branchDestructiveChangesMap = new Map<Id, Destructive_Changes__c>(
                        [SELECT Id FROM Destructive_Changes__c WHERE Branch__c = :branchRec.Id WITH SECURITY_ENFORCED]
                    );
                    if (!branchDestructiveChangesMap.isEmpty()) {
                        desChanId = JSON.serialize(branchDestructiveChangesMap.keySet());
                    }
                }

                String reposId = ApexPages.currentPage().getParameters().get('repId') != null
                    ? ApexPages.currentPage().getParameters().get('repId')
                    : null;
                if (reposId != null) {
                    partRun = true;
                    repoRun = true;

                    List<Repository__c> reps = [
                        SELECT Id, Name
                        FROM Repository__c
                        WHERE Id = :reposId
                        WITH SECURITY_ENFORCED
                    ];

                    if (reps.size() > 0) {
                        repId = reps[0].Id;
                        srcRepoName = reps[0].Name;
                        srcRepoNameEsc = String.escapeSingleQuotes(srcRepoName);
                    }
                }

                String listId = ApexPages.currentPage().getParameters().get('listIds') != null
                    ? ApexPages.currentPage().getParameters().get('listIds')
                    : null;
                if (listId != null) {
                    // restore listId
                    List<Attachment> mergeSetAtt = [
                        SELECT Id, Body, Bodylength
                        FROM Attachment
                        WHERE Id = :listId
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];

                    if (mergeSetAtt.size() == 1 && mergeSetAtt[0].BodyLength != 0) {
                        idsList = mergeSetAtt[0].Body.toString();
                        if (idsSet == '') {
                            idsSet = idsList;
                        }
                    }
                }
            } else {
                Set<String> ids = new Set<String>();
                for (Component__c c : [
                    SELECT Id
                    FROM Component__c
                    WHERE Branch__c = :branchRec.Id AND RecordType.Name = 'Branch'
                    WITH SECURITY_ENFORCED
                    LIMIT 40000
                ]) {
                    ids.add(c.Id);
                }
                idsSet = JSON.serialize(ids);

                Map<Id, Destructive_Changes__c> branchDestructiveChangesMap = new Map<Id, Destructive_Changes__c>(
                    [SELECT Id FROM Destructive_Changes__c WHERE Branch__c = :branchRec.Id WITH SECURITY_ENFORCED]
                );
                if (!branchDestructiveChangesMap.isEmpty()) {
                    desChanId = JSON.serialize(branchDestructiveChangesMap.keySet());
                }
            }

            String srcName = ApexPages.currentPage().getParameters().get('srcBranchName') != null
                ? ApexPages.currentPage().getParameters().get('srcBranchName')
                : null;
            if (srcName != null) {
                srcBranchName = srcName;
                branchRun = true;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, checkResult.errorMessage));
        }

        if (branchRecordTypeName == B2CConstants.TYPE && autoRun) {
            Set<Id> organizationIds = getOrganisationIdsFromDeploySteps(selectedPipeline);

            if (!organizationIds.isEmpty() && haveB2COrgsAnyActiveProcess(organizationIds)) {
                String orgName = getB2COrgNameFromFirstActiveProcess(organizationIds);

                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        B2CController.getB2CProcessInProgressErrorMessage(orgName)
                    )
                );
                idsSet = null;
                selectedPipeline = null;
                autoRun = false;
            }
        }

        if (idsSet != null && idsSet != '') {
            Set<String> ids = new Set<String>();
            Set<String> metadataComponentsSet = new Set<String>();
            Set<String> vlocityComponentsSet = new Set<String>();
            ids = (Set<String>) JSON.deserialize(idsSet, Set<String>.class);
            for (Component__c metadataOnlyComponentsList : [
                SELECT Id, Component_Type__c
                FROM Component__c
                WHERE
                    (Branch__c = :branchRec.Id
                    OR Repository__c = :repId)
                    AND Vlocity_Component__c = FALSE
                    AND Id IN :ids
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ]) {
                metadataComponentsSet.add(metadataOnlyComponentsList.Id);
                if (typesWithMeta.contains(metadataOnlyComponentsList.Component_Type__c)) {
                    countComponents = countComponents + 2;
                } else {
                    countComponents++;
                }
            }
            for (Component__c vlocityOnlyComponentsList : [
                SELECT Id
                FROM Component__c
                WHERE
                    (Branch__c = :branchRec.Id
                    OR Repository__c = :repId)
                    AND Vlocity_Component__c = TRUE
                    AND Id IN :ids
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ]) {
                vlocityComponentsSet.add(vlocityOnlyComponentsList.Id);
            }
            metadataComponentsIdsString = JSON.serialize(metadataComponentsSet);
            vlocityComponentsIdsString = JSON.serialize(vlocityComponentsSet);
            if (countComponents > 9996) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'This branch has too many files. Deployments are limited to 10000 files.'
                    )
                );
            }
        }
    }

    public void listPipelines(String brId) {
        pipeOptions.clear();
        pipeOptions.add(new SelectOption('', '--None--'));

        List<Branch__c> branchList = [
            SELECT Id, Repository__c, Repository__r.Show_Available_Pipelines_Only__c, RecordType.Name
            FROM Branch__c
            WHERE Id = :brId
            WITH SECURITY_ENFORCED
        ];
        Boolean isShowAllPipelines = !branchList[0].Repository__r.Show_Available_Pipelines_Only__c;

        if (ApexPages.currentPage().getParameters().get('pipeId') != null || isShowAllPipelines) {
            for (Pipeline__c pl : [
                SELECT Id, Name
                FROM Pipeline__c
                WHERE RecordType.Name IN :FlosumConstants.getPipelineTypes(branchList[0].RecordType.Name)
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 999
            ]) {
                pipeOptions.add(new SelectOption(pl.Id, pl.Name));
                mapPipeline.put(pl.Id, pl.Name);
            }
        } else {
            Set<String> pipelineSet = new Set<String>();
            for (Available_Pipeline__c ap : [
                SELECT Id, Pipeline__c
                FROM Available_Pipeline__c
                WHERE Repository__c = :branchList[0].Repository__c
                WITH SECURITY_ENFORCED
            ]) {
                pipelineSet.add(ap.Pipeline__c);
            }
            for (Pipeline__c pl : [
                SELECT Id, Name
                FROM Pipeline__c
                WHERE
                    Id IN :pipelineSet
                    AND RecordType.Name IN :FlosumConstants.getPipelineTypes(branchList[0].RecordType.Name)
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 999
            ]) {
                pipeOptions.add(new SelectOption(pl.Id, pl.Name));
                mapPipeline.put(pl.Id, pl.Name);
            }
        }
    }

    public PageReference cancel() {
        return customApexController.cancel();
    }

    /** Start Scheduler Pipeline **/

    public void schedulePipeline() {
        try {
            String seconds = '0';
            String Minutes = selectedPreferedMinute;
            String Hours = selectedPreferedTime;
            String Day_of_month = '?';
            String Month = '*';
            String Day_of_week = '?';
            String optional_year = '';
            if (selectedFrequency == 'Monthly' && selectedMonthlyDate != null) {
                Day_of_month = '';
                Day_of_month = selectedMonthlyDate;
            } else if (selectedFrequency == 'Weekly' && selecteddayOfWeek != null) {
                Day_of_week = '';
                for (String dayOfWeek : selecteddayOfWeek) {
                    if (Day_of_week == '') {
                        Day_of_week += dayOfWeek;
                    } else {
                        Day_of_week += ',' + dayOfWeek;
                    }
                }
                if (Day_of_week == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a day.'));
                    return;
                }
            } else if (selectedFrequency == 'Once') {
                //Day_of_month = '';
                Day_of_month = selectedMonthlyDate;
                Month = selectedMonth;
                optional_year = String.valueOf(System.now().year());
                String dateString =
                    System.now().year() +
                    '-' +
                    convertMonthTextToNumber(selectedMonth) +
                    '-' +
                    selectedMonthlyDate;
                Date myDate = Date.valueOf(dateString);
                if (myDate < System.now().date()) {
                    optional_year = String.valueOf(System.now().year() + 1);
                }
            }
            if (String.isEmpty(selectedBranch)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Branch.'));
                return;
            }
            if (String.isEmpty(selectedPipeline)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Pipeline.'));
                return;
            }
            String selectedPipelineName = mapPipeline.get(selectedPipeline);
            String cronExpression =
                '' +
                seconds +
                ' ' +
                Minutes +
                ' ' +
                Hours +
                ' ' +
                Day_of_month +
                ' ' +
                Month +
                ' ' +
                Day_of_week +
                ' ' +
                optional_year;
            String jobName =
                'Schedule Pipeline. Branch:' +
                srcBranchNameEsc +
                '. Pipeline:' +
                selectedPipelineName +
                '. ' +
                System.now().format('yyyy-MM-dd h:mm:ss a');
            String jobId = System.schedule(
                jobName,
                cronExpression,
                new SchedulePipeline(selectedPipeline, selectedBranch)
            );

            String statusMessage =
                'The Pipeline has been scheduled. Please monitor the job ' +
                jobName +
                ' (' +
                jobId +
                ') to check the progress.';
            cronTriggers = [
                SELECT
                    CronJobDetail.Name,
                    CreatedBy.Name,
                    CreatedDate,
                    CronExpression,
                    EndTime,
                    Id,
                    NextFireTime,
                    PreviousFireTime,
                    StartTime,
                    State,
                    TimesTriggered
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :pipeSchedulerName
            ];
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, statusMessage));
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }

    public void deletePipelineScheduler() {
        try {
            if (delPipelineSchedulerId != '') {
                List<CronTrigger> cronTriggersList = [SELECT Id FROM CronTrigger WHERE Id = :delPipelineSchedulerId];
                if (!cronTriggersList.isEmpty()) {
                    System.abortJob(cronTriggersList[0].Id);
                    delPipelineSchedulerId = '';
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Schedule Pipeline has been deleted')
                    );
                }
            }
            cronTriggers = [
                SELECT
                    CronJobDetail.Name,
                    CreatedBy.Name,
                    CreatedDate,
                    CronExpression,
                    EndTime,
                    Id,
                    NextFireTime,
                    PreviousFireTime,
                    StartTime,
                    State,
                    TimesTriggered
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :pipeSchedulerName
            ];
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public void initCrone() {
        selecteddayOfWeek = new List<String>();
        preferedTimeMinuteOptions = new List<SelectOption>();
        frequencyOptions = new List<SelectOption>();
        dayOfWeekOptions = new List<SelectOption>();
        monthlyDateOptions = new List<SelectOption>();
        monthOptions = new List<SelectOption>();
        preferedTimeOptions = new List<SelectOption>();
        frequencyOptions.add(new SelectOption('Once', 'Once'));
        frequencyOptions.add(new SelectOption('Weekly', 'Weekly'));
        frequencyOptions.add(new SelectOption('Monthly', 'Monthly'));
        selectedFrequency = 'Weekly';
        dayOfWeekOptions.add(new SelectOption('SUN', 'Sunday'));
        dayOfWeekOptions.add(new SelectOption('MON', 'Monday'));
        dayOfWeekOptions.add(new SelectOption('TUE', 'Tuesday'));
        dayOfWeekOptions.add(new SelectOption('WED', 'Wednesday'));
        dayOfWeekOptions.add(new SelectOption('THU', 'Thursday'));
        dayOfWeekOptions.add(new SelectOption('FRI', 'Friday'));
        dayOfWeekOptions.add(new SelectOption('SAT', 'Saturday'));
        for (Integer index = 1; index <= 31; index++) {
            monthlyDateOptions.add(new SelectOption('' + index, '' + index));
        }
        monthlyDateOptions.add(new SelectOption('L', 'last'));
        Integer currentDay = System.now().day();
        Integer currentMonth = System.now().month();
        Integer currentHour = System.now().hour();
        Integer currentMinut = System.now().minute();
        selectedMonthlyDate = String.valueOf(currentDay);
        selectedMonth = convertNumberToMonthText(currentMonth);
        selectedPreferedTime = String.valueOf(currentHour);
        selectedPreferedMinute = String.valueOf(currentMinut);
        monthOptions.add(new SelectOption('JAN', 'January'));
        monthOptions.add(new SelectOption('FEB', 'February'));
        monthOptions.add(new SelectOption('MAR', 'March'));
        monthOptions.add(new SelectOption('APR', 'April'));
        monthOptions.add(new SelectOption('MAY', 'May'));
        monthOptions.add(new SelectOption('JUN', 'June'));
        monthOptions.add(new SelectOption('JUL', 'July'));
        monthOptions.add(new SelectOption('AUG', 'August'));
        monthOptions.add(new SelectOption('SEP', 'September'));
        monthOptions.add(new SelectOption('OCT', 'October'));
        monthOptions.add(new SelectOption('NOV', 'November'));
        monthOptions.add(new SelectOption('DEC', 'December'));
        preferedTimeOptions.add(new SelectOption('0', '12 AM'));
        preferedTimeOptions.add(new SelectOption('1', '1 AM'));
        preferedTimeOptions.add(new SelectOption('2', '2 AM'));
        preferedTimeOptions.add(new SelectOption('3', '3 AM'));
        preferedTimeOptions.add(new SelectOption('4', '4 AM'));
        preferedTimeOptions.add(new SelectOption('5', '5 AM'));
        preferedTimeOptions.add(new SelectOption('6', '6 AM'));
        preferedTimeOptions.add(new SelectOption('7', '7 AM'));
        preferedTimeOptions.add(new SelectOption('8', '8 AM'));
        preferedTimeOptions.add(new SelectOption('9', '9 AM'));
        preferedTimeOptions.add(new SelectOption('10', '10 AM'));
        preferedTimeOptions.add(new SelectOption('11', '11 AM'));
        preferedTimeOptions.add(new SelectOption('12', '12 PM'));
        preferedTimeOptions.add(new SelectOption('13', '1 PM'));
        preferedTimeOptions.add(new SelectOption('14', '2 PM'));
        preferedTimeOptions.add(new SelectOption('15', '3 PM'));
        preferedTimeOptions.add(new SelectOption('16', '4 PM'));
        preferedTimeOptions.add(new SelectOption('17', '5 PM'));
        preferedTimeOptions.add(new SelectOption('18', '6 PM'));
        preferedTimeOptions.add(new SelectOption('19', '7 PM'));
        preferedTimeOptions.add(new SelectOption('20', '8 PM'));
        preferedTimeOptions.add(new SelectOption('21', '9 PM'));
        preferedTimeOptions.add(new SelectOption('22', '10 PM'));
        preferedTimeOptions.add(new SelectOption('23', '11 PM'));
        for (Integer index = 0; index < 60; index++) {
            preferedTimeMinuteOptions.add(new SelectOption('' + index, '' + index));
        }
    }

    private static Integer convertMonthTextToNumber(String matrixMonth) {
        if (matrixMonth == 'JAN') {
            return 1;
        } else if (matrixMonth == 'FEB') {
            return 2;
        } else if (matrixMonth == 'MAR') {
            return 3;
        } else if (matrixMonth == 'APR') {
            return 4;
        } else if (matrixMonth == 'MAY') {
            return 5;
        } else if (matrixMonth == 'JUN') {
            return 6;
        } else if (matrixMonth == 'JUL') {
            return 7;
        } else if (matrixMonth == 'AUG') {
            return 8;
        } else if (matrixMonth == 'SEP') {
            return 9;
        } else if (matrixMonth == 'OCT') {
            return 10;
        } else if (matrixMonth == 'NOV') {
            return 11;
        } else {
            return 12;
        }
    }
    private static String convertNumberToMonthText(Integer numberMonth) {
        if (numberMonth == 1) {
            return 'JAN';
        } else if (numberMonth == 2) {
            return 'FEB';
        } else if (numberMonth == 3) {
            return 'MAR';
        } else if (numberMonth == 4) {
            return 'APR';
        } else if (numberMonth == 5) {
            return 'MAY';
        } else if (numberMonth == 6) {
            return 'JUN';
        } else if (numberMonth == 7) {
            return 'JUL';
        } else if (numberMonth == 8) {
            return 'AUG';
        } else if (numberMonth == 9) {
            return 'SEP';
        } else if (numberMonth == 10) {
            return 'OCT';
        } else if (numberMonth == 11) {
            return 'NOV';
        } else {
            return 'DEC';
        }
    }

    public void changeEvent() {
    }
    /** End Scheduler Pipeline **/

    public void checkSelectedPipeline() {
        /*checking Pull Request approved for 'Add To Deployment' or not if Pipeline has RollBack or Deploy step*/
        Boolean isDeploymentFirst = true;
        DatabaseUtils.checkObjectsAndFieldsAccessibility(
            new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
                PipelineStep__c.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                    PipelineStep__c.Number__c.getDescribe(),
                    PipelineStep__c.Next_Step_Id_On_Fail__c.getDescribe(),
                    PipelineStep__c.Next_Step_Id_On_Pass__c.getDescribe(),
                    PipelineStep__c.Pipeline__c.getDescribe()
                }
            }
        );
        List<PipelineStep__c> stepsWithDeploymentLogicList = [
            SELECT Id, Number__c, Step__c, Next_Step_Id_On_Fail__c, Next_Step_Id_On_Pass__c
            FROM PipelineStep__c
            WHERE Pipeline__c = :selectedPipeline AND (Step__c = 'Rollback' OR Step__c = 'Deploy')
            WITH SECURITY_ENFORCED
            ORDER BY Number__c ASC
        ];
        List<PipelineStep__c> stepsWithPeerReviewList = [
            SELECT Id, Number__c, Step__c, Next_Step_Id_On_Fail__c, Next_Step_Id_On_Pass__c
            FROM PipelineStep__c
            WHERE Pipeline__c = :selectedPipeline AND Step__c = :FlosumConstants.PROCESS_PEER_REVIEW
            WITH SECURITY_ENFORCED
            ORDER BY Number__c ASC
        ];
        if (
            !stepsWithDeploymentLogicList.isEmpty() &&
            !stepsWithPeerReviewList.isEmpty() &&
            stepsWithDeploymentLogicList[0].Number__c > stepsWithPeerReviewList[0].Number__c
        ) {
            isDeploymentFirst = false;
        }
        if (stepsWithDeploymentLogicList.size() > 0 && isDeploymentFirst) {
            MetadataUtils.MoveForwardPermission MFP = MetadataUtils.allowUserToMoveForwardFromBranch(
                selectedBranch,
                FlosumConstants.PullRequestAddToDeploymentType
            );
            if (!MFP.isSuccess) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MFP.errorMessage));
                selectedPipeline = null;
                return;
            }
        }
        /*end of checking Pull Request*/

        if (branchRecordTypeName == B2CConstants.TYPE) {
            Set<Id> organizationIds = getOrganisationIdsFromDeploySteps(selectedPipeline);

            if (!organizationIds.isEmpty() && haveB2COrgsAnyActiveProcess(organizationIds)) {
                String orgName = getB2COrgNameFromFirstActiveProcess(organizationIds);

                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        B2CController.getB2CProcessInProgressErrorMessage(orgName)
                    )
                );
                selectedPipeline = null;
            }
            return;
        }
    }

    public Boolean haveB2COrgsAnyActiveProcess(Set<Id> organizationIds) {
        return B2CController.hasActiveMetadataLogs(organizationIds) && !Test.isRunningTest();
    }

    public static Set<Id> getOrganisationIdsFromDeploySteps(String pipelineId) {
        Set<Id> organizationIds = new Set<Id>();

        for (PipelineStep__c step : [
            SELECT Id, Step__c, Destination__c
            FROM PipelineStep__c
            WHERE Pipeline__c = :pipelineId AND Step__c = :FlosumConstants.PIPELINE_STEP_DEPLOY
            WITH SECURITY_ENFORCED
        ]) {
            if (String.isBlank(step.Destination__c)) {
                continue;
            }

            organizationIds.add(step.Destination__c);
        }

        return organizationIds;
    }

    public static String getB2COrgNameFromFirstActiveProcess(Set<Id> organizationIds) {
        List<Metadata_Log__c> metadataLogs = B2CService.getActiveMetadataLogs(organizationIds);

        if (metadataLogs.isEmpty() || String.isBlank(metadataLogs.get(0).Organisation__r.Name)) {
            return '';
        }

        return metadataLogs.get(0).Organisation__r.Name;
    }

    public void startPipeline() {
        Set<String> ids = new Set<String>();
        if (String.isNotBlank(idsSet)) {
            ids = (Set<String>) JSON.deserialize(idsSet, Set<String>.class);
        }

        Set<String> destructiveChangesIds = new Set<String>();
        if (String.isNotBlank(desChanId)) {
            destructiveChangesIds = (Set<String>) JSON.deserialize(desChanId, Set<String>.class);
        }

        Integer bodyLength = 0;
        for (Attachment att : [
            SELECT Id, BodyLength
            FROM Attachment
            WHERE
                ParentId IN (
                    SELECT Id
                    FROM Component_History__c
                    WHERE Component__c IN :ids AND isLastVersion__c = :true
                )
            WITH SECURITY_ENFORCED
        ]) {
            bodyLength += att.BodyLength;
        }

        Set<Id> organizationIds = new Set<Id>();
        for (PipelineStep__c step : [
            SELECT Id, Step__c, Destination__c
            FROM PipelineStep__c
            WHERE Pipeline__c = :selectedPipeline AND (Step__c = 'Deploy' OR Step__c = 'Validate')
            WITH SECURITY_ENFORCED
        ]) {
            if (String.isNotBlank(step.Destination__c)) {
                organizationIds.add(step.Destination__c);
            }
        }

        List<Pipeline__c> pipelines = [
            SELECT Delta_Deployment__c
            FROM Pipeline__c
            WHERE Id = :selectedPipeline
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!pipelines.isEmpty()) {
            isDeltaDeployment = pipelines[0].Delta_Deployment__c;
        }

        MetadataUtils.LatestDeployedInfo latestDeployedInfoResult = new MetadataUtils.LatestDeployedInfo(
            organizationIds
        );
        if (isDeltaDeployment && !repoRun) {
            latestDeployedInfoResult.getLatestDeployedInfo(branchRec.Id);
        }

        deployedTestClasses = latestDeployedInfoResult.deployedTestClasses;
        latestDeployedComponentsJSON = JSON.serialize(latestDeployedInfoResult.orgToDeployedComponentsMap);
        latestDeployedDestructiveChangesJSON = JSON.serialize(
            latestDeployedInfoResult.orgToDeployedDestructiveChangesMap
        );

        try {
            Integer countSteps = [
                SELECT COUNT()
                FROM PipelineStep__c
                WHERE Pipeline__c = :selectedPipeline
                WITH SECURITY_ENFORCED
            ];
            AnalyticsService.trackDetails(
                new Map<String, String>{ 'eventType' => 'Pipeline Run', 'branchId' => branchRec.Id },
                new Map<String, String>{
                    'pipeline_name' => mapPipeline.get(selectedPipeline),
                    'count_steps' => String.valueOf(countSteps)
                }
            );
        } catch (Exception e) {
        }
        isAgent =
            !String.isBlank(FlosumUtils.getAgentAppURL()) &&
            bodyLength > 4000000 &&
            branchRecordTypeName != B2CConstants.TYPE;

        if (partRun != true) {
            if (isAgent) {
                insertAtt(mergeSetName, branchRec.Id, idsSet);

                if (!ids.isEmpty() || !destructiveChangesIds.isEmpty()) {
                    try {
                        MetadataUtils.runPipeline(selectedBranch, selectedPipeline, '', mergeSetName, desChanId);
                    } catch (Exception e) {
                        msg = e.getMessage();
                        errorCode = 20;
                        return;
                    }
                } else {
                    msg = Label.Full_Branch_No_Components;
                    errorCode = 21;
                    return;
                }
            } else {
                try {
                    insertAtt(mergeSetName, branchRec.Id, idsSet);

                    if (ids.isEmpty() && destructiveChangesIds.isEmpty()) {
                        msg = Label.Full_Branch_No_Components;
                        errorCode = 22;
                        return;
                    }
                } catch (Exception ex) {
                    String errMsg = ex.getMessage();
                    msg = 'Error during full Pipeline run: ' + ex.getMessage();
                    errorCode = 23;
                    return;
                }
            }
        } else {
            if (isAgent) {
                if (!ids.isEmpty() || !destructiveChangesIds.isEmpty()) {
                    try {
                        MetadataUtils.runPipeline(selectedBranch, selectedPipeline, '', mergeSetName, desChanId);
                    } catch (Exception e) {
                        msg = e.getMessage();
                        errorCode = 26;
                        return;
                    }
                } else {
                    msg = Label.Partial_Branch_No_Components;
                    errorCode = 24;
                    return;
                }
            } else {
                if (ids.isEmpty() && destructiveChangesIds.isEmpty()) {
                    msg = Label.Partial_Branch_No_Components;
                    errorCode = 25;
                    return;
                }
            }
        }
    }

    private static void insertAtt(String mergeName, String parentId, String ids) {
        Attachment att = new Attachment(
            Body = Blob.valueOf(ids),
            ParentId = parentId,
            Description = 'MERGEBRANCHSET',
            Name = mergeName,
            ContentType = 'text/plain'
        );
        DatabaseUtils.insertRecord(
            att,
            new List<Schema.DescribeFieldResult>{
                Attachment.Body.getDescribe(),
                Attachment.Name.getDescribe(),
                Attachment.Description.getDescribe(),
                Attachment.ContentType.getDescribe(),
                Attachment.ParentId.getDescribe()
            }
        );
    }
    // added for CI
    public void insertMergeAttachment() {
        try {
            if (jsonStr != null && logId != null && patchId != null) {
                Attachment att = new Attachment();
                att.Name = 'Build';
                att.Body = EncodingUtil.base64Decode(jsonStr);
                //att.ParentId = patchId;
                att.ParentId = branchRec.Id;
                att.Description = 'Build' + logId;
                att.ContentType = 'application/zip';
                DatabaseUtils.insertRecord(
                    att,
                    new List<Schema.DescribeFieldResult>{
                        Attachment.Body.getDescribe(),
                        Attachment.Name.getDescribe(),
                        Attachment.Description.getDescribe(),
                        Attachment.ContentType.getDescribe(),
                        Attachment.ParentId.getDescribe()
                    }
                );
                buildAttId = att.Id;
            }
            jsonStr = null;
        } catch (Exception e) {
            jsonStr = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    //---------------------------repo------------------------

    @RemoteAction
    public static List<AttachmentWraper> getApexClassesContentRepo(String repoId, String compIds) {
        if (String.isBlank(compIds)) {
            return new List<AttachmentWraper>();
        }
        List<String> ids = new List<String>();
        ids = (List<String>) JSON.deserialize(compIds, List<String>.class);
        List<Repository__c> repoList = new List<Repository__c>();
        List<AttachmentWraper> attList = new List<AttachmentWraper>();

        repoList = [SELECT Id, Pipeline__c FROM Repository__c WHERE Id = :repoId WITH SECURITY_ENFORCED LIMIT 1];

        if (repoList.size() == 1) {
            if (repoList[0].Pipeline__c != null) {
                List<Id> compHist = new List<Id>();

                for (Component__c comp : [
                    SELECT Id, (SELECT Id, Version__c, CRC32__c FROM Components__r ORDER BY Version__c DESC LIMIT 1)
                    FROM Component__c
                    WHERE Id IN :ids AND Component_Type__c = 'ApexClass'
                    WITH SECURITY_ENFORCED
                ]) {
                    if (!comp.Components__r.isEmpty()) {
                        compHist.add(comp.Components__r[0].Id);
                    }
                }

                for (Attachment att : [
                    SELECT Id, Body, Description, ParentId
                    FROM Attachment
                    WHERE ParentId IN :compHist
                    WITH SECURITY_ENFORCED
                ]) {
                    AttachmentWraper wrap = new AttachmentWraper();
                    wrap.parentId = att.ParentId;
                    wrap.compType = att.Description;
                    wrap.base64 = EncodingUtil.base64Encode(att.Body);
                    attList.add(wrap);
                }
            }
        }

        return attList;
    }

    public void repoZipCreator() {
        errorCode = 1;
        logAttId = null;
        logId = null;
        message = '';

        try {
            List<Branch__c> brList = new List<Branch__c>();

            brList = [
                SELECT Id, Repository__c, Repository__r.Name, Repository__r.Pipeline__c, Branch_Name__c
                FROM Branch__c
                WHERE Id = :branchRec.Id
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (brList.size() == 1 && brList[0].Repository__c != null) {
                MetadataUtils.BuildWrapper bw = MetadataUtils.initMerge(
                    brList[0].Repository__r.Pipeline__c,
                    mergeSetName,
                    brList[0].Id,
                    brList[0].Branch_Name__c,
                    tests,
                    new Map<String, Set<String>>()
                );
                if (bw.msg == null || bw.msg == '') {
                    // no errors

                    if (brList[0].Repository__r.Pipeline__c != null) {
                        List<Pipeline__c> pipeList = [
                            SELECT Id, Deploy_entire_profile__c, Deploy_entire_Permission_Set__c, RecordType.Name
                            FROM Pipeline__c
                            WHERE Id = :brList[0].Repository__r.Pipeline__c
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                        ];
                        if (!pipeList.isEmpty()) {
                            isSkipBackup = pipeList[0].RecordType.Name == B2CConstants.TYPE;
                            isProfileValidation = !pipeList[0].Deploy_entire_profile__c;
                            isPermissionSetValidation = !pipeList[0].Deploy_entire_Permission_Set__c;
                        }
                    }

                    logId = bw.logId;
                    patchListJSON = bw.patchJson;
                    logsListJSON = bw.logsJson;
                    validateOnly = bw.validateOnly;
                    logAttId = bw.logAttId;
                    errorCode = 0;
                    saveComponentsAndDestructiveChangesList();
                } else {
                    message = bw.msg;
                }
            }
        } catch (Exception e) {
            message = e.getMessage();
        }
        //        return null;
    }

    //--------------------------end-repo------------------------

    @RemoteAction
    public static List<AttachmentWraper> getApexClassesContent(String branchId, String compIds) {
        List<Branch__c> brList = new List<Branch__c>();
        List<String> ids = new List<String>();
        if (compIds != null && compIds != '') {
            ids = (List<String>) JSON.deserialize(compIds, List<String>.class);
        }

        List<AttachmentWraper> attList = new List<AttachmentWraper>();

        brList = [
            SELECT Id, Branch_Name__c, Pipeline__c
            FROM Branch__c
            WHERE Id = :branchId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (brList.size() == 1) {
            List<Id> compHist = new List<Id>();

            for (Component__c comp : [
                SELECT Id, (SELECT Id, Version__c, CRC32__c FROM Components__r ORDER BY Version__c DESC LIMIT 1)
                FROM Component__c
                WHERE Branch__c = :branchId AND Component_Type__c = 'ApexClass' AND Id IN :ids
                WITH SECURITY_ENFORCED
            ]) {
                if (!comp.Components__r.isEmpty()) {
                    compHist.add(comp.Components__r[0].Id);
                }
            }

            for (Attachment att : [
                SELECT Id, Body, Description, ParentId
                FROM Attachment
                WHERE ParentId IN :compHist
                WITH SECURITY_ENFORCED
            ]) {
                AttachmentWraper wrap = new AttachmentWraper();
                wrap.parentId = att.ParentId;
                wrap.compType = att.Description;
                wrap.base64 = EncodingUtil.base64Encode(att.Body);
                attList.add(wrap);
            }
        }
        return attList;
    }
    // creates an empty set of patches (with Ids in patchListJSON)
    // transaction Id is in logId
    // set of History Component's Id is in attachment MERGE with id = logAttId
    public void branchZipCreator() {
        errorCode = 2;
        logAttId = null;
        logId = null;
        message = '';

        try {
            List<Branch__c> brList = new List<Branch__c>();
            brList = [
                SELECT Id, Branch_Name__c, Pipeline__c
                FROM Branch__c
                WHERE Id = :branchRec.Id
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (brList.size() == 1) {
                MetadataUtils.BuildWrapper bw = MetadataUtils.initMerge(
                    selectedPipeline,
                    mergeSetName,
                    brList[0].Id,
                    srcBranchName,
                    tests,
                    deployedTestClasses
                );

                if (bw.msg == null || bw.msg == '') {
                    // no errors

                    List<Pipeline__c> pipeList = [
                        SELECT Id, Deploy_entire_profile__c, Deploy_entire_Permission_Set__c, RecordType.Name
                        FROM Pipeline__c
                        WHERE Id = :selectedPipeline
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (!pipeList.isEmpty()) {
                        isSkipBackup = pipeList[0].RecordType.Name == B2CConstants.TYPE;
                        isProfileValidation = !pipeList[0].Deploy_entire_profile__c;
                        isPermissionSetValidation = !pipeList[0].Deploy_entire_Permission_Set__c;
                    }
                    logId = bw.logId;
                    patchListJSON = bw.patchJson;
                    validateOnly = bw.validateOnly;
                    logsListJSON = bw.logsJson;
                    logAttId = bw.logAttId;
                    errorCode = 0;
                    //addDestructiveToPatch(patchListJSON);
                    saveComponentsAndDestructiveChangesList();
                } else {
                    message = bw.msg;
                }
            } else {
                message = 'Target branch not found';
            }
        } catch (Exception e) {
            errorCode = 1;
            message = e.getMessage();
        }
    }

    public void saveComponentsAndDestructiveChangesList() {
        List<Attachment> attList = new List<Attachment>();

        List<String> mlIds = (List<String>) JSON.deserialize(logsListJSON, List<String>.class);
        Set<String> componentIds = (Set<String>) JSON.deserialize(idsSet, Set<String>.class);
        Set<String> destructiveChangeIds = (Set<String>) JSON.deserialize(desChanId, Set<String>.class);

        Set<Id> componentIdSet = new Set<Id>();
        Map<String, Id> cartridgeNameToIdMap = new Map<String, Id>();
        for (Component__c component : [
            SELECT Component_Type__c, Component_Name__c
            FROM Component__c
            WHERE (Branch__c = :branchRec.Id OR Repository__c = :repId) AND Id IN :componentIds
            WITH SECURITY_ENFORCED
            LIMIT 40000
        ]) {
            if (component.Component_Type__c == B2CConstants.CARTRIDGE_TYPE) {
                cartridgeNameToIdMap.put(component.Component_Name__c, component.Id);
            }
            componentIdSet.add(component.Id);
        }

        Set<Id> allCartridgeIdsSet = new Set<Id>(cartridgeNameToIdMap.values());
        if (!cartridgeNameToIdMap.isEmpty()) {
            List<Component__c> allCartridgesList = B2CService.getCartridgeComponents(branchRec.Id);

            for (Component__c component : allCartridgesList) {
                if (cartridgeNameToIdMap.containsKey(component.Component_Name__c)) {
                    continue;
                }
                allCartridgeIdsSet.add(component.Id);
            }
        }

        Set<Id> destructiveChangeIdSet = new Set<Id>();
        for (Destructive_Changes__c destructiveChange : [
            SELECT Id
            FROM Destructive_Changes__c
            WHERE Id IN :destructiveChangeIds
            WITH SECURITY_ENFORCED
            LIMIT 10000
        ]) {
            destructiveChangeIdSet.add(destructiveChange.Id);
        }

        Map<Id, Set<Id>> deployedComponentsMap = (Map<Id, Set<Id>>) JSON.deserialize(
            latestDeployedComponentsJSON,
            Map<Id, Set<Id>>.class
        );
        Map<Id, Set<Id>> deployedDestructiveChangesMap = (Map<Id, Set<Id>>) JSON.deserialize(
            latestDeployedDestructiveChangesJSON,
            Map<Id, Set<Id>>.class
        );

        Map<Id, Set<Id>> mapComponentNotDeployed = MetadataUtils.getMapComponentsNotDeployed(
            deployedComponentsMap,
            componentIdSet,
            new Set<Id>(cartridgeNameToIdMap.values()),
            allCartridgeIdsSet
        );
        Map<Id, Set<Id>> mapDestructiveChangesNotDeployed = MetadataUtils.getMapComponentsNotDeployed(
            deployedDestructiveChangesMap,
            destructiveChangeIdSet
        );

        for (Metadata_Log__c mlog : [
            SELECT Id, Organisation__c
            FROM Metadata_Log__c
            WHERE Id IN :mlIds
            WITH SECURITY_ENFORCED
            LIMIT 50
        ]) {
            String body = '[]';
            if (
                mlog.Organisation__c != null &&
                mapComponentNotDeployed.containsKey(mlog.Organisation__c) &&
                !mapComponentNotDeployed.get(mlog.Organisation__c).isEmpty()
            ) {
                body = JSON.serialize(mapComponentNotDeployed.get(mlog.Organisation__c));
            }
            Attachment attachmentComponents = new Attachment(
                Body = Blob.valueOf(body),
                Name = 'List Components',
                Description = 'List Components',
                ParentId = mlog.Id,
                ContentType = 'text/plain'
            );
            attList.add(attachmentComponents);

            body = '[]';
            if (
                mlog.Organisation__c != null &&
                mapDestructiveChangesNotDeployed.containsKey(mlog.Organisation__c) &&
                !mapDestructiveChangesNotDeployed.get(mlog.Organisation__c).isEmpty()
            ) {
                body = JSON.serialize(mapDestructiveChangesNotDeployed.get(mlog.Organisation__c));
            }
            Attachment attachmentDestructiveChanges = new Attachment(
                Body = Blob.valueOf(body),
                Name = 'List Destructive Changes',
                Description = 'List Destructive Changes',
                ParentId = mlog.Id,
                ContentType = 'text/plain'
            );
            attList.add(attachmentDestructiveChanges);
        }
        if (!attList.isEmpty()) {
            DatabaseUtils.insertRecords(
                attList,
                new List<Schema.DescribeFieldResult>{
                    Attachment.Body.getDescribe(),
                    Attachment.Name.getDescribe(),
                    Attachment.Description.getDescribe(),
                    Attachment.ParentId.getDescribe(),
                    Attachment.ContentType.getDescribe()
                }
            );
        }
    }

    public void addDestructiveToPatch(String patchJSON) {
        List<String> patchIdList = (List<String>) JSON.deserialize(patchJSON, List<String>.class);
        String depId = '';
        if (patchIdList.size() == 1) {
            depId = patchIdList[0];
            List<String> desChList = (List<String>) JSON.deserialize(desChanId, List<String>.class);

            List<Destructive_Changes__c> destList = [
                SELECT Id, Component_Name__c, Component_Type__c, Post_Deployment_Change__c
                FROM Destructive_Changes__c
                WHERE Id IN :desChList
                WITH SECURITY_ENFORCED
            ];
            List<Destructive_Manifest__c> dmList = new List<Destructive_Manifest__c>();
            for (Destructive_Changes__c ds : destList) {
                Destructive_Manifest__c dm = new Destructive_Manifest__c();
                dm.Patch__c = depId;
                dm.Component_Type__c = ds.Component_Type__c;
                dm.Component_Name2__c = ds.Component_Name__c;
                dm.Post_Deployment_Change__c = ds.Post_Deployment_Change__c;
                dmList.add(dm);
            }
            if (dmList.size() > 0) {
                DatabaseUtils.insertRecords(
                    dmList,
                    new List<Schema.DescribeFieldResult>{
                        Destructive_Manifest__c.Component_Name2__c.getDescribe(),
                        Destructive_Manifest__c.Component_Type__c.getDescribe(),
                        Destructive_Manifest__c.Post_Deployment_Change__c.getDescribe(),
                        Destructive_Manifest__c.Patch__c.getDescribe()
                    }
                );
            }
        }
    }

    public PageReference finalCall() {
        if (this.logId != null && this.logsListJSON != null) {
            List<String> mlIds = (List<String>) JSON.deserialize(this.logsListJSON, List<String>.class);
            if (!Test.isRunningTest()) {
                PipelineDeploymentResultBatch batch = new PipelineDeploymentResultBatch(
                    mlIds,
                    srcBranchName,
                    branchRun
                );
                Database.executeBatch(batch, 1);
            }

            List<Metadata_Log__c> metaLogFirst = [
                SELECT Id, Status__c
                FROM Metadata_Log__c
                WHERE Id IN :mlIds
                WITH SECURITY_ENFORCED
                ORDER BY Order__c ASC
                LIMIT 1
            ];
            if (!metaLogFirst.isEmpty()) {
                Model.Logger logger = new Model.Logger('Logs', metaLogFirst[0].Id, 2000000, false);
                logger.log('Starting first pipeline step.');
                logger.updateLog('Logs');
                metaLogFirst[0].Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                DatabaseUtils.updateRecord(
                    metaLogFirst[0],
                    new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Status__c.getDescribe() }
                );
            }
        }
        return null;
    }

    public PageReference complete() {
        if (repoRun == false) {
            return customApexController.cancel();
        } else {
            PageReference pref = Page.Repository;
            pref.getParameters().put('repoId', repId);
            return pref;
        }
    }

    @RemoteAction
    public static MergeDetailWraper getMergeDetail(String aId, String pipeId) {
        String componentListBody = '';
        String destructiveChangeListBody = '';

        List<Attachment> listComponentsAttachmentList = [
            SELECT Body, ParentId
            FROM Attachment
            WHERE ParentId = :aId AND Name = 'List Components'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!listComponentsAttachmentList.isEmpty()) {
            componentListBody = listComponentsAttachmentList[0].Body.toString();
        }

        List<Attachment> listDestructiveChangeAttachmentList = [
            SELECT Body, ParentId
            FROM Attachment
            WHERE ParentId = :aId AND Name = 'List Destructive Changes'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!listDestructiveChangeAttachmentList.isEmpty()) {
            destructiveChangeListBody = listDestructiveChangeAttachmentList[0].Body.toString();
        }
        List<String> desChList = new List<String>();
        if (String.isNotBlank(destructiveChangeListBody)) {
            desChList = (List<String>) JSON.deserialize(destructiveChangeListBody, List<String>.class);
        }

        Map<String, Set<String>> preMap = new Map<String, Set<String>>();
        Map<String, Set<String>> postMap = new Map<String, Set<String>>();

        List<String> parentIdList = new List<String>();
        List<String> componentIdList = new List<String>();
        if (String.isNotBlank(componentListBody)) {
            componentIdList = (List<String>) JSON.deserialize(componentListBody, List<String>.class);
        }
        for (Component__c component : [
            SELECT Id, (SELECT Id FROM Components__r ORDER BY Version__c DESC LIMIT 1)
            FROM Component__c
            WHERE Id IN :componentIdList
            WITH SECURITY_ENFORCED
        ]) {
            if (!component.Components__r.isEmpty()) {
                parentIdList.add(component.Components__r[0].Id);
            }
        }

        MergeDetailWraper wrap = new MergeDetailWraper();
        List<List<ZipDetailWraper>> tempAttIdList = new List<List<ZipDetailWraper>>();
        List<ZipDetailWraper> zipList = new List<ZipDetailWraper>();

        Integer bodyCount = 0;
        Map<String, List<CompDetailWraper>> compDetailMap = new Map<String, List<CompDetailWraper>>();

        for (Component_History__c history : [
            SELECT
                Component__r.Component_Name__c,
                (SELECT Id, BodyLength FROM Attachments ORDER BY LastModifiedDate DESC LIMIT 1),
                Component__r.Component_Type__c,
                Component__r.File_Name__c
            FROM Component_History__c
            WHERE Id IN :parentIdList
            WITH SECURITY_ENFORCED
        ]) {
            if (history.Attachments != null && history.Attachments.size() == 1) {
                bodyCount = bodyCount + history.Attachments[0].BodyLength;
                if (bodyCount > 2000000 && zipList.size() > 0) {
                    tempAttIdList.add(new List<ZipDetailWraper>(zipList));
                    bodyCount = history.Attachments[0].BodyLength;
                    zipList.clear();
                }
                zipList.add(new ZipDetailWraper(history.Component__r.Component_Name__c, history.Attachments[0].Id));

                List<CompDetailWraper> tempList = new List<CompDetailWraper>();
                String metaType = history.Component__r.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(metaType)) {
                    metaType = FlosumConstants.metadataFolderMap.get(metaType);
                }

                if (compDetailMap.containsKey(metaType)) {
                    tempList = compDetailMap.get(metaType);
                }

                CompDetailWraper compWrap = new CompDetailWraper();
                compWrap.compName = history.Component__r.Component_Name__c;
                compWrap.compType = metaType;
                compWrap.attId = history.Attachments[0].Id;
                compWrap.compFileName = history.Component__r.File_Name__c;
                tempList.add(compWrap);
                compDetailMap.put(metaType, tempList);
            }
        }
        if (zipList.size() > 0) {
            tempAttIdList.add(new List<ZipDetailWraper>(zipList));
        }

        for (String key : FlosumConstants.sortedList) {
            if (compDetailMap.containsKey(key)) {
                for (CompDetailWraper compWrap : compDetailMap.get(key)) {
                    wrap.compList.add(compWrap);
                }
                compDetailMap.remove(key);
            }
        }
        for (String key : compDetailMap.keySet()) {
            for (CompDetailWraper compWrap : compDetailMap.get(key)) {
                wrap.compList.add(compWrap);
            }
        }
        wrap.attIdList = tempAttIdList;

        //For Destructive changes.

        if (desChList.size() > 0) {
            for (Destructive_Changes__c dc : [
                SELECT Id, Post_Deployment_Change__c, Component_Type__c, Component_Name__c
                FROM Destructive_Changes__c
                WHERE Id IN :desChList
                WITH SECURITY_ENFORCED
            ]) {
                String metaType = dc.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(metaType)) {
                    if (metaType == 'EmailTemplateFolder' && dc.Component_Name__c != null) {
                        dc.Component_Name__c =
                            dc.Component_Name__c.substring(
                                dc.Component_Name__c.lastIndexOf('/') + 1,
                                dc.Component_Name__c.length()
                            ) + '/';
                    } else if (dc.Component_Name__c != null && dc.Component_Name__c.lastIndexOf('/') > -1) {
                        dc.Component_Name__c = dc.Component_Name__c.substring(
                            dc.Component_Name__c.lastIndexOf('/') + 1,
                            dc.Component_Name__c.length()
                        );
                    }
                    metaType = FlosumConstants.metadataFolderMap.get(metaType);
                }

                Set<String> itemNames = new Set<String>();
                if (dc.Post_Deployment_Change__c) {
                    if (postMap.containsKey(metaType)) {
                        itemNames = postMap.get(metaType);
                    }
                    itemNames.add(dc.Component_Name__c);
                    postMap.put(metaType, itemNames);
                } else {
                    if (preMap.containsKey(metaType)) {
                        itemNames = preMap.get(metaType);
                    }
                    itemNames.add(dc.Component_Name__c);
                    preMap.put(metaType, itemNames);
                }
            }

            DestructiveWraper dw = new DestructiveWraper();
            dw.preMap = preMap;
            dw.postMap = postMap;
            wrap.destructiveInfo = dw;
        }

        // For Environment variables
        Set<String> orgsList = new Set<String>();
        List<Metadata_Log__c> metadataLogs = [
            SELECT Id, PipelineStepId__r.Step__c, Organisation__c
            FROM Metadata_Log__c
            WHERE Id = :aId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (
            !metadataLogs.isEmpty() &&
            (metadataLogs[0].PipelineStepId__r.Step__c == 'Deploy' ||
            metadataLogs[0].PipelineStepId__r.Step__c == 'Validate')
        ) {
            orgsList.add(metadataLogs[0].Organisation__c);
        }
        wrap.orgList = new List<String>(orgsList);

        Map<String, Map<String, String>> env = new Map<String, Map<String, String>>();
        for (Env_var__c var : [
            SELECT Variable__c, Org__c, ReplacementString__c
            FROM Env_var__c
            WHERE Org__c IN :orgsList
            WITH SECURITY_ENFORCED
            LIMIT 50000
        ]) {
            if (!env.containsKey(var.Org__c)) {
                env.put(
                    var.Org__c,
                    new Map<String, String>{
                        var.Variable__c => var.ReplacementString__c == null ? '' : var.ReplacementString__c
                    }
                );
            } else {
                env.get(var.Org__c)
                    .put(var.Variable__c, var.ReplacementString__c == null ? '' : var.ReplacementString__c);
            }
        }
        wrap.envVarMap = env;

        FlosumCustomSetting flosumSetting = new FlosumCustomSetting();
        List<String> metaTypes = new List<String>();
        for (FlosumSetting__c flosum : flosumSetting.queryFlosumSetting()) {
            if (flosum.is_Enabled_Env_Var__c) {
                metaTypes.add(flosum.Metadata_Type_Name__c);
            }
        }
        wrap.metaTypes = metaTypes;
        return wrap;
    }

    @RemoteAction
    public static List<AttachmentWraper> getMergeAttachments(String JSN) {
        List<AttachmentWraper> wrapList = new List<AttachmentWraper>();
        Map<String, String> idCompMap = new Map<String, String>();
        List<ZipDetailWraper> zipDetailList = new List<ZipDetailWraper>();
        zipDetailList = (List<ZipDetailWraper>) JSON.deserialize(JSN, List<ZipDetailWraper>.class);
        for (ZipDetailWraper wrap : zipDetailList) {
            idCompMap.put(wrap.attId, wrap.compName);
        }

        zipDetailList.clear();

        for (Attachment att : [
            SELECT Id, Body, Description
            FROM Attachment
            WHERE Id IN :idCompMap.keySet()
            WITH SECURITY_ENFORCED
        ]) {
            AttachmentWraper wrap = new AttachmentWraper();
            wrap.parentId = idCompMap.get(att.Id);
            if (FlosumConstants.metadataFolderMap.containsKey(att.Description)) {
                wrap.compType = FlosumConstants.metadataFolderMap.get(att.Description);
            } else {
                wrap.compType = att.Description;
            }
            wrap.base64 = EncodingUtil.base64Encode(att.Body);
            wrapList.add(wrap);
        }
        return wrapList;
    }

    // form chunk blocks in 2MB to populate [created earlier] patches
    @RemoteAction
    public static List<List<String>> getChunkBlocks(String aId) {
        return MetadataUtils.getBlocks(aId);
    }

    @RemoteAction
    public static MetadataUtils.CredWrapper setUpAuthentication(String mlId) {
        return MetadataUtils.setUpAuthentication(mlId);
    }
    @RemoteAction
    public static Map<String, authDetail> setUpAuthenticationList(String mlIdsJson) {
        List<String> mlIds = (List<String>) JSON.deserialize(mlIdsJson, List<String>.class);
        Map<String, authDetail> mapAuth = new Map<String, authDetail>();
        Map<String, authDetail> duplicateAuth = new Map<String, authDetail>();

        List<Metadata_Log__c> mLogs = [
            SELECT Id, Organisation__c, Organisation__r.Username__c, Process_Type__c
            FROM Metadata_Log__c
            WHERE Id IN :mlIds
            WITH SECURITY_ENFORCED
            LIMIT 45
        ];
        List<String> orgIds = new List<String>();
        for (Metadata_Log__c ml : mLogs) {
            if (ml.Organisation__c != null && ml.Process_Type__c != null) {
                orgIds.add(ml.Organisation__c);
            }
        }
        Map<Id, AuthUtils.CredDetails> orgsCreds = AuthUtils.getListDefaultCreds(orgIds);

        for (Metadata_Log__c ml : mLogs) {
            if (ml.Organisation__c != null && ml.Process_Type__c != null) {
                String checkRole = '';
                if (
                    ml.Process_Type__c == 'Validate' ||
                    ml.Process_Type__c == FlosumConstants.PROCESS_EXECUTE_APEX ||
                    ml.Process_Type__c == FlosumConstants.PROCESS_OVERWRITE_PROTECTION
                ) {
                    checkRole = FlosumConstants.VALIDATE_ONLY;
                } else if (ml.Process_Type__c == FlosumConstants.PROCESS_PRE_DEPLOY_FIX) {
                    checkRole = FlosumConstants.DEVELOPER;
                } else {
                    checkRole = FlosumConstants.RELEASE_MANAGER;
                }
                if (checkRole != '') {
                    if (duplicateAuth.containsKey(checkRole + ml.Organisation__c)) {
                        mapAuth.put(ml.Id, duplicateAuth.get(checkRole + ml.Organisation__c));
                    } else {
                        AuthUtils.AuthenticateDetails auth = AuthUtils.authenticateAnOrg(
                            ml.Organisation__c,
                            ml.Organisation__r.Username__c,
                            checkRole,
                            orgsCreds.get(ml.Organisation__c)
                        );

                        authDetail detail = new authDetail();
                        detail.orgId = ml.Organisation__c;
                        detail.isSuccess = auth.isSuccess;
                        detail.accessType = auth.accessType;
                        detail.accessToken = auth.details.AccessToken__c;
                        detail.refreshToken = auth.details.RefreshToken__c;
                        detail.instanceUrl = auth.details.InstanceURL__c;
                        detail.consumerKey = orgsCreds.get(ml.Organisation__c).consumerKey;
                        detail.consumerSecret = orgsCreds.get(ml.Organisation__c).consumerSecret;
                        detail.callbackURL = orgsCreds.get(ml.Organisation__c).callbackURL;
                        detail.msg = auth.errorMessage;
                        mapAuth.put(ml.Id, detail);
                        duplicateAuth.put(checkRole + ml.Organisation__c, detail);
                    }
                }
            }
        }
        return mapAuth;
    }

    @RemoteAction
    public static Boolean populatePatch(String pId, String idHistoryLiJson, String sourceType, String sourceName) {
        if (idHistoryLiJson != null && idHistoryLiJson != '') {
            List<String> idHistoryLi = (List<String>) JSON.deserialize(idHistoryLiJson, List<String>.class);
            MetadataUtils.populatePatch(pId, idHistoryLi, sourceType, sourceName);
        }
        return true;
    }

    @ReadOnly
    @RemoteAction
    public static Map<Id, Map<String, Set<String>>> collectBackupInfo(
        String branchId,
        String idsComp,
        String destrChangJSON,
        String latestDeployedComponentsJSON,
        String latestDeployedDestructiveChangesJSON
    ) {
        Map<Id, Map<String, Set<String>>> retrieveMapByOrg = new Map<Id, Map<String, Set<String>>>();

        Map<Id, Set<Id>> deployedComponentsMap = (Map<Id, Set<Id>>) JSON.deserialize(
            latestDeployedComponentsJSON,
            Map<Id, Set<Id>>.class
        );
        Map<Id, Set<Id>> deployedDestructiveChangesMap = (Map<Id, Set<Id>>) JSON.deserialize(
            latestDeployedDestructiveChangesJSON,
            Map<Id, Set<Id>>.class
        );

        List<Branch__c> branchList = [SELECT Id FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];

        if (branchList.isEmpty()) {
            return retrieveMapByOrg;
        }

        List<String> desChList = String.isNotBlank(destrChangJSON)
            ? (List<String>) JSON.deserialize(destrChangJSON, List<String>.class)
            : new List<String>();

        Map<Id, Destructive_Changes__c> mapDestructiveChanges = new Map<Id, Destructive_Changes__c>(
            [
                SELECT Id, Component_Type__c, Component_Name__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchList[0].Id AND Id IN :desChList
                WITH SECURITY_ENFORCED
            ]
        );

        for (Id orgId : deployedDestructiveChangesMap.keySet()) {
            Set<Id> tempSet = new Set<Id>(mapDestructiveChanges.keySet());
            tempSet.removeAll(deployedDestructiveChangesMap.get(orgId));

            for (Id compId : tempSet) {
                String compType = mapDestructiveChanges.get(compId).Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                    compType = FlosumConstants.metadataFolderMap.get(compType);
                }
                String componentName = mapDestructiveChanges.get(compId).Component_Name__c;
                addComponentToMap(retrieveMapByOrg, orgId, compType, componentName);
            }
        }

        Set<String> ids = String.isNotBlank(idsComp)
            ? (Set<String>) JSON.deserialize(idsComp, Set<String>.class)
            : new Set<String>();
        Map<Id, Component__c> mapComponents = new Map<Id, Component__c>(
            [
                SELECT Id, File_Name__c, Component_Name__c, Component_Type__c
                FROM Component__c
                WHERE Id IN :ids
                WITH SECURITY_ENFORCED
            ]
        );
        for (Id orgId : deployedComponentsMap.keySet()) {
            Set<Id> tempSet = new Set<Id>(mapComponents.keySet());
            tempSet.removeAll(deployedComponentsMap.get(orgId));

            for (Id compId : tempSet) {
                String compType = mapComponents.get(compId).Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(compType)) {
                    compType = FlosumConstants.metadataFolderMap.get(compType);
                }
                String componentName = mapComponents.get(compId).Component_Name__c;
                addComponentToMap(retrieveMapByOrg, orgId, compType, componentName);
            }
        }

        return retrieveMapByOrg;
    }

    private static void addComponentToMap(
        Map<Id, Map<String, Set<String>>> retrieveMapByOrg,
        Id orgId,
        String compType,
        String componentName
    ) {
        Map<String, Set<String>> orgMap = retrieveMapByOrg.containsKey(orgId)
            ? retrieveMapByOrg.get(orgId)
            : new Map<String, Set<String>>();
        Set<String> temp = orgMap.containsKey(compType) ? orgMap.get(compType) : new Set<String>();
        temp.add(componentName);
        orgMap.put(compType, temp);

        retrieveMapByOrg.put(orgId, orgMap);
    }

    @ReadOnly
    @RemoteAction
    public static List<CommitWrapper> getProfileAndPermissionSet(String branchId, String metadataLogsJson) {
        List<CommitWrapper> commitWrappers = new List<CommitWrapper>();
        Set<String> profileSet = new Set<String>{ 'Profile', 'PermissionSet' };
        List<Branch__c> branchList = new List<Branch__c>();

        List<String> metadataLogIds = (List<String>) JSON.deserialize(metadataLogsJson, List<String>.class);
        List<Metadata_Log__c> metadataLogList = [
            SELECT Id
            FROM Metadata_Log__c
            WHERE Id IN :metadataLogIds AND Process_Type__c = :FlosumConstants.PROCESS_COMMIT_TO_SOURCE
            WITH SECURITY_ENFORCED
        ];
        branchList = [SELECT Id, Repository__c FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];
        if (!metadataLogList.isEmpty() && !branchList.isEmpty()) {
            Set<String> componentTypesSet = new Set<String>();
            Set<String> componentNamesSet = new Set<String>();
            Map<String, Component__c> componentBranchMap = new Map<String, Component__c>();
            for (Component__c component : [
                SELECT
                    Id,
                    Component_Name__c,
                    Component_Type__c,
                    (SELECT Id FROM Components__r ORDER BY Version__c DESC LIMIT 1)
                FROM Component__c
                WHERE Branch__c = :branchId AND Component_Type__c IN :profileSet
                WITH SECURITY_ENFORCED
            ]) {
                componentBranchMap.put(component.Component_Type__c + '#' + component.Component_Name__c, component);
                componentTypesSet.add(component.Component_Type__c);
                componentNamesSet.add(component.Component_Name__c);
            }
            List<Component__c> repositoryComponentsList = [
                SELECT
                    Id,
                    Component_Name__c,
                    Component_Type__c,
                    File_Name__c,
                    (SELECT Id FROM Components__r ORDER BY Version__c DESC LIMIT 1)
                FROM Component__c
                WHERE
                    RecordType.Name = 'Repository'
                    AND Component_Type__c IN :componentTypesSet
                    AND Component_Name__c IN :componentNamesSet
                    AND Repository__c = :branchList[0].Repository__c
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ];

            if (repositoryComponentsList.isEmpty()) {
                return commitWrappers;
            }
            List<Id> componentHistoryListIds = new List<Id>();

            for (Component__c repoComponent : repositoryComponentsList) {
                String componentKey = repoComponent.Component_Type__c + '#' + repoComponent.Component_Name__c;

                if (!componentBranchMap.containsKey(componentKey)) {
                    continue;
                }
                if (
                    !componentBranchMap.get(componentKey).Components__r.isEmpty() &&
                    !repoComponent.Components__r.isEmpty()
                ) {
                    commitWrappers.add(
                        new CommitWrapper(
                            metadataLogList[0].Id,
                            repoComponent.File_Name__c,
                            repoComponent.Component_Type__c,
                            componentBranchMap.get(componentKey).Components__r[0].Id,
                            repoComponent.Components__r[0].Id
                        )
                    );
                    componentHistoryListIds.add(componentBranchMap.get(componentKey).Components__r[0].Id);
                    componentHistoryListIds.add(repoComponent.Components__r[0].Id);
                }
            }
            Map<Id, Id> attachmentHistoryMap = new Map<Id, Id>();
            for (Attachment att : [
                SELECT Id, ParentId
                FROM Attachment
                WHERE ParentId IN :componentHistoryListIds
                WITH SECURITY_ENFORCED
            ]) {
                attachmentHistoryMap.put(att.ParentId, att.Id);
            }
            for (CommitWrapper wrapper : commitWrappers) {
                wrapper.branchAttId = attachmentHistoryMap.get(wrapper.branchHistId);
                wrapper.repoAttId = attachmentHistoryMap.get(wrapper.repoHistId);
            }
        }
        return commitWrappers;
    }

    @ReadOnly
    @RemoteAction
    public static List<AttachmentWraper> getProfileAndPermissionSetAttachments(String branchAttId, String repoAttId) {
        List<AttachmentWraper> attList = new List<AttachmentWraper>();

        for (Attachment att : [
            SELECT Id, Body, Description, ParentId
            FROM Attachment
            WHERE Id = :branchAttId OR Id = :repoAttId
            WITH SECURITY_ENFORCED
        ]) {
            AttachmentWraper wrap = new AttachmentWraper();
            wrap.parentId = att.ParentId;
            wrap.compType = att.Description;
            wrap.base64 = EncodingUtil.base64Encode(att.Body);
            attList.add(wrap);
        }
        return attList;
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class authDetail {
        String orgId;
        String accessToken;
        String instanceUrl;
        String refreshToken;
        String accessType;
        String consumerKey;
        String consumerSecret;
        String callbackURL;

        Boolean isSuccess = false;
        String msg = '';
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class CompDetailWraper {
        public String compName;
        public String compType;
        public String attId;
        public String compFileName;
    }
    @JsonAccess(serializable='always' deserializable='always')
    public class ZipDetailWraper {
        public String compName;
        public String attId;

        public ZipDetailWraper(String compName, String attId) {
            this.compName = compName;
            this.attId = attId;
        }
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class AttachmentWraper {
        public String parentId; //a0Iq00000012tdzEAA
        public String compType; //CustomObject
        public String base64;
    }
    @JsonAccess(serializable='always' deserializable='always')
    public class MergeDetailWraper {
        public DestructiveWraper destructiveInfo;
        public List<CompDetailWraper> compList;
        public List<List<ZipDetailWraper>> attIdList;
        public Map<String, Map<String, String>> envVarMap;
        public List<String> metaTypes;
        public List<String> orgList;

        public MergeDetailWraper() {
            destructiveInfo = new DestructiveWraper();
            compList = new List<CompDetailWraper>();
            attIdList = new List<List<ZipDetailWraper>>();
            envVarMap = new Map<String, Map<String, String>>();
            metaTypes = new List<String>();
            orgList = new List<String>();
        }
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class DestructiveWraper {
        Map<String, Set<String>> preMap;
        Map<String, Set<String>> postMap;

        public DestructiveWraper() {
            preMap = new Map<String, Set<String>>();
            postMap = new Map<String, Set<String>>();
        }
    }
    @JsonAccess(serializable='always' deserializable='always')
    public class Options {
        public String CIStyle;
        public String targetId;
        public String pipeExec;
        public String mergeSetName;
        public String manualStepId;
        public String branchRecordType;
        public Boolean isAgentPipeline;
    }
    @JsonAccess(serializable='always' deserializable='always')
    public class CommitWrapper {
        public String metadataLogId;
        public String fileName;
        public String compType;
        public String branchAttId;
        public String repoAttId;
        public String branchHistId;
        public String repoHistId;

        public CommitWrapper(
            String metadataLogId,
            String fileName,
            String compType,
            String branchHistId,
            String repoHistId
        ) {
            this.metadataLogId = metadataLogId;
            this.fileName = fileName;
            this.compType = compType;
            this.branchHistId = branchHistId;
            this.repoHistId = repoHistId;
            this.branchAttId = '';
            this.repoAttId = '';
        }
    }
}