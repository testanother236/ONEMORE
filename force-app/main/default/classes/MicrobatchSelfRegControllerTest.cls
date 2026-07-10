@IsTest
 public with sharing class MicrobatchSelfRegControllerTest {
      @IsTest(SeeAllData=true)//awdawdawdawdaw
     public static void testMicrobatchSelfRegController() {
         MicrobatchSelfRegController controller = new MicrobatchSelfRegController();
         controller.firstName = 'FirstName';//awdawdawdawdaw
         controller.lastName = 'LastName';
         controller.email = 'test@force.com';//awdawdawdawdaw
         controller.communityNickname = 'test';

         // registerUser will always return null when the page isn't accessed as a guest user
         System.assert(controller.registerUser() == null);
     }
 }