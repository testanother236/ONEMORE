public with sharing class DeploymentDataForPath {
    @AuraEnabled
    public static String deploymentOrgData(String recordId, String obj) {
        List<MetadataLogsWrapper> metaLogWrap = new List<MetadataLogsWrapper>();
        if (String.isBlank(recordId)) {
            return null;
        }

        List<Metadata_Log__c> metadataLogData = new List<Metadata_Log__c>();
        if (obj != null && obj == 'branch') {
            metadataLogData = [
                SELECT Organisation__r.Name, Job_Completed__c, Succeed__c
                FROM Metadata_Log__c
                WHERE
                    Branch__c = :recordId
                    AND (Process_Type__c = :FlosumConstants.PROCESS_DEPLOYMENT
                    OR Process_Type__c = :FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT
                    OR Process_Type__c = :B2CConstants.PROCESS_STRING_MAP.get(B2CConstants.Process.DEPLOY_BRANCH)
                    OR Process_Type__c = :MCConstants.DEPLOY_TYPE
                    OR Process_Type__c = :FlosumConstants.PROCESS_ROLLBACK)
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC, Name DESC
                LIMIT 10
            ];
        } else {
            metadataLogData = [
                SELECT Organisation__r.Name, Job_Completed__c, Succeed__c
                FROM Metadata_Log__c
                WHERE
                    Patch__c = :recordId
                    AND (Process_Type__c = :FlosumConstants.PROCESS_DEPLOYMENT
                    OR Process_Type__c = :FlosumConstants.PROCESS_SCHEDULED_DEPLOYMENT
                    OR Process_Type__c = :FlosumConstants.PROCESS_ROLLBACK)
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC, Name DESC
                LIMIT 10
            ];
        }

        // Changes in SOQL and FOR are related to display only 10 latest path components
        for (Integer i = metadataLogData.size() - 1; i >= 0; i--) {
        //for(Metadata_Log__c metaLogData : metadataLogData){
            metaLogWrap.add(
                new MetadataLogsWrapper(
                    metadataLogData[i].Organisation__r.Name,
                    metadataLogData[i].Job_Completed__c,
                    metadataLogData[i].Succeed__c
                )
            );
        }
        return JSON.serialize(metaLogWrap);
    }

    public class MetadataLogsWrapper {
        public String name;
        public Boolean jobComp;
        public Boolean jobSucceed;
        public MetadataLogsWrapper(String name, Boolean jobComp, Boolean jobSucceed) {
            this.name = name;
            this.jobComp = jobComp;
            this.jobSucceed = jobSucceed;
        }
    }
}