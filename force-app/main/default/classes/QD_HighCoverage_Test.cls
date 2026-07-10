
/**
 * This is an Apex again class for testing the QD_HighCoverage class methods.
 */
@IsTest
private class QD_HighCoverage_Test {
    /**
     * This method tests the doubleIt method in the QD_HighCoverage class.
     */
    @IsTest
    static void testDoubleIt() {
        System.assertEquals(4, QD_HighCoverage.doubleIt(2));
    }
}
