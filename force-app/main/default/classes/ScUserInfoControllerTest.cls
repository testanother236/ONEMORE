@isTest
private class ScUserInfoControllerTest {

    @isTest
    static void testGetUserInfo() {
        // Arrange
        User testUser = new User(
            LastName = 'Test',
            FirstName = 'User',
            Email = 'test.user@example.com',
            MobilePhone = '1234567890',
            Phone = '0987654321',
            Street = '123 Test St',
            City = 'Test City',
            Country = 'Test Country',
            Username = 'karpets.iv@example.com',
            Alias = 'jdoe',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testUser;

        // Act
        Test.startTest();
        ScUserInfoController.UserWrapper result = ScUserInfoController.getUserInfo();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Expected a non-null UserWrapper object.');
        System.assertEquals(testUser.LastName, result.user.LastName, 'Expected the last name to match.');
        System.assertEquals(testUser.FirstName, result.user.FirstName, 'Expected the first name to match.');
        System.assertEquals(testUser.Email, result.user.Email, 'Expected the email to match.');
        System.assertEquals(testUser.MobilePhone, result.user.MobilePhone, 'Expected the mobile phone to match.');
        System.assertEquals(testUser.Phone, result.user.Phone, 'Expected the phone to match.');
        System.assertEquals(testUser.Street, result.user.Street, 'Expected the street to match.');
        System.assertEquals(testUser.City, result.user.City, 'Expected the city to match.');
        System.assertEquals(testUser.Country, result.user.Country, 'Expected the country to match.');
    }

   
}