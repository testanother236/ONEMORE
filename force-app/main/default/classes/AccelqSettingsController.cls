public with sharing class AccelqSettingsController {
    public String namespacePrefix { get; set; }

    public AccelqSettingsController() {
        if (!FlosumFeature.hasFeaturePermission(FlosumFeature.FEATURE_ACCELQ_PROVAR_TESTING)) {
            throw new FlosumException(FlosumFeature.FEATURE_ERROR_MESSAGE);
        }
        namespacePrefix = FlosumConstants.getNameSpacePrefix();
    }

    @AuraEnabled
    public static String getConnectionFromCustomSettings() {
        List<AccelQ_Details__c> accelQDetailsList = [
            SELECT Id, Url__c, Username__c, Api_Key__c, Tenant_Code__c
            FROM AccelQ_Details__c
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!accelQDetailsList.isEmpty()) {
            return JSON.serialize(new AccelqConnectionWrapper(accelQDetailsList[0]));
        }

        return null;
    }

    @AuraEnabled
    public static void createRemoteSiteSetting(String endpointUrl) {
        if (MetadataUtils.checkDuplicateRemoteSiteSettings(endpointUrl)) {
            return;
        } else {
            MetadataUtils.createRemoteSiteSettings(endpointUrl, 'accelq' + Math.abs(endpointUrl.hashCode()));
        }
    }

    @AuraEnabled
    public static String testConnection(Map<String, Object> dataMap) {
        if (!dataMap.containsKey('connection'))
            throw new FlosumException('There are not data for test connection.');
        AccelqConnectionWrapper connection = dataMap.containsKey('connection')
            ? (AccelqConnectionWrapper) JSON.deserialize(
                  (String) dataMap.get('connection'),
                  AccelqConnectionWrapper.class
              )
            : null;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(connection.url + '/awb/api/2.0/' + connection.tenantCode + '/administration/projects');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('API_KEY', connection.apiKey);
        request.setHeader('USER_ID', connection.username);
        HttpResponse response = new Http().send(request);
        String body = response.getBody();
        if (response.getStatusCode() == 200) {
            return JSON.serialize(new AccelqTestConnectionResponse(true));
        } else {
            if (String.isNotBlank(body)) {
                String errorMessage;
                try {
                    Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(body);
                    errorMessage = bodyMap.containsKey('error')
                        ? (String) bodyMap.get('error')
                        : 'Unexpected error';
                } catch (Exception e) {
                    errorMessage = body;
                }
                return JSON.serialize(new AccelqTestConnectionResponse(false, errorMessage));
            } else {
                return JSON.serialize(new AccelqTestConnectionResponse(false, response.getStatus()));
            }
        }
    }

    @AuraEnabled
    public static void saveConnection(Map<String, Object> dataMap) {
        if (!dataMap.containsKey('connection'))
            throw new FlosumException('There are not data for test connection.');
        AccelqConnectionWrapper connection = dataMap.containsKey('connection')
            ? (AccelqConnectionWrapper) JSON.deserialize(
                  (String) dataMap.get('connection'),
                  AccelqConnectionWrapper.class
              )
            : null;

        List<AccelQ_Details__c> accelQDetailsList = [SELECT Id FROM AccelQ_Details__c WITH SECURITY_ENFORCED LIMIT 1];
        AccelQ_Details__c accelQDetails = accelQDetailsList.isEmpty() ? new AccelQ_Details__c() : accelQDetailsList[0];
        accelQDetails.Url__c = connection.url;
        accelQDetails.Username__c = connection.username;
        accelQDetails.Api_Key__c = connection.apiKey;
        accelQDetails.Tenant_Code__c = connection.tenantCode;

        DatabaseUtils.upsertCustomSettingRecord(
            accelQDetails,
            new List<Schema.DescribeFieldResult>{
                AccelQ_Details__c.Url__c.getDescribe(),
                AccelQ_Details__c.Username__c.getDescribe(),
                AccelQ_Details__c.Api_Key__c.getDescribe(),
                AccelQ_Details__c.Tenant_Code__c.getDescribe()
            }
        );
    }

    @AuraEnabled
    public static String getAccelqTests() {
        List<AccelqTestWrapper> accelqTestWrapperList = new List<AccelqTestWrapper>();

        List<AccelQ_Test__c> accelQTestsList = [
            SELECT Id, Test_Name__c, Job_Id__c
            FROM AccelQ_Test__c
            WITH SECURITY_ENFORCED
            LIMIT 5000
        ];

        for (AccelQ_Test__c test : accelQTestsList) {
            accelqTestWrapperList.add(new AccelqTestWrapper(test));
        }

        return JSON.serialize(accelqTestWrapperList);
    }

    @AuraEnabled
    public static void deleteAccelqTest(String id) {
        if (String.isBlank(id))
            throw new FlosumException('Id is Blank');
        AccelQ_Test__c test = new AccelQ_Test__c(Id = id);
        DatabaseUtils.deleteRecord(test);
    }

    public class AccelqConnectionWrapper {
        public String url;
        public String username;
        public String apiKey;
        public String tenantCode;

        public AccelqConnectionWrapper() {
        }

        public AccelqConnectionWrapper(AccelQ_Details__c accelQDetails) {
            this.url = accelQDetails.Url__c;
            this.username = accelQDetails.Username__c;
            this.apiKey = accelQDetails.Api_Key__c;
            this.tenantCode = accelQDetails.Tenant_Code__c;
        }
    }

    public class AccelqTestConnectionResponse {
        public Boolean isSuccess;
        public String errorMessage;

        public AccelqTestConnectionResponse(Boolean isSuccess, String errorMessage) {
            this.isSuccess = isSuccess;
            this.errorMessage = errorMessage;
        }
        public AccelqTestConnectionResponse(Boolean isSuccess) {
            this.isSuccess = isSuccess;
        }
    }

    public class AccelqTestWrapper {
        public String testName;
        public String jobId;
        public String id;

        public AccelqTestWrapper() {
        }

        public AccelqTestWrapper(AccelQ_Test__c test) {
            this.testName = test.Test_Name__c;
            this.jobId = test.Job_Id__c;
            this.id = test.Id;
        }
    }
}