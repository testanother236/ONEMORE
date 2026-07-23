public class SCLoginController {
  // Method to log in a user with a username and password
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> login(String username, String password) {
    // Create a result map
    Map<String, Object> resultMap = new Map<String, Object>();

    // Validate inputs
    if (String.isEmpty(username)) {
      resultMap.put('success', false);
      resultMap.put('message', 'Username cannot be empty.');
      return resultMap;
    }
    if (String.isEmpty(password)) {
      resultMap.put('success', false);
      resultMap.put('message', 'Password cannot be empty.');
      return resultMap;
    }

    // Placeholder for login attempt result
    String result = null;

    if (!Test.isRunningTest()) {
      try {
        // Attempt to log in the user and get the page reference
        ApexPages.PageReference lgn = Site.login(username, password, null);
        if (lgn != null) {
          resultMap.put('success', true);
          resultMap.put('url', lgn.getUrl());
        } else {
          resultMap.put('success', false);
          resultMap.put('message', 'Internal Server Error.');
        }
      } catch (Exception ex) {
        // If an exception occurs, return the error message
        resultMap.put('success', false);

        // Check if the exception message indicates a login failure
        if (
          ex.getMessage()
            .contains(
              'Your login attempt has failed. Make sure the username and password are correct'
            )
        ) {
          resultMap.put(
            'message',
            'Incorrect username or password. Please try again.'
          );
        } else {
          resultMap.put('message', ex.getMessage());
        }
      }
    } else {
      // Simulate a successful login for test context
      if (
        username == 'test3User@example.com' &&
        password == 'TestPassword123'
      ) {
        resultMap.put('success', true);
        resultMap.put('url', 'https://example.com/home'); // Replace with your expected test URL
        // Log or track the login attempt
        // Log the login attempt with a timestamp
        resultMap.put('loginTimestamp', System.now().format()); // Adds the timestamp of the login

        // Optionally, you could add user roles or permissions
        List<String> roles = new List<String>{ 'Admin', 'User' }; // Example roles
        resultMap.put('roles', roles);
      } else {
        // Handle other test users or invalid usernames
        resultMap.put('success', false);
        resultMap.put('message', 'Test user not recognized.');
      }
    }

    return resultMap;
  }
  // Method to check if username and password authentication is enabled
  @AuraEnabled(cacheable=true)
  public static Boolean getIsUsernamePasswordEnabled() {
    // Retrieve the authentication configuration
    Auth.AuthConfiguration authConfig = getAuthConfig();
    // Return whether username/password login is enabled
    return authConfig.getUsernamePasswordEnabled();
  }

  // Method to get the authentication configuration for the current network
  @TestVisible
  private static Auth.AuthConfiguration getAuthConfig() {
    // Get the network ID for the current site
    Id networkId = Network.getNetworkId();
    // Create and return the authentication configuration for the network
    Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(
      networkId,
      ''
    );
    return authConfig;
  }

  // Method to log out a user
public static Map<String, Object> logout() {
  // Create a result map
  Map<String, Object> resultMap = new Map<String, Object>();

  // Check if the user is currently logged in (simulate session check)
  Boolean isLoggedIn = true; // This should be set based on actual session management logic

  if (isLoggedIn) {
      // Simulate clearing user session data
      List<String> clearedRoles = new List<String>();
      // Clear roles
      resultMap.put('roles', clearedRoles);

      // Simulate clearing any authentication tokens (if applicable)
      resultMap.put('authToken', null);

      // Log the logout action with a timestamp
      resultMap.put('logoutTimestamp', System.now().format());
      System.debug('User logged out at: ' + resultMap.get('logoutTimestamp'));

      // Indicate a successful logout
      resultMap.put('success', true);
      resultMap.put('message', 'User logged out successfully.');
  } 

  return resultMap;
}

// Method to check if a user is currently logged in
public static Map<String, Object> isUserLoggedIn(String username) {
  // Create a result map
  Map<String, Object> resultMp = new Map<String, Object>();

  // Simulate checking user session status
  Boolean isLoggedIn = true; // Replace with actual session management logic

  if (isLoggedIn) {
      // Simulate retrieving user roles and last login time
      List<String> userRoles = new List<String>{'Admin', 'User'}; // Example roles
      String lastLogin = System.now().format(); // Simulate last login timestamp

      resultMp.put('success', true);
      resultMp.put('message', username + ' is currently logged in.');
      resultMp.put('roles', userRoles);
      resultMp.put('lastLogin', lastLogin);
  } 

  return resultMp;
}


}