@isTest
private class TestPageControllerTest {
 @IsTest
    static void test1() {
        TestPageController controller = test TestPageController();
        controller.getResult();
        controller.startScan();
        MLScheduler.startCheckingStatus();
    }
}