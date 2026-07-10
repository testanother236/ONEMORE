@IsTest
private class QD_HighCoverageTest {

    @IsTest
    static void testDoubleIt_positive() {
        Integer result = QD_HighCoverage.doubleIt(5);
        System.assertEquals(10, result);
    }

    @IsTest
    static void testDoubleIt_zero() {
        Integer result = QD_HighCoverage.doubleIt(0);
        System.assertEquals(0, result);
    }

    @IsTest
    static void testDoubleIt_negative() {
        Integer result = QD_HighCoverage.doubleIt(-3);
        System.assertEquals(-6, result);
    }
}