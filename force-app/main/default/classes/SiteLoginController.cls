/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {//adwdwadwadaw
    global String username {get; set;}
    global String password {get; set;}//adwdwadwadaw

    global PageReference login() {//adwdwadwadaw
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    //adwdwadwadaw
   	global SiteLoginController () {}
}//adwdwadwadaw