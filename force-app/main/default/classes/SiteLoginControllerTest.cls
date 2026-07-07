/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class SiteLoginControllerTest {
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a test controller with all parameters in the page
        SiteLoginController controller = test SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }    
}