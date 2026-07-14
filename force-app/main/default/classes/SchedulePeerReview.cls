public with sharing class SchedulePeerReview implements Schedulable {
    private Id metadataLogId;

    public SchedulePeerReview(Id metadataLogId) {
        this.metadataLogId = metadataLogId;
    }
    public void execute(SchedulableContext sc) {
        String descriptionPeerReview = '';
        String userGroupsPeerReview = '';
        List<String> idsReviewers = new List<String>();
        Set<Id> userIdSet = new Set<Id>();
        String branchId = '';
        String branchName = '';
        String branchDescription = '';

        List<Metadata_Log__c> metadataLogRecords = [
            SELECT
                PipelineStepId__c,
                Job_Completed__c,
                Succeed__c,
                Status__c,
                Options__c,
                Branch__c,
                Branch__r.Branch_Name__c,
                Branch__r.Branch_Description__c,
                Branch__r.Enforce_pull_request__c,
                Metadata_Types__c
            FROM Metadata_Log__c
            WHERE Id = :metadataLogId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!metadataLogRecords.isEmpty() && !String.isEmpty(metadataLogRecords[0].Branch__c)) {
            branchId = metadataLogRecords[0].Branch__c;
            branchName = metadataLogRecords[0].Branch__r.Branch_Name__c;
            branchDescription = String.isEmpty(metadataLogRecords[0].Branch__r.Branch_Description__c)
                ? ''
                : metadataLogRecords[0].Branch__r.Branch_Description__c;
            List<PipelineStep__c> pipelineStepList = [
                SELECT Id, Peer_Review_Options__c
                FROM PipelineStep__c
                WHERE Id = :metadataLogRecords[0].PipelineStepId__c
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (!pipelineStepList.isEmpty() && String.isNotBlank(pipelineStepList[0].Peer_Review_Options__c)) {
                try {
                    Model.PeerReviewOptions peerReviewOptionsObj = new Model.PeerReviewOptions();
                    peerReviewOptionsObj = (Model.PeerReviewOptions) JSON.deserialize(
                        pipelineStepList[0].Peer_Review_Options__c,
                        Model.PeerReviewOptions.class
                    );
                    descriptionPeerReview = peerReviewOptionsObj.description;
                    userGroupsPeerReview = peerReviewOptionsObj.userGroups;
                    idsReviewers = peerReviewOptionsObj.idsReviewers;
                    if (userGroupsPeerReview == 'User') {
                        Integer index = idsReviewers.indexOf(UserInfo.getUserId());
                        if (index != -1) {
                            idsReviewers.remove(index);
                        }
                        userIdSet = verifyUsers(idsReviewers);
                    } else {
                        List<String> userFromGroup = new List<String>();
                        for (User userInGroup : [
                            SELECT Id
                            FROM User
                            WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Id IN :idsReviewers)
                            WITH SECURITY_ENFORCED
                        ]) {
                            if (userInGroup.Id != UserInfo.getUserId()) {
                                userFromGroup.add(userInGroup.Id);
                            }
                        }
                        userIdSet = verifyUsers(userFromGroup);
                    }

                    Pull_Request__c pullRequest = new Pull_Request__c();
                    pullRequest.Branch__c = branchId;
                    pullRequest.Name = branchName.abbreviate(80);
                    pullRequest.Approval_Status__c = 'Pending';
                    pullRequest.Description__c = descriptionPeerReview;
                    Integer valueForNumberOfUsers = 0;

                    List<Pull_Request_Reviewer__c> ListOfPullRequestReviewer = new List<Pull_Request_Reviewer__c>();
                    List<Messaging.SingleEmailMessage> listOfmails = new List<Messaging.SingleEmailMessage>();
                    List<User> userinfList = [
                        SELECT Email, FirstName
                        FROM User
                        WHERE Id IN :userIdSet AND IsActive = TRUE
                        WITH SECURITY_ENFORCED
                    ];

                    Boolean isNeedMoreReviewers = false;

                    Pull_Request_Setting__c pullRequestSetting = (Pull_Request_Setting__c.getOrgDefaults() != null &&
                        Pull_Request_Setting__c.getOrgDefaults().Id != null)
                        ? Pull_Request_Setting__c.getOrgDefaults()
                        : new Pull_Request_Setting__c();
                    Boolean isDeploymentPeerReviewSettingEnabled =
                        pullRequestSetting.PullRequestDeploymentSetting__c &
                        metadataLogRecords[0].Branch__r.Enforce_pull_request__c;

                    if (
                        pullRequestSetting.AddToDeploymentApprovalType__c != null &&
                        pullRequestSetting.DeploymentPercentageORNumberOfUsers__c != null &&
                        pullRequestSetting.DeploymentPercentageORNumberOfUsers__c > 0 &&
                        isDeploymentPeerReviewSettingEnabled
                    ) {
                        String selectedMethodForPullRequest = pullRequestSetting.AddToDeploymentApprovalType__c;

                        if (selectedMethodForPullRequest == 'NoOfUsers') {
                            valueForNumberOfUsers = (Integer) pullRequestSetting.DeploymentPercentageORNumberOfUsers__c;
                            if (userinfList.size() < valueForNumberOfUsers) {
                                isNeedMoreReviewers = true;
                            }
                        }
                    }

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

                    //  Analytics
                    try {
                        List<AnalyticsService.AnalyticsEvent> events = new List<AnalyticsService.AnalyticsEvent>();
                        Map<String, String> properties = AnalyticsService.getBranchAnalyticsDetails(branchId);
                        properties.put('trigger_source', 'Pipeline');
                        properties.put('count_of_selected_users', String.valueOf(userinfList.size()));
                        AnalyticsService.AnalyticsEvent event = new AnalyticsService.AnalyticsEvent('Peer Review Create', properties);
                        events.add(event);
                        if (Limits.getQueueableJobs() >= 1) {
                            AnalyticsService.scheduleAnalytics(events);
                        } else {
                            System.enqueueJob(new AnalyticsQueueable(events));
                        }
                    } catch (Exception e){}

                    DatabaseUtils.insertRecord(
                        pullRequest,
                        new List<Schema.DescribeFieldResult>{
                            Pull_Request__c.Branch__c.getDescribe(),
                            Pull_Request__c.Name.getDescribe(),
                            Pull_Request__c.Approval_Status__c.getDescribe(),
                            Pull_Request__c.Description__c.getDescribe(),
                            Pull_Request__c.Approval_Status__c.getDescribe()
                        }
                    );

                    metadataLogRecords[0].Metadata_Types__c = pullRequest.Id;
                    metadataLogRecords[0].Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                    metadataLogRecords[0].Start_Date__c = Datetime.now();
                    DatabaseUtils.updateRecord(
                        metadataLogRecords[0],
                        new List<Schema.DescribeFieldResult>{
                            Metadata_Log__c.Metadata_Types__c.getDescribe(),
                            Metadata_Log__c.Status__c.getDescribe(),
                            Metadata_Log__c.Start_Date__c.getDescribe()
                        }
                    );

                    for (User userInf : userinfList) {
                        //Add PullRequestReviewer
                        ListOfPullRequestReviewer.add(
                            new Pull_Request_Reviewer__c(
                                User__c = userInf.Id,
                                Status__c = 'Pending',
                                Pull_Request__c = pullRequest.Id
                            )
                        );
                    }

                    if (isNeedMoreReviewers) {
                        List<EmailTemplate> emailTemplateLi = [
                            SELECT Id, Name, DeveloperName, NamespacePrefix
                            FROM EmailTemplate
                            WHERE
                                DeveloperName = 'AddMoreReviewers'
                                AND NamespacePrefix = :FlosumConstants.getNameSpacePrefix()
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                        ];
                        if (!emailTemplateLi.isEmpty()) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if (FlosumConstants.getOrgWideEmailAddress() != null) {
                                mail.setOrgWideEmailAddressId(FlosumConstants.getOrgWideEmailAddress());
                            }
                            mail.setTemplateId(emailTemplateLi[0].Id);
                            mail.setTargetObjectId(UserInfo.getUserId());
                            mail.setSaveAsActivity(false);
                            mail.setWhatId(pullRequest.Id);
                            listOfmails.add(mail);
                        }
                    }

                    if (!ListOfPullRequestReviewer.isEmpty()) {
                        DatabaseUtils.insertRecords(
                            ListOfPullRequestReviewer,
                            new List<Schema.DescribeFieldResult>{
                                Pull_Request_Reviewer__c.User__c.getDescribe(),
                                Pull_Request_Reviewer__c.Status__c.getDescribe(),
                                Pull_Request_Reviewer__c.Pull_Request__c.getDescribe()
                            }
                        );
                    }

                    if (!Test.isRunningTest() && !listOfmails.isEmpty()) {
                        Messaging.sendEmail(listOfmails);
                    }

                    BranchActivityController.createPullRequestLog(pullRequest.Id);
                } catch (Exception e) {
                    completeMetadataLog(metadataLogRecords[0], 'Completed', false);
                    createErrorLog(metadataLogRecords[0], e.getMessage());
                }
            }
        }
        System.abortJob(sc.getTriggerId());
    }

    public static Set<Id> verifyUsers(List<String> usersIds) {

        Set<Id> userList = new Set<Id>();
        Set<Id> verifiedUserList = new Set<Id>();
        Set<Id> permissionSetIds = new Set<Id>();
        String apiName = FlosumConstants.Approve_Reject_Pull_Request;
        String strNameSpace = FlosumConstants.getNameSpacePrefix();

        for (SetupEntityAccess access : [
            SELECT ParentId
            FROM SetupEntityAccess
            WHERE
                SetupEntityId IN (
                    SELECT Id
                    FROM CustomPermission
                    WHERE DeveloperName = :apiName AND NamespacePrefix = :strNameSpace
                )
        ]) {
            permissionSetIds.add(access.ParentId);
        }

        if (strNameSpace != '') {
            for (User ur : [
                SELECT Name, Username
                FROM User
                WHERE Id IN (
                        SELECT AssigneeId
                        FROM PermissionSetAssignment
                        WHERE PermissionSetId IN :permissionSetIds
                    )
                    AND Id IN (
                        SELECT UserId
                        FROM UserPackageLicense
                        WHERE PackageLicense.NamespacePrefix = :strNameSpace
                    )
                LIMIT 1000
            ]) {
                userList.add(ur.Id);
            }
        } else {
            for (User ur : [
                SELECT Name, Username
                FROM User
                WHERE Id IN (
                        SELECT AssigneeId
                        FROM PermissionSetAssignment
                        WHERE PermissionSetId IN :permissionSetIds
                    )
                LIMIT 1000
            ]) {
                userList.add(ur.Id);
            }
        }
        for (String userId : usersIds) {
            if (userList.contains(userId)) {
                verifiedUserList.add(userId);
            }
        }
        return verifiedUserList;
    }

    public static void completeMetadataLog(Metadata_Log__c metadataLog, String status, Boolean isSucceed) {
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
    }

    public static void createErrorLog(Metadata_Log__c metadataLog, String errorMessage) {
        Attachment attError = new Attachment(
            ParentId = metadataLog.Id, // attach error log to metadata log
            Name = 'Peer Review Error Log',
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
}