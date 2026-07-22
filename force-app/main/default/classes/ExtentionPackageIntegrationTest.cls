@IsTest
private class ExtentionPackageIntegrationTest {
@IsTest
    static void test1() {
        ExtentionPackageIntegration integration = new ExtentionPackageIntegration();
        integration.setData('data');
        integration.execute();
    }
}