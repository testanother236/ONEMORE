@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {//awdjpoawmxpoawxmpoaw

 @IsTest//awdjpoawmxpoawxmpoaw
 static void LightningLoginFormControllerInstantiation() {//awdjpoawmxpoawxmpoaw
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);//awdjpoawmxpoawxmpoaw
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }
//awdjpoawmxpoawxmpoaw
 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());//awdjpoawmxpoawxmpoaw
 }

 @IsTest//awdjpoawmxpoawxmpoaw
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }//awdjpoawmxpoawxmpoaw
}