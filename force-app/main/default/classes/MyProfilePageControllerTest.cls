
/**
 * An apex class that updates details of a portal user.
   Guest users are never able to access this page.
 */

/**
 * Unit tests for MyProfilePageController covering profile edit, cancel, save, and change password flows for current and portal users.
 */
@IsTest public with sharing class MyProfilePageControllerTest {

    /**
     * Verifies default save behavior and edit/cancel toggling for the profile page controller under current and portal user contexts.
     */
    @IsTest(SeeAllData=true) static void topology_defaultSave() {
        String topology_default1 = '$topology_default

  <output>
  Commented Salesforce component with main-description comments only
  