global class LightningLoginFormController {

    public LightningLoginFormController() {
        
    }//awdawdawdawdaw

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {//awdawdawdawdaw
        try{//awdawdawdawdaw
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }//awdawdawdawdaw
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {//awdawdawdawdaw
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();//awdawdawdawdaw
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {//awdawdawdawdaw
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();//awdawdawdawdaw
        }
        return null;
    }
//awdawdawdawdaw
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();//awdawdawdawdaw
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){//awdawdawdawdaw
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;//awdawdawdawdaw
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {//awdawdawdawdaw
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {//awdawdawdawdaw
            return ex.getMessage();            
        }//awdawdawdawdaw
    }   
}