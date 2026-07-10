/**
 * An apex page controller that exposes the site login functionality
 *///test comment
@IsTest global with sharing class CommunitiesLoginControllerTest {//test comment
    @IsTest(SeeAllData=true) 
    global static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
     	System.assertEquals(null, controller.forwardToAuthPage());       
    }    
}