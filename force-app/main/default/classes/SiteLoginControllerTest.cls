/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class SiteLoginControllerTest {//awdjpoawmxpoawxmpoaw
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {//awdjpoawmxpoawxmpoaw
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}//awdjpoawmxpoawxmpoaw