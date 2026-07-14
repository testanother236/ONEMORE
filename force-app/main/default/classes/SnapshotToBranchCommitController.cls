public with sharing class SnapshotToBranchCommitController {
    public List<SelectOption> compareAgainstList { get; set; }
    public List<SelectOption> commitList { get; set; }
    public List<Metadata_Item__c> commoponentList { get; set; }

    public List<SelectOption> repositoryOptions { get; set; }
    public String selectedRepository { get; set; }
    public String newBranchName { get; set; }
    public Boolean fullPipelineRun { get; set; }
    public String pipelineId { get; set; }
    public Id snapId { get; set; }
    public Id snapOrganizationId { get; set; }
    public String commitTo { get; set; }
    public String commitToLabel { get; set; }
    public String snapName { get; set; }
    public String branchName { get; set; }
    public String tests { get; set; }
    public String GoToCommitType { get; set; }

    public List<SelectOption> availableMetadataTypes { get; set; }
    public String selectedMetadataType { get; set; }
    public String locale { get; set; }
    public String timezone { get; set; }
    public String timestamp;

    //for save attachments
    public Boolean commitSuccess { get; set; }
    public String MetaJSNToCommit { get; set; }

    private Set<String> metaTypeFilterSet = new Set<String>{ 'CustomLabels' };

    public Boolean isVeevaType { get; set; }

    public transient String attStr { get; set; }
    public transient String jsonStr { get; set; }
    public transient String message { get; set; }
    public String comment { get; set; }

    public String branchComponentId { get; set; }
    public String metadataItemId { get; set; }

    private String fullObjectName = 'Component__c';

    public String baseUrl { get; set; }
    public String nameSpacePrefix { get; set; }
    public transient String commitChunkJSON { get; set; }

    public String searchText { get; set; }
    public Boolean isSearch { get; set; }
    public Boolean isVlocity { get; set; }
    public String msg { get; set; }

    //added for Automated Deployment functionality
    // Id of Multibuild record
    public String logId { get; set; }
    public Integer localApiVersion { get; private set; }
    public List<String> idHistoryLi;
    public String patchListJSON { get; set; }
    public String logsListJSON { get; set; }
    public String patchId { get; set; }
    public Boolean isError { get; set; }
    public Boolean isSplitted { get; set; }
    public Boolean validateOnly { get; set; }
    public String metadataType { get; set; }
    public String mergeSetName { get; set; }
    public Boolean isProfileValidation { get; set; }
    public Set<String> idsComponents { get; set; }
    public Integer numberOfComponents { get; set; }
    public String editMetaDataPageName { get; set; }
    public String profileValidNameMapJSON {
        get {
            return JSON.serialize(FlosumConstants.PROFILE_VALID_NAME_MAP);
        }
        set;
    }

    public SnapshotToBranchCommitController() {
        locale = UserInfo.getLocale().replace('_', '-');
        timezone = UserInfo.getTimeZone().getID();
        timestamp = '' + Datetime.now().getTime();
        nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        localApiVersion = FlosumConstants.apiversion;
        baseUrl = Page.HistoryComparison.getUrl();
        isProfileValidation = true;
        fullPipelineRun = false;
        GoToCommitType = 'onsnap';
        commitSuccess = false;
        isError = false;
        isSearch = false;
        isVeevaType = false;
        searchText = '';
        idsComponents = new Set<String>();
        mergeSetName = 'MERGEBRANCHSET' + Datetime.now().getTime();
        editMetaDataPageName = Page.ComponentComparisonPanel.getUrl();

        availableMetadataTypes = new List<SelectOption>();

        commoponentList = new List<Metadata_Item__c>();
        commitList = new List<SelectOption>();
        compareAgainstList = new List<SelectOption>();

        repositoryOptions = new List<SelectOption>();

        for (String oneType : FlosumConstants.profilePermissionMap.keySet()) {
            metaTypeFilterSet.add(oneType);
        }

        String sId = ApexPages.currentPage().getParameters().get('sid') != null
            ? ApexPages.currentPage().getParameters().get('sid')
            : null;
        metadataType = ApexPages.currentPage().getParameters().containsKey('metadataType')
            ? ApexPages.currentPage().getParameters().get('metadataType')
            : null;
        //for commit functionality (commit from snapshot)
        String query = 'SELECT Id,Name,Is_Completed__c, ';
        isVlocity = metadataType == 'Vlocity';
        query += !isVlocity ? 'Organisation__c ' : 'Org__c ';
        query += 'FROM ';
        query += !isVlocity
            ? 'Snapshot__c WHERE Id=:sId WITH SECURITY_ENFORCED LIMIT 1'
            : 'Snapshot_Vlocity__c WHERE Id=:sId WITH SECURITY_ENFORCED LIMIT 1';
        List<SObject> snapList = Database.query(query);

        if (snapList.size() == 1) {
            if ((Boolean) snapList[0].get('Is_Completed__c')) {
                snapId = snapList[0].Id;
                snapName = (String) snapList[0].get('Name');
                snapOrganizationId = Id.valueOf(
                    !isVlocity ? (String) snapList[0].get('Organisation__c') : (String) snapList[0].get('Org__c')
                );
                if (!isVlocity) {
                    String orgType = [
                        SELECT Id, Organisation__r.Organisation_Type__c
                        FROM Snapshot__c
                        WHERE Id = :snapId
                        WITH SECURITY_ENFORCED
                    ][0]
                    .Organisation__r.Organisation_Type__c;
                    isVeevaType = orgType == VeevaConstants.VEEVA_TYPE;
                    if (isVeevaType) {
                        metadataType = VeevaConstants.VEEVA_TYPE;
                    }

                    if (orgType == MCConstants.TYPE) {
                        metadataType = MCConstants.TYPE;
                    }

                    if (orgType == B2CConstants.TYPE) {
                        metadataType = B2CConstants.TYPE;
                    }
                    if (orgType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                        metadataType = AbstractAuthentication.MULESOFT_ORG_TYPE;
                    }
                }
                listRepositories();
                listMetadataTypes();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Retrieval is in progress.'));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Snapshot not found.'));
        }
    }

    public String getBundleTypesListJSON() {
        return JSON.serialize(FlosumConstants.bundleTypesSet);
    }

    public String getEditableExtListJSON() {
        return JSON.serialize(FlosumConstants.EDITABLE_EXT_SET);
    }

    public void synchronize() {
        // Integration with external services
        List<Branch__c> branchList = new List<Branch__c>();
        branchList = [
            SELECT Id, Repository__c, LastModifiedById, Review_State__c, Review_Result__c
            FROM Branch__c
            WHERE Id = :commitTo
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (branchList.size() == 1) {
            branchList[0].Timestamp__c = System.now();
            DatabaseUtils.updateRecord(
                branchList[0],
                new List<Schema.DescribeFieldResult>{ Branch__c.Timestamp__c.getDescribe() }
            );

            HerokuCredentials__c hc = HTTPService.getCredentials('REVIEW');
            if (hc != null && hc.isAutoSync__c) {
                if (hc.IsFullReview__c) {
                    Set<String> allCompIds = new Set<String>();
                    for (Component__c c : [
                        SELECT Id
                        FROM Component__c
                        WHERE Branch__c = :branchList[0].Id
                        WITH SECURITY_ENFORCED
                        LIMIT 49900
                    ]) {
                        allCompIds.add(c.Id);
                    }
                    TaskSchedule.addReviewJob(branchList[0].Id, allCompIds);
                } else {
                    TaskSchedule.addReviewJob(branchList[0].Id, idsComponents);
                }
                branchList[0].Review_State__c = 'QUEUED';
                branchList[0].Review_Result__c = 0;
                DatabaseUtils.updateRecord(
                    branchList[0],
                    new List<Schema.DescribeFieldResult>{
                        Branch__c.Review_State__c.getDescribe(),
                        Branch__c.Review_Result__c.getDescribe()
                    }
                );
            }

            String syncDirection = ExtSynchronize.getSyncDirection();
            if (syncDirection != '' && syncDirection.contains('SFGIT')) {
                List<RepositoryCredentials__c> rCreds = [
                    SELECT Id
                    FROM RepositoryCredentials__c
                    WHERE RepositoryId__c = :branchList[0].Repository__c AND isLinked__c = TRUE
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (rCreds != null && rCreds.size() == 1) {
                    // new version
                    TaskSchedule.addSyncJob(branchList[0].Repository__c, branchList[0].Id, timestamp);
                    // legacy code
                    //System.enqueueJob(new ScheduleJob(branchList[0].Repository__c, branchList[0].Id, ExtConstants.SYNC_TYPE_SFGIT));
                    //return;// do not exec tasks twice
                }
            }
            TaskSchedule.executeJobs();
        }
    }

    public String getVlocityTypeListJSON() {
        return JSON.serialize(FlosumConstants.getAllVlocityTypes());
    }

    public void listRepositories() {
        repositoryOptions.clear();
        List<String> repositoryTypes = FlosumConstants.getRepositoryTypes(metadataType);
        List<Repository__c> repositoriesToAdd = new List<Repository__c>();

        //  Case 00014701 (Request to link Org and Repo so that we can display only the Repo based on the orgs selected on the 'commit to branch' page.)
        if (RepoRestrictionController.getRestrictionState()) {
            repositoriesToAdd = MetadataUtils.getRepositoriesFromDeploymentManagerByOrgId(
                new Map<String, Object>{
                    'orgId' => snapOrganizationId,
                    'repositoryTypes' => repositoryTypes,
                    'restrictionTypes' => new List<String>{
                        RepoRestrictionController.COMMIT_RESTRICTION,
                        RepoRestrictionController.DEPLOY_RESTRICTION
                    }
                }
            );
        }

        //  Case 00014701 (Request to link Org and Repo so that we can display only the Repo based on the orgs selected on the 'commit to branch' page.)
        //  the old logic will start if the "Deployment Manager" is disabled or incorrectly configured

        //  or "Bypass Deployment Manager custom permission"    (comment after testing)
        //  https://flosumbiz.lightning.force.com/lightning/r/Case/500QQ00000D1mCoYAJ/view

        if (
            repositoriesToAdd.isEmpty() ||
            RepoRestrictionController.isByPassUser(RepoRestrictionController.Bypass_Deploy_Restrictions)
        ) {
            repositoriesToAdd = [
                SELECT Id, Name, Is_Default_Repository__c
                FROM Repository__c
                WHERE Repository_Type__c IN :repositoryTypes
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 999
            ];
        }

        for (Repository__c repository : repositoriesToAdd) {
            repositoryOptions.add(new SelectOption(repository.Id, repository.Name));
            if (repository.Is_Default_Repository__c) {
                selectedRepository = repository.Id;
            }
        }
        if (repositoryOptions.size() > 0) {
            if (selectedRepository == null || selectedRepository == '') {
                selectedRepository = repositoryOptions[0].getValue();
            }
            listBranches();
        }
    }

    public void listBranches() {
        commitTo = '';
        commitToLabel = '';
        newBranchName = '';
        commitList.clear();
        if (selectedRepository != null && selectedRepository != '') {
            if (MetadataUtils.chekRepositoryPermission(selectedRepository)) {
                commitList.add(new SelectOption('', '--New--'));
            } else {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, FlosumConstants.COMMIT_PERMISSION_DENIED)
                );
            }
        }
    }

    public void setFilter() {
    }

    // creates initial empty Patch__c record
    public void createBuildRecords() {
        if (logId != null) {
            return; // build records have been created already
        }
        List<Branch__c> brList = new List<Branch__c>();
        try {
            brList = [
                SELECT Id, Branch_Name__c, Repository__c, Pipeline__c, Pipeline__r.Manual__c, Pipeline__r.Full_Deploy__c
                FROM Branch__c
                WHERE Id = :commitTo
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (!brList.isEmpty() && brList[0].Pipeline__c != null) {
                // create build records only if all flags are not null
                List<Pipeline__c> pipeList = [
                    SELECT
                        Id,
                        Specified_Tests__c,
                        Build_and_Deploy_Organizations__c,
                        Run_Tests_on_Deployment__c,
                        Deployment_Mode__c,
                        Deployment_Style__c,
                        Deploy_entire_profile__c
                    FROM Pipeline__c
                    WHERE Id = :brList[0].Pipeline__c
                    WITH SECURITY_ENFORCED
                ];

                List<PipelineStep__c> stepList = new List<PipelineStep__c>();
                stepList = [
                    SELECT Id
                    FROM PipelineStep__c
                    WHERE Pipeline__c = :brList[0].Pipeline__c
                    WITH SECURITY_ENFORCED
                    ORDER BY Number__c ASC
                ];

                // restore list of build orgs, verify each and create a build record for each to track the deployment of branch changes
                if (
                    !pipeList.isEmpty() &&
                    ((pipeList[0].Build_and_Deploy_Organizations__c != null &&
                    pipeList[0].Build_and_Deploy_Organizations__c != '{}') || (stepList.size() > 0))
                ) {
                    if (brList[0].Pipeline__r.Manual__c == true || brList[0].Pipeline__r.Full_Deploy__c == true) {
                        if (brList[0].Pipeline__r.Full_Deploy__c == true && brList[0].Pipeline__r.Manual__c == false) {
                            fullPipelineRun = true;
                            pipelineId = brList[0].Pipeline__c;
                        }
                    } else {
                        pipelineId = brList[0].Pipeline__c;
                    }

                    isProfileValidation = !pipeList[0].Deploy_entire_profile__c;
                    logId = getSignature(); //bw.logId;
                    patchListJSON = null; //bw.patchJson;
                    logsListJSON = null; //bw.logsJson;
                    validateOnly = null; //bw.validateOnly;
                }
            }
        } catch (Exception e) {
            isError = true;
            msg = e.getMessage();
        }
    }

    public static String getSignature() {
        return '' + Datetime.now().getTime();
    }

    public void commitInChunk() {
        String prefix = nameSpacePrefix;
        if (prefix != null && prefix != '') {
            prefix += '__';
        }

        if (commitChunkJSON != null && commitChunkJSON != '') {
            Map<String, String> recordTypeMap = new Map<String, String>();
            Set<String> idsComp = new Set<String>();
            String tempType = Schema.getGlobalDescribe()
                .get(prefix + (isVlocity ? 'Metadata_Item_Vlocity__c' : 'Metadata_Item__c'))
                .getDescribe()
                .getName();

            for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = :tempType
                WITH SECURITY_ENFORCED
                LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
            ]) {
                recordTypeMap.put(recordType.Id, recordType.Name);
            }
            Savepoint sp = Database.setSavepoint();
            Datetime commitDateTime = Datetime.now();
            String committerName = UserInfo.getName();
            try {
                List<Snapshot_Vlocity__c> snapListVlocityN = new List<Snapshot_Vlocity__c>();
                List<Snapshot__c> snapListN = new List<Snapshot__c>();

                String orgId = '';
                String snapName = '';
                snapListN = [
                    SELECT Id, Name, Organisation__c
                    FROM Snapshot__c
                    WHERE Id = :snapId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (snapListN.size() > 0) {
                    orgId = snapListN[0].Organisation__c;
                    snapName = snapListN[0].Name;
                }
                snapListVlocityN = [
                    SELECT Id, Name, Org__c
                    FROM Snapshot_Vlocity__c
                    WHERE Id = :snapId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (snapListVlocityN.size() > 0) {
                    orgId = snapListVlocityN[0].Org__c;
                    snapName = snapListVlocityN[0].Name;
                }

                CommitWraper wrapInfo = (CommitWraper) JSON.deserialize(commitChunkJSON, CommitWraper.class);
                if (metadataType == VeevaConstants.VEEVA_TYPE) {
                    for (String key : wrapInfo.dataMap.keySet()) {
                        wrapInfo.dataMap.put(key.toLowerCase(), wrapInfo.dataMap.get(key));
                    }
                }
                commitChunkJSON = null;
                Set<String> metaRecordTypeSet = new Set<String>();
                Set<String> metaFullNameSet = new Set<String>();
                List<Branch__c> branchList = new List<Branch__c>();

                branchList = [
                    SELECT Id, Repository__c, LastModifiedById, Deployment_Mode__c, Deployment_Style__c
                    FROM Branch__c
                    WHERE Id = :commitTo
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (branchList.size() == 1) {
                    String fullObjectName = Schema.SObjectType.Component__c.getName();
                    List<RecordType> rtList = new List<RecordType>();
                    rtList = [
                        SELECT Id, Name
                        FROM RecordType
                        WHERE SobjectType = :fullObjectName AND Name = 'Branch'
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (rtList.size() == 1) {
                        List<Component__c> insertList = new List<Component__c>();
                        List<Component__c> updateList = new List<Component__c>();
                        List<Component_History__c> historyList = new List<Component_History__c>();
                        Map<String, Component__c> itemMap = new Map<String, Component__c>();
                        List<String> metadataIds = wrapInfo.metaIds;
                        String query = 'SELECT Id,API_Name__c,Snapshot__r.Name, Label__c,RecordTypeId, LastModifiedBy.Name,Last_Modified_Date__c, Last_Updated_By__c';
                        query += isVlocity
                            ? ', Component_Name__c FROM Metadata_Item_Vlocity__c'
                            : ', Veeva_Component_Type__c, Component_Type__c, Name__c FROM Metadata_Item__c';
                        query += ' WHERE Snapshot__c = :snapId AND Id IN:metadataIds WITH SECURITY_ENFORCED';

                        for (SObject meta : Database.query(query)) {
                            Component__c comp = new Component__c();
                            comp.Component_Type__c = recordTypeMap.get((String) meta.get('RecordTypeId'));
                            comp.Component_Name__c = (String) meta.get('API_Name__c');
                            comp.File_Name__c = (String) meta.get('Label__c');
                            comp.Last_Modified_Date__c = (Datetime) meta.get('Last_Modified_Date__c');
                            comp.Last_Updated_By__c = (String) meta.get('Last_Updated_By__c');
                            comp.Committed_On__c = commitDateTime;
                            comp.Last_Modified_By__c = committerName;
                            comp.Branch__c = branchList[0].Id;
                            comp.RecordTypeId = rtList[0].Id;
                            comp.Version__c = 1;
                            comp.Parent_ID__c = snapId;
                            comp.Source__c = 'Snapshot';
                            comp.Org_ID__c = orgId;
                            comp.Parent_Name__c = (String) meta.getSObject('Snapshot__r').get('Name');

                            if (metadataType == 'Vlocity') {
                                comp.Component_Name__c = (String) meta.get('Component_Name__c');
                                comp.Vlocity_Component_Name__c = (String) meta.get('API_Name__c');
                                comp.Vlocity_Component__c = true;
                            }

                            if (metadataType == VeevaConstants.VEEVA_TYPE) {
                                comp.Component_Type__c = (String) meta.get('Veeva_Component_Type__c');
                                comp.Veeva_Component__c = true;
                            }

                            if (metadataType == B2CConstants.TYPE) {
                                String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                                comp.Component_Type__c = type;
                            }
                            if (metadataType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                                String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                                comp.Component_Type__c = type;
                            }

                            String key = comp.Component_Type__c + '#' + comp.Component_Name__c;

                            if (metadataType == VeevaConstants.VEEVA_TYPE) {
                                key = key.toLowerCase();
                            }

                            if (metadataType == MCConstants.TYPE) {
                                String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                                String name = (String) meta.get(Metadata_Item__c.Name__c.getDescribe().name);
                                String apiName = (String) meta.get(Metadata_Item__c.API_Name__c.getDescribe().name);

                                String mcKey = SnapshotToBranchCommitController.getMCKey(name, apiName);

                                key = type + '#' + mcKey;

                                comp.Component_Name__c = mcKey;
                                comp.Component_Type__c = type;
                                comp.MC_Key__c = apiName;
                            }

                            if (wrapInfo.dataMap.containsKey(key)) {
                                comp.CRC32__c = wrapInfo.dataMap.get(key).crc32;
                                metaRecordTypeSet.add(comp.Component_Type__c);
                                metaFullNameSet.add(comp.Component_Name__c);
                                itemMap.put(key, comp);
                            }
                        }

                        for (Component__c comp : [
                            SELECT
                                Id,
                                CRC32__c,
                                Org_ID__c,
                                Component_Type__c,
                                Component_Name__c,
                                RecordType.Name,
                                Version__c,
                                Name,
                                Last_Modified_Date__c,
                                Last_Updated_By__c,
                                Committed_On__c,
                                Last_Modified_By__c
                            FROM Component__c
                            WHERE
                                Branch__c = :commitTo
                                AND Component_Name__c IN :metaFullNameSet
                                AND Component_Type__c IN :metaRecordTypeSet
                            WITH SECURITY_ENFORCED
                        ]) {
                            String key = comp.Component_Type__c + '#' + comp.Component_Name__c;
                            if (metadataType == VeevaConstants.VEEVA_TYPE) {
                                key = key.toLowerCase();
                            }
                            if (itemMap.containsKey(key)) {
                                Component__c updateComp = itemMap.get(key);
                                //creating component history
                                Component_History__c history = new Component_History__c(
                                    Component__c = comp.Id,
                                    Version__c = comp.Version__c + 1,
                                    CRC32__c = updateComp.CRC32__c,
                                    Changed_By__c = updateComp.Last_Updated_By__c,
                                    Changed_On__c = updateComp.Last_Modified_Date__c,
                                    External_Committed_By__c = timestamp,
                                    Action_Type__c = EditComponentHistoryController.ACTION_TYPE_COMMIT,
                                    Source_Type__c = 'Snapshot',
                                    Source_Name__c = snapName,
                                    Source_Id__c = snapId
                                );
                                historyList.add(history);

                                //updating old record
                                if (isVlocity) {
                                    comp.Vlocity_Component_Name__c = updateComp.Vlocity_Component_Name__c;
                                    comp.Vlocity_Component__c = true;
                                }
                                comp.File_Name__c = updateComp.File_Name__c;
                                comp.Last_Modified_Date__c = updateComp.Last_Modified_Date__c;
                                comp.Last_Updated_By__c = updateComp.Last_Updated_By__c;
                                comp.Committed_On__c = commitDateTime;
                                comp.Last_Modified_By__c = committerName;
                                comp.Version__c = comp.Version__c + 1;
                                comp.CRC32__c = updateComp.CRC32__c;
                                comp.Comments__c = null;
                                comp.Parent_ID__c = snapId;
                                comp.Source__c = 'Snapshot';
                                comp.Org_ID__c = orgId;
                                comp.Parent_Name__c = snapName;
                                updateList.add(comp);
                                idsComp.add(comp.Id);
                                itemMap.remove(key);
                            }
                        }
                        metaFullNameSet.clear();
                        metaRecordTypeSet.clear();

                        for (Component__c comp : itemMap.values()) {
                            insertList.add(comp);
                        }

                        itemMap.clear();
                        //upsert component and Component History records
                        if (insertList.size() > 0) {
                            DatabaseUtils.insertRecords(
                                insertList,
                                new List<Schema.DescribeFieldResult>{
                                    Component__c.Component_Name__c.getDescribe(),
                                    Component__c.Component_Type__c.getDescribe(),
                                    Component__c.File_Name__c.getDescribe(),
                                    Component__c.Last_Modified_Date__c.getDescribe(),
                                    Component__c.Last_Updated_By__c.getDescribe(),
                                    Component__c.Committed_On__c.getDescribe(),
                                    Component__c.Last_Modified_By__c.getDescribe(),
                                    Component__c.Branch__c.getDescribe(),
                                    Component__c.Version__c.getDescribe(),
                                    Component__c.Parent_ID__c.getDescribe(),
                                    Component__c.Source__c.getDescribe(),
                                    Component__c.CRC32__c.getDescribe(),
                                    Component__c.Parent_Name__c.getDescribe(),
                                    Component__c.RecordTypeId.getDescribe(),
                                    Component__c.Org_ID__c.getDescribe(),
                                    Component__c.Vlocity_Component__c.getDescribe()
                                }
                            );
                            for (Component__c comp : insertList) {
                                Component_History__c history = new Component_History__c(
                                    Component__c = comp.Id,
                                    Version__c = comp.Version__c,
                                    CRC32__c = comp.CRC32__c,
                                    Changed_By__c = comp.Last_Updated_By__c,
                                    Changed_On__c = comp.Last_Modified_Date__c,
                                    External_Committed_By__c = timestamp,
                                    Action_Type__c = EditComponentHistoryController.ACTION_TYPE_COMMIT,
                                    Source_Type__c = comp.Source__c,
                                    Source_Name__c = comp.Parent_Name__c,
                                    Source_Id__c = comp.Parent_ID__c
                                );
                                historyList.add(history);
                                idsComp.add(comp.Id);
                            }
                            insertList.clear();
                        }
                        if (updateList.size() > 0) {
                            DatabaseUtils.updateRecords(
                                updateList,
                                new List<Schema.DescribeFieldResult>{
                                    Component__c.File_Name__c.getDescribe(),
                                    Component__c.Committed_On__c.getDescribe(),
                                    Component__c.Last_Modified_By__c.getDescribe(),
                                    Component__c.Last_Modified_Date__c.getDescribe(),
                                    Component__c.Last_Updated_By__c.getDescribe(),
                                    Component__c.Comments__c.getDescribe(),
                                    Component__c.Version__c.getDescribe(),
                                    Component__c.CRC32__c.getDescribe(),
                                    Component__c.Parent_ID__c.getDescribe(),
                                    Component__c.Source__c.getDescribe(),
                                    Component__c.Parent_Name__c.getDescribe(),
                                    Component__c.Org_ID__c.getDescribe(),
                                    Component__c.Vlocity_Component__c.getDescribe()
                                }
                            );
                            updateList.clear();
                        }
                        if (historyList.size() > 0) {
                            DatabaseUtils.insertRecords(
                                historyList,
                                new List<Schema.DescribeFieldResult>{
                                    Component_History__c.Component__c.getDescribe(),
                                    Component_History__c.Version__c.getDescribe(),
                                    Component_History__c.CRC32__c.getDescribe(),
                                    Component_History__c.Changed_By__c.getDescribe(),
                                    Component_History__c.Changed_On__c.getDescribe(),
                                    Component_History__c.External_Committed_By__c.getDescribe(),
                                    Component_History__c.Action_Type__c.getDescribe(),
                                    Component_History__c.Source_Type__c.getDescribe(),
                                    Component_History__c.Source_Name__c.getDescribe(),
                                    Component_History__c.Source_Id__c.getDescribe()
                                }
                            );
                            List<Attachment> attList = new List<Attachment>();
                            idHistoryLi = new List<String>();

                            for (Component_History__c history : [
                                SELECT
                                    Id,
                                    Component__r.Component_Type__c,
                                    Component__r.Component_Name__c,
                                    Component__r.Vlocity_Component_Name__c
                                FROM Component_History__c
                                WHERE Id IN :historyList
                                WITH SECURITY_ENFORCED
                            ]) {
                                Attachment att = new Attachment(
                                    Name = history.Component__r.Component_Type__c,
                                    ParentId = history.Id,
                                    Description = history.Component__r.Component_Type__c,
                                    ContentType = 'application/zip'
                                );

                                String key =
                                    history.Component__r.Component_Type__c +
                                    '#' +
                                    history.Component__r.Component_Name__c;

                                if (metadataType == VeevaConstants.VEEVA_TYPE) {
                                    key = key.toLowerCase();
                                }

                                if (wrapInfo.dataMap.containsKey(key)) {
                                    att.Body = EncodingUtil.base64Decode(wrapInfo.dataMap.get(key).data);
                                    wrapInfo.dataMap.remove(key);
                                    attList.add(att);
                                }
                                idHistoryLi.add(history.Id);
                            }
                            wrapInfo = new CommitWraper();
                            if (attList.size() > 0) {
                                DatabaseUtils.insertRecords(
                                    attList,
                                    new List<Schema.DescribeFieldResult>{
                                        Attachment.Body.getDescribe(),
                                        Attachment.Name.getDescribe(),
                                        Attachment.Description.getDescribe(),
                                        Attachment.ContentType.getDescribe(),
                                        Attachment.ParentId.getDescribe()
                                    }
                                );
                            }

                            // TODO create map hist Id => attachment Id
                            // TODO analyse heap
                            historyList.clear();
                            attList.clear();
                        }
                    }
                }
                idsComponents.addAll(idsComp);
            } catch (Exception ex) {
                isError = true;
                System.debug(ex.getMessage());
                Database.rollback(sp);
                msg = FlosumConstants.parseCatchMessage(ex.getMessage());
            }
        }
    }

    public void nextByJS() {
        if (commitChunkJSON != null && commitChunkJSON != '') {
            JSCommitWraper result = (JSCommitWraper) JSON.deserialize(commitChunkJSON, JSCommitWraper.class);
            if (idHistoryLi == null) {
                idHistoryLi = new List<String>();
            }
            idsComponents.addAll(result.idsComponents);
            idHistoryLi.addAll(result.idHistoryLi);
            commitChunkJSON = null;
        }
    }

    @RemoteAction
    public static JSCommitWraper jsCommit(String commitChunkJSON, String snapId, String commitTo, String metadataType) {
        JSCommitWraper result = new JSCommitWraper();
        String timestamp = '' + Datetime.now().getTime();
        String prefix = FlosumConstants.getNameSpacePrefix();
        if (prefix != null && prefix != '') {
            prefix += '__';
        }
        if (commitChunkJSON != null && commitChunkJSON != '') {
            Map<String, String> recordTypeMap = new Map<String, String>();
            Set<String> idsComp = new Set<String>();
            String tempType = Schema.getGlobalDescribe()
                .get(prefix + (metadataType == 'Vlocity' ? 'Metadata_Item_Vlocity__c' : 'Metadata_Item__c'))
                .getDescribe()
                .getName();

            for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = :tempType
                WITH SECURITY_ENFORCED
                LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
            ]) {
                recordTypeMap.put(recordType.Id, recordType.Name);
            }
            Datetime commitDateTime = Datetime.now();
            String committerName = UserInfo.getName();

            List<Snapshot_Vlocity__c> snapListVlocityN = new List<Snapshot_Vlocity__c>();
            List<Snapshot__c> snapListN = new List<Snapshot__c>();

            String orgId = '';
            String snapName = '';
            snapListN = [
                SELECT Id, Name, Organisation__c
                FROM Snapshot__c
                WHERE Id = :snapId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (snapListN.size() > 0) {
                orgId = snapListN[0].Organisation__c;
                snapName = snapListN[0].Name;
            }
            snapListVlocityN = [
                SELECT Id, Name, Org__c
                FROM Snapshot_Vlocity__c
                WHERE Id = :snapId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (snapListVlocityN.size() > 0) {
                orgId = snapListVlocityN[0].Org__c;
                snapName = snapListVlocityN[0].Name;
            }

            CommitWraper wrapInfo = (CommitWraper) JSON.deserialize(commitChunkJSON, CommitWraper.class);
            if (metadataType == VeevaConstants.VEEVA_TYPE) {
                for (String key : wrapInfo.dataMap.keySet()) {
                    wrapInfo.dataMap.put(key.toLowerCase(), wrapInfo.dataMap.get(key));
                }
            }
            commitChunkJSON = null;
            Set<String> metaRecordTypeSet = new Set<String>();
            Set<String> metaFullNameSet = new Set<String>();
            List<Branch__c> branchList = new List<Branch__c>();
            branchList = [
                SELECT Id, Repository__c, LastModifiedById, Deployment_Mode__c, Deployment_Style__c
                FROM Branch__c
                WHERE Id = :commitTo
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (branchList.size() == 1) {
                String fullObjectName = Schema.SObjectType.Component__c.getName();
                List<RecordType> rtList = new List<RecordType>();
                rtList = [
                    SELECT Id, Name
                    FROM RecordType
                    WHERE SobjectType = :fullObjectName AND Name = 'Branch'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (rtList.size() == 1) {
                    List<Component__c> insertList = new List<Component__c>();
                    List<Component__c> updateList = new List<Component__c>();
                    List<Component_History__c> historyList = new List<Component_History__c>();
                    Map<String, Component__c> itemMap = new Map<String, Component__c>();
                    List<String> metadataIds = wrapInfo.metaIds;
                    String query = 'SELECT Id,API_Name__c,Snapshot__r.Name, Label__c,RecordTypeId, LastModifiedBy.Name,Last_Modified_Date__c, Last_Updated_By__c';
                    query += metadataType == 'Vlocity'
                        ? ', Component_Name__c FROM Metadata_Item_Vlocity__c'
                        : ', Veeva_Component_Type__c, Name__c, Component_Type__c FROM Metadata_Item__c';
                    query += ' WHERE Snapshot__c = :snapId AND Id IN:metadataIds WITH SECURITY_ENFORCED';

                    for (SObject meta : Database.query(query)) {
                        Component__c comp = new Component__c();
                        comp.Component_Type__c = recordTypeMap.get((String) meta.get('RecordTypeId'));
                        comp.Component_Name__c = (String) meta.get('API_Name__c');
                        comp.File_Name__c = (String) meta.get('Label__c');
                        comp.Last_Modified_Date__c = (Datetime) meta.get('Last_Modified_Date__c');
                        comp.Last_Updated_By__c = (String) meta.get('Last_Updated_By__c');
                        comp.Committed_On__c = commitDateTime;
                        comp.Last_Modified_By__c = committerName;
                        comp.Branch__c = branchList[0].Id;
                        comp.RecordTypeId = rtList[0].Id;
                        comp.Version__c = 1;
                        comp.Parent_ID__c = snapId;
                        comp.Source__c = 'Snapshot';
                        comp.Org_ID__c = orgId;
                        comp.Parent_Name__c = (String) meta.getSObject('Snapshot__r').get('Name');
                        if (metadataType == 'Vlocity') {
                            comp.Component_Name__c = (String) meta.get('Component_Name__c');
                            comp.Vlocity_Component_Name__c = (String) meta.get('API_Name__c');
                            comp.Vlocity_Component__c = true;
                        } else if (metadataType == VeevaConstants.VEEVA_TYPE) {
                            comp.Component_Type__c = (String) meta.get('Veeva_Component_Type__c');
                            comp.Veeva_Component__c = true;
                        } else if (metadataType == B2CConstants.TYPE) {
                            String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                            comp.Component_Type__c = type;
                        } else if (metadataType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                            String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                            comp.Component_Type__c = type;
                        }

                        String key = comp.Component_Type__c + '#' + comp.Component_Name__c;

                        if (metadataType == VeevaConstants.VEEVA_TYPE) {
                            key = key.toLowerCase();
                        } else if (metadataType == MCConstants.TYPE) {
                            String type = (String) meta.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                            String name = (String) meta.get(Metadata_Item__c.Name__c.getDescribe().name);
                            String apiName = (String) meta.get(Metadata_Item__c.API_Name__c.getDescribe().name);

                            String mcKey = SnapshotToBranchCommitController.getMCKey(name, apiName);

                            key = type + '#' + mcKey;

                            comp.Component_Name__c = mcKey;
                            comp.Component_Type__c = type;
                            comp.MC_Key__c = apiName;
                        }

                        if (wrapInfo.dataMap.containsKey(key)) {
                            comp.CRC32__c = wrapInfo.dataMap.get(key).crc32;
                            metaRecordTypeSet.add(comp.Component_Type__c);
                            metaFullNameSet.add(comp.Component_Name__c);
                            itemMap.put(key, comp);
                        }
                    }

                    for (Component__c comp : [
                        SELECT
                            Id,
                            Vlocity_Component__c,
                            CRC32__c,
                            Org_ID__c,
                            Component_Type__c,
                            Component_Name__c,
                            RecordType.Name,
                            Version__c,
                            Name,
                            Last_Modified_Date__c,
                            Last_Updated_By__c,
                            Committed_On__c,
                            Last_Modified_By__c
                        FROM Component__c
                        WHERE
                            Branch__c = :commitTo
                            AND Component_Name__c IN :metaFullNameSet
                            AND Component_Type__c IN :metaRecordTypeSet
                        WITH SECURITY_ENFORCED
                    ]) {
                        String key = comp.Component_Type__c + '#' + comp.Component_Name__c;
                        if (metadataType == VeevaConstants.VEEVA_TYPE) {
                            key = key.toLowerCase();
                        }
                        if (itemMap.containsKey(key)) {
                            Component__c updateComp = itemMap.get(key);
                            //creating component history
                            Component_History__c history = new Component_History__c(
                                Component__c = comp.Id,
                                Version__c = comp.Version__c + 1,
                                CRC32__c = updateComp.CRC32__c,
                                Changed_By__c = updateComp.Last_Updated_By__c,
                                Changed_On__c = updateComp.Last_Modified_Date__c,
                                External_Committed_By__c = timestamp,
                                Action_Type__c = EditComponentHistoryController.ACTION_TYPE_COMMIT,
                                Source_Type__c = 'Snapshot',
                                Source_Name__c = snapName,
                                Source_Id__c = snapId
                            );
                            historyList.add(history);

                            //updating old record
                            if (metadataType == 'Vlocity') {
                                comp.Vlocity_Component_Name__c = updateComp.Vlocity_Component_Name__c;
                                comp.Vlocity_Component__c = true;
                            }
                            comp.File_Name__c = updateComp.File_Name__c;
                            comp.Last_Modified_Date__c = updateComp.Last_Modified_Date__c;
                            comp.Last_Updated_By__c = updateComp.Last_Updated_By__c;
                            comp.Committed_On__c = commitDateTime;
                            comp.Last_Modified_By__c = committerName;
                            comp.Version__c = comp.Version__c + 1;
                            comp.CRC32__c = updateComp.CRC32__c;
                            comp.Comments__c = null;
                            comp.Parent_ID__c = snapId;
                            comp.Source__c = 'Snapshot';
                            comp.Org_ID__c = orgId;
                            comp.Parent_Name__c = snapName;
                            updateList.add(comp);
                            idsComp.add(comp.Id);
                            itemMap.remove(key);
                        }
                    }
                    metaFullNameSet.clear();
                    metaRecordTypeSet.clear();

                    for (Component__c comp : itemMap.values()) {
                        insertList.add(comp);
                    }
                    itemMap.clear();
                    //upsert component and Component History records
                    try {
                        if (insertList.size() > 0) {
                            DatabaseUtils.insertRecords(
                                insertList,
                                new List<Schema.DescribeFieldResult>{
                                    Component__c.Component_Name__c.getDescribe(),
                                    Component__c.Component_Type__c.getDescribe(),
                                    Component__c.File_Name__c.getDescribe(),
                                    Component__c.Last_Modified_Date__c.getDescribe(),
                                    Component__c.Last_Updated_By__c.getDescribe(),
                                    Component__c.Committed_On__c.getDescribe(),
                                    Component__c.Last_Modified_By__c.getDescribe(),
                                    Component__c.Branch__c.getDescribe(),
                                    Component__c.Version__c.getDescribe(),
                                    Component__c.Parent_ID__c.getDescribe(),
                                    Component__c.Source__c.getDescribe(),
                                    Component__c.CRC32__c.getDescribe(),
                                    Component__c.Parent_Name__c.getDescribe(),
                                    Component__c.RecordTypeId.getDescribe(),
                                    Component__c.Org_ID__c.getDescribe(),
                                    Component__c.Vlocity_Component__c.getDescribe()
                                }
                            );
                            for (Component__c comp : insertList) {
                                Component_History__c history = new Component_History__c(
                                    Component__c = comp.Id,
                                    Version__c = comp.Version__c,
                                    CRC32__c = comp.CRC32__c,
                                    Changed_By__c = comp.Last_Updated_By__c,
                                    Changed_On__c = comp.Last_Modified_Date__c,
                                    External_Committed_By__c = timestamp,
                                    Action_Type__c = EditComponentHistoryController.ACTION_TYPE_COMMIT,
                                    Source_Type__c = comp.Source__c,
                                    Source_Name__c = comp.Parent_Name__c,
                                    Source_Id__c = comp.Parent_ID__c
                                );
                                historyList.add(history);
                                idsComp.add(comp.Id);
                            }
                            insertList.clear();
                        }
                        if (updateList.size() > 0) {
                            DatabaseUtils.updateRecords(
                                updateList,
                                new List<Schema.DescribeFieldResult>{
                                    Component__c.File_Name__c.getDescribe(),
                                    Component__c.Committed_On__c.getDescribe(),
                                    Component__c.Last_Modified_By__c.getDescribe(),
                                    Component__c.Last_Modified_Date__c.getDescribe(),
                                    Component__c.Last_Updated_By__c.getDescribe(),
                                    Component__c.Comments__c.getDescribe(),
                                    Component__c.Version__c.getDescribe(),
                                    Component__c.CRC32__c.getDescribe(),
                                    Component__c.Parent_ID__c.getDescribe(),
                                    Component__c.Source__c.getDescribe(),
                                    Component__c.Parent_Name__c.getDescribe(),
                                    Component__c.Org_ID__c.getDescribe(),
                                    Component__c.Vlocity_Component__c.getDescribe()
                                }
                            );
                            updateList.clear();
                        }
                        if (historyList.size() > 0) {
                            DatabaseUtils.insertRecords(
                                historyList,
                                new List<Schema.DescribeFieldResult>{
                                    Component_History__c.Component__c.getDescribe(),
                                    Component_History__c.Version__c.getDescribe(),
                                    Component_History__c.CRC32__c.getDescribe(),
                                    Component_History__c.Changed_By__c.getDescribe(),
                                    Component_History__c.Changed_On__c.getDescribe(),
                                    Component_History__c.External_Committed_By__c.getDescribe(),
                                    Component_History__c.Action_Type__c.getDescribe(),
                                    Component_History__c.Source_Type__c.getDescribe(),
                                    Component_History__c.Source_Name__c.getDescribe(),
                                    Component_History__c.Source_Id__c.getDescribe()
                                }
                            );
                            List<Attachment> attList = new List<Attachment>();

                            for (Component_History__c history : [
                                SELECT
                                    Id,
                                    Component__r.Component_Type__c,
                                    Component__r.Component_Name__c,
                                    Component__r.Vlocity_Component_Name__c
                                FROM Component_History__c
                                WHERE Id IN :historyList
                                WITH SECURITY_ENFORCED
                            ]) {
                                Attachment att = new Attachment(
                                    Name = history.Component__r.Component_Type__c +
                                        '#' +
                                        history.Component__r.Component_Name__c,
                                    ParentId = history.Id,
                                    Description = history.Component__r.Component_Type__c,
                                    ContentType = 'application/zip'
                                );
                                String key =
                                    history.Component__r.Component_Type__c +
                                    '#' +
                                    history.Component__r.Component_Name__c;
                                if (metadataType == VeevaConstants.VEEVA_TYPE) {
                                    key = key.toLowerCase();
                                }
                                if (wrapInfo.dataMap.containsKey(key)) {
                                    att.Body = EncodingUtil.base64Decode('UEsFBgAAAAAAAAAAAAAAAAAAAAAAAA==');
                                    wrapInfo.dataMap.remove(key);
                                    attList.add(att);
                                }
                                result.idHistoryLi.add(history.Id);
                            }
                            wrapInfo = new CommitWraper();
                            if (attList.size() > 0) {
                                DatabaseUtils.insertRecords(
                                    attList,
                                    new List<Schema.DescribeFieldResult>{
                                        Attachment.Body.getDescribe(),
                                        Attachment.Name.getDescribe(),
                                        Attachment.Description.getDescribe(),
                                        Attachment.ContentType.getDescribe(),
                                        Attachment.ParentId.getDescribe()
                                    }
                                );
                                for (Attachment att : attList) {
                                    result.attList.add(new JSAttWrapper(att));
                                }
                            }
                            // TODO create map hist Id => attachment Id
                            // TODO analyse heap
                            historyList.clear();
                            //attList.clear();
                        }
                    } catch (Exception ex) {
                        throw new FlosumException(
                            FlosumConstants.parseCatchMessage(ex.getMessage())
                                + '\n'
                                + System.Label.Please_refresh_the_page
                        );
                    }
                }
            }
            result.idsComponents.addAll(idsComp);
        }
        return result;
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class JSCommitWraper {
        public Set<String> idsComponents;
        public List<String> idHistoryLi;
        public List<JSAttWrapper> attList;

        public JSCommitWraper() {
            idsComponents = new Set<String>();
            idHistoryLi = new List<String>();
            attList = new List<JSAttWrapper>();
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class JSAttWrapper {
        public String Id;
        public String Name;
        public String Description;
        public String ContentType;
        public String ParentId;

        public JSAttWrapper(Attachment att) {
            this.Id = att.Id;
            this.Name = att.Name;
            this.Description = att.Description;
            this.ContentType = att.ContentType;
            this.ParentId = att.ParentId;
        }
    }


    @ReadOnly
    @RemoteAction
    public static Map<String, Set<String>> collectBackupInfo(String pId) {
        return MetadataUtils.collectBackupInfo(pId);
    }

    //list metadatatypes and metadataitems for commit functionality
    public void listMetadataTypes() {
        availableMetadataTypes.clear();

        if (String.isBlank(snapId)) {
            return;
        }

        String objectName = metadataType == 'Vlocity'
            ? Metadata_Item_Vlocity__c.getSObjectType().getDescribe().name
            : Metadata_Item__c.getSObjectType().getDescribe().name;

        List<String> fields = new List<String>{ 'RecordType.Name' };

        if (isVeevaType) {
            fields.add(Metadata_Item__c.Veeva_Component_Type__c.getDescribe().name);
        } else {
            fields.add(Metadata_Item__c.RecordTypeId.getDescribe().name);
            fields.add(Metadata_Item__c.Component_Type__c.getDescribe().name);
        }

        String template = 'SELECT {0} FROM {1} WHERE Snapshot__c = :snapId AND Attachment_ID__c != NULL WITH SECURITY_ENFORCED LIMIT 40000';

        String query = String.format(template, new List<String>{ String.join(fields, ', '), objectName });

        for (SObject metadataItem : Database.query(query)) {
            String componentType;
            RecordType recordType = (RecordType) metadataItem.getSObject('RecordType');

            if (
                recordType?.Name == MCConstants.TYPE ||
                recordType?.Name == B2CConstants.TYPE ||
                recordType?.Name == AbstractAuthentication.MULESOFT_ORG_TYPE
            ) {
                componentType = (String) metadataItem.get('Component_Type__c');
            } else if (isVeevaType) {
                componentType = (String) metadataItem.get('Veeva_Component_Type__c');
            } else {
                componentType = recordType.Name;
            }

            if (!metaTypeFilterSet.contains(componentType)) {
                availableMetadataTypes.add(new SelectOption(componentType, componentType));
            }

            metaTypeFilterSet.add(componentType);
        }

        availableMetadataTypes.sort();
        availableMetadataTypes.add(0, new SelectOption('all', 'All'));

        selectedMetadataType = 'all';
    }

    @ReadOnly
    @RemoteAction
    public static Map<String, Object> getAllItems(String snapId, String metadataType, String lastId) {
        Map<String, Object> result = new Map<String, Object>();
        Set<String> typeFilterSet = new Set<String>();
        typeFilterSet.addAll(FlosumConstants.profilePermissionMap.keySet());
        List<String> total = new List<String>();
        String query = 'SELECT Id FROM ';
        query += metadataType == 'Vlocity'
            ? 'Metadata_Item_Vlocity__c WHERE Snapshot__c = :snapId AND RecordType.Name NOT IN :typeFilterSet AND Attachment_ID__c!= null AND Id > :lastId WITH SECURITY_ENFORCED ORDER BY Id LIMIT 40000'
            : 'Metadata_Item__c WHERE Snapshot__c = :snapId AND RecordType.Name NOT IN :typeFilterSet AND Attachment_ID__c!= null AND Id > :lastId WITH SECURITY_ENFORCED ORDER BY Id LIMIT 40000';

        for (SObject mi : Database.query(query)) {
            total.add((String) mi.get('Id'));
        }
        lastId = total.size() >= 40000 ? total.get(total.size() - 1) : '';
        result.put('metaItemListId', total);
        result.put('lastId', lastId);
        return result;
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaItemInfoWrapper {
        public List<MetaItemWrapper> items;
        public Map<String, String> attIdsMap;

        public MetaItemInfoWrapper() {
            items = new List<MetaItemWrapper>();
            attIdsMap = new Map<String, String>();
        }
    }

    @ReadOnly
    @RemoteAction
    public static MetaItemInfoWrapper getItems(String snapId, String idsJSON, String metadataType) {
        Boolean isVlocity = metadataType == 'Vlocity';

        String objectName;

        if (isVlocity) {
            objectName = Metadata_Item_Vlocity__c.getSObjectType().getDescribe().name;
        } else {
            objectName = Metadata_Item__c.getSObjectType().getDescribe().name;
        }

        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :objectName
            WITH SECURITY_ENFORCED
            LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
        ]) {
            recordTypeMap.put(recordType.Id, recordType.Name);
        }

        MetaItemInfoWrapper metaItemInfoWrapper = new MetaItemInfoWrapper();

        if (String.isBlank(idsJSON)) {
            return metaItemInfoWrapper;
        }

        List<String> ids = (List<String>) JSON.deserialize(idsJSON, List<String>.class);

        List<String> fields = new List<String>{
            Metadata_Item__c.Id.getDescribe().name,
            Metadata_Item__c.API_Name__c.getDescribe().name,
            Metadata_Item__c.Label__c.getDescribe().name,
            Metadata_Item__c.RecordTypeId.getDescribe().name,
            Metadata_Item__c.Attachment_ID__c.getDescribe().name,
            Metadata_Item__c.Last_Updated_By__c.getDescribe().name,
            Metadata_Item__c.Last_Modified_Date__c.getDescribe().name
        };

        if (isVlocity) {
            fields.add(Metadata_Item_Vlocity__c.Component_Name__c.getDescribe().name);
            fields.add(Metadata_Item_Vlocity__c.Sub_Items__c.getDescribe().name);
        } else {
            fields.add(Metadata_Item__c.Veeva_Component_Type__c.getDescribe().name);
            fields.add(Metadata_Item__c.Component_Type__c.getDescribe().name);
            fields.add(Metadata_Item__c.Name__c.getDescribe().name);
        }

        String query = String.format(
            FlosumConstants.ITEMS_QUERY_TEMPLATE,
            new List<String>{ String.join(fields, ', '), objectName }
        );

        for (List<SObject> metadataItems : Database.query(query)) {
            for (SObject metadataItem : metadataItems) {
                MetaItemWrapper metaItemWrapper = new MetaItemWrapper(
                    (String) metadataItem.get(Metadata_Item__c.Id.getDescribe().name),
                    (String) metadataItem.get(Metadata_Item__c.API_Name__c.getDescribe().name),
                    recordTypeMap.get((String) metadataItem.get(Metadata_Item__c.RecordTypeId.getDescribe().name)),
                    (String) metadataItem.get(Metadata_Item__c.Label__c.getDescribe().name),
                    (String) metadataItem.get(Metadata_Item__c.Last_Updated_By__c.getDescribe().name),
                    (Datetime) metadataItem.get(Metadata_Item__c.Last_Modified_Date__c.getDescribe().name)
                );

                if (metadataType == VeevaConstants.VEEVA_TYPE) {
                    metaItemWrapper.compType = (String) metadataItem.get(
                        Metadata_Item__c.Veeva_Component_Type__c.getDescribe().name
                    );
                }

                if (isVlocity) {
                    metaItemWrapper.compName = (String) metadataItem.get(
                        Metadata_Item_Vlocity__c.Component_Name__c.getDescribe().name
                    );

                    metaItemWrapper.vlocityCompName = (String) metadataItem.get(
                        Metadata_Item_Vlocity__c.API_Name__c.getDescribe().name
                    );

                    if (metadataItem.get(Metadata_Item_Vlocity__c.Sub_Items__c.getDescribe().name) != null) {
                        try {
                            metaItemWrapper.subItemList = (List<String>) JSON.deserialize(
                                (String) metadataItem.get(Metadata_Item_Vlocity__c.Sub_Items__c.getDescribe().name),
                                List<String>.class
                            );
                        } catch (Exception e) {
                            // Nothing...
                        }
                    }
                }

                if (metadataType == B2CConstants.TYPE) {
                    String type = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                    metaItemWrapper.compType = type;
                }

                if (metadataType == MCConstants.TYPE) {
                    String type = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                    String name = (String) metadataItem.get(Metadata_Item__c.Name__c.getDescribe().name);
                    String key = (String) metadataItem.get(Metadata_Item__c.API_Name__c.getDescribe().name);

                    metaItemWrapper.compType = type;
                    metaItemWrapper.compName = SnapshotToBranchCommitController.getMCKey(name, key);
                }

                if (metadataType == B2CConstants.TYPE) {
                    metaItemWrapper.compName = (String) metadataItem.get(Metadata_Item__c.Name__c.getDescribe().name);
                }

                if (metadataType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                    String type = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                    metaItemWrapper.compType = type;
                }

                metaItemInfoWrapper.items.add(metaItemWrapper);
                metaItemInfoWrapper.attIdsMap.put(
                    (String) metadataItem.get(Metadata_Item__c.Id.getDescribe().name),
                    (String) metadataItem.get(Metadata_Item__c.Attachment_ID__c.getDescribe().name)
                );
            }
        }

        return metaItemInfoWrapper;
    }

    public static String getMCKey(String name, String key) {
        String componentKey = name;

        if (name != key) {
            componentKey += ' (' + key + ')';
        }

        return componentKey;
    }

    @ReadOnly
    @RemoteAction
    public static CommitInfoWraper getSnapshotAttInfo(String snapAttIdsJSON) {
        CommitInfoWraper masterWrap = new CommitInfoWraper();
        List<Attachment> attList = new List<Attachment>();
        List<String> attIdSet = (List<String>) JSON.deserialize(snapAttIdsJSON, List<String>.class);
        if (attIdSet != null && attIdSet.size() > 0) {
            attList = [
                SELECT Id, Name, BodyLength, Description, ParentId
                FROM Attachment
                WHERE Id IN :attIdSet
                WITH SECURITY_ENFORCED
            ];
        }
        masterWrap.attList = attList;
        return masterWrap;
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class CompareRequest {
        public List<String> metaIdList;
        public Map<String, String> crcMap;
    }

    @ReadOnly
    @RemoteAction
    public static CompareResultWrapper getComparison(
        String snapshotId,
        String branchId,
        String metaIdMapJSON,
        String metadataType
    ) {
        CompareResultWrapper compareResultWrapper = new CompareResultWrapper();

        if (String.isBlank(snapshotId)) {
            compareResultWrapper.msg = 'Snapshot Id is not specified.';
            return compareResultWrapper;
        }

        if (String.isBlank(branchId)) {
            compareResultWrapper.msg = 'Branch Id is not specified.';
            return compareResultWrapper;
        }

        if (String.isBlank(branchId)) {
            return compareResultWrapper;
        }

        CompareRequest compareRequest = (CompareRequest) JSON.deserialize(metaIdMapJSON, CompareRequest.class);

        // get MetaItem's ids
        if (compareRequest.metaIdList == null || compareRequest.crcMap == null) {
            compareResultWrapper.msg = 'Wrong JSON request';
            return compareResultWrapper;
        }

        String nameSpacePrefix = FlosumConstants.getNameSpacePrefix();
        if (nameSpacePrefix != null && nameSpacePrefix != '') {
            nameSpacePrefix += '__';
        }

        Map<String, String> recordTypeMap = new Map<String, String>();

        String sObjectType = Schema.getGlobalDescribe()
            .get(nameSpacePrefix + (metadataType == 'Vlocity' ? 'Metadata_Item_Vlocity__c' : 'Metadata_Item__c'))
            .getDescribe()
            .getName();

        for (RecordType recordType : [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :sObjectType
            WITH SECURITY_ENFORCED
            LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
        ]) {
            recordTypeMap.put(recordType.Id, recordType.Name);
        }

        Set<String> metaRecordTypeSet = new Set<String>();
        Set<String> metaFullNameSet = new Set<String>();

        List<Branch__c> branches = [
            SELECT Id, Branch_Name__c, LastModifiedById, Repository__c
            FROM Branch__c
            WHERE Id = :branchId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (branches.isEmpty()) {
            compareResultWrapper.msg = 'Branch not found.';
            return compareResultWrapper;
        }

        List<Schema.DescribeFieldResult> fields = getComparisonQueryFields(metadataType);

        List<String> queryFields = new List<String>();

        for (DescribeFieldResult describeField : fields) {
            queryFields.add(describeField.name);
        }

        Schema.DescribeSObjectResult describeObject = metadataType == 'Vlocity'
            ? Metadata_Item_Vlocity__c.getSObjectType().getDescribe()
            : Metadata_Item__c.getSObjectType().getDescribe();

        List<String> metadataIds = compareRequest.metaIdList;

        String queryTemplate = 'SELECT {0} FROM {1} WHERE Snapshot__c = :snapshotId AND Id IN :metadataIds WITH SECURITY_ENFORCED';

        String query = String.format(
            queryTemplate,
            new List<String>{ String.join(queryFields, ', '), describeObject.name }
        );

        Map<String, SObject> itemMap = new Map<String, SObject>();

        DatabaseUtils.checkObjectsAndFieldsAccessibility(
            new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{ describeObject => fields }
        );

        for (SObject metadataItem : Database.query(query)) {
            String componentType = recordTypeMap.get((String) metadataItem.get('RecordTypeId'));

            if (metadataType == VeevaConstants.VEEVA_TYPE) {
                componentType = (String) metadataItem.get(Metadata_Item__c.Veeva_Component_Type__c.getDescribe().name);
            }

            Boolean isVlocity = metadataType == 'Vlocity';

            String componentName = (String) metadataItem.get(
                isVlocity
                    ? Metadata_Item_Vlocity__c.Component_Name__c.getDescribe().name
                    : Metadata_Item__c.API_Name__c.getDescribe().name
            );

            if (metadataType == B2CConstants.TYPE) {
                componentType = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
            }

            if (metadataType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                componentType = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
            }

            String key = getKey(componentType, componentName, isVlocity);

            if (metadataType == MCConstants.TYPE) {
                String type = (String) metadataItem.get(Metadata_Item__c.Component_Type__c.getDescribe().name);
                String name = (String) metadataItem.get(Metadata_Item__c.Name__c.getDescribe().name);
                String apiName = (String) metadataItem.get(Metadata_Item__c.API_Name__c.getDescribe().name);

                String mcKey = SnapshotToBranchCommitController.getMCKey(name, apiName);

                key = type + '#' + mcKey;

                componentType = type;
                componentName = mcKey;
            }

            metaRecordTypeSet.add(componentType);
            metaFullNameSet.add(componentName);
            metadataItem.put('CRC32__c', compareRequest.crcMap.get(metadataItem.Id));

            itemMap.put(key, metadataItem); // map key=>metaItem
        }

        //iterate over all potential candidates for compare
        for (Component__c component : [
            SELECT
                Id,
                CRC32__c,
                Component_Type__c,
                Component_Name__c,
                RecordType.Name,
                Version__c,
                Name,
                Last_Updated_By__c,
                Last_Modified_Date__c,
                Last_Modified_By__c,
                Vlocity_Component_Name__c,
                (SELECT CRC32__c, Version__c FROM Components__r ORDER BY Version__c DESC LIMIT 200)
            FROM Component__c
            WHERE
                ((RecordType.Name = 'Branch'
                AND Branch__c = :branchId)
                OR (RecordType.Name = 'Repository'
                AND Repository__c = :branches[0].Repository__c))
                AND Component_Name__c IN :metaFullNameSet
                AND Component_Type__c IN :metaRecordTypeSet
            WITH SECURITY_ENFORCED
            ORDER BY RecordType.Name DESC
        ]) {
            String key = getKey(component.Component_Type__c, component.Component_Name__c, metadataType == 'Vlocity');

            if (metadataType == MCConstants.TYPE) {
                String type = (String) component.get(Component__c.Component_Type__c.getDescribe().name);
                String apiName = (String) component.get(Component__c.Component_Name__c.getDescribe().name);

                key = type + '#' + apiName;
            }

            if (itemMap.containsKey(key)) {
                // conflict or safe
                SObject meta = itemMap.get(key);

                if (component.RecordType.Name == 'Repository') {
                    for (Component_History__c his : component.Components__r) {
                        if (meta.get('CRC32__c') == his.CRC32__c) {
                            compareResultWrapper.notCommit.add(new NotCommitWrapper(meta.Id, his.Version__c, true));
                            itemMap.remove(key);
                            break;
                        }
                    }
                } else {
                    Boolean found = false;
                    String histId = '';
                    if (component.Components__r != null && component.Components__r.size() > 0) {
                        for (Component_History__c his : component.Components__r) {
                            if (meta.get('CRC32__c') == his.CRC32__c) {
                                compareResultWrapper.notCommit.add(
                                    new NotCommitWrapper(meta.Id, his.Version__c, false)
                                );
                                found = true;
                                break;
                            }
                        }
                        histId = component.Components__r[0].Id;
                    }

                    //if component already exist in Branch with same LastModifiedDate add it to Not Commit Section.
                    if (found) {
                    } else if (
                        metadataType != 'Vlocity' &&
                        meta.get('Last_Updated_By__c') == component.Last_Updated_By__c
                    ) {
                        compareResultWrapper.safeCommit.add(
                            new SafeCommitCompWrapper(component, histId, meta.Id, branches[0].Branch_Name__c)
                        );
                    } else {
                        compareResultWrapper.conflictCommit.add(
                            new ConflictWrapper(component, histId, meta.Id, branches[0].Branch_Name__c)
                        );
                    }
                    itemMap.remove(key);
                }
            }
        }
        // add all the rest as new
        for (SObject meta : itemMap.values()) {
            compareResultWrapper.safeCommit.add(new SafeCommitCompWrapper(meta.Id, branches[0].Branch_Name__c));
        }

        return compareResultWrapper;
    }

    private static List<Schema.DescribeFieldResult> getComparisonQueryFields(String metadataType) {
        if (metadataType == 'Vlocity') {
            return new List<DescribeFieldResult>{
                Metadata_Item_Vlocity__c.Id.getDescribe(),
                Metadata_Item_Vlocity__c.CRC32__c.getDescribe(),
                Metadata_Item_Vlocity__c.API_Name__c.getDescribe(),
                Metadata_Item_Vlocity__c.RecordTypeId.getDescribe(),
                Metadata_Item_Vlocity__c.Last_Updated_By__c.getDescribe(),
                Metadata_Item_Vlocity__c.Component_Name__c.getDescribe()
            };
        }

        return new List<DescribeFieldResult>{
            Metadata_Item__c.Id.getDescribe(),
            Metadata_Item__c.CRC32__c.getDescribe(),
            Metadata_Item__c.API_Name__c.getDescribe(),
            Metadata_Item__c.RecordTypeId.getDescribe(),
            Metadata_Item__c.Last_Updated_By__c.getDescribe(),
            Metadata_Item__c.Component_Type__c.getDescribe(),
            Metadata_Item__c.Name__c.getDescribe(),
            Metadata_Item__c.Veeva_Component_Type__c.getDescribe()
        };
    }

    public static String getKey(String cType, String cName, Boolean isVlocity) {
        if (cName != null && !isVlocity) {
            return cType + '#' + cName.toLowerCase();
        } else {
            return cType + '#' + cName;
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class CompareResultWrapper {
        public List<NotCommitWrapper> notCommit;
        public List<SafeCommitCompWrapper> safeCommit;
        public List<ConflictWrapper> conflictCommit;
        public String msg = ''; // if empty then no errors

        public CompareResultWrapper() {
            notCommit = new List<NotCommitWrapper>();
            safeCommit = new List<SafeCommitCompWrapper>();
            conflictCommit = new List<ConflictWrapper>();
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class NotCommitWrapper {
        public String id { get; set; }
        public Decimal sameToVersion { get; set; }
        public Boolean isFromRepository { get; set; }

        public NotCommitWrapper(String id, Decimal sameToVersion, Boolean isFromRepository) {
            this.id = id;
            this.sameToVersion = sameToVersion;
            this.isFromRepository = isFromRepository;
        }
    }

    @JsonAccess(serializable='always' deserializable='always')
    public class ConflictWrapper {
        public Id id { get; set; }
        public Id compId { get; set; }
        public String lastCompHistoryId { get; set; }
        public Datetime changedOn { get; set; }
        public String changedBy { get; set; }
        public String crc32 { get; set; }
        public String status { get; set; }
        public String branchName { get; set; }

        public ConflictWrapper(Component__c comp, Id srcCompHistoryId, Id metaId, String branchName) {
            this.id = metaId;
            this.compId = comp.Id;
            this.lastCompHistoryId = srcCompHistoryId;
            this.changedOn = comp.Last_Modified_Date__c;
            this.changedBy = comp.Last_Updated_By__c;
            this.crc32 = comp.CRC32__c;
            this.status = 'Conflict';
            this.branchName = branchName;
        }
    }
    @JsonAccess(serializable='always' deserializable='always')
    public class SafeCommitCompWrapper {
        public Id id { get; set; }
        public Id compId { get; set; }
        public String lastCompHistoryId { get; set; }
        public Datetime changedOn { get; set; }
        public String changedBy { get; set; }
        public String crc32 { get; set; }
        public String status { get; set; }
        public String branchName { get; set; }

        public SafeCommitCompWrapper(Component__c comp, Id srcCompHistoryId, Id metaId, String branchName) {
            this.id = metaId;
            this.compId = comp.Id;
            this.lastCompHistoryId = srcCompHistoryId;
            this.changedOn = comp.Last_Modified_Date__c;
            this.changedBy = comp.Last_Updated_By__c;
            this.crc32 = comp.CRC32__c;
            this.status = 'Autoresolved';
            this.branchName = branchName;
        }
        public SafeCommitCompWrapper(Id metaId, String branchName) {
            this.id = metaId;
            this.lastCompHistoryId = '';
            this.status = 'New';
            this.branchName = branchName;
        }
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class CommitWraper {
        public List<String> metaIds;
        public Map<String, CommitFileWraper> dataMap;
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class CommitFileWraper {
        public String data;
        public String crc32;
        public String filename;
    }

    public void goToCommit() {
        FlosumUtils.runMaintenanceScheduler();

        commitSuccess = false;
        MetaJSNToCommit = '';
        msg = '';

        if (snapId != null && selectedRepository != null && selectedRepository != '') {
            try {
                if (MetadataUtils.chekRepositoryPermission(selectedRepository)) {
                    if (commitTo == null || commitTo == '') {
                        if (newBranchName != null && newBranchName != '') {
                            List<Repository__c> repos = [
                                SELECT Id
                                FROM Repository__c
                                WHERE Id = :selectedRepository
                                WITH SECURITY_ENFORCED
                                LIMIT 1
                            ];
                            Branch__c br = new Branch__c();
                            br.Repository__c = selectedRepository;
                            br.Branch_Name__c = newBranchName;
                            DatabaseUtils.insertRecord(
                                br,
                                new List<Schema.DescribeFieldResult>{
                                    Branch__c.Branch_Name__c.getDescribe(),
                                    Branch__c.Repository__c.getDescribe()
                                }
                            );

                            //refreshBranches();
                            commitTo = br.Id;
                            commitToLabel = br.Branch_Name__c;
                        } else {
                            msg = 'Please enter branch name.';
                            return;
                        }
                    }
                    RepoRestrictionController.RestrictionDetails restrictionD = RepoRestrictionController.checkForCommitRestrictions(
                        snapId,
                        commitTo
                    );
                    if (!restrictionD.isSuccess) {
                        throw new FlosumException(restrictionD.errorMessage);
                    }
                    List<Branch__c> branchList = new List<Branch__c>();
                    branchList = [
                        SELECT Id, Branch_Name__c, Repository__c, Repository__r.Name
                        FROM Branch__c
                        WHERE Id = :commitTo
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (branchList.size() == 1) {
                        BranchPermissionController.MoveForwardPermission checkResult = BranchPermissionController.allowUserToMoveForwardFromBranch(
                            commitTo,
                            BranchPermissionController.Commit_To_Branch
                        );
                        if (checkResult.isSuccess) {
                            commitToLabel = branchList[0].Branch_Name__c;
                            commitSuccess = true;
                        } else {
                            msg = checkResult.errorMessage;
                        }
                    } else {
                        msg = 'Branch ' + commitTo + '  not found.';
                    }
                } else {
                    msg = FlosumConstants.COMMIT_PERMISSION_DENIED;
                }
            } catch (Exception exe) {
                msg = exe.getMessage();
            }
        } else {
            if (snapId != null) {
                msg = 'Please create at least one Repository';
                if (metadataType == VeevaConstants.VEEVA_TYPE) {
                    msg += ' with Veeva Vault Type';
                }

                if (metadataType == MCConstants.TYPE) {
                    msg += ' with Marketing Cloud Type';
                }

                if (metadataType == B2CConstants.TYPE) {
                    msg += ' with Commerce Cloud Type';
                }
                if (metadataType == AbstractAuthentication.MULESOFT_ORG_TYPE) {
                    msg += ' with MuleSoft Type';
                }
            } else {
                msg = 'Snapshot not found.';
            }
        }
    }

    public void backToSnap() {
        selectedMetadataType = 'all';
        newBranchName = '';
        GoToCommitType = 'onsnap';
        List<Snapshot__c> snapList = new List<Snapshot__c>();
        snapList = [SELECT Id FROM Snapshot__c WHERE Id = :snapId WITH SECURITY_ENFORCED LIMIT 1];
        if (snapList.size() != 1) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Snapshot not found.'));
        }
    }

    // method for commit from snapshot
    public PageReference snapCommit() {
        commitSuccess = false;
        isError = false;
        MetaJSNToCommit = null;
        msg = ''; // if msg left empty then non errors
        if (snapId != null) {
            List<Branch__c> branchList = new List<Branch__c>();
            branchList = [
                SELECT
                    Id,
                    Branch_Name__c,
                    Repository__c,
                    Repository__r.Name,
                    isConflict__c,
                    Status__c,
                    Last_Updated_On__c
                FROM Branch__c
                WHERE Id = :commitTo
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (branchList.size() == 1) {
                RepoRestrictionController.RestrictionDetails restrictionD = RepoRestrictionController.checkForCommitRestrictions(
                    snapId,
                    commitTo
                );
                if (!restrictionD.isSuccess) {
                    msg = restrictionD.errorMessage;
                    return null;
                }
                if (MetadataUtils.chekRepositoryPermission(branchList[0].Repository__c)) {
                    branchList[0].Last_Updated_On__c = System.now();
                    branchList[0].Status__c = 'In Progress';
                    branchList[0].isConflict__c = false;
                    //branchList[0].Timestamp__c = System.now();
                    DatabaseUtils.updateRecords(
                        branchList,
                        new List<Schema.DescribeFieldResult>{
                            Branch__c.Last_Updated_On__c.getDescribe(),
                            Branch__c.Status__c.getDescribe(),
                            Branch__c.isConflict__c.getDescribe()
                        }
                    );
                    createBuildRecords();
                    commitSuccess = !isError;
                } else {
                    msg = FlosumConstants.COMMIT_PERMISSION_DENIED;
                }
            } else {
                msg = 'select branch to commit.';
            }
        } else {
            msg = 'Snapshot not found.';
        }

        return null;
    }

    public PageReference compareComponent() {
        if (branchComponentId != null && branchComponentId != '' && metadataItemId != null && metadataItemId != '') {
            List<Component_History__c> compList = new List<Component_History__c>();
            compList = [
                SELECT Id
                FROM Component_History__c
                WHERE Component__c = :branchComponentId
                WITH SECURITY_ENFORCED
                ORDER BY Version__c DESC
                LIMIT 1
            ];
            if (compList.size() == 1) {
                PageReference pref = Page.HistoryComparison;
                pref.getParameters().put('branchCompHisId', compList[0].Id);
                pref.getParameters().put('metadataType', metadataType);
                pref.getParameters().put('metaId', metadataItemId);
                pref.getParameters().put('fromMerge', 'fromCommit');
                return pref;
            }
        }
        return null;
    }

    private static void insertAtt(String mergeName, String parentId, Set<String> ids) {
        List<Attachment> att = new List<Attachment>();
        att.add(
            new Attachment(
                Body = Blob.valueOf(JSON.serialize(ids)),
                ParentId = parentId,
                Description = 'MERGEBRANCHSET',
                Name = mergeName,
                ContentType = 'text/plain'
            )
        );
        DatabaseUtils.insertRecords(
            att,
            new List<Schema.DescribeFieldResult>{
                Attachment.Body.getDescribe(),
                Attachment.Name.getDescribe(),
                Attachment.Description.getDescribe(),
                Attachment.ContentType.getDescribe(),
                Attachment.ParentId.getDescribe()
            },
            'SnapshotToBranchCommitController.insertAtt',
            true
        );
    }

    public PageReference showMessage() {
        List<String> messageList = this.message.split('#');
        if (messageList.size() == 2) {
            List<Branch__c> branchList = new List<Branch__c>();
            branchList = [
                SELECT Id, Last_Updated_On__c, Source_Orgs__c
                FROM Branch__c
                WHERE Id = :commitTo
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (branchList.size() == 1) {
                BranchActivityController.createSnapCommitCompLog(idsComponents, commitTo, snapId);
                branchList[0].Status__c = 'Completed';
                branchList[0].Source_Orgs__c = DeploymentDashboardController.fillSourceOrgDetail(
                    branchList[0],
                    null,
                    snapId,
                    'Snapshot'
                );
                DatabaseUtils.updateRecords(
                    branchList,
                    new List<Schema.DescribeFieldResult>{
                        Branch__c.Status__c.getDescribe(),
                        Branch__c.Source_Orgs__c.getDescribe()
                    },
                    'SnapshotToBranchCommitController.showMessage',
                    true
                );
                if (fullPipelineRun == true && pipelineId != null) {
                    PageReference pageRef = new PageReference(Page.RunPipeline.getUrl());
                    pageRef.getParameters().put('id', branchList[0].Id);
                    pageRef.getParameters().put('pipeId', pipelineId);
                    return pageRef;
                } else if (fullPipelineRun == false && pipelineId != null) {
                    insertAtt(mergeSetName, commitTo, idsComponents);
                    PageReference pageRef = new PageReference(Page.RunPipeline.getUrl());
                    pageRef.getParameters().put('id', branchList[0].Id);
                    pageRef.getParameters().put('pipeId', pipelineId);
                    pageRef.getParameters().put('mergeSetName', mergeSetName);
                    return pageRef;
                } else {
                    if (isError) {
                        // error during Apex commit
                        ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.ERROR, msg)
                        );
                        ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Please_refresh_the_page)
                        );
                        return null;
                    }
                    return new PageReference('/' + branchList[0].Id);
                }
            }
        } else {
            // error during JS commit
            List<String> messageListN = !String.isBlank(message)
                ? message.split('\n')
                : new List<String>{ message };

            for (String mes : messageListN) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, mes)
                );
            }
        }
        return null;
    }
    public PageReference analyticsTrack() {
        AnalyticsService.trackDetails(
            new Map<String, String>{
                'eventType' => 'Commit to Branch',
                'branchId' => commitTo
            },
            new Map<String, String>{
                'source' => 'Snapshot',
                'count_components' => String.valueOf(numberOfComponents)
            }
        );
        return null;
    }

    public PageReference back() {
        if (snapId != null) {
            return new PageReference('/' + snapId);
        }
        return null;
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class CommitInfoWraper {
        public List<Attachment> attList;
        public List<MetaItemWraper> metaItemList;
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaItemWraper {
        public Id metId;
        public Id snapId;
        public String API_Name;
        public String File_Name;
        public String MetaType;
        public String crc32;
    }

    @RemoteAction
    public static List<AttachmentWraper> getComponentAttachment(String compHistId) {
        List<AttachmentWraper> wrapList = new List<AttachmentWraper>();
        for (Attachment att : [
            SELECT Id, Body, Description
            FROM Attachment
            WHERE ParentId = :compHistId
            WITH SECURITY_ENFORCED
        ]) {
            AttachmentWraper wrap = new AttachmentWraper();
            wrap.parentId = att.Id;
            wrap.compType = att.Description;
            wrap.base64 = EncodingUtil.base64Encode(att.Body);
            wrapList.add(wrap);
        }
        return wrapList;
    }

    @RemoteAction
    public static List<AttachmentWraper> getAttachments(String JSN) {
        List<AttachmentWraper> wrapList = new List<AttachmentWraper>();
        List<String> parentIdList = new List<String>();
        parentIdList = (List<String>) JSON.deserialize(JSN, List<String>.class);
        for (Attachment att : [
            SELECT Id, Body, Description
            FROM Attachment
            WHERE Id IN :parentIdList
            WITH SECURITY_ENFORCED
        ]) {
            AttachmentWraper wrap = new AttachmentWraper();
            wrap.parentId = att.Id;
            wrap.compType = att.Description;
            wrap.base64 = EncodingUtil.base64Encode(att.Body);
            wrapList.add(wrap);
        }
        return wrapList;
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class AttachmentWraper {
        public String parentId; //a0Iq00000012tdzEAA
        public String compType; //CustomObject
        public String base64;
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaItemWrapper {
        public String id;
        public String compName;
        public String vlocityCompName;
        public List<String> subItemList;
        public String compType;
        public String fileName;
        public String changedBy;
        public Datetime changedOn;

        public MetaItemWrapper(
            String id,
            String compName,
            String compType,
            String fileName,
            String changedBy,
            Datetime changedOn
        ) {
            this.id = id;
            this.compName = compName;
            this.compType = compType;
            this.fileName = fileName;
            this.changedBy = changedBy;
            this.changedOn = changedOn;
        }
    }
}