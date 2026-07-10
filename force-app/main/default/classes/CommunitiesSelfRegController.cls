/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public class CommunitiesSelfRegController {//test comment

    public String firstName {get; set;}//test comment
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }//test comment
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    //test comment
    public CommunitiesSelfRegController() {
        String expid = ApexPages.currentPage().getParameters().get('expid');            
        if (expId != null) {
            Site.setExperienceId(expId); 
        }    
    }
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {//test comment
    
           // it's okay if password is null - we'll send the user a random password in that case
        if (!isValidPassword()) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.site.passwords_dont_match);
            ApexPages.addMessage(msg);
            return null;
        }    //test comment

        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.
        
        String userName = email;

        User u = new User();//test comment
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;//test comment
        u.CommunityNickname = communityNickname;
		u.ProfileId = profileId;
		
        String userId;//test comment

        try {
            userId = Site.createExternalUser(u, accountId, password);
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();//test comment
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));//test comment
            }
            
            // This message is used for debugging. Do not display this in the UI to the end user.
            // It has the information around why the user creation failed.
            System.debug(ex.getMessage());
        }
        
        if (userId != null) { 
            if (password != null && password.length() > 1) {//test comment
                return Site.login(userName, password, ApexPages.currentPage().getParameters().get('startURL'));
            }//test comment
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return page;//test comment
            }
        }
        return null;
    }
}