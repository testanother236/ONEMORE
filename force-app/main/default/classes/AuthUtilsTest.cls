@isTest
private class AuthUtilsTest {
    static testMethod void myUnitTest() {
        Credentials__c cred = new Credentials__c(
            ConsumerSecret__c = '123456987',
            Redirect_URL__c = '001',
            Consumer_Key_Auto__c = 'key',
            Consumer_Secret_Auto__c = 'secret',
            ConsumerKey__c = '1234569874563214569513578264'
        );
        insert cred;
        Authorization_Details__c auth = new Authorization_Details__c(
            AuthorisedUser__c = 'test@testOrg.com',
            Name = 'test@testOrg.com',
            AccessToken__c = 'test',
            RefreshToken__c = 'test',
            InstanceURL__c = 'test'
        );
        insert auth;

        Organisation__c org = new Organisation__c(Username__c = 'test@testOrg.com', Name = 'Test12345678@testorg.com');
        insert org;

        Test.startTest();
        Map<Id, AuthUtils.CredDetails> orgsCreds = AuthUtils.getListDefaultCreds(new List<String>{ org.Id });
        AuthUtils.authenticateAnOrg(org.Id, 'test@testOrg.com', FlosumConstants.DEVELOPER, orgsCreds.get(org.Id));
        AuthUtils.authenticateAnOrg(org.Id, 'test@testOrg.com', FlosumConstants.RELEASE_MANAGER, orgsCreds.get(org.Id));
        AuthUtils.authenticateAnOrg(org.Id, 'test@testOrg.com', FlosumConstants.VALIDATE_ONLY, orgsCreds.get(org.Id));
        AuthUtils.authenticateAnOrg(org.Id, FlosumConstants.DEVELOPER);
        AuthUtils.authenticateAnOrg(org.Id, FlosumConstants.RELEASE_MANAGER);
        AuthUtils.authenticateAnOrg(org.Id, FlosumConstants.READONLY);
        AuthUtils.authenticateAnOrg(org.Id, FlosumConstants.VALIDATE_ONLY);
        AuthUtils.authenticateAnOrg(org.Id, FlosumConstants.AUDIT_ONLY);
        AuthUtils.authenticateAnOrg(org.Id, null);
        Test.stopTest();
        System.assertNotEquals(cred.Id, null);
    }

    static testMethod void myUnitTest1() {
        Credentials__c cred = new Credentials__c(
            ConsumerSecret__c = '123456987',
            Redirect_URL__c = '001',
            Consumer_Key_Auto__c = 'key',
            Consumer_Secret_Auto__c = 'secret',
            ConsumerKey__c = '1234569874563214569513578264'
        );
        insert cred;
        Test.startTest();
        AuthUtils.getValue(null, 'key');
        Test.stopTest();
        System.assertNotEquals(cred.Id, null);
    }
}