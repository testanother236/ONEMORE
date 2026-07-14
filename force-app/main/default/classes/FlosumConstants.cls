/*
 *  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  Class Name    : FlosumConstants
 *  Author        : Ashwani Soni
 *  Created Date  :
 *  Description   : Flosum settings and configuration values holder
 *  Referenced by : Almost all classes exist in product
 *  Changes       : Added Business and Entitlement Process - 10-12-2014
 *  Change by     : Ravikant Saini
 *
 *  Methods       :
 *                : parseCatchMessage - Parse clean error message from a raw exception string (from catch).
 *                : correctEndpoint - Used for Named Credentials. Corrects the endpoint value based on the configuration in the provided SObject.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */

public with sharing class FlosumConstants {
    // Metatdata API version
    public static final Integer DEFAULT_METADATA_API_VERSION = 66;
    public static final Integer apiversion = getMetadataAPIVersion();
    // Tooling API version
    public static final Decimal TOOLING_API_VERSION = 51.0;

    public static final String Default_RepoSitory_Name = 'Default';

    // Tooling API Endpoint
    public static final String TOOLING_ENDPOINT = '/services/data/v' + FlosumConstants.TOOLING_API_VERSION + '/tooling';
    public static final Integer COMP_TYPE_SOQL_LIMIT = 900;

    // Visible metadata type in Set
    public static final Set<String> metaDataTypeFilterSet = getAllMetadataTypes();
    public static final Set<String> snapshotTypesNotSupportedByDescribeSet = new Set<String>{
        'FeatureParameterBoolean',
        'FeatureParameterDate',
        'FeatureParameterInteger'
    };

    public static final Set<String> SNAPSHOT_TYPES_FOR_ADDITIONAL_LOGIC = new Set<String>{
        'DataPackageKitObject',
        'TestCoverage__DataKit'
    };

    public static final Set<String> metaDataItemFilterSet = new Set<String>{
        'appMenus/AppSwitcher.appMenu',
        'objects/Idea.object'
    };

    public static final Set<String> managedPackageManageableStateSet = new Set<String>{
        'installed',
        'installedEditable'
    };

    public static final Set<String> manageableStateToRetrieveSet = new Set<String>{
        'beta',
        'deleted',
        'deprecated',
        'deprecatedEditable',
        //'installed',
        //'installedEditable',
        'released',
        'unmanaged',
        null
    };
    public static final Set<String> manageMetadataTypeToRetrieve = new Set<String>{
        'Layout',
        'CustomField',
        'FieldSet',
        'WebLink',
        'RecordType',
        'ListView',
        'ValidationRule',
        'WorkflowTask',
        'WorkflowOutboundMessage',
        'WorkflowFieldUpdate',
        'WorkflowAlert',
        'WorkflowRule',
        'CustomObject',
        'DocumentFolder',
        'DashboardFolder',
        'ReportFolder',
        'EmailFolder',
        'Document',
        'Dashboard',
        'EmailTemplate',
        'GlobalValueSet',
        'Report',
        'HomePageLayout',
        'Letterhead',
        'RemoteSiteSetting',
        'CustomTab',
        'CustomApplication',
        'ConnectedApp',
        'ReportType',
        'ExternalDataSource',
        'Flow',
        'NamedCredential',
        'QuickAction',
        'Scontrol',
        'CustomMetadata'
    };

    public static final String PIPELINE_STEP_DEPLOY = 'Deploy';
    public static final String PIPELINE_STEP_VALIDATE = 'Validate';
    public static final String PIPELINE_STEP_ROLLBACK = 'Rollback';
    public static final String PIPELINE_STEP_EXECUTE_APEX = 'Execute Apex';
    public static final String PIPELINE_STEP_OVERWRITE_PROTECTION = 'Overwrite Protection';
    public static final String PIPELINE_STEP_AUTOMATION_STEP = 'Automation Step';
    public static final String PIPELINE_STEP_PRE_DEPLOY_FIX = 'PreDeploy Fix';
    public static final String PIPELINE_STEP_WEBHOOK = 'WebHook';
    public static final String PIPELINE_STEP_BACKUP = 'Backup';
    public static final String PIPELINE_STEP_PEER_REVIEW = 'Peer Review';
    public static final String PIPELINE_STEP_MANUAL_STEP = 'Manual Step';
    public static final String PIPELINE_STEP_PAUSE = 'Pause';
    public static final String PIPELINE_STEP_LOCK_BRANCH = 'Lock Branch';
    public static final String PIPELINE_STEP_UNLOCK_BRANCH = 'Unlock Branch';
    public static final String PIPELINE_STEP_CHANGE_BRANCH_RECORD_TYPE = 'Change Branch Record Type';
    public static final String PIPELINE_STEP_COMMIT_TO_SOURCE = 'Commit to Source';

    public static final Set<String> PIPELINE_STEPS_WITH_ORG = new Set<String>{
        PIPELINE_STEP_DEPLOY,
        PIPELINE_STEP_VALIDATE,
        PIPELINE_STEP_ROLLBACK,
        PIPELINE_STEP_EXECUTE_APEX,
        PIPELINE_STEP_OVERWRITE_PROTECTION,
        PIPELINE_STEP_AUTOMATION_STEP,
        PIPELINE_STEP_PRE_DEPLOY_FIX,
        PIPELINE_STEP_MANUAL_STEP
    };
    public static final Set<String> PIPELINE_STEPS_NOT_ALLOWED_TO_RUN_TESTS = new Set<String>{
        PIPELINE_STEP_WEBHOOK,
        PIPELINE_STEP_BACKUP,
        PIPELINE_STEP_EXECUTE_APEX,
        PIPELINE_STEP_PEER_REVIEW,
        PIPELINE_STEP_MANUAL_STEP,
        PIPELINE_STEP_LOCK_BRANCH,
        PIPELINE_STEP_UNLOCK_BRANCH,
        PIPELINE_STEP_CHANGE_BRANCH_RECORD_TYPE,
        PIPELINE_STEP_OVERWRITE_PROTECTION,
        PIPELINE_STEP_AUTOMATION_STEP,
        PIPELINE_STEP_PRE_DEPLOY_FIX,
        PIPELINE_STEP_COMMIT_TO_SOURCE,
        PIPELINE_STEP_PAUSE
    };
    public static final Set<String> PIPELINE_RECORDTYPES_NOT_ALLOWED_TO_RUN_TESTS = new Set<String>{
        B2CConstants.TYPE
    };

    public static final Integer retrievalLimit = 3000;
    public static final Integer CommitLimit = 4000;
    public static final Integer PatchComponentsLimit = 7500;
    public static final Integer PatchMergeLimit = 15;

    public static final String NO_TEST_RUN = 'NoTestRun';
    public static final String RUN_LOCAL_TEST = 'RunLocalTests';
    public static final String RUN_ALL_TEST_IN_ORG = 'RunAllTestsInOrg';
    public static final String RUN_SPECIFIC_TEST = 'RunSpecifiedTests';
    public static final String RUN_BRANCH_SPECIFIC_TEST = 'RunBranchSpecifiedTests';
    public static final String RUN_INCLUDED_TEST = 'RunIncludedTests';
    public static final String NO_SPECIFIC_TEST = 'NoSpecificTests';
    public static final String Default_TEST = 'Default';
    public static final String DEPLOY_JOB_CANCELED = 'Canceled';

    public static final String RUN_SPECIFIC_TEST_ERROR = 'Please enter a test name.';

    public static final String GOVT_ORG_PICK_VAL = 'Government cloud org';

    public static final Set<String> branchMergeSet = new Set<String>{ 'BranchToBranchMergeBatch' };
    public static final Set<String> commitToRepositorySet = new Set<String>{ 'BranchMergeBatch' };
    public static final String BRANCH_MERGE_IN_PROGRESS = 'There is already a merge in process. Please try after some time.';
    public static final String COMMIT_IN_PROGRESS = 'There is already a commit in process. Please try after some time.';

    public static final String ITEMS_QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE Snapshot__c = :snapId AND Id IN :ids WITH SECURITY_ENFORCED';

    public static final Set<String> runTestParamSet = new Set<String>{
        NO_TEST_RUN,
        RUN_LOCAL_TEST,
        RUN_ALL_TEST_IN_ORG
    };
    public static final Map<String, String> runTestParamMap = new Map<String, String>{
        NO_TEST_RUN => 'Do not run tests',
        RUN_LOCAL_TEST => 'Run local tests, ignore tests from managed packages',
        RUN_ALL_TEST_IN_ORG => 'Run all tests',
        NO_SPECIFIC_TEST => 'No group tests'
    };
    public static final Map<String, String> runTestParamPatchMap = new Map<String, String>{
        Default_TEST => 'Default',
        NO_TEST_RUN => 'Do not run tests',
        RUN_LOCAL_TEST => 'Run local tests, ignore tests from managed packages',
        RUN_ALL_TEST_IN_ORG => 'Run all tests',
        RUN_SPECIFIC_TEST => 'Run specified tests',
        RUN_INCLUDED_TEST => 'Run included tests',
        RUN_BRANCH_SPECIFIC_TEST => 'Run tests specified on Branch'
    };
    public static final String ACCELQ_RUN_BRANCH_SPECIFIC_TEST = 'AccelqRunBranchSpecifiedTests';

    public static final Map<String, String> runAccelqTestParamMap = new Map<String, String>{
        Default_TEST => 'Default',
        ACCELQ_RUN_BRANCH_SPECIFIC_TEST => 'Run AccelQ Test specified on Branch'
    };

    public static final String PATCH_TYPE_REPOSITORY = 'Repository';
    public static final String PATCH_TYPE_SNAPSHOT = 'Snapshot';
    public static final String PATCH_TYPE_PATCHMANIFEST = 'PatchManifest';

    // Metadata Log object status values
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_EXCEPTION = 'Exception';
    public static final String STATUS_PARTIAL_COMPLETED = 'Partial Completed';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_NOT_STARTED = 'Not Started';
    public static final String STATUS_DID_NOT_RUN = 'Did Not Run';

    //Metadata Log Attachment Names
    public static final String CODE_COVERAGE_LOG_ATTACHMENT_NAME = 'Code Coverage Log';

    //Backup integration constants
    public static final String BACKUP_JOB_DETAILED_LOG_ATTACHMENT_NAME = 'Backup job detailed log';
    public static final String BACKUP_LOGIC_ERROR_ATTACHMENT_NAME = 'Backup Integration ERROR log';
    public static final String BACKUP_REQUEST_LOG_ATTACHMENT_NAME = 'Backup Integration log';
    public static final String BACKUP_JOB_STATUS_PROCESS_NAME = 'BackupJobCheckerScheduled class';
    public static final String BACKUP_STATUS_JOB_IN_PROGRESS = 'In Progress';
    public static final String BACKUP_STATUS_JOB_IN_EXCEPTION = 'Exception';
    public static final String BACKUP_STATUS_JOB_IN_COMPLETED = 'Completed';
    public static final String BACKUP_STATUS_JOB_IN_ABORTED = 'Aborted';
    public static final Integer BACKUP_START_PROCESS_SEC = 5;
    public static final Integer BACKUP_RESCHEDULE_JOB_CHEKER_TIME_MIN = 1;
    public static final String BACKUP_SERVICE_SCHEDULED_JOB_NAME = 'BackupServiceScheduled_';
    public static final Integer BACKUP_REQUEST_TIMEOUT = 120000;

    // added for git integration
    public static final String PROCESS_GIT_DOWNLOAD = 'Download [Git]';
    public static final String PROCESS_GIT_UPLOAD = 'Upload [Git]';

    public static final String RETRIEVAL_TYPE_DEFAULT = 'Default';
    public static final String RETRIEVAL_TYPE_SERIALIZE = 'Serialize';

    public static final String PROCESS_SNAPSHOT = 'Retrieve';
    public static final String PROCESS_PATCH = 'Patch';
    public static final String PROCESS_DEPLOYMENT = 'Deployment';
    public static final String PROCESS_DEPLOYMENT_VLOCITY = 'Deployment (SFI)';
    public static final String PROCESS_VALIDATE = 'Validate';
    public static final String PROCESS_SCHEDULED_DEPLOYMENT = 'Schedule Deployment';
    public static final String PROCESS_SCHEDULED_DEPLOYMENT_VLOCITY = 'Schedule Deployment (SFI)';
    public static final String PROCESS_SNAPSHOT_LOG = 'Retrieval Log';
    public static final String PROCESS_SNAPSHOT_LOG_JS = 'Retrieval Log(JS)';
    public static final String PROCESS_SNAPSHOT_LOG_APEX = 'Retrieval Log(Apex)';

    public static final String PROCESS_VALIDATE_ROLLBACK = 'Rollback (Validate)';
    public static final String PROCESS_ROLLBACK = 'Rollback (Deployment)';
    public static final String PROCESS_WEBHOOK = 'WebHook';
    public static final String PROCESS_EXECUTE_APEX = 'Execute Apex';
    public static final String PROCESS_BACKUP = 'Backup';
    public static final String PROCESS_MERGE_BRANCHES = 'Merge Branches';
    public static final String PROCESS_COMMIT_BRANCH_TO_REPOSITORY = 'Branch to Repository Сommit';
    public static final String PROCESS_COMMIT_SNAPSHOT_TO_REPOSITORY = 'Snapshot to Repository Сommit';
    public static final String PROCESS_ACCELQ = 'AccelQ';
    public static final String PROCESS_PEER_REVIEW = 'Peer Review';
    public static final String PROCESS_MANUAL_STEP = 'Manual Step';
    public static final String PROCESS_PAUSE = 'Pause';
    public static final String PROCESS_AUTOMATION_STEP = 'Automation Step';
    public static final String PROCESS_LOCK_BRANCH = 'Lock Branch';
    public static final String PROCESS_UNLOCK_BRANCH = 'Unlock Branch';
    public static final String PROCESS_CHANGE_BRANCH_RECORD_TYPE = 'Change Branch Record Type';
    public static final String PROCESS_OVERWRITE_PROTECTION = 'Overwrite Protection';
    public static final String PROCESS_PRE_DEPLOY_FIX = 'PreDeploy Fix';
    public static final String PROCESS_COMMIT_TO_SOURCE = 'Commit to Source';

    public static final String ROLL_BACK_VLOCITY_FILE_DESCRIPTION = 'Vlocity Rollback';
    public static final String ROLL_BACK_FILE_DESCRIPTION = 'Rollback';
    public static final String ROLL_BACK_ZIP_DESCRIPTION = 'BACKUP ZIP';
    public static final String ROLL_BACK_VLOCITY_ZIP_DESCRIPTION = 'VLOCITY BACKUP ZIP';
    public static final String ATTACHMENT_DESCRIPTION = 'BACKUP ZIP';

    public static final String AUDIT_AUTOMATED = 'Automated';
    public static final String AUDIT_MANUAL = 'Manual';

    public static final String GroupLast = 'M';

    public static final Map<String, Set<String>> profilePermissionMap = new Map<String, Set<String>>{
        FlosumConstants.PROFILE_CUSTOMOBJECT_PERMISSION => new Set<String>{ FlosumConstants.META_CustomObject },
        FlosumConstants.PROFILE_APEXCLASS_PERMISSION => new Set<String>{ FlosumConstants.META_ApexClass },
        FlosumConstants.PROFILE_APEXPAGE_PERMISSION => new Set<String>{ FlosumConstants.META_ApexPage },
        FlosumConstants.PROFILE_LAYOUT_PERMISSION => new Set<String>{ FlosumConstants.META_Layout },
        FlosumConstants.PROFILE_OTHER_PERMISSION => new Set<String>{
            FlosumConstants.META_CustomTab,
            FlosumConstants.META_CustomApplication,
            FlosumConstants.META_ExternalDataSource,
            FlosumConstants.META_CustomPermission
        },
        FlosumConstants.PERMISSIONSET_CUSTOMOBJECT_PERMISSION => new Set<String>{ FlosumConstants.META_CustomObject },
        FlosumConstants.PERMISSIONSET_APEXCLASS_PERMISSION => new Set<String>{ FlosumConstants.META_ApexClass },
        FlosumConstants.PERMISSIONSET_APEXPAGE_PERMISSION => new Set<String>{ FlosumConstants.META_ApexPage },
        FlosumConstants.PERMISSIONSET_LAYOUT_PERMISSION => new Set<String>{ FlosumConstants.META_Layout },
        FlosumConstants.PERMISSIONSET_OTHER_PERMISSION => new Set<String>{
            FlosumConstants.META_CustomTab,
            FlosumConstants.META_CustomApplication,
            FlosumConstants.META_ExternalDataSource,
            FlosumConstants.META_CustomPermission
        }
    };
    public static final String META_CustomObject = 'CustomObject';
    public static final String META_ApexClass = 'ApexClass';
    public static final String META_ApexPage = 'ApexPage';
    public static final String META_Layout = 'Layout';
    public static final String META_CustomTab = 'CustomTab';
    public static final String META_CustomApplication = 'CustomApplication';
    public static final String META_ExternalDataSource = 'ExternalDataSource';
    public static final String META_CustomPermission = 'CustomPermission';
    public static final String META_Profile = 'Profile';
    public static final String META_PermissionSet = 'PermissionSet';
    public static final String META_CustomField = 'CustomField';
    public static final String META_RecordType = 'RecordType';

    public static final String META_WILD_CARD = '*';

    public static final String PROFILE_APEXCLASS_PERMISSION = 'Profile_ApexClass';
    public static final String PROFILE_APEXPAGE_PERMISSION = 'Profile_ApexPage';
    public static final String PROFILE_CUSTOMOBJECT_PERMISSION = 'Profile_CustomObject';
    public static final String PROFILE_LAYOUT_PERMISSION = 'Profile_Layout';
    public static final String PROFILE_OTHER_PERMISSION = 'Profile_Other_Permissions';

    public static final String PERMISSIONSET_APEXCLASS_PERMISSION = 'PermissionSet_ApexClass';
    public static final String PERMISSIONSET_APEXPAGE_PERMISSION = 'PermissionSet_ApexPage';
    public static final String PERMISSIONSET_CUSTOMOBJECT_PERMISSION = 'PermissionSet_CustomObject';
    public static final String PERMISSIONSET_LAYOUT_PERMISSION = 'PermissionSet_Layout';
    public static final String PERMISSIONSET_OTHER_PERMISSION = 'PermissionSet_Other_Permissions';

    public static final Set<String> MetaTypesForPermissionSet = new Set<String>{
        META_CustomObject,
        META_ApexClass,
        META_ApexPage,
        META_CustomTab,
        META_CustomApplication,
        META_Layout,
        META_ExternalDataSource,
        META_CustomPermission,
        META_CustomField,
        META_RecordType,
        'DataCategoryGroup',
        'Flow',
        'ServicePresenceStatus',
        'Bot'
    };

    public static final Map<String, List<String>> PROFILE_VALID_NAME_MAP = new Map<String, List<String>>{
        'ApexClass' => new List<String>(),
        'CustomObject' => new List<String>(),
        'ApexPage' => new List<String>(),
        'CustomTab' => new List<String>(),
        'Layout' => new List<String>(),
        'CustomApplication' => new List<String>(),
        'ExternalDataSource' => new List<String>(),
        'CustomPermission' => new List<String>(),
        'CustomField' => new List<String>(),
        'RecordType' => new List<String>(),
        'DataCategoryGroup' => new List<String>(),
        'Flow' => new List<String>(),
        'Bot' => new List<String>(),
        'ServicePresenceStatus' => new List<String>()
    };

    public static final Map<String, String> metadataFolderMap = new Map<String, String>{
        'DocumentFolder' => 'Document',
        'DashboardFolder' => 'Dashboard',
        'ReportFolder' => 'Report',
        'EmailFolder' => 'EmailTemplate',
        'EmailTemplateFolder' => 'EmailTemplate'
    };

    public static final Map<String, String> metadataToFolderMap = new Map<String, String>{
        'Document' => 'DocumentFolder',
        'Dashboard' => 'DashboardFolder',
        'Report' => 'ReportFolder',
        'EmailTemplate' => 'EmailFolder'
    };

    public static final Map<String, OmniComponentRecordWrapper> activeOmnistudioComponentTypes = new Map<String, OmniComponentRecordWrapper>{ // EPU
        'OmniUiCard' => new OmniComponentRecordWrapper('OmniUiCard', 'omniUiCard', '.ouc'),
        'OmniScript' => new OmniComponentRecordWrapper('OmniProcess', 'omniScripts', '.os'),
        'OmniIntegrationProcedure' => new OmniComponentRecordWrapper(
            'OmniProcess',
            'omniIntegrationProcedures',
            '.oip'
        ),
        'OmniDataTransform' => new OmniComponentRecordWrapper('OmniDataTransform', 'omniDataTransforms', '.rpt')
    };

    public class OmniComponentRecordWrapper {
        public String nameObject;
        public String extension;
        public String folderName;

        public OmniComponentRecordWrapper(String nameObject, String folderName, String extension) {
            this.nameObject = nameObject;
            this.extension = extension;
            this.folderName = folderName;
        }
    }

    public static final Set<String> skipInCaseOfObjSet = new Set<String>{
        'CustomField',
        'ActionOverride',
        'WebLink',
        'ListView',
        'RecordType',
        'CompactLayout',
        'ValidationRule'
    };

    public static final List<GroupWraper> groupTypes = new List<GroupWraper>{
        new GroupWraper('A - Custom Label', new Set<String>{ 'CustomLabel', 'CustomLabels' }, 500)
    };

    public static final Set<String> apexComparisonSet = new Set<String>{
        'ApexClass',
        'ApexComponent',
        'ApexPage',
        'ApexTrigger',
        'AppMenu',
        'ApprovalProcess',
        'CustomApplication',
        'CustomApplicationComponent',
        'CustomField',
        //'CustomLabel',
        'CustomLabels',
        'CustomObject',
        'CustomPageWebLink',
        'CustomTab',
        'Dashboard',
        'Document',
        'DocumentFolder',
        'EmailTemplate',
        'FlexiPage',
        'Group',
        'HomePageComponent',
        'HomePageLayout',
        'Layout',
        'PermissionSet',
        'Picklist',
        'Profile',
        'Queue',
        'RemoteSiteSetting',
        'Report',
        'ReportType',
        'Role',
        'SearchLayouts',
        'StaticResource',
        'Workflow',
        'ActionOverride',
        'BaseSharingRule',
        'CriteriaBasedSharingRule'
    };

    public static final Set<String> viewDetailFilterSet = new Set<String>{
        'EmailFolder',
        'ReportFolder',
        'DashboardFolder',
        'DocumentFolder',
        'StaticResource',
        'Document',
        //'CustomLabel',
        'AuraDefinitionBundle',
        'SiteDotCom'
        /*'CompactLayout',
                                                                            'BusinessProcess',
                                                                            'RecordType',
                                                                            'WebLink',
                                                                            'ValidationRule',
                                                                            'SharingReason',
                                                                            'ListView',
                                                                            'FieldSet',
                                                                            'WorkflowFieldUpdate',
                                                                            'WorkflowKnowledgePublish',
                                                                            'WorkflowTask',
                                                                            'WorkflowAlert',
                                                                            'WorkflowSend',
                                                                            'WorkflowOutboundMessage',
                                                                            'WorkflowFlowAction',
                                                                            'WorkflowRule',
                                                                            'AssignmentRule',
                                                                            'AutoResponseRule',
                                                                            'EscalationRule',
                                                                            'MatchingRule',
                                                                            'SharingOwnerRule',
                                                                            'SharingCriteriaRule',
                                                                            'ManagedTopic'*/
    };
    public static final Set<String> EDIT_MANIFEST_FILTER_SET = new Set<String>{
        'AuraDefinitionBundle',
        //'StaticResource',
        'Document',
        'ContentAsset',
        'SiteDotCom'
    };

    public static final Set<String> bundleTypesSet = new Set<String>{
        'AuraDefinitionBundle',
        'LightningComponentBundle',
        'ExperienceBundle',
        'WaveTemplateBundle',
        'DigitalExperience',
        'DigitalExperienceBundle',
        'GenAiFunction',
        'AppFrameworkTemplateBundle',
        'LightningTypeBundle',
        'GenAiPlannerBundle',
        'ContentTypeBundle',
        'AiAuthoringBundle'
    };

    public static final Set<String> EDITABLE_EXT_SET = new Set<String>{
        '.app',
        '.auradoc',
        '.cls',
        '.cmp',
        '.component',
        '.css',
        '.dep',
        '.design',
        '.email',
        '.evt',
        '.genAiPlannerBundle',
        '.html',
        '.intf',
        '.js',
        '.json',
        '.label',
        '.labels',
        '.layout',
        '.managedContentType',
        '.mdl',
        '.object',
        '.objectTranslation',
        '.os',
        '.page',
        '.profile',
        '.remoteSite',
        '.report',
        '.resource',
        '.scss',
        '.settings',
        '.tab',
        '.tokens',
        '.trigger',
        '.txt',
        '.workflow',
        '.xml',
        '.agent'
    };

    public static final Set<String> comparisonFilterSet = new Set<String>{
        /*'EmailFolder','ReportFolder','DashboardFolder',*/ 'DocumentFolder',
        /*'StaticResource',*/ 'Document',
        'SiteDotCom',
        'ContentAsset'
    };
    public static final Set<String> customObjectTranslationsInfoSet = new Set<String>{
        'CustomField',
        'QuickAction',
        'RecordType',
        'SharingReason',
        'ValidationRule',
        'WebLink',
        'WorkflowTask',
        'Layout'
    };
    public static final Set<String> translationsInfoSet = new Set<String>{
        'CustomApplication',
        'CustomLabels',
        'CustomPageWebLink',
        'CustomTab',
        'QuickAction',
        'ReportType',
        'Scontrol'
    };
    public static final Set<String> viewDataFilter = new Set<String>{
        /*'StaticResource',*/ 'Document',
        /*'AuraDefinitionBundle',*/ 'ContentAsset'
    };

    public static final Set<String> asyncJobStatus = new Set<String>{ 'Queued', 'Preparing', 'Processing', 'Holding' };

    public static final String CREATED = 'CREATED ';
    public static final String UPDATED = 'UPDATED ';
    public static final String DELETED = 'DELETED ';
    public static final String NA = ' N/A ';
    public static final String Warning = 'Warning';

    public static final String DEPLOYMENT_COMPLETE_NOTIFICATION = 'Deploy Complete. Please see logs for more details. ';
    public static final String VALIDATE_COMPLETE_NOTIFICATION = 'Validate Complete. Please see logs for more details. ';
    public static final String SNAPSHOT_RETRIEVAL_START_NOTIFICATION = 'Snapshot retrieval started. ';
    public static final String PLEASE_WAIT = 'Please wait... ';

    public static final String CREDENTIALS_NOT_EXIST = 'Selected Organization Credentials not found. Please authenticate again.';
    public static final String ORG_NOT_EXIST = 'Organization doesn not exist';
    public static final String RELEASE_MANAGER = 'Release Manager';
    public static final String VALIDATE_ONLY = 'Validate Only';
    public static final String DEVELOPER = 'Developer';
    public static final String READONLY = 'View Only';
    public static final String AUDIT_ONLY = 'Audit Only';

    public static final String PERMISSION_DENIED = 'Permission Denied';
    public static final String DELETE_PERMISSION_DENIED = 'You do not have permission to delete record related to this organization';
    public static final String DEPLOY_PERMISSION_DENIED = 'You do not have permission for deployment in this organization';
    public static final String VALIDATE_PERMISSION_DENIED = 'You do not have permission to validate against this organization';
    public static final String VALIDATE_DEPLOY_PERMISSION_DENIED = 'You do not have permission to validate and deploy to this organization.';
    public static final String COMMIT_PERMISSION_DENIED = 'You do not have permissions to commit to this repository. The System Administrator can grant you access to commit to this repository from the Settings tab. (See Section: Repository).';
    public static final String REPOSITORY_PERMISSION_DENIED = 'You do not have permissions to this repository. The System Administrator can grant you access to this repository from the Settings tab. (See Section: Repository).';
    public static final String RETRIEVE_PERMISSION_DENIED = 'You do not have permission to retrieve snapshots and components from this organization.';
    public static final String SESSION_EXPIRE = 'The token for the org has expired. Please re-authenticate the org by using the Edit button on the Org details page.';
    public static final String AUTHENTICATION_SUCCESSFUL = 'Authentication Successful.';
    public static final String FILL_PATCH_NAME = 'Please enter the Deployment name.';
    public static final String PATCH_NAME_TOO_LONG = 'Deployment name cannot exceed more than 80 character.';

    public static final String NO_SLOT_AVAILABLE =
        'There are already ' +
        MetadataUtils.getSnapshotJobLimit() +
        ' snapshots are in process. Please try after some time.';
    public static final String MERGE_IN_PROGRESS = 'There is already a branch merge in process. Please try after some time.';
    public static final String Production_NoTestMessage1 = 'Please do not use "Do not Run tests" option for the production org.';
    public static final String Production_NoTestMessage2 = 'To skip tests for the production org, choose the option "Run Specified Tests" and leave the box for tests empty. If you are specifying any tests to be run, those tests must have at least 75% code coverage.';

    public static final String SNAPSHOT_PERFORMANCE_TIP_1 = 'Performance Tip: Please specify the component type to improve the retrieval speed.';
    public static final String SNAPSHOT_PERFORMANCE_TIP_2 = 'Please specify 0 in \'Retrieve changes in the last days\' field to retrieve all components.';
    public static final String SNAPSHOT_PERFORMANCE_TIP_3 = 'Please specify component type(s) to speed up the retrieval.';

    public static final String LOW_CODE_COVERAGE_ERROR_TEMPLATE =
        'Code Coverage Check is enabled for this organization. ' +
        'It is required to have {0}% code coverage for deployment, but the actual code coverage is {1}%. \n';
    public static final String CODE_COVERAGE_FAILURES_TEMPLATE =
        'Code Coverage Check is enabled for this organization. ' +
        'There are test failures on the target org while calculating code coverage, please check the test log. \n';
    public static final String CODE_COVERAGE_CHECK_FAILED_TEMPLATE =
        'The code coverage check has failed since code coverage ' +
        'returned {0}% which is less than the threshold of {1}%.';

    public static final String BUILD_ORG = 'Build Organization';

    public static final String REDIRECT_URI = 'oob';
    public static final String MANUAL_AUTH = 'Manual';
    public static final String AUTO_AUTH = 'Automatic';
    public static final String JWT_AUTH = 'JWT';
    public static final String EXTERNAL_CLIENT_AUTH = 'External Client App';

    public static final String Create_Pull_Request = 'Create_Pull_Request';
    public static final String Update_Pull_Request = 'Update_Pull_Request';
    public static final String Approve_Reject_Pull_Request = 'Approve_or_Reject_Pull_Request';
    public static final String Override_Pull_Request_Permission = 'Override_Pull_Request_Permission_for_the_Branch';
    public static final String MASS_BRANCH_DELETE_PERMISSION = 'Mass_Branch_Delete';
    public static final String APEX_EXECUTION_PERMISSION = 'Run_Apex_Post_Deploy';

    public static final String PullRequestCommitToRepoType = 'CommitToRepo';
    public static final String PullRequestAddToDeploymentType = 'AddToDeployment';
    public static final String PullRequestMergeBranchType = 'MergeBranch';

    public static String PROFILE_OBJECT_PERMISSION = '<objectPermissions><allowCreate>true</allowCreate><allowDelete>true</allowDelete><allowEdit>true</allowEdit><allowRead>true</allowRead><object>{0}</object><viewAllRecords>true</viewAllRecords><modifyAllRecords>true</modifyAllRecords></objectPermissions>';

    public static final Set<String> logFilterSet = new Set<String>{ 'package.xml' };

    public static List<String> sortedList = new List<String>{
        'CustomLabel',
        'StaticResource',
        'Group',
        'Queue',
        'DocumentFolder',
        'DashboardFolder',
        'ReportFolder',
        'EmailFolder',
        'Document',
        'EmailTemplate',
        'CustomObject',
        'CustomField',
        'RecordType',
        'Picklist',
        'FieldSet',
        'ValidationRule',
        'ListView',
        'WebLink',
        'SharingReason',
        'BusinessProcess',
        'ActionOverride',
        'CompactLayout',
        'ReportType',
        'ApexClass',
        'ApexComponent',
        'ApexPage',
        'ApexTrigger',
        'CustomTab',
        'Layout',
        'SearchLayouts',
        'HomePageLayout',
        'HomePageComponent',
        'CustomPageWebLink',
        'AssignmentRules',
        'AssignmentRule',
        'AutoResponseRules',
        'AutoResponseRule',
        'Workflow',
        'WorkflowAlert',
        'WorkflowKnowledgePublish',
        'WorkflowFieldUpdate',
        'WorkflowOutboundMessage',
        'WorkflowTask',
        'WorkflowRule',
        'ApprovalProcess',
        'RemoteSiteSetting',
        'CriteriaBasedSharingRule',
        'BaseSharingRule',
        'AppMenu',
        'CustomApplication',
        'CustomApplicationComponent',
        'PermissionSet',
        'Role',
        'Profile',
        'Dashboard',
        'Report',
        'SharingRules',
        'SharingOwnerRule',
        'SharingCriteriaRule',
        'SharingGuestRule',
        'MatchingRules',
        'MatchingRule',
        'EscalationRules',
        'EscalationRule',
        'FlexiPage',
        'DigitalExperienceBundle',
        'Bot',
        'BotVersion'
    };
    public static final Set<String> filterTheseTypesSet = new Set<String>{ 'CustomLabels', 'DataSourceField' };
    public static final String CRON_EXPRESSION_TEMPLATE = '{0} {1} {2} {3} {4} ? {5}';
    public static final String NOT_SELECTED_TYPES = ' No one type for scanning was not select';
    public static final String NOT_COMPONENTS_IN_BRANCH = 'Branch does not contain components matching the selected types';
    public static final String BRANCH_NOT_FOUND = 'Branch not found';

    public static final Set<String> branchRecordTypesForPR = new Set<String>{
        'Veeva',
        B2CConstants.TYPE,
        MCConstants.TYPE
    };

    public static final Set<String> BUNDLE_TYPES_REQUIRE_FILENAME_FIX = new Set<String>{
        'GenAiFunction',
        'LightningTypeBundle',
        'GenAiPlannerBundle',
        'ContentTypeBundle'
    };

    public static Set<String> getAllMetadataTypes() {
        return getAllMetadataTypesWithFilter(new List<String>());
    }

    public static Set<String> getAllMetadataTypesWithFilter(List<String> additionalFilter) {
        Set<String> metadataTypeSet = new Set<String>();
        List<FlosumSetting__c> rtype = [
            SELECT Metadata_Type_Name__c
            FROM FlosumSetting__c
            WHERE
                is_Enabled__c = TRUE
                AND Configuration_Only__c = FALSE
                AND Metadata_Type_Name__c NOT IN :filterTheseTypesSet
                AND Metadata_Type_Name__c NOT IN :additionalFilter
            WITH SECURITY_ENFORCED
        ];
        if (rtype.size() > 0) {
            for (FlosumSetting__c rt : rtype) {
                metadataTypeSet.add(rt.Metadata_Type_Name__c);
            }
        }
        return metadataTypeSet;
    }

    public static Set<String> getAllMetadataTypesSourceTracking() {
        List<String> sourceTrackingFilterList = getSourceTrackingFilterList();
        return getAllMetadataTypesWithFilter(sourceTrackingFilterList);
    }

    //  Case Number 00016963 (In-app warnings for Snapshots - "Source Tracking"- 3 of 3.)
    //  Profile,CustomObjectTranslation,Translations
    public static List<String> getSourceTrackingFilterList() {
        try {
            if (Test.isRunningTest()) {
                return new List<String>{ 'DummyMetadataComponent' };
            }
            return (Flosum_Advanced_Settings__mdt.getInstance('Source_Member_Meta_Ignore').Value_Text_1__c).split(',');
        } catch (Exception e) {
            return new List<String>();
        }
    }

    public static Set<String> getAllVlocityTypes() {
        Set<String> vlocityTypeSet = new Set<String>();
        String objectName = Metadata_Item_Vlocity__c.getSObjectType().getDescribe().name;
        for (RecordType recordType : [
            SELECT Name
            FROM RecordType
            WHERE SobjectType = :objectName AND IsActive = TRUE
            WITH SECURITY_ENFORCED
        ]) {
            vlocityTypeSet.add(recordType.Name);
        }
        return vlocityTypeSet;
    }

    public static String getOrgWideEmailAddress() {
        Email_Setting__c est = Email_Setting__c.getOrgDefaults();
        if (
            est != null &&
            est.Organization_Wide_Email_Address__c != null &&
            est.Organization_Wide_Email_Address__c != ''
        ) {
            List<OrgWideEmailAddress> addressLi = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE Address = :est.Organization_Wide_Email_Address__c
                WITH SECURITY_ENFORCED
            ];
            if (addressLi.size() > 0) {
                return addressLi[0].Id;
            }
        }
        return null;
    }

    //  The method has been moved from "ComponentQueryBatch" for reuse in other logic
    public static FlosumUtils.SnapshotFilterInfo filterCorrection(String filterJSON) {
        FlosumUtils.SnapshotFilterInfo filterInfo = new FlosumUtils.SnapshotFilterInfo();
        if (String.isBlank(filterJSON)) {
            return filterInfo;
        }

        FlosumUtils.SnapshotFilterInfo tempFilterInfo = (FlosumUtils.SnapshotFilterInfo) JSON.deserialize(
            filterJSON,
            FlosumUtils.SnapshotFilterInfo.class
        );
        if (tempFilterInfo.IsRetrieveStandard != null) {
            filterInfo.IsRetrieveStandard = tempFilterInfo.IsRetrieveStandard;
        }
        if (tempFilterInfo.isOnlyActiveOmnistudioComponents != null) {
            filterInfo.isOnlyActiveOmnistudioComponents = tempFilterInfo.isOnlyActiveOmnistudioComponents;
        }
        if (tempFilterInfo.filterList != null) {
            for (FlosumUtils.SnapshotFilterWraper filterRow : tempFilterInfo.filterList) {
                if (filterRow != null && !String.isBlank(filterRow.value) && !String.isBlank(filterRow.operator)) {
                    filterInfo.filterList.add(filterRow);
                }
            }
        }
        if (tempFilterInfo.selectedComponentsName != null) {
            filterInfo.selectedComponentsName = tempFilterInfo.selectedComponentsName;
        }
        if (tempFilterInfo.isNameSpaceSelected != null) {
            filterInfo.isNameSpaceSelected = tempFilterInfo.isNameSpaceSelected;
        }
        if (tempFilterInfo.selectedNamespaceSet != null) {
            filterInfo.selectedNamespaceSet.addAll(tempFilterInfo.selectedNamespaceSet);
        }
        return filterInfo;
    }

    public static Boolean filterFilePropertyItem(
        MetadataService.FileProperties fileProperty,
        Datetime filterDate,
        FlosumUtils.SnapshotFilterInfo filterInfo
    ) {
        if (
            filterManageableState(fileProperty, filterInfo) &&
            (filterDate == null ||
            fileProperty.lastModifiedDate >= filterDate ||
            (filterInfo.IsRetrieveStandard && fileProperty.lastModifiedDate.getTime() == 0))
        ) {
            return true;
        }
        return false;
    }

    public static Boolean filterManageableState(
        MetadataService.FileProperties fileProperty,
        FlosumUtils.SnapshotFilterInfo filterInfo
    ) {
        if (
            (manageableStateToRetrieveSet.contains(fileProperty.manageableState) ||
            fileProperty.namespacePrefix == null ||
            (filterInfo.isNameSpaceSelected && filterInfo.selectedNamespaceSet.contains(fileProperty.namespacePrefix)))
        ) {
            return true;
        }
        return false;
    }

    public static Boolean filterName(
        MetadataService.FileProperties fileProperty,
        FlosumUtils.SnapshotFilterInfo filterInfo
    ) {
        if (filterInfo.selectedComponentsName.containsKey(fileProperty.type_x)) {
            List<String> compNameSet = filterInfo.selectedComponentsName.get(fileProperty.type_x);
            if (compNameSet != null && compNameSet.size() == 1 && compNameSet.contains('*')) {
                return false;
            } else if (compNameSet.contains(fileProperty.fullName)) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }

    public static List<String> getOrgTypes(String orgType) {
        List<String> allTypes = new List<String>{ 'Sandbox', 'Developer/Production', 'Government cloud org' };

        if (
            orgType == VeevaConstants.VEEVA_TYPE ||
            orgType == B2CConstants.TYPE ||
            orgType == MCConstants.TYPE ||
            orgType == AbstractAuthentication.MULESOFT_ORG_TYPE
        ) {
            return new List<String>{ orgType };
        }
        return allTypes;
    }

    public static List<String> getRepositoryTypes(String repositoryType) {
        List<String> allTypes = new List<String>{ null, 'Vlocity' };

        if (
            repositoryType == VeevaConstants.VEEVA_TYPE ||
            repositoryType == B2CConstants.TYPE ||
            repositoryType == MCConstants.TYPE ||
            repositoryType == AbstractAuthentication.MULESOFT_ORG_TYPE
        ) {
            return new List<String>{ repositoryType };
        }
        return allTypes;
    }

    public static List<String> getPipelineTypes(String pipelineType) {
        List<String> allTypes = new List<String>{ null, 'Default' };

        if (pipelineType == B2CConstants.TYPE) {
            return new List<String>{ pipelineType };
        }
        return allTypes;
    }

    public static List<SelectOption> getSelectOptionFromMap(Map<String, String> stringMap) {
        List<SelectOption> selectOptions = new List<SelectOption>();

        for (String key : stringMap.keySet()) {
            selectOptions.add(new SelectOption(key, stringMap.get(key)));
        }

        return selectOptions;
    }

    public static String getLightningDomain() {
        return 'https://' + DomainCreator.getLightningHostname();
    }

    public static String getVisualforceDomain() {
        return 'https://' + DomainCreator.getVisualforceHostname(FlosumConstants.getNameSpacePrefix());
    }

    public static MetadataService.FileProperties fixNamesOfItems(MetadataService.FileProperties fileProperty) {
        //Modifications in fullName and fileName according to errors we get from salesforce
        if (
            fileProperty.type_x == 'Layout' &&
            managedPackageManageableStateSet.contains(fileProperty.manageableState) &&
            fileProperty.namespacePrefix != null
        ) {
            fileProperty.fullName = fileProperty.fullName.replaceFirst('-', '-' + fileProperty.namespacePrefix + '__');
            fileProperty.fileName = fileProperty.fileName.replaceFirst('-', '-' + fileProperty.namespacePrefix + '__');
        }
        if (
            fileProperty.type_x == 'CustomMetadata' &&
            managedPackageManageableStateSet.contains(fileProperty.manageableState) &&
            fileProperty.namespacePrefix != null
        ) {
            //  Case Number 00015901 (The latest components components are not retrieved for one of the orgs)
            //  issue was found for "Financial Services Cloud" package
            //  as the result we had not correct fileProperty.fullName
            //  FinServ__FeatureFlagSettings.FinServ__FinServ__QueryOptimization    (double prefix)
            if (!fileProperty.fullName.contains('.' + fileProperty.namespacePrefix + '__')) {
                fileProperty.fullName = fileProperty.fullName.replace('.', '.' + fileProperty.namespacePrefix + '__');
            }
            fileProperty.fileName = 'customMetadata/' + fileProperty.fullName + '.md';
        }
        if (
            fileProperty.type_x == 'QuickAction' &&
            managedPackageManageableStateSet.contains(fileProperty.manageableState) &&
            fileProperty.namespacePrefix != null &&
            fileProperty.fullName.indexOf('.') == -1
        ) {
            fileProperty.fullName = fileProperty.namespacePrefix + '__' + fileProperty.fullName;
            fileProperty.fileName = 'quickActions/' + fileProperty.fullName + '.quickAction';
        }
        if (fileProperty.type_x == 'ManagedTopics') {
            if (fileProperty.fileName.indexOf('ManagedTopics/') == 0)
                fileProperty.fileName = fileProperty.fileName.replace('ManagedTopics/', 'managedTopics/');
            fileProperty.fileName = EncodingUtil.urlDecode(fileProperty.fileName, 'UTF-8');
        }
        if (fileProperty.type_x == 'Workflow' && fileProperty.fileName.indexOf('Workflow/') == 0) {
            fileProperty.fileName = fileProperty.fileName.replace('Workflow/', 'workflows/');
        }
        if (fileProperty.type_x == 'MatchingRules' && fileProperty.fileName.indexOf('MatchingRules/') == 0) {
            fileProperty.fileName = fileProperty.fileName.replace('MatchingRules/', 'matchingRules/');
        }
        if (fileProperty.type_x == 'SynonymDictionary' && fileProperty.fullName == '_Default') {
            fileProperty.fileName = 'synonymDictionaries/_Default.synonymDictionary';
        }
        if (fileProperty.type_x == 'DigitalExperience' || fileProperty.type_x == 'DigitalExperienceBundle') {
            fileProperty.fileName = 'digitalExperiences/' + fileProperty.fullName.replace('.sfdc_', '/sfdc_');
        }
        if (BUNDLE_TYPES_REQUIRE_FILENAME_FIX.contains(fileProperty.type_x)) {
            String fileName = fileProperty.fileName;
            fileProperty.fileName = fileName.substring(0, fileName.indexOf('.'));
        }
        if (metadataFolderMap.containsKey(fileProperty.type_x)) {
            fileProperty.fileName = fileProperty.fileName + '-meta.xml';
        }
        return fileProperty;
    }

    public static MetadataService.DeployMessage fixNamesOfComponents(MetadataService.DeployMessage componentSuccess) {
        //Modifications in fullName and fileName according to errors we get from salesforce
        //Names are using in audit trails and branch user story. So wrong names can cause issues or user misunderstanding.
        if (componentSuccess.componentType == 'GlobalValueSet' && componentSuccess.fullName.endsWith('__gvs')) {
            componentSuccess.fullName = componentSuccess.fullName.replaceFirst('__gvs', '');
        }
        return componentSuccess;
    }

    public static String getNameSpacePrefix() {
        String nameSpacePrefix = FlosumConstants.class.getName().substringBefore('FlosumConstants');
        if (nameSpacePrefix != '')
            return nameSpacePrefix = nameSpacePrefix.replace('.', '');
        else
            return '';
    }

    public static String getNameSpacePrefixForPage() {
        String nameSpacePrefix = FlosumConstants.class.getName().substringBefore('FlosumConstants');
        if (nameSpacePrefix != '')
            return nameSpacePrefix = nameSpacePrefix.replace('.', '__');
        else
            return '';
    }

    public static Integer getMetadataAPIVersion() {
        Credentials__c cred = AuthUtils.getOrgDefaultsCredentials();
        if (cred.Metadata_API_Version__c != null) {
            return (Integer) cred.Metadata_API_Version__c;
        } else {
            return DEFAULT_METADATA_API_VERSION;
        }
    }

    public static String getSnapshotHTMLHyperlinks() {
        String result = '';
        result += FlosumConstants.flosumHyperLinks.containsKey('SNAPSHOT_RETRIEVAL_BEST_PRACTICES')
            ? '<br/><a href="' +
              FlosumConstants.flosumHyperLinks.get('SNAPSHOT_RETRIEVAL_BEST_PRACTICES') +
              '" target="_blank" style="margin: 0px">Snapshot Retrieval Best Practices</a>'
            : '';
        result += FlosumConstants.flosumHyperLinks.containsKey('SNAPSHOT_OVERVIEW_AND_STRATEGY')
            ? '<br/><a href="' +
              FlosumConstants.flosumHyperLinks.get('SNAPSHOT_OVERVIEW_AND_STRATEGY') +
              '" target="_blank" style="margin: 0px">Snapshot Overview and Strategy</a>'
            : '';
        return result;
    }

    public static String getSnapshotHasErrorOrCancelledMessage(Id snapshotId, String apexName) {
        List<Snapshot__c> snap = [
            SELECT Is_Error__c
            FROM Snapshot__c
            WHERE Id = :snapshotId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (snap.isEmpty() || !snap[0].Is_Error__c) {
            return '';
        }
        return MetadataUtils.getTimeForLog() +
            ':  Snapshot was stopped. ' +
            apexName +
            ' was interrupted (Reason: Error or cancelled by user).\n';
    }

    //  support method for apex batches (snapshot retrieval)
    public static void updateSnapshotApex(Boolean needToUpdateMetaLog, Id snapshotId, String logLine) {
        updateSnapshotApex(needToUpdateMetaLog, snapshotId, logLine, null, null, null, null);
    }

    //  support method for apex batches (snapshot retrieval)
    public static void updateSnapshotApex(
        Boolean needToUpdateMetaLog,
        Id snapshotId,
        String logLine,
        String status,
        Boolean isJobCompleted,
        Boolean isSucceed,
        Boolean isError
    ) {
        List<Metadata_Log__c> metaLog = [
            SELECT Snapshot__r.Name, Job_Completed__c, Status__c, Succeed__c, Is_Error__c
            FROM Metadata_Log__c
            WHERE
                Snapshot__c = :snapshotId
                AND Process_Type__c = :PROCESS_SNAPSHOT_LOG_APEX
                AND Status__c = :STATUS_IN_PROGRESS
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        //  no actions required (Metadata_Log__c not found)
        if (metaLog.isEmpty()) {
            return;
        }
        //  do we need to update Metadata_Log__c record ?
        if (needToUpdateMetaLog) {
            updateSnapshotApexMetaLog(metaLog[0], status, isJobCompleted, isSucceed, isError);
        }
        //  do we need to upsert Metadata_Log__c APEX text Attachment record ?
        if (String.isNotBlank(logLine)) {
            upsertSnapshotApexTextAttachment(metaLog[0].Id, metaLog[0].Snapshot__r.Name, logLine);
        }
    }

    public static void updateSnapshotApexMetaLog(
        Metadata_Log__c metaLog,
        String status,
        Boolean isJobCompleted,
        Boolean isSucceed,
        Boolean isError
    ) {
        metaLog.Job_Completed__c = isJobCompleted;
        metaLog.Status__c = status;
        metaLog.Succeed__c = isSucceed;
        metaLog.Is_Error__c = isError;
        DatabaseUtils.updateRecord(
            metaLog,
            new List<Schema.DescribeFieldResult>{
                Metadata_Log__c.Job_Completed__c.getDescribe(),
                Metadata_Log__c.Status__c.getDescribe(),
                Metadata_Log__c.Is_Error__c.getDescribe(),
                Metadata_Log__c.Succeed__c.getDescribe()
            }
        );
    }

    public static void upsertSnapshotApexTextAttachment(Id metaLogId, String snapshotName, String logLine) {
        List<Schema.DescribeFieldResult> fResult = new List<Schema.DescribeFieldResult>{
            Attachment.Name.getDescribe(),
            Attachment.Body.getDescribe(),
            Attachment.Description.getDescribe(),
            Attachment.ContentType.getDescribe()
        };

        //  upsert related attachment
        List<Attachment> logAttachment = [
            SELECT Name, Body, Description
            FROM Attachment
            WHERE Description = 'APEX' AND ParentId = :metaLogId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Attachment logAttachmentToUpsert = new Attachment();
        //  Not updatable entity Attachment.ParentId (upsert workaround)
        if (!logAttachment.isEmpty()) {
            logAttachmentToUpsert.Id = logAttachment[0].Id;
            logAttachmentToUpsert.Body = Blob.valueOf(logAttachment[0].Body.toString() + logLine);
            DatabaseUtils.updateRecord(logAttachmentToUpsert, fResult);
        } else {
            fResult.add(Attachment.ParentId.getDescribe());
            logAttachmentToUpsert.ParentId = metaLogId;
            logAttachmentToUpsert.Name = snapshotName + ' Logfile';
            logAttachmentToUpsert.Body = Blob.valueOf(logLine);
            logAttachmentToUpsert.Description = 'APEX';
            logAttachmentToUpsert.ContentType = 'text/plain';
            DatabaseUtils.insertRecord(logAttachmentToUpsert, fResult);
        }
    }

    /**
     * Parse clean error message from a raw exception string.
     * Example input: "FIELD_CUSTOM_VALIDATION_EXCEPTION, Amount must be greater than 100: []"
     * Output: "Amount must be greater than 100"
     *
     * @param rawMessage full error string
     * @return parsed message or the original string if parsing fails
     */
    public static String parseCatchMessage(String rawMessage) {
        try {
            if (String.isBlank(rawMessage)) {
                return rawMessage;
            }

            // Try to find the part between comma and colon
            String parsed = rawMessage.substringAfter(',').substringBefore(':').trim();

            if (String.isNotBlank(parsed)) {
                return parsed;
            }

            // If parsing did not work, return the original message
            return rawMessage;
        } catch (Exception ex) {
            // In case of unexpected errors, return the original message
            return rawMessage;
        }
    }

    /**
     * Corrects the endpoint value based on the configuration in the provided SObject.
     * This method checks the custom field "Is_Use_Named_Credentials__c" on the given SObject.
     * If the field value is true, the method prefixes the provided named credential with
     * 'callout:' to use it as a named credential reference. Otherwise, the input string is returned unchanged.
     *
     * @param urlOrNamed  The original endpoint URL or the name of the Named Credential.
     * @param obj         The SObject that contains the field Is_Use_Named_Credentials__c.
     * @return            The corrected endpoint string, either prefixed with 'callout:' or unchanged.
     */

    public static String correctEndpoint(String urlOrNamed, SObject obj) {
        String result = urlOrNamed;
        try {
            Boolean isUseNamed = Boolean.valueOf(String.valueOf(obj.get('Is_Use_Named_Credentials__c')));
            result = isUseNamed ? 'callout:' + urlOrNamed : urlOrNamed;
        } catch (SObjectException ex) {
            System.debug(ex);
        }
        return result;
    }

    public class GroupWraper {
        public Integer itemLimit;
        public String groupKey;
        public Set<String> types;
        public GroupWraper(String groupKey, Set<String> types, Integer itemLimit) {
            this.groupKey = groupKey;
            this.types = types;
            this.itemLimit = itemLimit;
        }
    }

    public static Set<String> standardValueSet = getStandardValueSetList();

    public static Set<String> getStandardValueSetList() {
        Set<String> stdSet = new Set<String>{
            'AAccreditationRating',
            'ACISumRecipientCategory',
            'ACInitSumEmployeeType',
            'ACInitSumInitiativeType',
            'ACorruptionInitSumCountry',
            'ACorruptionInitSumRegion',
            'AFSIBuiltUpAreaUnit',
            'AFSIConstructionStage',
            'AFSIIntendedUse',
            'AFSIItemCondition',
            'AFSIType',
            'APTCategoryEnum',
            'APTSourceTypeEnum',
            'APTSubcategoryEnum',
            'AQuestionQuestionCategory',
            'AReasonAppointmentReason',
            'AccPlanObjectivePriority',
            'AccPlanObjectiveStatus',
            'AccountContactMultiRoles',
            'AccountContactRole',
            'AccountOwnership',
            'AccountPlanStatus',
            'AccountRating',
            'AccountType',
            'AccreditationAccreditingBody',
            'AccreditationStatus',
            'AccreditationSubType',
            'AccreditationType',
            'ActionPlanState',
            'ActivityTimeEnum',
            'AddressType',
            'AdmissionSource',
            'AdmissionType',
            'AgeOver',
            'AllergyIntoleranceCategory',
            'AllergyIntoleranceSeverity',
            'AllergyIntoleranceStatus',
            'AllergyIntoleranceType',
            'AllergyVerificationStatus',
            'AppFormProductDisbursement',
            'AppealRequestReasonType',
            'ApplicantBusinessEntityType',
            'ApplicantPhoneType',
            'ApplicantRole',
            'ApplicantSalutation',
            'ApplicantStage',
            'ApplicationActionItemStatus',
            'ApplicationActionItemType',
            'ApplicationFormIntakeChannelType',
            'ApplicationFormProductApplicantVisibleStatus',
            'ApplicationFormProductFeeType',
            'ApplicationFormProductLoanPurpose',
            'ApplicationFormProductLoanType',
            'ApplicationFormProductOwnership',
            'ApplicationFormProductPartnerVisibleStatus',
            'ApplicationFormProductProposalInterestRateType',
            'ApplicationFormProductProposalSelectedBy',
            'ApplicationFormProductProposalStage',
            'ApplicationFormProductStage',
            'ApplicationFormStage',
            'ApplicationFormTierType',
            'ApprovedLevelOfCare',
            'AssessmentRating',
            'AssessmentStatus',
            'AssetActionCategory',
            'AssetRelationshipType',
            'AssetStatus',
            'AssociatedLocationType',
            'AuthorNoteRecipientType',
            'AwardsStatus',
            'AwardsVerificationStatus',
            'BCCertificationType',
            'BLicenseJurisdictionType',
            'BLicenseVerificationStatus',
            'BarrierCodeType',
            'BenefitProcessType',
            'BoardCertificationStatus',
            'BusinessLicenseStatus',
            'BusinessMilestoneType',
            'CBCoverageType',
            'CBItemLimitCoverageLevel',
            'CBItemLimitNetworkType',
            'CBenefitItemLimitTermType',
            'CCFALineOfBusiness',
            'CCPAdditionalBenefits',
            'CCPStandardsAgencyName',
            'CCProjectMitigationType',
            'CCRDPriority',
            'CCreditProjectProjectType',
            'CDPresentOnAdmission',
            'CEIdentifierIdUsageType',
            'CEncounterAdmissionSource',
            'CEncounterCategory',
            'CEncounterDietPreference',
            'CEncounterFacilityStatus',
            'CEncounterServiceType',
            'CEncounterSpecialCourtesy',
            'CEncounterStatus',
            'CEpisodeDetailDetailType',
            'COCValueInterpretation',
            'COComponentValueType',
            'COProcessingResult',
            'COValueInterpretation',
            'CPAActivityType',
            'CPADetailDetailType',
            'CPAProhibitedActivity',
            'CPAdverseActionActionType',
            'CPAdverseActionStatus',
            'CPAgreementAgreementType',
            'CPAgreementLineofBusiness',
            'CPDProblemPriority',
            'CPEligibilityRuleStatus',
            'CPEnrolleeProductStatus',
            'CPEnrollmentCardStatus',
            'CPFSpecialtySpecialtyRole',
            'CPPRole',
            'CPTemplateProblemPriority',
            'CProgramProductAvailability',
            'CRDDrugAdministrationSetting',
            'CRDNameType',
            'CRDRequestType',
            'CRDStatus',
            'CRDStatusReason',
            'CRECaseSubStatus',
            'CREDocumentAttachmentStatus',
            'CREIndependentReviewDetermination',
            'CREPriorAuthRequestIdentifier',
            'CREPriorDischargeStatus',
            'CREReopenRequestOutcome',
            'CREReopenRequestType',
            'CRERequestOutcome',
            'CRIApprovedLevelOfCare',
            'CRIClinicalDetermination',
            'CRICurrentLevelOfCare',
            'CRIDeniedLevelOfCare',
            'CRIModifiedLevelOfCare',
            'CRIPriority',
            'CRIRequestType',
            'CRIRequestedLevelOfCare',
            'CRReviewerReviewerType',
            'CSBundleUsageType',
            'CSRequestDetailDetailType',
            'CServiceRequestIntent',
            'CServiceRequestPriority',
            'CServiceRequestStatus',
            'CampaignMemberStatus',
            'CampaignStatus',
            'CampaignType',
            'CardType',
            'CareAmbulanceTransReason',
            'CareAmbulanceTransType',
            'CareBarrierPriority',
            'CareBarrierStatus',
            'CareBenefitVerifyRequestStatus',
            'CareDeterminantPriority',
            'CareDeterminantTypeDomain',
            'CareDeterminantTypeType',
            'CareEpisodeStatus',
            'CareEpisodeType',
            'CareItemStatus',
            'CareItemStatusReason',
            'CareMetricTargetType',
            'CareObservationCategory',
            'CareObservationStatus',
            'CarePlanActivityStatus',
            'CarePlanAuthorizationType',
            'CarePlanDetailDetailType',
            'CarePreauthItemLaterality',
            'CarePreauthStatus',
            'CareProgramEnrolleeStatus',
            'CareProgramGoalPriority',
            'CareProgramGoalStatus',
            'CareProgramProductStatus',
            'CareProgramProviderRole',
            'CareProgramProviderStatus',
            'CareProgramStatus',
            'CareProgramTeamMemberRole',
            'CareQuantityType',
            'CareRegisteredDeviceStatus',
            'CareRequestExtensionAmbulanceTransportReason',
            'CareRequestExtensionAmbulanceTransportType',
            'CareRequestExtensionNursingHomeResidentialStatus',
            'CareRequestExtensionRequestType',
            'CareRequestExtensionServiceLevel',
            'CareRequestMemberGender',
            'CareRequestMemberPrognosis',
            'CareRequestQuantityType',
            'CareRequestReviewerStatus',
            'CareSpecialtySpecialtyType',
            'CareSpecialtySpecialtyUsage',
            'CareTaxonomyTaxonomyType',
            'CareTeamStatus',
            'CaseContactRole',
            'CaseEpisodeSubType',
            'CaseEpisodeType',
            'CaseOrigin',
            'CasePriority',
            'CaseReason',
            'CaseServicePlanStatus',
            'CaseStatus',
            'CaseType',
            'ChangeRequestBusinessReason',
            'ChangeRequestCategory',
            'ChangeRequestImpact',
            'ChangeRequestPriority',
            'ChangeRequestRelatedItemImpactLevel',
            'ChangeRequestRiskLevel',
            'ChangeRequestStatus',
            'ClassRankReportingFormat',
            'ClassRankWeightingType',
            'ClinicalAlertCategories',
            'ClinicalAlertStatus',
            'ClinicalCaseType',
            'ClinicalDetectedIssueSeverityLevel',
            'ClinicalDetectedIssueStatus',
            'CodeSetCodeSetType',
            'CommunicationChannel',
            'CompanyRelationshipType',
            'ComplaintSourceType',
            'ComplianceGroup',
            'ConsequenceOfFailure',
            'ContactPointAddressType',
            'ContactPointUsageType',
            'ContactRequestReason',
            'ContactRequestRequestedChannel',
            'ContactRequestStatus',
            'ContactRole',
            'ContractContactRole',
            'ContractLineItemStatus',
            'ContractStatus',
            'CurrentLevelOfCare',
            'DChecklistItemStatus',
            'DEISumDiversityCategory',
            'DEInclSumDiversityType',
            'DEInclSumEmployeeType',
            'DEInclSumEmploymentType',
            'DEInclSumGender',
            'DIssueDetailType',
            'DSDDocumentRelationType',
            'DSDocumentStage',
            'DSummaryDetailDetailType',
            'DSummaryUsageType',
            'DecisionReason',
            'DeniedLevelOfCare',
            'DiagnosisCodeType',
            'DiagnosticSummaryCategory',
            'DiagnosticSummaryStatus',
            'DigitalAssetStatus',
            'DigitalSignatureType',
            'DischargeDiagnosisCodeType',
            'DivrsEquityInclSumLocation',
            'DivrsEquityInclSumRace',
            'DrugClinicalDetermination',
            'EBSEmployeeBenefitType',
            'EBSPercentageCalcType',
            'EBSummaryBenefitUsage',
            'EBSummaryEmploymentType',
            'ECTypeContactPointType',
            'EDSumEmployeeType',
            'EDSumEmploymentType',
            'EDSumProgramCategory',
            'EDemographicSumAgeGroup',
            'EDemographicSumGender',
            'EDemographicSumRegion',
            'EDemographicSumReportType',
            'EDemographicSumWorkType',
            'EDevelopmentSumGender',
            'EEligibilityCriteriaStatus',
            'EPSumMarket',
            'EPSumPerformanceCategory',
            'EPSumPerformanceType',
            'EPSumRegion',
            'ERCompanyBusinessRegion',
            'ERCompanySector',
            'ERTTargetSettingMethod',
            'ERTargetOtherTargetKpi',
            'EReductionTargetTargetType',
            'EducationLevel',
            'EmploymentOccupation',
            'EmploymentStatus',
            'EngagementAttendeeRole',
            'EngagementSentimentEnum',
            'EngagementStatusEnum',
            'EngagementTypeEnum',
            'EnrolleeOptOutReasonType',
            'EnrollmentStatus',
            'EntitlementType',
            'EventSubject',
            'EventType',
            'FacilityRoomBedType',
            'FieldBusinessStatus',
            'FinalLevelOfCare',
            'FinanceEventAction',
            'FinanceEventType',
            'FiscalYearPeriodName',
            'FiscalYearPeriodPrefix',
            'FiscalYearQuarterName',
            'FiscalYearQuarterPrefix',
            'ForecastCategoryName',
            'ForecastingItemCategory',
            'FreightHaulingMode',
            'FtprntAuditApprovalStatus',
            'FulfillmentStatus',
            'FulfillmentType',
            'GADetailDetailType',
            'GCMRelationshipType',
            'Gender',
            'GoalAssignmentProgressionStatus',
            'GoalAssignmentStatus',
            'GoalDefinitionCategory',
            'GoalDefinitionUsageType',
            'GovtFinancialAsstSumType',
            'GpaWeightingType',
            'GrievanceType',
            'HCFacilityLocationType',
            'HFNetworkGenderRestriction',
            'HFNetworkPanelStatus',
            'HPFGenderRestriction',
            'HPFTerminationReason',
            'HPSpecialtySpecialtyRole',
            'HPayerNetworkNetworkType',
            'HPayerNwkLineOfBusiness',
            'HProviderNpiNpiType',
            'HProviderProviderClass',
            'HProviderProviderType',
            'HSActionLogActionStatus',
            'HcpCategory',
            'HcpCodeType',
            'HealthCareDiagnosisCategory',
            'HealthCareDiagnosisCodeType',
            'HealthCareDiagnosisGender',
            'HealthConditionDetailType',
            'HealthConditionSeverity',
            'HealthConditionStatus',
            'HealthConditionType',
            'HealthDiagnosticStatus',
            'HealthcareProviderStatus',
            'IAItemStatus',
            'IARejectionReason',
            'IAServiceType',
            'IFnolChannel',
            'IPCBenefitPaymentFrequency',
            'IPCCategory',
            'IPCCategoryGroup',
            'IPCDeathBenefitOptionType',
            'IPCIncomeOptionType',
            'IPCLimitRange',
            'IPCancelationReasonType',
            'IPOwnerPOwnerType',
            'IPPRelationshipToInsured',
            'IPParticipantRole',
            'IPolicyAuditTerm',
            'IPolicyChangeSubType',
            'IPolicyChangeType',
            'IPolicyChannel',
            'IPolicyPlanTier',
            'IPolicyPlanType',
            'IPolicyPolicyType',
            'IPolicyPremiumCalcMethod',
            'IPolicyPremiumFrequency',
            'IPolicyPremiumPaymentType',
            'IPolicyStatus',
            'IPolicySubStatusCode',
            'IPolicyTerm',
            'IPolicyTransactionStatus',
            'IPolicyTransactionType',
            'IaApplnStatus',
            'IaAuthCategory',
            'IaInternalStatus',
            'IdDocumentType',
            'IdeaCategory',
            'IdeaMultiCategory',
            'IdeaStatus',
            'IdeaThemeStatus',
            'IdentifierIdUsageType',
            'IncidentCategory',
            'IncidentImpact',
            'IncidentPriority',
            'IncidentRelatedItemImpactLevel',
            'IncidentRelatedItemImpactType',
            'IncidentReportedMethod',
            'IncidentStatus',
            'IncidentSubCategory',
            'IncidentType',
            'IncidentUrgency',
            'Industry',
            'InterventionCodeType',
            'LPEVerificationStatus',
            'LPIApplnCategory',
            'LPIApplnStatus',
            'LPIIncomeFrequency',
            'LPIIncomeStatus',
            'LPIIncomeType',
            'LPIVerificationStatus',
            'LeadSource',
            'LeadStatus',
            'LicenseClassType',
            'LifeEventEventType',
            'LineOfAuthorityType',
            'LocationType',
            'MRequestPriority',
            'MRequestStatus',
            'MRequestTherapyDuration',
            'MRequestType',
            'MStatementDeliverySetting',
            'MStatementDetailType',
            'MaritalStatus',
            'MedReviewRepresentativeType',
            'MedTherapyReviewSubtype',
            'MedicationCategoryEnum',
            'MedicationDispenseMedAdministrationSettingCategory',
            'MedicationDispenseStatus',
            'MedicationDispenseSubstitutionReason',
            'MedicationDispenseSubstitutionType',
            'MedicationStatementStatus',
            'MedicationStatus',
            'MemberPlanPriSecTer',
            'MemberPlanPrimarySecondaryTertiary',
            'MemberPlanRelToSub',
            'MemberPlanStatus',
            'MemberPlanVerificStatus',
            'MilitaryService',
            'ModifiedCareCodeType',
            'ModifiedDiagnosisCodeType',
            'ModifiedDrugCodeType',
            'ModifiedLevelOfCare',
            'OISCorrectiveActionType',
            'OISummaryIncidentSubtype',
            'OISummaryIncidentType',
            'OISummaryPenaltyType',
            'OIncidentSummaryHazardType',
            'OcrService',
            'OcrStatus',
            'OpportunityCompetitor',
            'OpportunityStage',
            'OpportunityType',
            'OrderItemSummaryChgRsn',
            'OrderStatus',
            'OrderSummaryRoutingSchdRsn',
            'OrderSummaryStatus',
            'OrderType',
            'PEFEFctrDataSourceType',
            'PERecurrenceInterval',
            'PFAOwnershipTypeEnum',
            'PFAStatusEnum',
            'PFATypeEnum',
            'PFAVerificationStatusEnum',
            'PHealthReactionSeverity',
            'PIVOverriddenResult',
            'PIVResultOverrideReason',
            'PIVSVerificationDecision',
            'PIVerificationStepStatus',
            'PIVerificationStepType',
            'PIVerificationVerifiedBy',
            'PIdentityVerificationResult',
            'PIdentityVerificationStatus',
            'PMDDosageDefinitionType',
            'PMDosageDosageAmountType',
            'PMDosageRateType',
            'PMPDetailDetailType',
            'PMPOutcome',
            'PMPStatus',
            'PPCreditScoreProvider',
            'PPPrimaryIdentifierType',
            'PPROverridenRiskCategory',
            'PPTaxIdentificationType',
            'PProfileAddressAddressType',
            'PProfileCountryOfDomicile',
            'PProfileEmploymentIndustry',
            'PProfileNationality',
            'PProfileOffBoardingReason',
            'PProfileRiskRiskCategory',
            'PRStatus',
            'PSSResultOverrideReason',
            'PSStepMatchedFieldList',
            'PSSummaryScreenedBy',
            'PSSummaryScreeningDecision',
            'PScreeningStepResultCode',
            'PScreeningStepStatus',
            'PSearchSyncLogSyncStatus',
            'ParProvider',
            'PartnerRole',
            'PartyExpenseStatus',
            'PartyExpenseType',
            'PartyProfileCountryofBirth',
            'PartyProfileEmploymentType',
            'PartyProfileFundSource',
            'PartyProfileGender',
            'PartyProfileResidentType',
            'PartyProfileReviewDecision',
            'PartyProfileRiskType',
            'PartyProfileStage',
            'PartyScreeningStepType',
            'PartyScreeningSummaryStatus',
            'PatientImmunizationStatus',
            'PaymentMandateAccountType',
            'PaymentMandateAuthorizationType',
            'PaymentMandateMandateFrequency',
            'PaymentMandateMandateStatus',
            'PaymentMandateMandateType',
            'PersonEmploymentType',
            'PersonLanguageLanguage',
            'PersonLanguageSpeakingProficiencyLevel',
            'PersonLanguageWritingProficiencyLevel',
            'PersonNameNameUsageType',
            'PersonVerificationStatus',
            'PlaceOfService',
            'PlanBenefitStatus',
            'ProblemCategory',
            'ProblemDefinitionCategory',
            'ProblemDefinitionPriority',
            'ProblemDefinitionUsageTypeEnum',
            'ProblemImpact',
            'ProblemPriority',
            'ProblemRelatedItemImpactLevel',
            'ProblemRelatedItemImpactType',
            'ProblemStatus',
            'ProblemSubCategory',
            'ProblemUrgency',
            'ProcessExceptionCategory',
            'ProcessExceptionPriority',
            'ProcessExceptionSeverity',
            'ProcessExceptionStatus',
            'ProdRequestLineItemStatus',
            'Product2Family',
            'ProductFeeFrequency',
            'ProductFeeType',
            'ProductLineEnum',
            'ProductRequestShipmentType',
            'ProductRequestStatus',
            'ProgressionCriteriaMet',
            'PtyFinclLiabilityShareType',
            'PtyFinclLiabilityStatus',
            'PtyFinclLiabilityType',
            'PtyFinclLiabilityVerficationStatus',
            'PurchaserPlanAffiliation',
            'PurchaserPlanAssoRole',
            'PurchaserPlanAssoStatus',
            'PurchaserPlanStatus',
            'PurchaserPlanType',
            'QuantityUnitOfMeasure',
            'QuestionOrigin',
            'QuickTextCategory',
            'QuickTextChannel',
            'QuoteStatus',
            'RLAAmortType',
            'RLAAppStatus',
            'RLAAppliedFor',
            'RLAEstateType',
            'RLALoanPurpose',
            'RLAMortLienType',
            'RLANativeTenure',
            'RLAProjectType',
            'RLARefProgType',
            'RLARefinanceType',
            'RLATitleType',
            'RLATrustType',
            'ReceivedDocumentDirection',
            'ReceivedDocumentOcrStatus',
            'ReceivedDocumentPriority',
            'ReceivedDocumentStatus',
            'RegAuthCategory',
            'RegulatoryBodyType',
            'ReopenReason',
            'RequestPractitionerLicense',
            'RequestPractitionerSpecialty',
            'RequestedCareCodeType',
            'RequestedDrugCodeType',
            'RequestedLevelOfCare',
            'RequesterType',
            'RequestingPractitionerLicense',
            'RequestingPractitionerSpecialty',
            'ResidenceStatusType',
            'ResourceAbsenceType',
            'ReturnOrderLineItemProcessPlan',
            'ReturnOrderLineItemReasonForRejection',
            'ReturnOrderLineItemReasonForReturn',
            'ReturnOrderLineItemRepaymentMethod',
            'ReturnOrderShipmentType',
            'ReturnOrderStatus',
            'RoleInTerritory',
            'SAppointmentGroupStatus',
            'SContributionSumCategory',
            'SalesTeamRole',
            'Salutation',
            'ScienceBasedTargetStatus',
            'Scope3CrbnFtprntStage',
            'ScorecardMetricCategory',
            'SecurityClassification',
            'ServTerrMemRoleType',
            'ServiceAppointmentStatus',
            'ServiceContractApprovalStatus',
            'ServicePlanTemplateStatus',
            'ServicePractitionerSpecialty',
            'ServicingPractitionerLicense',
            'ServicingPractitionerSpecialty',
            'ShiftStatus',
            'SocialContributionSumType',
            'SocialPostClassification',
            'SocialPostEngagementLevel',
            'SocialPostReviewedStatus',
            'SolutionStatus',
            'SourceBusinessRegion',
            'StatusReason',
            'StnryAssetCrbnFtprntStage',
            'StnryAssetWaterFtprntStage',
            'StnryAstCrbnFtAllocStatus',
            'StnryAstCrbnFtDataGapSts',
            'StnryAstEvSrcStnryAstTyp',
            'SupplierClassification',
            'SupplierEmssnRdctnCmtTypev',
            'SupplierReportingScope',
            'SupplierTier',
            'SustainabilityScorecardStatus',
            'TCDDetailType',
            'TCPriority',
            'TCStatus',
            'TCStatusReason',
            'TaskPriority',
            'TaskStatus',
            'TaskSubject',
            'TaskType',
            'TopicFailureReasonEnum',
            'TopicProcessStatusEnum',
            'TrackedCommunicationType',
            'TypesOfIntervention',
            'UnitOfMeasure',
            'UnitOfMeasureType',
            'VehicleAstCrbnFtprntStage',
            'VehicleType',
            'VisitPriority',
            'WasteDisposalType',
            'WasteFootprintStage',
            'WasteType',
            'WorkOrderLineItemPriority',
            'WorkOrderLineItemStatus',
            'WorkOrderPriority',
            'WorkOrderStatus',
            'WorkStepStatus',
            'WorkTypeDefApptType',
            'WorkTypeGroupAddInfo'
        };
        for (Custom_Component__c ccmp : [
            SELECT Id, Component_Name__c
            FROM Custom_Component__c
            WHERE Component_Type__c = 'StandardValueSet'
            WITH SECURITY_ENFORCED
        ]) {
            stdSet.add(ccmp.Component_Name__c);
        }
        return stdSet;
    }

    public final static Set<String> innerTypesSet = new Set<String>{
        'ActionOverride',
        'BusinessProcess',
        'CompactLayout',
        'CustomField',
        'FieldSet',
        'HistoryRetentionPolicy',
        'ListView',
        'RecordType',
        'SearchLayouts',
        'SharingReason',
        'SharingRecalculation',
        'ValidationRule',
        'WebLink',
        'SharingCriteriaRule',
        'SharingGuestRule',
        'SharingOwnerRule',
        'SharingTerritoryRule',
        'WorkflowAlert',
        'WorkflowFieldUpdate',
        'WorkflowKnowledgePublish',
        'WorkflowOutboundMessage',
        'WorkflowRule',
        'WorkflowTask',
        'AssignmentRule',
        'EscalationRule',
        'CustomLabel'
    };
    public final static Map<String, String> childParentMap = new Map<String, String>{
        'AssignmentRule' => 'AssignmentRules',
        'AutoResponseRule' => 'AutoResponseRules',
        'BusinessProcess' => 'CustomObject',
        'CompactLayout' => 'CustomObject',
        'CustomField' => 'CustomObject',
        'CustomLabel' => 'CustomLabels',
        'EscalationRule' => 'EscalationRules',
        'FieldSet' => 'CustomObject',
        'ListView' => 'CustomObject',
        'ManagedTopic' => 'ManagedTopics',
        'MatchingRule' => 'MatchingRules',
        'RecordType' => 'CustomObject',
        'SharingCriteriaRule' => 'SharingRules',
        'SharingGuestRule' => 'SharingRules',
        'SharingOwnerRule' => 'SharingRules',
        'SharingReason' => 'CustomObject',
        'ValidationRule' => 'CustomObject',
        'WebLink' => 'CustomObject',
        'WorkflowAlert' => 'Workflow',
        'WorkflowFieldUpdate' => 'Workflow',
        'WorkflowKnowledgePublish' => 'Workflow',
        'WorkflowOutboundMessage' => 'Workflow',
        'WorkflowRule' => 'Workflow',
        'WorkflowTask' => 'Workflow'
    };

    public static final Map<String, String> metaTypeFolderMap = new Map<String, String>{
        'AccountRelationshipShareRule' => 'accountRelationshipShareRules',
        'ActionLinkGroupTemplate' => 'actionLinkGroupTemplates',
        'ActionPlanTemplate' => 'actionPlanTemplates',
        'AIApplication' => 'aiApplications',
        'AIApplicationConfig' => 'aiApplicationConfigs',
        'AnalyticSnapshot' => 'analyticSnapshots',
        'AnimationRule' => 'animationRules',
        'ArticleType' => 'objects',
        'ApexClass' => 'classes',
        'ApexComponent' => 'components',
        'ApexEmailNotifications' => 'apexEmailNotifications',
        'ApexPage' => 'pages',
        'ApexTestSuite' => 'testSuites',
        'ApexTrigger' => 'triggers',
        'AppMenu' => 'appMenus',
        'AppointmentAssignmentPolicy' => 'appointmentSchedulingPolicies',
        'AppointmentSchedulingPolicy' => 'appointmentSchedulingPolicies',
        'ApprovalProcess' => 'approvalProcesses',
        'AssignmentRules' => 'assignmentRules',
        'Audience' => 'audience',
        'AuraDefinitionBundle' => 'aura',
        'AuthProvider' => 'authproviders',
        'AutoResponseRules' => 'autoResponseRules',
        'BatchCalcJobDefinition' => 'batchCalcJobDefinitions',
        'BatchProcessJobDefinition' => 'batchProcessJobDefinitions',
        'Bot' => 'bots',
        'BotVersion' => 'bots',
        'BrandingSet' => 'brandingSets',
        'BriefcaseDefinition' => 'briefcaseDefinitions',
        'BusinessProcessGroup' => 'businessProcessGroups',
        'CallCenter' => 'callCenters',
        'CallCoachingMediaProvider' => 'CallCoachingMediaProvider',
        'CampaignInfluenceModel' => 'campaignInfluenceModels',
        'CaseSubjectParticle' => 'CaseSubjectParticles',
        'CareSystemFieldMapping' => 'careSystemFieldMappings',
        'CareProviderSearchConfig' => 'careProviderSearchConfigs',
        'Certificate' => 'certs',
        //            'ChatterExtension' => '', not found !!!
        'CleanDataService' => 'cleanDataServices',
        'CMSConnectSource' => 'cmsConnectSource',
        'Community' => 'communities', // In API version 28, the API object label has changed to Zone, but the API type is still Community !!!
        'Zone' => 'communities', // In API version 28, the API object label has changed to Zone, but the API type is still Community !!!
        'CommunityTemplateDefinition' => 'communityTemplateDefinitions',
        'CommunityThemeDefinition' => 'communityThemeDefinitions',
        'ConnectedApp' => 'connectedApps',
        'ContentAsset' => 'contentassets',
        'CorsWhitelistOrigin' => 'corswhitelistorigins',
        'CspTrustedSite' => 'cspTrustedSites',
        'CustomApplication' => 'applications',
        'CustomApplicationComponent' => 'customApplicationComponents',
        'CustomFeedFilter' => 'feedFilters',
        'CustomHelpMenuSection' => 'customHelpMenuSections',
        //            'CustomLabels' => '', not found, all custom labels store in 'labels/CustomLabels.labels' !!!
        'CustomMetadata' => 'objects',
        'CustomNotificationType' => 'notificationtypes',
        'CustomObject' => 'objects',
        'CustomObjectTranslation' => 'objectTranslations',
        'CustomPageWebLink' => 'weblinks',
        'CustomPermission' => 'customPermissions',
        'CustomSite' => 'sites',
        'CustomTab' => 'tabs',
        //            'CustomValue' => '', not found !!!
        'CustomTab' => 'dashboards',
        'DataCategoryGroup' => 'datacategorygroups',
        'DataCategoryGroup' => 'datacategorygroups',
        'DataPackageKitObject' => 'DataPackageKitObjects',
        'DataConnectorS3' => 's3DataConnectors',
        'DataSource' => 'mktDataSources',
        'DataSourceObject' => 'mktDataSourceObjects',
        'DataStreamDefinition' => 'dataStreamDefinitions',
        'Dashboard' => 'dashboards',
        'DecisionTable' => 'decisionTables',
        'DecisionTableDatasetLink' => 'decisionTableDatasetLinks',
        'DelegateGroup' => 'delegateGroups',
        'DiscoveryAIModel' => 'discovery',
        'DiscoveryGoal' => 'discovery',
        //            'Document' => 'DocumentFolder', // can be custom folder
        'DocumentFolder' => 'documents',
        'DuplicateRule' => 'duplicateRules',
        'EclairGeoData' => 'eclair',
        'EmailServicesFunction' => 'emailservices',
        'EmailTemplate' => 'email',
        'EmailFolder' => 'email',
        'EmbeddedServiceBranding' => 'EmbeddedServiceBranding',
        'EmbeddedServiceConfig' => 'EmbeddedServiceConfig',
        'EmbeddedServiceFieldService' => 'EmbeddedServiceFieldService',
        'EmbeddedServiceFlowConfig' => 'EmbeddedServiceFlowConfig',
        'EmbeddedServiceLiveAgent' => 'EmbeddedServiceLiveAgent',
        'EmbeddedServiceMenuSettings' => 'EmbeddedServiceMenuSettings',
        'EntitlementProcess' => 'entitlementProcesses',
        'EntitlementTemplate' => 'entitlementTemplates',
        'EscalationRules' => 'escalationRules',
        'EventDelivery' => 'eventDeliveries',
        'EventSubscription' => 'eventSubscriptions',
        //            'ExperienceBundle' => '', not found !!!
        'ExternalDataConnector' => 'externalDataConnectors',
        'ExternalDataSource' => 'dataSources',
        'ExternalServiceRegistration' => 'dataSources',
        'FeatureParameterBoolean' => 'featureParameters',
        'FeatureParameterDate' => 'featureParameters',
        'FeatureParameterInteger' => 'featureParameters',
        'FieldRestrictionRule' => 'fieldRestrictionRules',
        'FieldSrcTrgtRelationship' => 'fieldSrcTrgtRelationship',
        'FlexiPage' => 'flexipages',
        'Flow' => 'Flow',
        'FlowCategory' => 'flowCategories',
        'FlowDefinition' => 'flowDefinitions',
        //            'Folder' => '', can be documents, email, reports, and dashboards !!!
        'ForecastingSourceDefinition' => 'forecastingSourceDefinitions',
        'ForecastingType' => 'forecastingTypes',
        'ForecastingTypeSource' => 'ForecastingTypeSources',
        'FunctionReference' => 'functions',
        //            'GatewayProviderPaymentMethodType' => '', not found !!!
        'GlobalPicklist' => 'globalPicklist',
        //            'GlobalPicklistValue' => '', not found !!!
        'GlobalValueSet' => 'globalValueSets',
        'GlobalValueSetTranslation' => 'globalValueSetTranslations',
        'Group' => 'groups',
        'HomePageComponent' => 'homepagecomponents',
        'HomePageLayout' => 'homePageLayouts',
        'InboundCertificate' => 'inboundCertificates',
        'InboundNetworkConnection' => 'inboundNetworkConnections',
        'InstalledPackage' => 'installedPackages',
        'IPAddressRange' => 'IPAddressRanges',
        'KeywordList' => 'moderation',
        'Layout' => 'layouts',
        'Letterhead' => 'letterhead',
        'LightningBolt' => 'lightningBolts',
        //            'LightningComponentBundle' => '', not found !!!
        'LightningExperienceTheme' => 'lightningExperienceThemes',
        'LightningMessageChannel' => 'messageChannels',
        'LightningOnboardingConfig' => 'LightningOnboardingConfigs',
        'LiveChatAgentConfig' => 'liveChatAgentConfigs',
        'LiveChatButton' => 'liveChatButtons',
        'LiveChatDeployment' => 'liveChatDeployments',
        'LiveChatSensitiveDataRule' => 'liveChatSensitiveDataRule',
        'ManagedContentType' => 'managedContentTypes',
        'ManagedTopics' => 'managedTopics',
        'MatchingRule' => 'matchingRules',
        //            'Metadata' => '', not found !!!
        //            'MetadataWithContent' => '', not found !!!
        'MilestoneType' => 'milestoneTypes',
        'MlDomain' => 'mlDomains',
        'MktCalcInsightObjectDef' => 'mktCalcInsightObjectDefs',
        'MktDataTranObject' => 'mktDataTranObjects',
        'MLDataDefinition' => 'mlDataDefinitions',
        'MLPredictionDefinition' => 'mlPredictions',
        'MobileApplicationDetail' => 'MobileApplicationDetails',
        'ModerationRule' => 'moderation',
        'MutingPermissionSet' => 'mutingpermissionsets',
        'MyDomainDiscoverableLogin' => 'myDomainDiscoverableLogins',
        'NamedCredential' => 'namedCredentials',
        'NavigationMenu' => 'navigationMenus',
        'Network' => 'networks',
        'NetworkBranding' => 'networkBranding',
        'NotificationTypeConfig' => 'notificationTypeConfig',
        'OauthCustomScope' => 'oauthcustomscopes',
        'ObjectSourceTargetMap' => 'objectSourceTargetMaps',
        'OcrSampleDocument' => 'ocrSampleDocuments',
        'OcrTemplate' => 'ocrTemplates',
        'OutboundNetworkConnection' => 'outboundNetworkConnections',
        //            'Package' => '', not found !!!
        'PathAssistant' => 'pathAssistants',
        'PaymentGatewayProvider' => 'paymentGatewayProviders',
        //            'PermissionSet' => '', not found !!!
        'PermissionSetGroup' => 'permissionsetgroups',
        'PlatformCachePartition' => 'cachePartitions',
        'PlatformEventChannel' => 'platformEventChannels',
        'PlatformEventChannelMember' => 'platformEventChannelMembers',
        'PlatformEventSubscriberConfig' => 'PlatformEventSubscriberConfigs',
        'Portal' => 'portals',
        'PostTemplate' => 'postTemplates',
        'PresenceDeclineReason' => 'presenceDeclineReasons',
        'PresenceUserConfig' => 'presenceUserConfigs',
        'Profile' => 'profiles',
        //            'ProfileActionOverride' => '', not found, Profile-based action overrides are defined as part of a custom application or profile !!!
        'ProfilePasswordPolicy' => 'profilePasswordPolicies',
        'ProfileSessionSetting' => 'profileSessionSettings',
        'Prompt' => 'prompts',
        'Queue' => 'queues',
        'QueueRoutingConfig' => 'queueRoutingConfigs',
        'QuickAction' => 'quickActions',
        'RedirectWhitelistUrl' => 'redirectWhitelistUrls',
        'RecommendationStrategy' => 'recommendationStrategies',
        'RecordActionDeployment' => 'recordActionDeployments',
        'RemoteSiteSetting' => 'remoteSiteSettings',
        'Report' => 'reports', // can be custom folder
        'ReportFolder' => 'reports',
        'ReportType' => 'reportTypes',
        'RestrictionRule' => 'restrictionRules', // Beta
        'Role' => 'roles',
        //            'RoleOrTerritory' => '', not found !!!
        'SalesWorkQueueSettings' => 'salesworkqueuesettings',
        'SamlSsoConfig' => 'samlssoconfigs',
        'Scontrol' => 'scontrols',
        'ServiceAISetupDefinition' => 'serviceAISetupDescriptions',
        'ServiceChannel' => 'serviceChannels',
        'ServicePresenceStatus' => 'servicePresenceStatuses',
        'Settings' => 'settings',
        //            'SharedTo' => '', not found !!!
        //            'SharingBaseRule' => '', not found !!!
        'SharingRules' => 'sharingRules', // need to be careful !!!
        'SharingCriteriaRule' => 'sharingRules', // need to be careful !!!
        'SharingOwnerRule' => 'sharingRules', // need to be careful !!!
        'SharingGuestRule' => 'sharingRules', // need to be careful !!!
        'SharingSet' => 'sharingSets',
        'SiteDotCom' => 'siteDotComSites',
        'Skill' => 'skills',
        'StandardValueSet' => 'standardValueSets',
        'StandardValueSetTranslation' => 'standardValueSetTranslations',
        'StaticResource' => 'staticresources',
        'SynonymDictionary' => 'synonymDictionaries',
        'Territory' => 'territories',
        'Territory2' => 'territories', //need to be careful, stored in the territories folder under the folder for the corresponding Territory2Model !!!
        'Territory2Model' => 'territory2Models',
        'Territory2Rule' => 'rules', //need to be careful, stored in the rules folder under the folder for the corresponding Territory2Model !!!
        'Territory2Type' => 'territory2Types',
        'TimeSheetTemplate' => 'timeSheetTemplates',
        'TopicsForObjects' => 'topicsForObjects',
        'TransactionSecurityPolicy' => 'transactionSecurityPolicies',
        'Translations' => 'translations',
        'UserAuthCertificate' => 'userAuthCertificates',
        'UserCriteria' => 'UserCriteria',
        'UserProvisioningConfig' => 'UserProvisioningConfigs',
        'WaveApplication' => 'wave',
        'WaveDataflow' => 'wave',
        'WaveDashboard' => 'wave',
        'WaveDataset' => 'wave',
        'WaveLens' => 'wave',
        'WaveRecipe' => 'wave',
        'WaveTemplateBundle' => 'waveTemplates',
        'WaveXmd' => 'wave',
        'WebStoreTemplate' => 'webstoretemplate',
        'Workflow' => 'workflows',
        'WorkSkillRouting' => 'workSkillRoutings',
        'GenAiFunction' => 'genAiFunctions',
        'GenAiPlanner' => 'genAiPlanners',
        'GenAiPlugin' => 'genAiPlugins',
        'GenAiPromptTemplateActv' => 'genAiPromptTemplateActivations',
        'GenAiPromptTemplate' => 'genAiPromptTemplates'
    };

    public static final Map<String, String> metaTypeSuffixMap = new Map<String, String>{
        'AccountRelationshipShareRule' => 'accountRelationshipShareRule',
        'ActionLinkGroupTemplate' => 'actionLinkGroupTemplate',
        'ActionPlanTemplate' => 'apt',
        'AIApplication' => 'ai',
        'AIApplicationConfig' => 'aiapplicationconfig',
        'AnalyticSnapshot' => 'snapshot',
        'AnimationRule' => 'animationRule',
        'ArticleType' => '__kav', //need to be careful, example: newarticle__kav.description__c !!!
        'ApexClass' => 'cls',
        'ApexComponent' => 'component',
        'ApexEmailNotifications' => 'notifications', // example: apexEmailNotifications.notifications
        'ApexPage' => 'page',
        'ApexTestSuite' => 'testSuite',
        'ApexTrigger' => 'trigger',
        'AppMenu' => 'appMenu',
        'AppointmentAssignmentPolicy' => 'policy',
        'AppointmentSchedulingPolicy' => 'policy',
        'ApprovalProcess' => 'approvalProcess',
        'AssignmentRules' => 'assignmentRules', // For example, all Case assignment rules are stored in the Case.assignmentRules file.
        'Audience' => 'audience',
        //            'AuraDefinitionBundle' => ''  can be 'app','cmp','design','evt','intf','js','svg','css','auradoc','tokens' !!!
        'AuthProvider' => 'authprovider',
        'AutoResponseRules' => 'autoResponseRules',
        'BatchCalcJobDefinition' => 'batchCalcJobDefinition',
        'BatchProcessJobDefinition' => 'batchProcessJobDefinition',
        'Bot' => 'bot',
        'BotVersion' => 'bot',
        'BrandingSet' => 'brandingSet',
        'BriefcaseDefinition' => 'briefcaseDefinition',
        'BusinessProcessGroup' => 'businessProcessGroup',
        'CallCenter' => 'callCenter',
        'CallCoachingMediaProvider' => 'callCoachingMediaProvider',
        'CampaignInfluenceModel' => 'campaignInfluenceModel',
        'CaseSubjectParticle' => 'CaseSubjectParticle',
        'CareSystemFieldMapping' => 'careSystemFieldMapping',
        'CareProviderSearchConfig' => 'careProviderSearchConfig',
        'Certificate' => 'crt',
        //            'ChatterExtension' => '', not found !!!
        'CleanDataService' => 'cleanDataService',
        'CMSConnectSource' => 'cmsConnectSource',
        'Community' => 'community', // In API version 28, the API object label has changed to Zone, but the API type is still Community !!!
        'Zone' => 'community', // In API version 28, the API object label has changed to Zone, but the API type is still Community !!!
        'CommunityTemplateDefinition' => 'communityTemplateDefinition',
        'CommunityThemeDefinition' => 'communityThemeDefinition',
        'ConnectedApp' => 'connectedApp',
        'ContentAsset' => 'asset',
        'CorsWhitelistOrigin' => 'corswhitelistorigin',
        'CspTrustedSite' => 'cspTrustedSite',
        'CustomApplication' => 'app',
        'CustomApplicationComponent' => 'customApplicationComponent',
        'CustomFeedFilter' => 'feedFilter',
        'CustomHelpMenuSection' => 'customHelpMenuSection',
        //            'CustomLabels' => '', not found, all custom labels store in 'labels/CustomLabels.labels' !!!
        'CustomMetadata' => '__mdt', // need to be careful !!!
        'CustomNotificationType' => 'notiftype',
        'CustomObject' => 'object',
        'CustomObjectTranslation' => 'objectTranslation', // need to be careful !!!
        'CustomPageWebLink' => 'weblink',
        'CustomPermission' => 'customPermission',
        'CustomSite' => 'site',
        'CustomTab' => 'tab',
        'CustomValue' => 'customValue',
        'Dashboard' => 'dashboard',
        'DataCategoryGroup' => 'datacategorygroup',
        'DataPackageKitObject' => 'DataPackageKitObject',
        'DataConnectorS3' => 's3DataConnector',
        'DataSource' => 'dataSource',
        'DataSourceObject' => 'dataSourceObject',
        'DataStreamDefinition' => 'dataStreamDefinition',
        'DecisionTable' => 'decisionTable',
        'DecisionTableDatasetLink' => 'decisionTableDatasetLink',
        'DelegateGroup' => 'delegateGroup',
        'DiscoveryAIModel' => 'model',
        'DiscoveryGoal' => 'goal',
        //            'Document' => '', can be different suffixes
        'DuplicateRule' => 'duplicateRule',
        'EclairGeoData' => 'geodata',
        'EmailServicesFunction' => 'xml',
        'EmailTemplate' => 'email',
        //            'EmbeddedServiceBranding' => '', not found !!!
        //            'EmbeddedServiceConfig' => '', not found !!!
        //            'EmbeddedServiceFieldService' => '', not found !!!
        //            'EmbeddedServiceFlowConfig' => '', not found !!!
        //            'EmbeddedServiceLiveAgent' => '', not found !!!
        //            'EmbeddedServiceMenuSettings' => '', not found !!!
        'EntitlementProcess' => 'entitlementProcess', // need to be careful !!!
        'EntitlementTemplate' => 'entitlementTemplate',
        'EscalationRules' => 'escalationRules',
        'EventDelivery' => 'delivery',
        'EventSubscription' => 'subscription',
        'ExperienceBundle' => 'json', // need to be careful !!!
        'ExternalDataConnector' => 'externalDataConnector',
        'ExternalDataSource' => 'dataSource',
        'ExternalServiceRegistration' => 'dataSource',
        'FeatureParameterBoolean' => 'featureParameterBoolean',
        'FeatureParameterDate' => 'featureParameterDate',
        'FeatureParameterInteger' => 'featureParameterInteger',
        'FieldRestrictionRule' => 'rule',
        'FieldSrcTrgtRelationship' => 'fieldSrcTrgtRelationship',
        'FlexiPage' => 'flow',
        'FlowCategory' => 'flowCategory',
        'FlowDefinition' => 'flowDefinition',
        'Folder' => '-meta.xml', // need be careful !!!
        'ForecastingSourceDefinition' => 'forecastingSourceDefinition',
        'ForecastingType' => 'forecastingType',
        'ForecastingTypeSource' => 'forecastingTypeSource',
        'FunctionReference' => 'functions',
        //            'GatewayProviderPaymentMethodType' => '', not found !!!
        'GlobalPicklist' => 'globalPicklist',
        //            'GlobalPicklistValue' => '', not found !!!
        'GlobalValueSet' => 'globalValueSet',
        'GlobalValueSetTranslation' => 'globalValueSetTranslation', // need be careful !!!
        'Group' => 'group',
        'HomePageLayout' => 'homePageLayout',
        'InboundCertificate' => 'inboundCertificate',
        'InboundNetworkConnection' => 'inboundNetworkConnection',
        'InstalledPackage' => 'installedPackage', // need be careful !!!
        'IPAddressRange' => 'IPAddressRange',
        'KeywordList' => 'keywords',
        'Layout' => 'layout',
        'Letterhead' => 'letter',
        'LightningBolt' => 'lightningBolt',
        //            'LightningComponentBundle' => '', not found !!!
        'LightningExperienceTheme' => 'lightningExperienceTheme',
        'LightningMessageChannel' => 'messageChannel',
        'LightningOnboardingConfig' => 'lightningOnboardingConfig',
        'LiveChatAgentConfig' => 'liveChatAgentConfig',
        'LiveChatButton' => 'liveChatButton',
        'LiveChatDeployment' => 'liveChatDeployment',
        'LiveChatSensitiveDataRule' => 'liveChatSensitiveDataRule',
        'ManagedContentType' => 'managedContentType',
        'ManagedTopics' => 'managedTopics',
        'MatchingRule' => 'matchingRule',
        //            'Metadata' => '', not found !!!
        //            'MetadataWithContent' => '', not found !!!
        'MilestoneType' => 'milestoneType',
        'MlDomain' => 'mlDomain',
        'MktCalcInsightObjectDef' => 'mktCalcInsightObjectDef',
        'MktDataTranObject' => 'mktDataTranObject',
        'MLDataDefinition' => 'mlDataDefinition',
        'MLPredictionDefinition' => 'mlPrediction',
        'MobileApplicationDetail' => 'MobileApplicationDetail',
        'ModerationRule' => 'rule', // need be careful !!!
        'MutingPermissionSet' => 'mutingpermissionset',
        'MyDomainDiscoverableLogin' => 'myDomainDiscoverableLogin',
        'NamedCredential' => 'namedCredential',
        'NavigationMenu' => 'navigationMenu',
        'Network' => 'network',
        'NetworkBranding' => 'networkBranding',
        'NotificationTypeConfig' => 'config',
        'OauthCustomScope' => 'oauthcustomscope',
        'ObjectSourceTargetMap' => 'objectSourceTargetMap',
        'OcrSampleDocument' => 'ocrSampleDocument',
        'OcrTemplate' => 'ocrTemplate',
        'OutboundNetworkConnection' => 'outboundNetworkConnection',
        //            'Package' => '', not found !!!
        'PathAssistant' => 'pathAssistant',
        'PaymentGatewayProvider' => 'paymentGatewayProvider',
        //            'PermissionSet' => '', not found !!!
        'PermissionSetGroup' => 'permissionsetgroup',
        'PlatformCachePartition' => 'cachePartition',
        'PlatformEventChannel' => 'platformEventChannel',
        'PlatformEventChannelMember' => 'platformEventChannelMember',
        'PlatformEventSubscriberConfig' => 'platformEventSubscriberConfig',
        'Portal' => 'portal',
        'PostTemplate' => 'postTemplate',
        'PresenceDeclineReason' => 'presenceDeclineReason',
        'PresenceUserConfig' => 'presenceUserConfig',
        'Profile' => 'profile',
        //            'ProfileActionOverride' => '', not found, Profile-based action overrides are defined as part of a custom application or profile !!!
        'ProfilePasswordPolicy' => 'profilePasswordPolicy',
        'ProfileSessionSetting' => 'profileSessionSetting',
        'Prompt' => 'prompt',
        'Queue' => 'queue',
        'QueueRoutingConfig' => 'queueRoutingConfig',
        'QuickAction' => 'quickAction',
        'RedirectWhitelistUrl' => 'redirectWhitelistUrl',
        'RecommendationStrategy' => 'recommendationStrategy',
        'RecordActionDeployment' => 'deployment', // need to be careful !!!
        'RemoteSiteSetting' => 'remoteSite',
        'Report' => 'report',
        'ReportType' => 'reportType',
        'RestrictionRule' => 'rule', // Beta
        'Role' => 'role',
        //            'RoleOrTerritory' => '', not found !!!
        'SalesWorkQueueSettings' => 'salesworkqueuesetting',
        'SamlSsoConfig' => 'samlssoconfig',
        'Scontrol' => 'scf',
        'ServiceAISetupDefinition' => 'serviceAISetupDescription',
        'ServiceChannel' => 'serviceChannel',
        'ServicePresenceStatus' => 'servicePresenceStatus',
        'Settings' => 'settings', // need to be careful !!!
        //            'SharedTo' => '', not found !!!
        //            'SharingBaseRule' => '', not found !!!
        'SharingRules' => 'sharingRules', // need to be careful !!!
        'SharingSet' => 'sharingSet',
        'SiteDotCom' => 'site', // need to be careful !!!
        'Skill' => 'skill',
        'StandardValueSet' => 'standardValueSet',
        'SharingCriteriaRule' => 'sharingRules',
        'SharingOwnerRule' => 'sharingRules',
        'SharingGuestRule' => 'sharingRules',
        'StandardValueSetTranslation' => 'standardValueSetTranslation', //need to be careful !!!
        'StaticResource' => 'resource',
        'SynonymDictionary' => 'synonymDictionary',
        'Territory' => 'territory',
        'Territory2' => 'territory2',
        'Territory2Model' => 'territory2Rule',
        'Territory2Type' => 'territory2Type',
        'TimeSheetTemplate' => 'timeSheetTemplate',
        'TopicsForObjects' => 'topicsForObjects',
        'TransactionSecurityPolicy' => 'transactionSecurityPolicy',
        'Translations' => 'translation', // need to be careful !!!
        'UserAuthCertificate' => 'userAuthCertificate',
        'UserCriteria' => 'userCriteria', // need to be careful !!!
        'UserProvisioningConfig' => 'userProvisioningConfig',
        'WaveApplication' => 'wapp',
        'WaveDataflow' => 'wdf',
        'WaveDashboard' => 'wdash',
        'WaveDataset' => 'wds',
        'WaveLens' => 'wlens',
        'WaveRecipe' => 'wdpr',
        //            'WaveTemplateBundle' => '', not found !!!
        'WaveXmd' => 'xmd',
        'WebStoreTemplate' => 'webstoretemplate',
        'Workflow' => 'workflow',
        'WorkSkillRouting' => 'workSkillRouting'
    };

    public static Map<String, String> encodingSymbolMap = new Map<String, String>{
        '%' => '%25', // should be first to avoid encoding '%' in already encoded symbols
        '!' => '%21',
        '"' => '%22',
        '#' => '%23',
        '$' => '%24',
        '&' => '%26',
        '\'' => '%27',
        '(' => '%28',
        ')' => '%29',
        //'*' => '%2A',
        '+' => '%2B',
        ',' => '%2C',
        '/' => '%2F',
        ':' => '%3A',
        ';' => '%3B',
        '<' => '%3C',
        '=' => '%3D',
        '>' => '%3E',
        '?' => '%3F',
        '@' => '%40',
        '[' => '%5B',
        '\\' => '%5C',
        ']' => '%5D',
        '^' => '%5E',
        '`' => '%60'
    };

    public static Set<String> bestPracticesRuleSet = new Set<String>{
        'ApexAssertionsShouldIncludeMessage',
        'ApexUnitTestClassShouldHaveAsserts',
        'ApexUnitTestClassShouldHaveRunAs',
        'ApexUnitTestMethodShouldHaveIsTestAnnotation',
        'ApexUnitTestShouldNotUseSeeAllDataTrue',
        'AvoidGlobalModifier',
        'AvoidLogicInTrigger',
        'DebugsShouldUseLoggingLevel',
        'QueueableWithoutFinalizer',
        'UnusedLocalVariable'
    };

    public static Set<String> codeStyleRuleSet = new Set<String>{
        'ClassNamingConventions',
        'FieldDeclarationsShouldBeAtStart',
        'FieldNamingConventions',
        'ForLoopsMustUseBraces',
        'FormalParameterNamingConventions',
        'IfElseStmtsMustUseBraces',
        'IfStmtsMustUseBraces',
        'LocalVariableNamingConventions',
        'MethodNamingConventions',
        'OneDeclarationPerLine',
        'PropertyNamingConventions',
        'WhileLoopsMustUseBraces'
    };
    public static Set<String> designRuleSet = new Set<String>{
        'AvoidDeeplyNestedIfStmts',
        'CognitiveComplexity',
        'CyclomaticComplexity',
        'ExcessiveClassLength',
        'ExcessiveParameterList',
        'ExcessivePublicCount',
        'NcssConstructorCount',
        'NcssMethodCount',
        'NcssTypeCount',
        'StdCyclomaticComplexity',
        'TooManyFields',
        'UnusedMethod'
    };
    public static Set<String> documentationRuleSet = new Set<String>{ 'ApexDoc' };
    public static Set<String> errorProneRuleSet = new Set<String>{
        'ApexCSRF',
        'AvoidDirectAccessTriggerMap',
        'AvoidHardcodingId',
        'AvoidNonExistentAnnotations',
        'AvoidStatefulDatabaseResult',
        'EmptyCatchBlock',
        'EmptyIfStmt',
        'EmptyStatementBlock',
        'EmptyTryOrFinallyBlock',
        'EmptyWhileStmt',
        'InaccessibleAuraEnabledGetter',
        'MethodWithSameNameAsEnclosingClass',
        'OverrideBothEqualsAndHashcode',
        'TestMethodsMustBeInTestClasses',
        'TypeShadowsBuiltInNamespace'
    };
    public static Set<String> performanceRuleSet = new Set<String>{
        'AvoidDebugStatements',
        'AvoidNonRestrictiveQueries',
        'EagerlyLoadedDescribeSObjectResult',
        'OperationWithHighCostInLoop',
        'OperationWithLimitsInLoop'
    };
    public static Set<String> securityRuleSet = new Set<String>{
        'ApexBadCrypto',
        'ApexCRUDViolation',
        'ApexDangerousMethods',
        'ApexInsecureEndpoint',
        'ApexOpenRedirect',
        'ApexSharingViolations',
        'ApexSOQLInjection',
        'ApexSuggestUsingNamedCred',
        'ApexXSSFromEscapeFalse',
        'ApexXSSFromURLParam'
    };
    public static Set<String> securityVFRuleSet = new Set<String>{ 'VfCsrf', 'VfHtmlStyleTagXss', 'VfUnescapeEl' };
    public static Map<String, Set<String>> rulesSet = new Map<String, Set<String>>{
        'Best Practices' => bestPracticesRuleSet,
        'Code Style' => codeStyleRuleSet,
        'Design' => designRuleSet,
        'Documentation' => documentationRuleSet,
        'Error Prone' => errorProneRuleSet,
        'Performance' => performanceRuleSet,
        'Apex Security' => securityRuleSet,
        'VisualForce Security' => securityVFRuleSet
    };
    public static Map<String, String> rulesRef = new Map<String, String>{
        'Best Practices' => 'category/apex/bestpractices.xml/',
        'Code Style' => 'category/apex/codestyle.xml/',
        'Design' => 'category/apex/design.xml/',
        'Documentation' => 'category/apex/documentation.xml/',
        'Error Prone' => 'category/apex/errorprone.xml/',
        'Performance' => 'category/apex/performance.xml/',
        'Apex Security' => 'category/apex/security.xml/',
        'VisualForce Security' => 'category/visualforce/security.xml/'
    };
    public static Map<String, String> flosumHyperLinks = new Map<String, String>{
        'SNAPSHOT_RETRIEVAL_BEST_PRACTICES' => 'https://success.flosum.com/s/article/Snapshot-Retrieval-Best-Practices',
        'SNAPSHOT_OVERVIEW_AND_STRATEGY' => 'https://success.flosum.com/s/article/Snapshot-Overview-and-Strategy'
    };
}