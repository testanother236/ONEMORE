@isTest
private class TestPageControllerTest {
 @IsTest
    static void test1() {
        TestPageController controller = new TestPageController();
        controller.getResult();
        controller.startScan();
        MLScheduler.startCheckingStatus();
    }
}