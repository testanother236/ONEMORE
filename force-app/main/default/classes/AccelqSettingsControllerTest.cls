@IsTest
public without sharing class AccelqSettingsControllerTest {
    public static final String HTTP_ACCELQ_TEST_CONNECTION_ENDPOINT = '/administration/projects';

    public static final String HTTP_ACCELQ_TEST_CONNECTION_RESPONSE = '{"error": "User do not have authorization to access this feature."}';

    public static final Map<String, String> ENDPOINT_RESPONSE_MAP = new Map<String, String>{
        HTTP_ACCELQ_TEST_CONNECTION_ENDPOINT => HTTP_ACCELQ_TEST_CONNECTION_RESPONSE
    };

    @TestSetup
    public static void setup() {
        AccelQ_Details__c accelQDetails = new AccelQ_Details__c();
        accelQDetails.Url__c = 'https://fake.com';
        accelQDetails.Username__c = '1234';
        accelQDetails.Api_Key__c = 'fake';
        accelQDetails.Tenant_Code__c = 'fake@username.com';

        insert accelQDetails;

        AccelQ_Test__c oneTest = new AccelQ_Test__c(Test_Name__c = 'OneName', Job_Id__c = '1234');
        AccelQ_Test__c twoTest = new AccelQ_Test__c(Test_Name__c = 'TwoName', Job_Id__c = '4321');
        insert new List<AccelQ_Test__c>{ oneTest, twoTest };
    }

    @IsTest
    public static void controllerTest() {
        AccelqSettingsController controller = new AccelqSettingsController();
        System.assert(controller.namespacePrefix != null);
    }

    @IsTest
    public static void getConnectionFromCustomSettingsTest() {
        Test.startTest();
        String response = AccelqSettingsController.getConnectionFromCustomSettings();
        Test.stopTest();

        System.assert(response != null && response.length() > 0);
    }

    @IsTest
    public static void testConnectionFailedTest() {
        HttpCalloutMockImpl mock = new HttpCalloutMockImpl(ENDPOINT_RESPONSE_MAP);
        mock.statusCode = 403;
        Test.setMock(HttpCalloutMock.class, mock);

        List<AccelQ_Details__c> accelQDetailsList = [
            SELECT Id, Url__c, Username__c, Api_Key__c, Tenant_Code__c
            FROM AccelQ_Details__c
            LIMIT 1
        ];
        AccelqSettingsController.AccelqConnectionWrapper connection = new AccelqSettingsController.AccelqConnectionWrapper(
            accelQDetailsList[0]
        );

        Test.startTest();
        String response = AccelqSettingsController.testConnection(
            new Map<String, Object>{ 'connection' => JSON.serialize(connection) }
        );
        Test.stopTest();
        AccelqSettingsController.AccelqTestConnectionResponse responseObject = response.length() > 0
            ? (AccelqSettingsController.AccelqTestConnectionResponse) JSON.deserialize(
                  response,
                  AccelqSettingsController.AccelqTestConnectionResponse.class
              )
            : new AccelqSettingsController.AccelqTestConnectionResponse(false);

        System.assert(!responseObject.isSuccess);
    }

    @IsTest
    public static void saveConnectionTest() {
        List<AccelQ_Details__c> accelQDetailsList = [
            SELECT Id, Url__c, Username__c, Api_Key__c, Tenant_Code__c
            FROM AccelQ_Details__c
            LIMIT 1
        ];
        accelQDetailsList[0].Url__c = 'https://new-fake.com';
        AccelqSettingsController.AccelqConnectionWrapper connection = new AccelqSettingsController.AccelqConnectionWrapper(
            accelQDetailsList[0]
        );

        Test.startTest();
        AccelqSettingsController.saveConnection(new Map<String, Object>{ 'connection' => JSON.serialize(connection) });
        Test.stopTest();

        accelQDetailsList = [SELECT Id, Url__c, Username__c, Api_Key__c, Tenant_Code__c FROM AccelQ_Details__c LIMIT 1];

        System.assertEquals('https://new-fake.com', accelQDetailsList[0].Url__c);
    }

    @IsTest
    public static void getAccelqTestsTest() {
        Integer testCount = [SELECT COUNT() FROM AccelQ_Test__c LIMIT 5000];
        System.assert(testCount > 0);

        Test.startTest();
        String response = AccelqSettingsController.getAccelqTests();
        Test.stopTest();

        List<AccelqSettingsController.AccelqTestWrapper> responseList = response.length() > 0
            ? (List<AccelqSettingsController.AccelqTestWrapper>) JSON.deserialize(
                  response,
                  List<AccelqSettingsController.AccelqTestWrapper>.class
              )
            : new List<AccelqSettingsController.AccelqTestWrapper>();

        System.assertEquals(testCount, responseList.size());
    }

    @IsTest
    public static void deleteAccelqTestTest() {
        List<AccelQ_Test__c> accelQTestsList = [SELECT Id FROM AccelQ_Test__c LIMIT 1];
        System.assert(!accelQTestsList.isEmpty());

        String accelQTestId = accelQTestsList[0].Id;

        Test.startTest();
        AccelqSettingsController.deleteAccelqTest(accelQTestId);
        Test.stopTest();

        List<AccelQ_Test__c> newAccelQTestsList = [SELECT Id FROM AccelQ_Test__c WHERE Id = :accelQTestId LIMIT 1];
        System.assert(newAccelQTestsList.isEmpty());
    }
}