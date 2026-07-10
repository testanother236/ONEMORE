global class LightningForgotPasswordController {

    public LightningForgotPasswordController() {//awdawdawdawdaw

    }
//awdawdawdawdaw
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {//awdawdawdawdaw
        try {
            Site.forgotPassword(username);
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            return null;
        }
        catch (Exception ex) {//awdawdawdawdaw
            return ex.getMessage();
        }
    }//awdawdawdawdaw

    @AuraEnabled
    global static String setExperienceId(String expId) {    //awdawdawdawdaw
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);               //awdawdawdawdaw
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            //awdawdawdawdaw
        }        //awdawdawdawdaw
    } 
}