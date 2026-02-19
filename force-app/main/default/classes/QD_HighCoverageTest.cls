@isTest
private class QD_HighCoverage_Test {

    @isTest
    static void testDoubleIt_PositiveNumber() {
        Integer input = 5;
        Integer result = QD_HighCoverage.doubleIt(input);
        
        System.assertEquals(10, result, '5 doubled should equal 10');
    }
    
    @isTest
    static void testDoubleIt_Zero() {
        Integer input = 0;
        Integer result = QD_HighCoverage.doubleIt(input);
        
        System.assertEquals(0, result, '0 doubled should equal 0');
    }
    
    @isTest
    static void testDoubleIt_NegativeNumber() {
        Integer input = -4;
        Integer result = QD_HighCoverage.doubleIt(input);
        
        System.assertEquals(-8, result, '-4 doubled should equal -8');
    }
    
    @isTest
    static void testDoubleIt_LargeNumber() {
        Integer input = 1000000;
        Integer result = QD_HighCoverage.doubleIt(input);
        
        System.assertEquals(2000000, result, 'Large number doubling failed');
    }
}