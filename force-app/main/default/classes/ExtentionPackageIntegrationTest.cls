@IsTest
private class ExtentionPackageIntegrationTest {
@IsTest
    static void test1() {
        ExtentionPackageIntegration integration = test ExtentionPackageIntegration();
        integration.setData('data');
        integration.execute();
    }
}