public with sharing class ComponentBranchDeployController {
    public Boolean isUsedAgent {
        get {
            return isUsedAgent == true;
        }
        set;
    }
    public Boolean isCompileB2CCartridges {
        get {
            return isCompileB2CCartridges == true;
        }
        set;
    }
    public Boolean isUseB2CCertificate {
        get {
            return isUseB2CCertificate == true;
        }
        set;
    }
    public Boolean isLintChecking {
        get {
            return isLintChecking == true;
        }
        set;
    }
    public Boolean isUIValidationSuccess {
        get {
            return isUIValidationSuccess == true;
        }
        set;
    }
    public Boolean isActivateB2CCodeVersion {
        get {
            return isActivateB2CCodeVersion == true;
        }
        set;
    }
    public Boolean isB2CBranch {
        get {
            return metadataType == B2CConstants.TYPE;
        }
        set;
    }
    public String lintLogName {
        get {
            return B2CConstants.DEFAULT_LINT_VALIDATION_LOG_NAME;
        }
        set;
    }
    public Boolean isDisabledB2CNewCodeVersion {
        get {
            return isDisabledB2CNewCodeVersion == true;
        }
        set;
    }
    public String B2CNewCodeVersion {
        get {
            return B2CNewCodeVersion == null ? getNewCodeVersionName() : B2CNewCodeVersion;
        }
        set;
    }
    public Boolean isDisplayB2CPanel {
        get {
            return isDisplayB2CPanel == true;
        }
        set;
    }
    public String selectedB2CFilter { get; set; }
    public List<SelectOption> B2CCartridgeOptions { get; set; }
    public List<SelectOption> B2CCodeVersionOptions { get; set; }
    public String selectedB2CCodeVersion { get; set; }

    public Credentials__c cred { get; set; }
    public List<SelectOption> targetOrgOptions { get; set; }
    public String selectedOrg { get; set; }
    public Boolean isVeevaOrg { get; set; }
    public String B2CCartridgeType { get; set; }
    public Boolean isMCOrg { get; set; }
    public List<SelectOption> runTestOption { get; set; }
    public String selectedRunTest { get; set; }
    public String specifiedTests { get; set; }

    public List<SelectOption> availableMetatypes { get; set; }
    public String selectedMetadataType { get; set; }
    private Set<String> metaTypeFilterSet = new Set<String>{ 'CustomLabels' };

    public String attachmentName { get; set; }
    public String singleAttachmentId { get; set; }
    public String vlocityComponentIdList { get; set; }
    public String veevaComponentIdList { get; set; }
    public String commerceCloudComponentIdList { get; set; }
    public String commerceCloudType { get; set; }
    public String mcComponentIds { get; set; }
    public String mcType { get; set; }

    public Branch__c branch { get; set; }
    public String branchName { get; set; }
    public String branchTests { get; set; }
    public Id branchId { get; set; }

    public String message { get; set; }
    public Boolean authSuccessful { get; set; }
    public Boolean deploySuccessful { get; set; }

    public String logRecordId { get; set; }
    public String targetSession { get; set; }
    public String targetInstance { get; set; }
    public String targetRefresh { get; set; }

    public Integer totalCodeCoverage { get; set; } //code coverage
    public Boolean overrideCodeCoverageEnabled { get; set; }
    public Boolean isQuickDeploy { get; set; }
    public Integer requiredCodeCoverage { get; set; }

    // For Vlocity
    public Boolean isExistVlocityComponents { get; set; }
    public Boolean isLWCActivation { get; set; }
    public Boolean isSeparateMatrixVersions { get; set; }
    public Boolean isSeparateCalculationProcedureVersions { get; set; }
    public Boolean isEnabledApexPostDeploy { get; set; }
    public String apexCode { get; set; }

    public Boolean validProfile { get; set; }
    public Boolean validPermissionSet { get; set; }
    public Boolean isValidate { get; set; }
    public String metadataLogId { get; set; }
    public Boolean isSuccessDeployment { get; set; }
    public String NameSpacePrefix { get; set; }
    public Integer localApiVersion { get; private set; }

    public Boolean isRollbackOnError { get; set; }
    public String deployStartDate { get; set; }
    public String deployCompletedDate { get; set; }
    public String deploymentOption { get; set; }
    public String deploymentName { get; set; }

    public String listMetaComp { get; set; }
    public String listMetaDest { get; set; }
    public String listMetaDestIds { get; set; }
    public String listMetaCompIds { get; set; }

    public String metadataType { get; set; }
    public String disablePermissionSTR { get; set; }
    public Boolean apexPostDeploy { get; set; }
    public Boolean ignoreWarningState { get; set; }

    public Boolean allowApexExecution { get; set; }

    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                List<Organization> orgs = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
                if (orgs.size() == 1) {
                    isSandbox = orgs[0].IsSandbox;
                } else {
                    isSandbox = false;
                }
            }
            return isSandbox;
        }
        private set;
    }

    public ComponentBranchDeployController(ApexPages.StandardController controller) {
        isUsedAgent = String.isNotBlank(B2CService.getAgentUrl());
        isLintChecking = isUsedAgent;
        isCompileB2CCartridges = isUsedAgent;
        commerceCloudType = B2CConstants.TYPE;
        B2CCartridgeType = B2CConstants.CARTRIDGE_TYPE;
        mcType = MCConstants.TYPE;
        ignoreWarningState = MetadataUtils.getIgnoreWarningState();
        getDisablePermissionSetting();
        Credentials__c credsUpdate = Credentials__c.getOrgDefaults();
        if (credsUpdate != null) {
            deploymentOption = credsUpdate.Deployment_Option__c;
        }
        isRollbackOnError = true;
        attachmentName = '';
        deploymentName = '';
        overrideCodeCoverageEnabled = false;
        apexPostDeploy = false;
        localApiVersion = FlosumConstants.apiversion;
        cred = (Credentials__c.getOrgDefaults() != null &&
            Credentials__c.getOrgDefaults().id != null)
            ? Credentials__c.getOrgDefaults()
            : new Credentials__c();
        isLWCActivation = true;
        validProfile = true;
        validPermissionSet = !MetadataUtils.turnOffPermissionSetState();
        NameSpacePrefix = FlosumConstants.getNameSpacePrefix();

        isExistVlocityComponents = false;
        isSuccessDeployment = false;
        authSuccessful = false;
        isValidate = false;
        isQuickDeploy = false;
        requiredCodeCoverage = 0;
        targetOrgOptions = new List<SelectOption>();
        runTestOption = new List<SelectOption>();
        listMetaComp = '';
        listMetaDest = '';
        listMetaDestIds = '';
        listMetaCompIds = '';
        targetOrgOptions.add(new SelectOption('', '-- None --'));

        allowApexExecution = MetadataUtils.doesRunningUserHavePermission(FlosumConstants.APEX_EXECUTION_PERMISSION);

        branch = new Branch__c();
        Branch__c tempBranch = new Branch__c();
        tempBranch = (Branch__c) controller.getRecord();
        List<Branch__c> branchList = new List<Branch__c>();

        branchId = tempBranch.Id;

        if (branchId == null) {
            branchId = ApexPages.currentPage().getParameters().get('state').substringAfter('?').substringAfter('=');
        }

        for (String oneType : FlosumConstants.profilePermissionMap.keySet()) {
            metaTypeFilterSet.add(oneType);
        }

        branchList = [
            SELECT Id, Name, Branch_Name__c, Branch_Type__c, Specified_Tests__c, Repository_Type__c
            FROM Branch__c
            WHERE Id = :branchId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!branchList.isEmpty()) {
            if (ApexPages.currentPage().getParameters().get('validate') == 'true') {
                isValidate = true;
            }
            String typeOfOperation = isValidate == true
                ? BranchPermissionController.Validate
                : BranchPermissionController.Deploy;
            BranchPermissionController.MoveForwardPermission checkResult = BranchPermissionController.allowUserToMoveForwardFromBranch(
                branchId,
                typeOfOperation
            );
            if (checkResult.isSuccess) {
                metadataLogId = ApexPages.currentPage().getParameters().get('meta') != null
                    ? ApexPages.currentPage().getParameters().get('meta')
                    : '';
                if (String.isNotBlank(metadataLogId)) {
                    List<Attachment> attComp = [
                        SELECT Id, Body
                        FROM Attachment
                        WHERE ParentId = :metadataLogId AND Name = 'List Components'
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (attComp.size() > 0) {
                        listMetaComp = attComp[0].Body.toString();
                    } else {
                        listMetaComp = '[]';
                    }
                    List<Attachment> attDest = [
                        SELECT Id, Body
                        FROM Attachment
                        WHERE ParentId = :metadataLogId AND Name = 'List Destructive Changes'
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (attDest.size() > 0) {
                        listMetaDest = attDest[0].Body.toString();
                    } else {
                        listMetaDest = '[]';
                    }

                    List<String> componentIdList = (List<String>) JSON.deserialize(listMetaComp, List<String>.class);
                    isExistVlocityComponents =
                        [
                            SELECT COUNT()
                            FROM Component__c
                            WHERE Vlocity_Component__c = TRUE AND Id IN :componentIdList
                            WITH SECURITY_ENFORCED
                            LIMIT 50000
                        ] > 0;
                } else {
                    isExistVlocityComponents =
                        [
                            SELECT COUNT()
                            FROM Component__c
                            WHERE Vlocity_Component__c = TRUE AND Branch__c = :branchId
                            WITH SECURITY_ENFORCED
                            LIMIT 50000
                        ] > 0;
                }

                if (branchList[0].Specified_Tests__c != null) {
                    branchTests = branchList[0].Specified_Tests__c.replaceAll('(\r\n|\r)', '\n');
                } else {
                    branchTests = '';
                }

                branch = branchList[0];
                branchName = branchList[0].Name;
                metadataType = branchList[0].Repository_Type__c;

                if (isB2CBranch) {
                    isDisplayB2CPanel = ![
                            SELECT Id
                            FROM Component__c
                            WHERE Branch__c = :branchId AND Component_Type__c = :B2CCartridgeType
                            WITH SECURITY_ENFORCED
                            LIMIT 1
                        ]
                        .isEmpty();
                    B2CCartridgeOptions = getB2CCartridgeOptions();
                    B2CCodeVersionOptions = new List<SelectOption>{ new SelectOption('', '-- none --') };
                }

                for (String key : FlosumConstants.runTestParamPatchMap.keySet()) {
                    if (key != FlosumConstants.RUN_INCLUDED_TEST) {
                        runTestOption.add(new SelectOption(key, FlosumConstants.runTestParamPatchMap.get(key)));
                    }
                }

                selectedRunTest = FlosumConstants.Default_TEST;

                selectedMetadataType = 'all';
                availableMetatypes = new List<SelectOption>();
                listMetadataTypes();

                if (!isValidate) {
                    MetadataUtils.MoveForwardPermission MFP = MetadataUtils.allowUserToMoveForwardFromBranch(
                        branchList[0].Id,
                        FlosumConstants.PullRequestAddToDeploymentType
                    );
                    if (!MFP.isSuccess) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MFP.errorMessage));
                        return;
                    }
                }

                List<Organisation__c> organisationList = [
                    SELECT Id, Name
                    FROM Organisation__c
                    WHERE Organisation_Type__c IN :FlosumConstants.getOrgTypes(metadataType)
                    WITH SECURITY_ENFORCED
                    ORDER BY Name
                    LIMIT 999
                ];

                for (Organisation__c org : organisationList) {
                    targetOrgOptions.add(new SelectOption(org.Id, org.Name));
                }
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, checkResult.errorMessage));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Branch not found.'));
        }
    }

    public String getBundleTypesListJSON() {
        return JSON.serialize(FlosumConstants.bundleTypesSet);
    }

    public void getDisablePermissionSetting() {
        disablePermissionSTR = '';
        Set<String> disablePermissionSet = new Set<String>{
            'applicationVisibilities',
            'categoryGroupVisibilities',
            'classAccesses',
            'customMetadataTypeAccesses',
            'customPermissions',
            'customSettingAccesses',
            'externalDataSourceAccesses',
            'fieldPermissions',
            'flowAccesses',
            'layoutAssignments',
            'loginHours',
            'loginIpRanges',
            'objectPermissions',
            'pageAccesses',
            'recordTypeVisibilities',
            'tabSettings',
            'tabVisibilities' /*,
             'userPermissions'*/
        };
        Boolean isTrue = false;
        for (Disable_Permission__mdt dpm : [
            SELECT Id, DeveloperName, Disable_Permission__c
            FROM Disable_Permission__mdt
            WHERE DeveloperName = 'Profile' AND Disable_Permission__c = TRUE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ]) {
            if (dpm.Disable_Permission__c == true) {
                isTrue = true;
            }
        }
        if (isTrue) {
            disablePermissionSTR = JSON.serialize(disablePermissionSet);
        }
    }

    @ReadOnly
    @RemoteAction
    public static ComponentListWrapper getAllData(String branchId, String componentIdListJson) {
        ComponentListWrapper componentListWrapper = new ComponentListWrapper();

        if (String.isBlank(branchId)) {
            return componentListWrapper;
        }

        try {
            List<Component__c> componentList = new List<Component__c>();
            if (String.isNotBlank(componentIdListJson)) {
                List<String> componentIdList = (List<String>) JSON.deserialize(componentIdListJson, List<String>.class);

                componentList = [
                    SELECT
                        Id,
                        Component_Name__c,
                        Component_Type__c,
                        Veeva_Component__c,
                        Last_Modified_Date__c,
                        Last_Updated_By__c,
                        Vlocity_Component__c,
                        Last_Modified_By__c,
                        Committed_On__c
                    FROM Component__c
                    WHERE Id IN :componentIdList
                    WITH SECURITY_ENFORCED
                    LIMIT 50000
                ];
                if (componentIdList.size() > componentList.size()) {
                    componentListWrapper.err = 'MetadataLog contains deleted components. New deployment has to be done from branch';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, componentListWrapper.err));
                }
            } else {
                componentList = [
                    SELECT
                        Id,
                        Component_Name__c,
                        Component_Type__c,
                        Veeva_Component__c,
                        Last_Modified_Date__c,
                        Last_Updated_By__c,
                        Vlocity_Component__c,
                        Last_Modified_By__c,
                        Committed_On__c
                    FROM Component__c
                    WHERE RecordType.Name = 'Branch' AND Branch__c = :branchId
                    WITH SECURITY_ENFORCED
                    LIMIT 50000
                ];
            }

            for (Component__c component : componentList) {
                componentListWrapper.newList.add(new SafeCommitCompWrapper(component));
            }
        } catch (Exception e) {
            componentListWrapper.err = e.getMessage();
        }

        return componentListWrapper;
    }

    @ReadOnly
    @RemoteAction
    public static ComponentListWrapper getDestructiveBranchData(String branchId, String metaDestIds) {
        ComponentListWrapper allLists = new ComponentListWrapper();

        List<Destructive_Changes__c> dList = new List<Destructive_Changes__c>();
        if (metaDestIds != '') {
            List<String> ids = (List<String>) JSON.deserialize(metaDestIds, List<String>.class);

            dList = [
                SELECT Id, Component_Name__c, Component_Type__c, Post_Deployment_Change__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchId AND Id IN :ids
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ];

            if (ids.size() > dList.size()) {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'MetadataLog contains deleted components. New deployment has to be done from branch'
                    )
                );
                allLists.err = 'MetadataLog contains deleted Destructive changes components. New deployment has to be done from branch';
            }
        } else {
            dList = [
                SELECT Id, Component_Name__c, Component_Type__c, Post_Deployment_Change__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchId
                WITH SECURITY_ENFORCED
                LIMIT 50000
            ];
        }

        for (Destructive_Changes__c destComp : dList) {
            allLists.destChangesList.add(new DestructiveChangesWrapper(destComp, false));
        }
        return allLists;
    }

    //list metadatatypes and metadataitems for commit functionality
    public void listMetadataTypes() {
        availableMetatypes.clear();

        if (branchId != null) {
            availableMetatypes.add(new SelectOption('all', 'All'));

            Set<String> typesSet = new Set<String>();

            List<AggregateResult> aggregateResultList = new List<AggregateResult>();
            aggregateResultList.addAll(
                [
                    SELECT Component_Type__c typeName
                    FROM Component__c
                    WHERE Branch__c = :branchId
                    WITH SECURITY_ENFORCED
                    GROUP BY Component_Type__c
                    LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
                ]
            );
            aggregateResultList.addAll(
                [
                    SELECT Component_Type__c typeName
                    FROM Destructive_Changes__c
                    WHERE Branch__c = :branchId
                    WITH SECURITY_ENFORCED
                    GROUP BY Component_Type__c
                    LIMIT :FlosumConstants.COMP_TYPE_SOQL_LIMIT
                ]
            );

            for (AggregateResult ag : aggregateResultList) {
                String recordTypeName = (String) ag.get('typeName');
                if (!metaTypeFilterSet.contains(recordTypeName) && String.isNotBlank(recordTypeName)) {
                    typesSet.add(recordTypeName);
                }
            }
            List<String> typesSetList = new List<String>(typesSet);
            typesSetList.sort();
            for (String type : typesSetList) {
                availableMetatypes.add(new SelectOption(type, type));
            }

            if (availableMetatypes.size() > 0) {
                selectedMetadataType = availableMetatypes[0].getValue();
            }
        }
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class ComponentListWrapper {
        public List<SafeCommitCompWrapper> newList;
        public List<DestructiveChangesWrapper> destChangesList;
        public String wrn = '';
        public String err = '';

        public ComponentListWrapper() {
            newList = new List<SafeCommitCompWrapper>();
            destChangesList = new List<DestructiveChangesWrapper>();
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class SafeCommitCompWrapper {
        public Boolean check { get; set; }
        public Boolean isVlocity { get; set; }
        public Boolean isVeeva { get; set; }
        public Boolean newInRepo { get; set; } // rename to newInBranch
        public Id compId { get; set; }
        public String compName { get; set; }
        public String compType { get; set; }
        public Datetime changedOn { get; set; }
        public String changedBy { get; set; }
        public Datetime committedOn { get; set; }
        public String committedBy { get; set; }

        public SafeCommitCompWrapper(Component__c component) {
            this.check = false;
            this.newInRepo = true;
            this.compId = component.Id;
            this.compName = component.Component_Name__c;
            this.compType = component.Component_Type__c;
            this.changedOn = component.Last_Modified_Date__c;
            this.changedBy = component.Last_Updated_By__c;
            this.committedBy = component.Last_Modified_By__c;
            this.committedOn = component.Committed_On__c;
            this.isVlocity = component.Vlocity_Component__c;
            this.isVeeva = component.Veeva_Component__c;
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class DestructiveChangesWrapper {
        public Id compId { get; set; }
        public String compName { get; set; }
        public String compType { get; set; }
        public Boolean postDeploymentChange { get; set; }
        public Boolean same { get; set; }

        public DestructiveChangesWrapper(Destructive_Changes__c destComp, Boolean same) {
            this.compId = destComp.Id;
            this.compName = destComp.Component_Name__c;
            this.compType = destComp.Component_Type__c;
            this.postDeploymentChange = destComp.Post_Deployment_Change__c;
            this.same = same;
        }
    }
    public void disableCodeCoverageCheck() {
        overrideCodeCoverageEnabled = true;
        checkCodeCoverageChange();
    }
    public void checkCodeCoverageChange() {
        system.debug('Code Coverage change: ' + overrideCodeCoverageEnabled);
        if (overrideCodeCoverageEnabled) {
            isQuickDeploy = false;
            isValidate = false;
        } else {
            isQuickDeploy = true;
            isValidate = true;
        }
    }

    public void setUpAuthentication() {
        authSuccessful = false;
        targetSession = '';
        targetInstance = '';
        targetRefresh = '';
        if (isB2CBranch && !isValidate) {
            B2CCodeVersionOptions = new List<SelectOption>{ new SelectOption('', '-- none --') };
            selectedB2CCodeVersion = '';
        }
        if (selectedOrg != null && selectedOrg != '') {
            String checkRole;
            this.isVeevaOrg = false;
            Boolean isB2COrg = false;
            this.isMCOrg = false;
            if (isValidate) {
                checkRole = FlosumConstants.VALIDATE_ONLY;
            } else {
                checkRole = FlosumConstants.RELEASE_MANAGER;
                List<Organisation__c> organisationList = [
                    SELECT Id, Organisation_Type__c
                    FROM Organisation__c
                    WHERE Id = :selectedOrg
                    WITH SECURITY_ENFORCED
                ];

                if (!organisationList.isEmpty()) {
                    this.isVeevaOrg = organisationList[0].Organisation_Type__c == VeevaConstants.VEEVA_TYPE;
                    isB2COrg = organisationList[0].Organisation_Type__c == B2CConstants.TYPE;
                    this.isMCOrg = organisationList[0].Organisation_Type__c == MCConstants.TYPE;
                }
            }

            VeevaAuthUtils.AuthenticateDetails veevaAuthDetails = null;
            AuthUtils.AuthenticateDetails authDetails = null;
            AuthenticateDetailsWrapper authWrapper = null;

            if (this.isVeevaOrg) {
                veevaAuthDetails = VeevaAuthUtils.authenticateAnOrg(selectedOrg, checkRole);
                authWrapper = new AuthenticateDetailsWrapper(veevaAuthDetails);
            } else if (isB2COrg) {
                CommerceCloudAuthentication authentication = new CommerceCloudAuthentication(selectedOrg);
                authWrapper = new AuthenticateDetailsWrapper(authentication);
                if (authWrapper.isSuccess && !FlosumSecurity.checkDeployPermission(selectedOrg)) {
                    authWrapper.isSuccess = false;
                    authWrapper.errorMessage = FlosumConstants.DEPLOY_PERMISSION_DENIED;
                }
            } else if (this.isMCOrg) {
                MarketingCloudAuthentication authentication = new MarketingCloudAuthentication(Id.valueOf(selectedOrg));
                authWrapper = new AuthenticateDetailsWrapper(authentication);
                if (authWrapper.isSuccess && !FlosumSecurity.checkDeployPermission(selectedOrg)) {
                    authWrapper.isSuccess = false;
                    authWrapper.errorMessage = FlosumConstants.DEPLOY_PERMISSION_DENIED;
                }
            } else {
                authDetails = AuthUtils.authenticateAnOrg(selectedOrg, checkRole);
                authWrapper = new AuthenticateDetailsWrapper(authDetails);
            }

            if (authWrapper.isSuccess) {
                authSuccessful = true;
                targetSession = authWrapper.accessToken;
                targetInstance = authWrapper.instanceUrl;
                targetRefresh = authWrapper.refreshToken;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, authWrapper.infoMessage));

                if (!isValidate || (isQuickDeploy && isValidate)) {
                    List<Deployment_Settings__c> settingsList = [
                        SELECT Id, isEnabled__c, Code_Coverage__c
                        FROM Deployment_Settings__c
                        WHERE Organisation__c = :selectedOrg
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ];
                    if (!settingsList.isEmpty()) {
                        isValidate = settingsList[0].isEnabled__c;
                        isQuickDeploy = settingsList[0].isEnabled__c;
                        requiredCodeCoverage = settingsList[0].isEnabled__c
                            ? MetadataQuickDeployController.getRequiredCodeCoverage(
                                  Integer.valueOf(settingsList[0].Code_Coverage__c),
                                  branchId,
                                  null
                              )
                            : 0;
                    }
                }

                if (authDetails != null && authDetails.details != null && authDetails.needToUpdateDetails) {
                    update authDetails.details;
                }

                if (isB2CBranch && !isValidate) {
                    B2CCodeVersionOptions = getB2CCodeVersionOptions(selectedOrg);
                }

                showNoteMessage();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, authWrapper.errorMessage));
            }
        }
    }

    public void showNoteMessage() {
        if (selectedRunTest == FlosumConstants.NO_TEST_RUN) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.INFO, FlosumConstants.Production_NoTestMessage1)
            );
        }
    }

    public static void deploymentNotify(Id srcBranchId, Id orgId) {
        List<EmailTemplate> emailTemplates = [
            SELECT Id
            FROM EmailTemplate
            WHERE
                DeveloperName = 'PostManualStepsReminder'
                AND Folder.Name = 'Flosum'
                AND NameSpacePrefix = :FlosumConstants.getNameSpacePrefix()
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        List<Related_Manual_Step__c> relatedManualSteps = [
            SELECT Id, Manual_Step__c
            FROM Related_Manual_Step__c
            WHERE Manual_Step__r.Type__c = 'post' AND Branch__c = :srcBranchId
            WITH SECURITY_ENFORCED
            LIMIT 49999
        ];
        if (relatedManualSteps.size() > 0 && emailTemplates.size() > 0) {
            Set<Id> manualStepIds = new Set<Id>();
            for (Related_Manual_Step__c relatedStep : relatedManualSteps) {
                manualStepIds.add(relatedStep.Manual_Step__c);
            }
            if (!manualStepIds.isEmpty()) {
                List<Manual_Step__c> manualSteps = new List<Manual_Step__c>();
                manualSteps = [
                    SELECT Id, Name, Short_Description__c, Completed_Per_Org__c, OwnerId, Owner.Email
                    FROM Manual_Step__c
                    WHERE Id IN :manualStepIds
                    WITH SECURITY_ENFORCED
                ];
                if (manualSteps.size() > 0) {
                    Set<Id> ownerSet = new Set<Id>();
                    Set<String> sendToSet = new Set<String>();
                    for (Manual_Step__c step : manualSteps) {
                        sendToSet.add(step.Owner.Email);
                    }
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setToAddresses(new List<String>(sendToSet));
                    message.setTargetObjectId(manualSteps[0].OwnerId);
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(false);
                    message.setTemplateID(emailTemplates[0].Id);
                    message.setWhatId(srcBranchId);
                    if (FlosumConstants.getOrgWideEmailAddress() != null) {
                        message.setOrgWideEmailAddressId(FlosumConstants.getOrgWideEmailAddress());
                    }
                    try {
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ message });
                    } catch (Exception ex) {
                        System.debug('Error with sending email: ' + ex);
                    }
                }
            }
        }
    }

    public PageReference redirectToLog() {
        List<Metadata_Log__c> logList = new List<Metadata_Log__c>();
        logList = [
            SELECT
                Id,
                Name,
                Status__c,
                Process_Type__c,
                Organisation__c,
                Async_Request_Id__c,
                Process_Log__c,
                Code_Coverage__c,
                Branch__c,
                Job_Completed__c,
                PipelineStepId__c,
                Succeed__c,
                Run_Test_Param__c,
                Attachment_Id__c
            FROM Metadata_Log__c
            WHERE Id = :logRecordId
            WITH SECURITY_ENFORCED
        ];

        if (logList.size() == 1) {
            try {
                if (deployStartDate != null)
                    logList[0].Start_Date__c = Datetime.valueOfGMT(deployStartDate.replace('T', ' '));
                if (deployCompletedDate != null)
                    logList[0].Completed_Date__c = Datetime.valueOfGMT(deployCompletedDate.replace('T', ' '));
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
            logList[0].Job_Completed__c = true;
            logList[0].Succeed__c = isSuccessDeployment;
            logList[0].Status__c = FlosumConstants.STATUS_COMPLETED;
            logList[0].Code_Coverage__c = totalCodeCoverage;

            //run execute anonymous code after deployment.
            if (
                logList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE ||
                logList[0].Process_Type__c == FlosumConstants.PROCESS_DEPLOYMENT
            ) {
                Boolean isDeploy = logList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE ? false : true;
                ApexDeploymentBatchForBranch.runApexPostDeploy(logList[0].Id, isDeploy, isSuccessDeployment);
            }
            if (isValidate && isQuickDeploy) {
                try {
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
                        'Backup QuickDeployForJavascriptDeploy ' + sysTime.getTime(),
                        cronExpression,
                        new MetadataQuickDeployController(
                            logList[0],
                            FlosumConstants.PROCESS_DEPLOYMENT,
                            requiredCodeCoverage
                        )
                    );
                    if (totalCodeCoverage < requiredCodeCoverage) {
                        logList[0].Succeed__c = false;
                    }
                } catch (Exception err) {
                    system.debug('Error in starting QuickDeployment: ' + err.getMessage());
                }
            }

            DatabaseUtils.updateRecords(
                logList,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe(),
                    Metadata_Log__c.Succeed__c.getDescribe(),
                    Metadata_Log__c.Code_Coverage__c.getDescribe()
                },
                'ComponentBranchDeployController.redirectToLog',
                true
            );
            if (logList[0].Organisation__c != null && logList[0].Branch__c != null && !isValidate) {
                //(!isValidate || (isValidate && isQuickDeploy))
                // record banta h isse, org pe dikhta h ye, deployment history ke liye
                Patch_Application__c patchApp = new Patch_Application__c();
                patchApp.Org__c = logList[0].Organisation__c;
                patchApp.Branch__c = logList[0].Branch__c;
                patchApp.User__c = UserInfo.getUserId();
                patchApp.Deployment_URL__c = Url.getSalesforceBaseUrl().toExternalForm() + '/' + logList[0].Id;
                patchApp.Deployment_Log__c = logList[0].Name;

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

            try {
                deploymentNotify(logList[0].Branch__c, logList[0].Organisation__c);
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }

            BranchActivityController.createDeploymentLog(logRecordId);
            if ([SELECT COUNT() FROM User_Story_Rule__mdt WITH SECURITY_ENFORCED LIMIT 1] > 0) {
                System.enqueueJob(new StoriesRelatedToBranchQueueable(logRecordId));
            }
            return new PageReference('/' + logList[0].Id);
        } else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Log record not found.'));
        return null;
    }

    // for validate deployment.
    public void deploymentValidate() {
        try {
            if (
                selectedRunTest == FlosumConstants.RUN_SPECIFIC_TEST &&
                isVeevaOrg &&
                (specifiedTests == null ||
                specifiedTests.trim() == '')
            ) {
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, FlosumConstants.RUN_SPECIFIC_TEST_ERROR)
                );
            } else {
                if (!MetadataUtils.isSafe(branchId)) {
                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'Deployment contains unsafe components. Check security settings on page SecuritySettings'
                        )
                    );
                    return;
                }

                if (isExistDeploymentName(deploymentName) && (deploymentName != null && deploymentName != '')) {
                    ApexPages.addMessage(
                        new ApexPages.Message(ApexPages.Severity.ERROR, 'Deployment already exists with the same name')
                    );
                    return;
                }

                attachmentName = String.valueOf(System.now());

                if (isB2CBranch && isValidate) {
                    // In B2C we do not select the organization
                    deploySuccessful = true;
                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.INFO,
                            'Please do not close this page until the validation is complete.'
                        )
                    );
                    return;
                }

                List<Organisation__c> organisationList = [
                    SELECT Name
                    FROM Organisation__c
                    WHERE Id = :selectedOrg
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (!organisationList.isEmpty()) {
                    attachmentName += ' ' + organisationList[0].Name;
                }
                String testMode = selectedRunTest;
                if (selectedRunTest == FlosumConstants.RUN_BRANCH_SPECIFIC_TEST) {
                    List<Branch__c> branchList = [
                        SELECT Id, Specified_Tests__c
                        FROM Branch__c
                        WHERE Id = :branchId
                        WITH SECURITY_ENFORCED
                    ];

                    if (!branchList.isEmpty()) {
                        if (branchList[0].Specified_Tests__c != null) {
                            specifiedTests = branchList[0].Specified_Tests__c.replaceAll('(\r\n|\r)', '\n');
                        }

                        if (String.isBlank(specifiedTests)) {
                            testMode = FlosumConstants.Default_TEST;
                        } else {
                            testMode = FlosumConstants.RUN_SPECIFIC_TEST;
                        }
                    }
                }

                Deployment_Approval__c deploymentApproval = new Deployment_Approval__c();
                deploymentApproval.Org__c = selectedOrg;
                deploymentApproval.Branch__c = branchId;
                deploymentApproval.Run_Test_Param__c = testMode;
                deploymentApproval.Process_Type__c = isValidate
                    ? isQuickDeploy ? FlosumConstants.PROCESS_DEPLOYMENT : FlosumConstants.PROCESS_VALIDATE
                    : FlosumConstants.PROCESS_DEPLOYMENT;

                if (specifiedTests != null && specifiedTests != '') {
                    deploymentApproval.Specified_Tests__c = specifiedTests;
                }

                deploymentApproval.User__c = UserInfo.getUserId();

                DatabaseUtils.insertRecord(
                    deploymentApproval,
                    new List<Schema.DescribeFieldResult>{
                        Deployment_Approval__c.Org__c.getDescribe(),
                        Deployment_Approval__c.Branch__c.getDescribe(),
                        Deployment_Approval__c.Run_Test_Param__c.getDescribe(),
                        Deployment_Approval__c.Process_Type__c.getDescribe(),
                        Deployment_Approval__c.Specified_Tests__c.getDescribe(),
                        Deployment_Approval__c.User__c.getDescribe()
                    }
                );

                deploySuccessful = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Creating Deployment...'));
            }
        } catch (DmlException exe) {
            deploySuccessful = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exe.getMessage()));
        } catch (Exception exe) {
            deploySuccessful = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exe.getMessage()));
        }
    }

    public Boolean isExistDeploymentName(String depName) {
        List<Metadata_Log__c> mLogLi = [
            SELECT Deployment_Name__c
            FROM Metadata_Log__c
            WHERE Deployment_Name__c = :depName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (mLogLi != null && mLogLi.size() > 0) {
            return true;
        }
        return false;
    }

    // for show message by javascript.
    public void showMessage() {
        List<String> messageList = this.message.split('#');
        if (messageList.size() == 2) {
            if (messageList[1] == 'confirm') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, messageList[0]));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, messageList[0]));
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, messageList[0]));
        }
    }

    public void createLogRecord() {
        logRecordId = null;
        if (branchId != null && (selectedOrg != null && selectedOrg != '' || isB2CBranch && isValidate)) {
            Boolean isContinoue = false;

            if (isValidate) {
                isContinoue = isB2CBranch ? true : FlosumSecurity.checkValidatePermission(selectedOrg);
            } else {
                isContinoue = FlosumSecurity.checkDeployPermission(selectedOrg);
            }

            if (isContinoue) {
                //collect record types
                String objName = Schema.SObjectType.Metadata_Log__c.getName();
                List<RecordType> rtList = new List<RecordType>();
                rtList = [
                    SELECT Id, Name
                    FROM RecordType
                    WHERE SobjectType = :objName AND Name = 'Validate'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                if (rtList.size() == 1) {
                    List<Branch__c> br = [
                        SELECT Id, Specified_Tests__c, Branch_Name__c
                        FROM Branch__c
                        WHERE Id = :branchId
                        WITH SECURITY_ENFORCED
                    ];
                    String testMode = selectedRunTest;
                    if (selectedRunTest == FlosumConstants.RUN_BRANCH_SPECIFIC_TEST) {
                        if (br.size() == 1) {
                            if (br[0].Specified_Tests__c != null) {
                                specifiedTests = br[0].Specified_Tests__c.replaceAll('(\r\n|\r)', '\n');
                            }
                            if (String.isBlank(specifiedTests)) {
                                testMode = FlosumConstants.Default_TEST;
                            } else {
                                testMode = FlosumConstants.RUN_SPECIFIC_TEST;
                            }
                        }
                    }
                    if (deploymentName == null || deploymentName == '') {
                        deploymentName = br[0].Branch_Name__c + ' ' + System.now().format('MM-dd-yyyy HH:mm:ss');
                    }
                    Metadata_Log__c logRecord = new Metadata_Log__c();
                    logRecord.Branch__c = branchId;
                    logRecord.Deployment_Name__c = deploymentName;
                    logRecord.Organisation__c = selectedOrg;
                    logRecord.Status__c = FlosumConstants.STATUS_IN_PROGRESS;
                    logRecord.Run_Test_Param__c = testMode;
                    logRecord.Attachment_Id__c = singleAttachmentId;

                    if (apexPostDeploy && apexCode != null && apexCode.trim() != '') {
                        Map<String, Object> ApexSettingMap = new Map<String, Object>();
                        ApexSettingMap.put('isSpecifyApexClass', false);
                        ApexSettingMap.put('anonymousApexCode', apexCode);
                        ApexSettingMap.put('apexCodeClassName', '');
                        logRecord.Execute_Apex__c = JSON.serialize(ApexSettingMap);
                    }
                    if (isQuickDeploy) {
                        logRecord.Code_Coverage__c = 0;
                    }
                    if (
                        testMode == FlosumConstants.RUN_SPECIFIC_TEST ||
                        testMode == FlosumConstants.RUN_BRANCH_SPECIFIC_TEST
                    ) {
                        logRecord.Process_Log__c = specifiedTests;
                    }
                    if (isValidate) {
                        logRecord.RecordTypeId = rtList[0].Id;
                        logRecord.Process_Type__c = isB2CBranch
                            ? B2CConstants.PROCESS_STRING_MAP.get(B2CConstants.Process.VALIDATE_BRANCH)
                            : FlosumConstants.PROCESS_VALIDATE;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Validating...'));
                    } else {
                        logRecord.Process_Type__c = FlosumConstants.PROCESS_DEPLOYMENT;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying...'));
                    }
                    DatabaseUtils.insertRecord(
                        logRecord,
                        new List<Schema.DescribeFieldResult>{
                            Metadata_Log__c.Branch__c.getDescribe(),
                            Metadata_Log__c.Organisation__c.getDescribe(),
                            Metadata_Log__c.Status__c.getDescribe(),
                            Metadata_Log__c.Run_Test_Param__c.getDescribe(),
                            Metadata_Log__c.Process_Log__c.getDescribe(),
                            Metadata_Log__c.RecordTypeId.getDescribe(),
                            Metadata_Log__c.Execute_Apex__c.getDescribe(),
                            Metadata_Log__c.Process_Type__c.getDescribe()
                        }
                    );
                    logRecordId = logRecord.Id;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Type Not Found.'));
                }
            } else {
                if (isValidate) {
                    logRecordId = FlosumConstants.VALIDATE_PERMISSION_DENIED;
                } else {
                    logRecordId = FlosumConstants.DEPLOY_PERMISSION_DENIED;
                }
            }
        }
    }

    public PageReference saveListComp() {
        if (logRecordId != null && logRecordId != '') {
            List<Deployment_Result__c> dList = new List<Deployment_Result__c>();
            List<Deployment_Result__c> metaCompList = new List<Deployment_Result__c>();
            if (listMetaDestIds != '') {
                List<String> ids = (List<String>) JSON.deserialize(listMetaDestIds, List<String>.class);
                for (Destructive_Changes__c des : [
                    SELECT Id, Component_Name__c, Component_Type__c, Post_Deployment_Change__c
                    FROM Destructive_Changes__c
                    WHERE Branch__c = :branchId AND Id IN :ids
                    WITH SECURITY_ENFORCED
                    LIMIT 10000
                ]) {
                    Deployment_Result__c newDest = new Deployment_Result__c(
                        Metadata_Log__c = logRecordId,
                        Component_Name__c = des.Component_Name__c,
                        Component_Type__c = des.Component_Type__c,
                        Type__c = 'Destructive Changes',
                        Org__c = selectedOrg,
                        Post_Deployment_Change__c = des.Post_Deployment_Change__c
                    );
                    dList.add(newDest);
                }
            }
            if (listMetaCompIds != '') {
                List<String> ids = (List<String>) JSON.deserialize(listMetaCompIds, List<String>.class);
                for (Component__c comp : [
                    SELECT Id, Component_Name__c, Component_Type__c, Last_Updated_By__c, Last_Modified_Date__c
                    FROM Component__c
                    WHERE Id IN :ids
                    WITH SECURITY_ENFORCED
                    LIMIT 10000
                ]) {
                    Deployment_Result__c metaComp = new Deployment_Result__c(
                        Component_Name__c = comp.Component_Name__c,
                        Component_Type__c = comp.Component_Type__c,
                        Last_Updated_By__c = comp.Last_Updated_By__c,
                        Last_Modified_Date__c = comp.Last_Modified_Date__c,
                        Metadata_Log__c = logRecordId,
                        Org__c = selectedOrg,
                        Type__c = 'Component'
                    );
                    metaCompList.add(metaComp);
                }
            }
            if (dList.size() > 0) {
                DatabaseUtils.insertRecords(
                    dList,
                    new List<Schema.DescribeFieldResult>{
                        Deployment_Result__c.Component_Name__c.getDescribe(),
                        Deployment_Result__c.Component_Type__c.getDescribe(),
                        Deployment_Result__c.Post_Deployment_Change__c.getDescribe(),
                        Deployment_Result__c.Type__c.getDescribe(),
                        Deployment_Result__c.Metadata_Log__c.getDescribe()
                    }
                );
            }
            if (metaCompList.size() > 0) {
                DatabaseUtils.insertRecords(
                    metaCompList,
                    new List<Schema.DescribeFieldResult>{
                        Deployment_Result__c.Component_Name__c.getDescribe(),
                        Deployment_Result__c.Component_Type__c.getDescribe(),
                        Deployment_Result__c.Last_Updated_By__c.getDescribe(),
                        Deployment_Result__c.Last_Modified_Date__c.getDescribe(),
                        Deployment_Result__c.Metadata_Log__c.getDescribe(),
                        Deployment_Result__c.Type__c.getDescribe()
                    }
                );
            }
        }
        return null;
    }

    public PageReference apexDeployment() {
        if (
            String.isNotBlank(branchId) &&
            String.isNotBlank(selectedOrg) &&
            String.isNotBlank(logRecordId) &&
            String.isNotBlank(singleAttachmentId)
        ) {
            List<Id> parameterIdLi = new List<Id>();
            parameterIdLi.add(branchId);
            parameterIdLi.add(selectedOrg);
            parameterIdLi.add(logRecordId);
            parameterIdLi.add(singleAttachmentId);

            VlocityDeployWrapper vlocityWrapper = new VlocityDeployWrapper();
            vlocityWrapper.metadataLogName = deploymentName;
            vlocityWrapper.branchId = branchId;
            vlocityWrapper.orgId = selectedOrg;
            vlocityWrapper.isLWCActivation = isLWCActivation;
            vlocityWrapper.isSeparateMatrixVersions = isSeparateMatrixVersions;
            vlocityWrapper.vlocityComponentIdListJSON = vlocityComponentIdList;
            vlocityWrapper.isSeparateCalculationProcedureVersions = isSeparateCalculationProcedureVersions;
            vlocityWrapper.isEnabledApexPostDeploy = isEnabledApexPostDeploy;
            vlocityWrapper.apexCode = apexCode;

            FlosumUtils.runMaintenanceScheduler();
            AnalyticsService.runAnalyticsScheduler();
            Database.executeBatch(
                new ApexDeploymentBatchForBranch(parameterIdLi, JSON.serialize(vlocityWrapper), isRollbackOnError),
                1
            );
            return new PageReference('/' + logRecordId);
        }
        return null;
    }

    public PageReference vlocityDeployment() {
        if (branchId != null && String.isNotBlank(selectedOrg) && String.isNotBlank(vlocityComponentIdList)) {
            List<String> vlocityComponentIds = (List<String>) JSON.deserialize(
                vlocityComponentIdList,
                List<String>.class
            );

            if (vlocityComponentIds != null && !vlocityComponentIds.isEmpty()) {
                VlocityService.deployFromBranch(
                    selectedOrg,
                    branchId,
                    deploymentName,
                    vlocityComponentIds,
                    isSeparateMatrixVersions,
                    isSeparateCalculationProcedureVersions,
                    isEnabledApexPostDeploy,
                    isLWCActivation,
                    apexCode
                );
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying Vlocity...'));
            } else {
                System.debug('Vlocity empty list ids');
            }
        }
        return null;
    }
    public PageReference OnlyVlocityDeployment() {
        if (branchId != null && String.isNotBlank(selectedOrg) && String.isNotBlank(vlocityComponentIdList)) {
            List<String> vlocityComponentIds = (List<String>) JSON.deserialize(
                vlocityComponentIdList,
                List<String>.class
            );

            if (vlocityComponentIds != null && !vlocityComponentIds.isEmpty()) {
                String metadataLogId = VlocityService.deployFromBranch(
                    selectedOrg,
                    branchId,
                    deploymentName,
                    vlocityComponentIds,
                    isSeparateMatrixVersions,
                    isSeparateCalculationProcedureVersions,
                    isEnabledApexPostDeploy,
                    isLWCActivation,
                    apexCode
                );
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying Vlocity...'));
                if (String.isNotBlank(metadataLogId)) {
                    return new PageReference('/' + metadataLogId);
                }
                return null;
            } else {
                System.debug('Vlocity empty list ids');
            }
        }
        return null;
    }

    public PageReference veevaDeploy() {
        if (
            branchId != null &&
            String.isNotBlank(selectedOrg) &&
            isVeevaOrg &&
            String.isNotBlank(veevaComponentIdList)
        ) {
            List<String> veevaComponentIds = (List<String>) JSON.deserialize(veevaComponentIdList, List<String>.class);

            if (veevaComponentIds != null && !veevaComponentIds.isEmpty()) {
                String metadataLogId = VeevaService.deployFromBranch(
                    selectedOrg,
                    branchId,
                    deploymentName,
                    veevaComponentIds
                );
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying Veeva...'));
                if (String.isNotBlank(metadataLogId)) {
                    return new PageReference('/' + metadataLogId);
                }
                return null;
            } else {
                System.debug('Veeva empty list ids');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Veeva empty list ids'));
            }
        }
        return null;
    }

    // ---------------- B2C Validation ----------------

    @TestVisible
    private static Map<String, String> getB2CValidationSchemas(String staticFileName) {
        Map<String, String> filesMap = new Map<String, String>();

        List<StaticResource> staticZipFiles = [
            SELECT Name, Body, SystemModstamp
            FROM StaticResource
            WHERE Name = :staticFileName
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (Test.isRunningTest()) {
            Zippex zipFile = new Zippex();
            zipFile.addFile('test1.xsd', Blob.valueOf('<test></test>'), null);
            zipFile.addFile('folder/inventory.xsd', Blob.valueOf('<test></test>'), null);
            staticZipFiles.clear();
            staticZipFiles.add(new StaticResource(Name = 'test', Body = zipFile.getZipArchive()));
        }

        if (!staticZipFiles.isEmpty()) {
            Zippex zipFile = new Zippex(staticZipFiles[0].Body);

            String nameSpacePrefix = FlosumConstants.getNameSpacePrefixForPage();

            for (String fileUrl : zipFile.getFileNames()) {
                List<String> fileUrlParts = fileUrl.split('/');
                if (fileUrlParts.size() < 2) {
                    continue;
                }

                String fileName = fileUrlParts.get(fileUrlParts.size() - 1)?.replace('.xsd', '.xml');
                String localFileUrl =
                    '/resource/' +
                    String.valueOf(((Datetime) staticZipFiles[0].get('SystemModstamp'))?.getTime()) +
                    '/' +
                    nameSpacePrefix +
                    staticZipFiles[0].get('Name') +
                    '/' +
                    fileUrl;

                filesMap.put(fileName, localFileUrl);
            }
        }

        return filesMap;
    }

    @RemoteAction
    public static List<Map<String, String>> getB2CBranchComponents(List<Id> componentIds) {
        Map<String, String> allXsdSchemas = getB2CValidationSchemas(B2CConstants.VALIDATOR_STATIC_FILE_NAME);
        List<Map<String, String>> branchComponents = new List<Map<String, String>>();

        for (Component_History__c componentHistory : [
            SELECT
                Component__c,
                Component__r.File_Name__c,
                Component__r.Component_Name__c,
                Component__r.Component_Type__c
            FROM Component_History__c
            WHERE Component__c IN :componentIds AND isLastVersion__c = TRUE
            WITH SECURITY_ENFORCED
        ]) {
            List<String> fileNameParts = componentHistory.Component__r.File_Name__c.split('/');
            String fileName = fileNameParts.get(fileNameParts.size() - 1);
            String schemaName = fileName;

            if (fileNameParts.contains('custom-objects')) {
                schemaName = 'custom-objects.xml';
            } else if (fileNameParts.contains('inventory-lists')) {
                schemaName = 'inventory.xml';
            } else if (fileNameParts.contains('pricebooks')) {
                schemaName = 'pricebooks.xml';
            } else if (fileNameParts.contains('geolocations')) {
                schemaName = 'geolocations.xml';
            } else if (fileNameParts.contains('meta')) {
                schemaName = 'metadata.xml';
            } else if (fileNameParts.contains('customer-lists')) {
                schemaName = 'customer-lists2.xml';
            }
            branchComponents.add(
                new Map<String, String>{
                    'componentId' => componentHistory.Component__c,
                    'componentName' => componentHistory.Component__r.Component_Name__c,
                    'componentType' => componentHistory.Component__r.Component_Type__c,
                    'componentHistoryId' => componentHistory.Id,
                    'fileName' => fileName,
                    'XSDSchemaUrl' => allXsdSchemas.get(schemaName)
                }
            );
        }

        return branchComponents;
    }

    @RemoteAction
    public static Map<String, Object> getB2CComponentData(List<Map<String, String>> components) {
        Map<String, String> component = components.remove(0);
        String componentHistoryId = component.get('componentHistoryId');
        String XSDSchemaUrl = component.get('XSDSchemaUrl');

        String base64SchemaBody;
        try {
            base64SchemaBody = EncodingUtil.base64Encode(new PageReference(XSDSchemaUrl)?.getContent());
        } catch (Exception e) {
        }

        Blob blobData = [
            SELECT Body
            FROM Attachment
            WHERE ParentId = :componentHistoryId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ]
        ?.Body;

        return new Map<String, Object>{
            'component' => component,
            'base64FileContent' => EncodingUtil.base64Encode(blobData),
            'base64SchemaContent' => base64SchemaBody,
            'components' => components
        };
    }

    public PageReference finishB2CValidation() {
        if (isLintChecking) {
            return new PageReference('/' + logRecordId);
        }

        List<Metadata_Log__c> metadataLogs = [
            SELECT Job_Completed__c, Succeed__c, Status__c
            FROM Metadata_Log__c
            WHERE Id = :logRecordId
            WITH SECURITY_ENFORCED
        ];

        if (metadataLogs.size() == 1) {
            metadataLogs[0].Job_Completed__c = true;
            metadataLogs[0].Succeed__c = isSuccessDeployment;
            metadataLogs[0].Status__c = FlosumConstants.STATUS_COMPLETED;
            DatabaseUtils.updateRecords(
                metadataLogs,
                new List<Schema.DescribeFieldResult>{
                    Metadata_Log__c.Job_Completed__c.getDescribe(),
                    Metadata_Log__c.Status__c.getDescribe(),
                    Metadata_Log__c.Succeed__c.getDescribe()
                }
            );
            BranchActivityController.createDeploymentLog(logRecordId);

            return new PageReference('/' + logRecordId);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Log record not found.'));
            return null;
        }
    }

    // END B2C Validation ----------------

    private String getNewCodeVersionName() {
        return B2CController.getNewCodeVersionName();
    }

    public void disableB2CNewCodeVersion() {
        isDisabledB2CNewCodeVersion = String.isNotBlank(selectedB2CCodeVersion);
        B2CNewCodeVersion = !isDisabledB2CNewCodeVersion ? null : '';
    }

    @TestVisible
    private List<SelectOption> getB2CCodeVersionOptions(Id orgId) {
        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '-- none --') };

        if (orgId != null) {
            B2CApiService B2CApi = new B2CApiService();
            B2CApi.auth(orgId);

            Map<String, Object> codeVersions = B2CApi.getCodeVersions();
            List<Object> dataList = (List<Object>) codeVersions.get('data');
            Map<String, String> labelToValueMap = new Map<String, String>();

            for (Object data : dataList) {
                Map<String, Object> dataMap = (Map<String, Object>) data;
                String label = String.valueOf(dataMap.get('id'));
                String value = label;
                if (Boolean.valueOf(dataMap.get('active'))) {
                    label += ' (Active)';
                }
                labelToValueMap.put(label, value);
            }

            List<String> labels = new List<String>(labelToValueMap.keySet());
            labels.sort();

            for (String label : labels) {
                options.add(new SelectOption(labelToValueMap.get(label), label));
            }
        }

        return options;
    }

    public List<SelectOption> getB2CCartridgeOptions() {
        List<SelectOption> options = new List<SelectOption>{ new SelectOption('', '-- none --') };
        List<String> folders = new List<String>();

        for (Component__c component : [
            SELECT Component_Name__c, Component_Type__c
            FROM Component__c
            WHERE RecordType.Name = 'Branch' AND Branch__c = :branchId
            WITH SECURITY_ENFORCED
            LIMIT 50000
        ]) {
            if (component.Component_Type__c == B2CCartridgeType) {
                List<String> path = component.Component_Name__c?.split('/');
                if (!path.isEmpty()) {
                    String folderName = path[0];
                    if (!folders.contains(folderName)) {
                        folders.add(folderName);
                    }
                }
            }
        }

        folders.sort();

        for (String folder : folders) {
            options.add(new SelectOption(folder, folder));
        }

        return options;
    }

    public Boolean isSelectedB2CCartridge(List<Id> componentIds) {
        return ![
                SELECT Id
                FROM Component__c
                WHERE Branch__c = :branchId AND Id IN :componentIds AND Component_Type__c = :B2CConstants.CARTRIDGE_TYPE
                WITH SECURITY_ENFORCED
                LIMIT 1
            ]
            .isEmpty();
    }

    public PageReference commerceCloudDeploy() {
        if (
            branchId != null &&
            String.isNotBlank(selectedOrg) &&
            isB2CBranch &&
            String.isNotBlank(commerceCloudComponentIdList)
        ) {
            List<String> selectedComponentIds = (List<String>) JSON.deserialize(
                commerceCloudComponentIdList,
                List<String>.class
            );
            if (selectedComponentIds != null && !selectedComponentIds.isEmpty()) {
                if (
                    isSelectedB2CCartridge(selectedComponentIds) &&
                    String.isBlank(B2CNewCodeVersion) &&
                    String.isBlank(selectedB2CCodeVersion)
                ) {
                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'An existing code version or a new one should be specified.'
                        )
                    );
                    return null;
                }

                Id metadataLogId;

                if (!Test.isRunningTest()) {
                    String codeVersion = String.isNotBlank(B2CNewCodeVersion)
                        ? B2CNewCodeVersion
                        : String.isNotBlank(selectedB2CCodeVersion) ? selectedB2CCodeVersion : '';

                    metadataLogId = B2CController.deployBranch(
                        selectedOrg,
                        branchId,
                        deploymentName,
                        selectedComponentIds,
                        codeVersion,
                        isUseB2CCertificate,
                        isCompileB2CCartridges,
                        isActivateB2CCodeVersion,
                        isUsedAgent
                    );
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying Commerce Cloud...'));
                if (String.isNotBlank(metadataLogId)) {
                    return new PageReference('/' + metadataLogId);
                }
                return null;
            } else {
                System.debug('Commerce Cloud empty list ids');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Commerce Cloud empty list ids'));
            }
        }
        ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, 'Unknown error during Commerce Cloud Deploy')
        );
        return null;
    }

    public void B2CLintValidate() {
        if (
            branchId != null &&
            metadataLogId != null &&
            isB2CBranch &&
            isLintChecking &&
            String.isNotBlank(commerceCloudComponentIdList)
        ) {
            List<String> selectedCartridgeFilesIds = (List<String>) JSON.deserialize(
                commerceCloudComponentIdList,
                List<String>.class
            );
            if (selectedCartridgeFilesIds != null && !selectedCartridgeFilesIds.isEmpty()) {
                if (!Test.isRunningTest()) {
                    B2CController.agentLintValidation(
                        metadataLogId,
                        branchId,
                        selectedCartridgeFilesIds,
                        isUIValidationSuccess
                    );
                }
            }
        }
    }

    public PageReference mcDeploy() {
        if (String.isBlank(this.branchId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Branch id is empty.'));
            return null;
        }

        if (String.isBlank(this.selectedOrg)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Target org is empty.'));
            return null;
        }

        if (!this.isMCOrg) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Marketing Cloud deploy should be run from Marketing cloud branch.'
                )
            );
            return null;
        }

        if (String.isBlank(this.mcComponentIds)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Component list is empty.'));
            return null;
        }

        List<Id> mcComponentIds = (List<Id>) JSON.deserialize(this.mcComponentIds, List<String>.class);

        if (mcComponentIds == null || mcComponentIds.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Component list is empty.'));
            return null;
        }

        System.debug('--- deploy mc ' + mcComponentIds.size());

        Id metadataLogId = MCDeployBatch.launch(this.selectedOrg, this.branchId, deploymentName, mcComponentIds);

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Deploying Marketing Cloud...'));

        return new PageReference('/' + metadataLogId);
    }

    @RemoteAction
    public static List<String> getOrgDetails(String targetOrgId) {
        List<String> infoLi = new List<String>();
        AuthUtils.AuthenticateDetails authDetails = AuthUtils.authenticateAnOrg(
            targetOrgId,
            FlosumConstants.RELEASE_MANAGER
        );
        if (authDetails != null && authDetails.details != null && authDetails.isSuccess || Test.isRunningTest()) {
            infoLi.add(authDetails.details.AccessToken__c);
            infoLi.add(authDetails.details.RefreshToken__c);
            infoLi.add(authDetails.details.InstanceURL__c);
            if (authDetails.needToUpdateDetails)
                update authDetails.details;
        }
        return infoLi;
    }

    @RemoteAction
    public static MetaBranchDetailWraper getBranchData(
        String branchId,
        List<String> ids,
        List<String> destIds,
        String orgId,
        Boolean isQuickDeploy
    ) {
        Map<String, Set<String>> preMap = new Map<String, Set<String>>();
        Map<String, Set<String>> postMap = new Map<String, Set<String>>();
        List<MetaTypeWraper> metaTypeWraperList = new List<MetaTypeWraper>();
        Map<String, List<MetaItemWraper>> typeItemsMap = new Map<String, List<MetaItemWraper>>();
        Set<Id> compHistId = new Set<Id>();
        Boolean isApexComponentInDeploy;

        List<Branch__c> branchList = new List<Branch__c>();
        branchList = [SELECT Id FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];
        if (branchList.size() == 1) {
            for (Component__c comp : [
                SELECT Id, (SELECT Id, Version__c FROM Components__r ORDER BY Version__c DESC LIMIT 1)
                FROM Component__c
                WHERE Branch__c = :branchId AND Id IN :ids
                WITH SECURITY_ENFORCED
            ]) {
                for (Component_History__c comHist : comp.Components__r) {
                    compHistId.add(comHist.Id);
                }
            }

            // Their is a validation which checks AttachmentId and its parentId and so we need both
            for (Component_History__c compHist : [
                SELECT
                    Id,
                    Component__r.File_Name__c,
                    Component__r.Component_Name__c,
                    Component__r.Component_Type__c,
                    (SELECT Id FROM Attachments ORDER BY LastModifiedDate DESC LIMIT 1)
                FROM Component_History__c
                WHERE Id IN :compHistId
                WITH SECURITY_ENFORCED
            ]) {
                if (
                    compHist.Component__r.Component_Type__c == 'ApexClass' ||
                    compHist.Component__r.Component_Type__c == 'ApexTrigger'
                ) {
                    isApexComponentInDeploy = true;
                }
                String metaType = compHist.Component__r.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(metaType)) {
                    metaType = FlosumConstants.metadataFolderMap.get(metaType);
                }

                List<MetaItemWraper> itemList = new List<MetaItemWraper>();
                if (typeItemsMap.containsKey(metaType)) {
                    itemList = typeItemsMap.get(metaType);
                }
                //Here-------------------------------- Zip_Parent_ID__c --> send ComponentHistory Id in this
                if (compHist.Attachments.size() != 1) {
                    String error =
                        'Component ' +
                        compHist.Component__r.Component_Name__c +
                        ' has an error. Please delete this component from branch, take a new snapshot from source org and try to add to branch again. # Error';
                    //showMessage();
                    return new MetaBranchDetailWraper(null, null, error);
                } else {
                    itemList.add(
                        new MetaItemWraper(
                            compHist.Component__r.Component_Name__c,
                            compHist.Component__r.File_Name__c,
                            compHist.Id,
                            new Set<Id>{ compHist.Attachments[0].id }
                        )
                    );
                    typeItemsMap.put(metaType, itemList);
                }
            }
            //For Destructive changes.
            for (Destructive_Changes__c dm : [
                SELECT Id, Post_Deployment_Change__c, Component_Type__c, Component_Name__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchList[0].Id AND Id IN :destIds
                WITH SECURITY_ENFORCED
            ]) {
                if (dm.Component_Type__c == 'ApexClass' || dm.Component_Type__c == 'ApexTrigger') {
                    isApexComponentInDeploy = true;
                }
                String metaType = dm.Component_Type__c;
                if (FlosumConstants.metadataFolderMap.containsKey(metaType)) {
                    if (metaType == 'EmailTemplateFolder' && dm.Component_Name__c != null) {
                        dm.Component_Name__c =
                            dm.Component_Name__c.substring(
                                dm.Component_Name__c.lastIndexOf('/') + 1,
                                dm.Component_Name__c.length()
                            ) + '/';
                    } else if (dm.Component_Name__c != null && dm.Component_Name__c.lastIndexOf('/') > -1) {
                        dm.Component_Name__c = dm.Component_Name__c.substring(
                            dm.Component_Name__c.lastIndexOf('/') + 1,
                            dm.Component_Name__c.length()
                        );
                    }
                    metaType = FlosumConstants.metadataFolderMap.get(metaType);
                }

                Set<String> itemNames = new Set<String>();
                if (dm.Post_Deployment_Change__c) {
                    if (postMap.containsKey(metaType))
                        itemNames = postMap.get(metaType);
                    itemNames.add(dm.Component_Name__c);
                    postMap.put(metaType, itemNames);
                } else {
                    if (preMap.containsKey(metaType))
                        itemNames = preMap.get(metaType);
                    itemNames.add(dm.Component_Name__c);
                    preMap.put(metaType, itemNames);
                }
            }

            for (String key : FlosumConstants.sortedList) {
                if (typeItemsMap.containsKey(key)) {
                    metaTypeWraperList.add(new MetaTypeWraper(key, typeItemsMap.get(key)));
                    typeItemsMap.remove(key);
                }
            }
            for (String compType : typeItemsMap.keySet()) {
                metaTypeWraperList.add(new MetaTypeWraper(compType, typeItemsMap.get(compType)));
            }
        }

        // For Environment variables

        MetaBranchDetailWraper wrap = new MetaBranchDetailWraper(
            metaTypeWraperList,
            new DestructiveWraper(preMap, postMap),
            null
        );

        Map<String, Map<String, String>> env = new Map<String, Map<String, String>>();

        for (Env_var__c var : [
            SELECT Variable__c, Org__c, ReplacementString__c
            FROM Env_var__c
            WHERE Org__c = :orgId
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
        wrap.isApexComponentInDeploy = isApexComponentInDeploy;
        wrap.isQuickDeploy = isQuickDeploy;
        return wrap;
    }

    @RemoteAction
    public static List<Attachment> getAttachmentsDetail(String JSN) {
        Map<String, String> attachmentMap = new Map<String, String>();
        attachmentMap = (Map<String, String>) JSON.deserialize(JSN, Map<String, String>.class);
        List<Attachment> attList = new List<Attachment>();
        attList = [
            SELECT Id, BodyLength, Description
            FROM Attachment
            WHERE Id IN :attachmentMap.keySet()
            WITH SECURITY_ENFORCED
        ];
        return attList;
    }

    @RemoteAction
    public static List<AttachmentWraper> getAttachments(String JSN, String branchId) {
        List<String> attIdList = new List<String>();
        attIdList = (List<String>) JSON.deserialize(JSN, List<String>.class);
        List<AttachmentWraper> attList = new List<AttachmentWraper>();
        List<Branch__c> branchList = new List<Branch__c>();
        branchList = [SELECT Id FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];
        if (branchList.size() == 1) {
            for (Attachment att : [
                SELECT Id, Body, Description, ParentId
                FROM Attachment
                WHERE Id IN :attIdList
                WITH SECURITY_ENFORCED
            ]) {
                AttachmentWraper wrap = new AttachmentWraper();
                wrap.parentId = att.ParentId;
                if (FlosumConstants.metadataFolderMap.containsKey(att.Description))
                    wrap.compType = FlosumConstants.metadataFolderMap.get(att.Description);
                else
                    wrap.compType = att.Description;
                wrap.base64 = EncodingUtil.base64Encode(att.Body);
                attList.add(wrap);
            }
        }
        return attList;
    }

    // commented for once
    @RemoteAction
    public static Map<String, Set<String>> collectBackupInfo(String branchId, List<String> ids, List<String> destIds) {
        Map<String, Set<String>> retrieveMap = new Map<String, Set<String>>();
        List<Branch__c> branchList = new List<Branch__c>();
        branchList = [SELECT Id FROM Branch__c WHERE Id = :branchId WITH SECURITY_ENFORCED LIMIT 1];
        if (branchList.size() == 1) {
            for (Destructive_Changes__c dm : [
                SELECT Id, Component_Type__c, Component_Name__c
                FROM Destructive_Changes__c
                WHERE Branch__c = :branchList[0].Id AND Id IN :destIds
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
            for (Component__c repo : [
                SELECT Id, File_Name__c, Component_Name__c, Component_Type__c
                FROM Component__c
                WHERE Branch__c = :branchList[0].Id AND Id IN :ids
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

    // if possible to send id of Component history  here then try that else how to find component History Id which is required in query.
    @RemoteAction
    public static List<AttachmentWraper> getApexClassesContent(String branchId, List<String> ids) {
        Set<String> attachmentSet = new Set<String>();
        Set<Id> compHistId = new Set<Id>();
        for (Component__c comp : [
            SELECT Id, (SELECT Id, version__c FROM Components__r ORDER BY version__c DESC LIMIT 1)
            FROM Component__c
            WHERE Branch__c = :branchId AND Component_Type__c = 'ApexClass' AND Id IN :ids
            WITH SECURITY_ENFORCED
        ]) {
            for (Component_History__c comHist : comp.Components__r) {
                compHistId.add(comHist.Id);
            }
        }

        for (Component_History__c compHist : [
            SELECT Id, (SELECT Id FROM Attachments ORDER BY lastModifiedDate DESC LIMIT 1)
            FROM Component_history__c
            WHERE Id IN :compHistId
            WITH SECURITY_ENFORCED
        ]) {
            attachmentSet.add(compHist.Attachments[0].Id);
        }

        List<AttachmentWraper> attList = new List<AttachmentWraper>();

        for (Attachment att : [
            SELECT Id, Body, Description, ParentId
            FROM Attachment
            WHERE Id IN :attachmentSet
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

    @RemoteAction
    public static String insertDeploymentResults(String jsnStr, String deployBranchId) {
        MetadataUtils.processDeploymentResultsJS(jsnStr, deployBranchId);
        return 'done';
    }

    @RemoteAction
    public static String getDeploymentIdInCaseOfNullResponse(String deploymentLogId, Boolean checkOnly) {
        List<Metadata_Log__c> logList = [
            SELECT
                Id,
                CreatedDate,
                Status__c,
                Organisation__c,
                Async_Request_Id__c,
                Branch__c,
                Job_Completed__c,
                Succeed__c
            FROM Metadata_Log__c
            WHERE Id = :deploymentLogId AND Organisation__c != NULL
            WITH SECURITY_ENFORCED
        ];
        if (!logList.isEmpty()) {
            AuthUtils.AuthenticateDetails authDetails = AuthUtils.authenticateAnOrg(logList[0].Organisation__c);
            if (authDetails.isSuccess) {
                String finalAsyncId;
                String query =
                    'SELECT Id, Status, CreatedBy.Username,CreatedById,CreatedDate FROM DeployRequest WHERE CreatedBy.Username=\'' +
                    authDetails.details.AuthorisedUser__c +
                    '\' AND Type=\'Api\' AND CheckOnly=' +
                    checkOnly +
                    ' ORDER BY CreatedDate DESC LIMIT 20';
                String endpoint =
                    authDetails.details.InstanceURL__c +
                    '/services/data/v56.0/tooling' +
                    '/query/?q=' +
                    EncodingUtil.urlEncode(query, 'UTF-8');
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + authDetails.details.AccessToken__c);
                req.setHeader('Content-Type', 'application/json');
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                req.setTimeout(120000);
                Http httpreq = new Http();
                HttpResponse res = httpreq.send(req);
                String reqresponse = res.getBody();
                //parsing resoponse and get the fullname of flow
                boolean isFound = JSON.deserializeUntyped(reqresponse) instanceof Map<String, Object>;
                if (isFound) {
                    Map<String, Object> customFieldDefination = (Map<String, Object>) JSON.deserializeUntyped(
                        reqresponse
                    );
                    Object classList = customFieldDefination.get('records');
                    if (classList instanceof List<Object>) {
                        List<Object> tempList = (List<Object>) classList;
                        if (tempList != null && tempList.size() > 0) {
                            for (object fielddata : tempList) {
                                if (fielddata instanceof Map<string, object>) {
                                    Map<string, object> tempMap = (Map<string, object>) fielddata;
                                    String toolingStatus = string.valueof(tempMap.get('Status'));
                                    String toolingId = string.valueof(tempMap.get('Id'));
                                    String toolingCreatedById = string.valueof(tempMap.get('CreatedById'));

                                    String CreatedDateStr = String.valueof(tempMap.get('CreatedDate'));
                                    CreatedDateStr = CreatedDateStr.replace('T', ' ');
                                    DateTime toolingCreatedDate = DateTime.valueOfGmt(CreatedDateStr);

                                    String toolingCreatedByUsername;
                                    Object createdByObj = tempMap.get('CreatedBy');
                                    if (createdByObj != null && createdByObj instanceof Map<string, object>) {
                                        Map<String, object> tempMap4 = (Map<String, object>) createdByObj;
                                        toolingCreatedByUsername = String.valueof(tempMap4.get('Username'));
                                    }

                                    //deployment after log created date.
                                    if (finalAsyncId == null && toolingCreatedDate > logList[0].CreatedDate) {
                                        finalAsyncId = toolingId;
                                    } else if (finalAsyncId != null && toolingCreatedDate > logList[0].CreatedDate) {
                                        //Multiple deployments found
                                        return null;
                                    }
                                }
                            }
                        }
                    }
                }
                if (finalAsyncId != null) {
                    logList[0].Async_Request_Id__c = finalAsyncId;

                    DatabaseUtils.updateRecords(
                        logList,
                        new List<Schema.DescribeFieldResult>{ Metadata_Log__c.Async_Request_Id__c.getDescribe() }
                    );
                    return finalAsyncId;
                }
            }
        }
        return null;
    }

    @RemoteAction
    public static void runApexPostDeploy(String deploymentLogId) {
        List<Metadata_Log__c> logRecordList = [
            SELECT
                ID,
                Name,
                Branch__c,
                Organisation__c,
                Process_Type__c,
                Process_Log__c,
                Start_Date__c,
                Code_Coverage__c,
                Completed_Date__c,
                PipelineStepId__c,
                Async_Request_Id__c,
                Succeed__c,
                Job_Completed__c,
                Status__c,
                Run_Test_Param__c
            FROM Metadata_Log__c
            WHERE Id = :deploymentLogId
            WITH SECURITY_ENFORCED
        ];
        if (!logRecordList.isEmpty()) {
            Boolean isDeploy = logRecordList[0].Process_Type__c == FlosumConstants.PROCESS_VALIDATE ? false : true;
            ApexDeploymentBatchForBranch.runApexPostDeploy(logRecordList[0].Id, isDeploy, logRecordList[0].Succeed__c);
        }
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class AuthenticateDetailsWrapper {
        public Boolean isSuccess;
        public String accessToken;
        public String instanceUrl;
        public String refreshToken;
        public String infoMessage;
        public String errorMessage;

        public AuthenticateDetailsWrapper(AuthUtils.AuthenticateDetails authDetails) {
            this.isSuccess = authDetails.isSuccess;
            this.accessToken = authDetails.details?.AccessToken__c;
            this.instanceUrl = authDetails.details?.InstanceURL__c;
            this.refreshToken = authDetails.details?.RefreshToken__c;
            this.infoMessage = authDetails.infoMessage;
            this.errorMessage = authDetails.errorMessage;
        }

        public AuthenticateDetailsWrapper(VeevaAuthUtils.AuthenticateDetails authDetails) {
            this.isSuccess = authDetails.isSuccess;
            this.accessToken = authDetails.details?.accessToken;
            this.instanceUrl = authDetails.details?.instanceUrl;
            this.infoMessage = authDetails.infoMessage;
            this.errorMessage = authDetails.errorMessage;
        }

        public AuthenticateDetailsWrapper(CommerceCloudAuthentication B2CDetails) {
            this.isSuccess = true;
            this.accessToken = B2CDetails.accessToken;
            this.instanceUrl = B2CDetails.instanceURL;
            this.infoMessage = 'Authentication Successful.';
        }

        public AuthenticateDetailsWrapper(MarketingCloudAuthentication mcAuth) {
            this.isSuccess = true;
            this.accessToken = mcAuth.accessToken;
            this.instanceUrl = mcAuth.instanceURL;
            this.infoMessage = 'Authentication Successful.';
        }
    }

    @JsonAccess(Serializable='always' Deserializable='always')
    public class AttachmentWraper {
        public String parentId; //a0Iq00000012tdzEAA
        public String compType; //CustomObject
        public String base64;
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaItemWraper {
        public String itemName;
        public String fileName;
        public Id snapId;
        public Set<Id> attachmentIds;
        public Id MetaId;

        public MetaItemWraper(String itemName, String fileName, Id snapId, Set<Id> attachmentIds) {
            this.itemName = itemName;
            this.fileName = fileName;
            this.snapId = snapId;
            this.attachmentIds = attachmentIds;
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaTypeWraper {
        public String metaType;
        public List<MetaItemWraper> items;

        public MetaTypeWraper(String metaType, List<MetaItemWraper> items) {
            this.metaType = metaType;
            this.items = items;
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class MetaBranchDetailWraper {
        public DestructiveWraper destructiveInfo;
        public List<MetaTypeWraper> MetaItemlist;
        public String error;
        public Map<String, Map<String, String>> envVarMap;
        public List<String> metaTypes;
        public Boolean isApexComponentInDeploy;
        public Boolean isQuickDeploy;

        public MetaBranchDetailWraper(
            List<MetaTypeWraper> MetaItemlist,
            DestructiveWraper destructiveInfo,
            String error
        ) {
            this.destructiveInfo = destructiveInfo;
            this.MetaItemlist = MetaItemlist;
            this.error = error;
            this.envVarMap = new Map<String, Map<String, String>>();
            this.metaTypes = new List<String>();
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class DestructiveWraper {
        Map<String, Set<String>> preMap;
        Map<String, Set<String>> postMap;

        public DestructiveWraper(Map<String, Set<String>> preMap, Map<String, Set<String>> postMap) {
            this.preMap = preMap;
            this.postMap = postMap;
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class VlocityDeployWrapper {
        public String metadataLogName { get; set; }
        public String branchId { get; set; }
        public String orgId { get; set; }
        public String vlocityComponentIdListJSON { get; set; }
        public Boolean isLWCActivation { get; set; }
        public Boolean isSeparateMatrixVersions { get; set; }
        public Boolean isSeparateCalculationProcedureVersions { get; set; }
        public Boolean isEnabledApexPostDeploy { get; set; }
        public String apexCode { get; set; }
        public VlocityDeployWrapper() {
        }
    }
    @JsonAccess(Serializable='always' Deserializable='always')
    public class BranchDataWrapper {
        public Integer componentsCount { get; set; }
        public String branchId { get; set; }
        public String componentIdListJson { get; set; }
        public String flosumUrl { get; set; }
        public String flosumToken { get; set; }
        public String clientId { get; set; }
        public String clientSecret { get; set; }
        public String vlocityUrl { get; set; }
        public String vlocityToken { get; set; }
        public String nameSpacePrefix { get; set; }
        public String snapshotType { get; set; }
        public String logId { get; set; }
        public Boolean isSeparateMatrixVersions { get; set; }
        public Boolean isSeparateCalculationProcedureVersions { get; set; }
        public Boolean isLWCActivation { get; set; }
        public Boolean isEnabledApexPostDeploy { get; set; }
        public String apexCode { get; set; }
        public String attachLogId { get; set; }
        public String timestamp { get; set; }
        public BranchDataWrapper() {
        }
    }
}