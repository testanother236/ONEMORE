@IsTest
private class ExtentionPackageIntegrationTest2 {
@IsTest
    static void test1() {
        ExtentionPackageIntegration2 integration = new ExtentionPackageIntegration2();
        integration.execute('data');
        integration.getResult('data');
    }
}