@isTest
private class SCLoginControllerTest {
    
    @isTest
    static void testLoginWithValidCredentials() {
        // Arrange: Create a test useraaa
        User testUser = new User(
            Username = 'test3User@example.com',
            Email = 'test3User@example.com',
            Alias = 'test',
            LastName = 'User',
            FirstName = 'Test',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert testUser;
    
        // Act: Attempt to log in with valid credentials
        Test.startTest();
        Map<String, Object> result = SCLoginController.login('test3User@example.com', 'TestPassword123');
        Test.stopTest();
        
        
         // Assert: Check if the login was successful
        System.assertEquals(true, result.get('success'), 'Expected login to be successful for test3User.');
        System.assertEquals('https://example.com/home', result.get('url'), 'Expected specific URL for test3User.');

        // Assert: Check for the presence of login timestamp
        System.assertNotEquals(null, result.get('loginTimestamp'), 'Expected login timestamp to be present.');

        // Assert: Check for user roles
        List<String> expectedRoles = new List<String>{'Admin', 'User'};
        System.assertEquals(expectedRoles, result.get('roles'), 'Expected roles to match the defined roles for test3User.');
    }
    
    
    @isTest
    static void testLoginWithInvalidCredentials() {
        // Act: Attempt to log in with invalid credentials
        Test.startTest();
        Map<String, Object> result = SCLoginController.login('invalidUser@example.com', 'WrongPassword');
        Test.stopTest();

        // Assert: Check for error message
        System.assertEquals(false, result.get('success'), 'Expected login to fail.');
        System.assertEquals('Test user not recognized.', result.get('message'), 'Expected specific error message for incorrect credentials.');
    }

       
	@isTest
  static void testLoginWithEmptyUsername() {
    // Call the login method with an empty username
    Map<String, Object> result = SCLoginController.login('', 'password');

    // Assert the expected result (in this case, failure and an error message)
    System.assertEquals(false, result.get('success'), 'Expected login to fail with empty username.');
    System.assertEquals('Username cannot be empty.', result.get('message'), 'Expected error message for empty username.');
  }
    
    @isTest
  static void testLoginWithEmptyPassword() {
    // Call the login method with an empty username
    Map<String, Object> result = SCLoginController.login('user', '');

    // Assert the expected result (in this case, failure and an error message)
    System.assertEquals(false, result.get('success'), 'Expected login to fail with empty username.');
    System.assertEquals('Password cannot be empty.', result.get('message'), 'Expected error message for empty username.');
  }
        
    
     @isTest
    static void testGetIsUsernamePasswordEnabled() {
        // Act
        Test.startTest();
        Boolean isEnabled = SCLoginController.getIsUsernamePasswordEnabled();
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, isEnabled, 'Expected a boolean value indicating if username/password is enabled.');
    }
    
    @isTest
    static void testLogout() {
        // Act: Simulate logout
        Test.startTest();
        Map<String, Object> result = SCLoginController.logout();
        Test.stopTest();

        // Assert: Check if the logout was successful
        System.assertEquals(true, result.get('success'), 'Expected logout to be successful.');
        System.assertEquals('User logged out successfully.', result.get('message'), 'Expected specific logout message.');
        
        // Assert: Check that roles are cleared
        System.assertEquals(new List<String>(), result.get('roles'), 'Expected roles to be cleared upon logout.');
        
        // Assert: Check that authToken is cleared
        System.assertEquals(null, result.get('authToken'), 'Expected authToken to be null upon logout.');
    }
    
     @isTest
    static void testIsUserLoggedInWithDetails() {
        // Act: Check if a user is logged in
        Test.startTest();
        Map<String, Object> result = SCLoginController.isUserLoggedIn('test3User@example.com');
        Test.stopTest();

        // Assert: Check if the response indicates the user is logged in
        System.assertEquals(true, result.get('success'), 'Expected user to be logged in.');
        System.assertEquals('test3User@example.com is currently logged in.', result.get('message'), 'Expected specific message for logged-in user.');

        // Assert: Check that roles are returned
        List<String> expectedRoles = new List<String>{'Admin', 'User'};
        System.assertEquals(expectedRoles, result.get('roles'), 'Expected user roles to be returned.');

        // Assert: Check that lastLogin timestamp is present
        System.assertNotEquals(null, result.get('lastLogin'), 'Expected lastLogin timestamp to be present.');
    }


   
}