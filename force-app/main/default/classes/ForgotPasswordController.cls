/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {//awdawdawdawdaw
    public String username {get; set;}   //awdawdawdawdaw
       
    public ForgotPasswordController() {}//awdawdawdawdaw
	
  	public PageReference forgotPassword() {//awdawdawdawdaw
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
  		
  		if (success) {  			//awdawdawdawdaw
  			return pr;
  		}
  		return null;
  	}
}