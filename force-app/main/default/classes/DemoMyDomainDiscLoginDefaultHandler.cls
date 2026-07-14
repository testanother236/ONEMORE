// This sample class contains the default logic for My Domain login discovery by password. 
// You can customize the code to ensure it meets your needs. The requestAttributes parameter
// provides additional information you can use in the discovery logic. Attributes include MyDomainUrl, 
// IpAddress, UserAgent, and location information (such as Country and City). 
// Use Auth.DiscoveryCustomErrorException to throw custom errors which will be shown on login page.
 global class DemoMyDomainDiscLoginDefaultHandler implements Auth.MyDomainLoginDiscoveryHandler {
 global PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes) 
{
   if (identifier != null) {
        // Search for user by email
        List<User> users = [SELECT Id FROM User WHERE Email = :identifier AND IsActive = TRUE];
        if (!users.isEmpty() && users.size() == 1) {
            return discoveryResult(users[0], startUrl, requestAttributes);
        } else {
            throw new Auth.LoginDiscoveryException('No unique user found. User count=' + users.size());
        }
    }
    throw new Auth.LoginDiscoveryException('Invalid Identifier');
  }
    private PageReference getSsoRedirect(User user, String startUrl, Map<String, String> requestAttributes) {
    // You can look up if the user should log in with SAML or an Auth Provider and return the URL to initialize SSO. For example:
    // SamlSsoConfig SSO = [select Id from SamlSsoConfig where DeveloperName='SamlTest' limit 1];
    // String ssoUrl = Auth.AuthConfiguration.getSamlSsoUrl(requestAttributes.get('MyDomainUrl'), startUrl, SSO.Id);
    // return new PageReference(ssoUrl);
    return null;
  }
     private PageReference discoveryResult(User user, String startUrl, Map<String, String> requestAttributes) 
     {
     PageReference ssoRedirect = getSsoRedirect(user, startUrl, requestAttributes);
      if (ssoRedirect != null) {
        return ssoRedirect;
      } 
      else {
        return Auth.SessionManagement.finishLoginDiscovery(Auth.LoginDiscoveryMethod.password, user.Id);    
      }
   }
}