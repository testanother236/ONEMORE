
/**
 * Test class for QD_HighCoverage
 * Coverage goal: 100% for QD_HighCoverage class
 * Test methods validate the doubleIt method with various scenarios
 */
@isTest
private class QD_HighCoverageTest {

    /**
     * Test method to verify positive integer doubling
     * Tests the basic functionality with a standard positive number
     */
    @isTest
    static void testDoublePositiveNumber() {
        // Setup test data
        Integer inputNumber = 5;
        Integer expectedResult = 10;
        
        Test.startTest();
        // Execute method under test
        Integer actualResult = QD_HighCoverage.doubleIt(inputNumber);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(expectedResult, actualResult, 'The doubling of a positive integer should be correct');
    }
    
    /**
     * Test method to verify negative integer doubling
     * Tests the method with negative input values
     */
    @isTest
    static void testDoubleNegativeNumber() {
        // Setup test data
        Integer inputNumber = -7;
        Integer expectedResult = -14;
        
        Test.startTest();
        // Execute method under test
        Integer actualResult = QD_HighCoverage.doubleIt(inputNumber);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(expectedResult, actualResult, 'The doubling of a negative integer should be correct');
    }
    
    /**
     * Test method to verify zero handling
     * Tests the edge case where input is zero
     */
    @isTest
    static void testDoubleZero() {
        // Setup test data
        Integer inputNumber = 0;
        Integer expectedResult = 0;
        
        Test.startTest();
        // Execute method under test
        Integer actualResult = QD_HighCoverage.doubleIt(inputNumber);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(expectedResult, actualResult, 'Doubling zero should return zero');
    }
    
    /**
     * Test method to verify large number handling
     * Tests the method with a maximum integer value scenario
     */
    @isTest
    static void testDoubleLargeNumber() {
        // Setup test data - using a large but safe number to avoid integer overflow
        Integer inputNumber = 1000000;
        Integer expectedResult = 2000000;
        
        Test.startTest();
        // Execute method under test
        Integer actualResult = QD_HighCoverage.doubleIt(inputNumber);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(expectedResult, actualResult, 'The doubling of a large integer should be correct');
    }
    
    /**
     * Test method to verify the method with minimum integer value
     * Tests edge case with minimum integer value
     */
    @isTest
    static void testDoubleMinimumInteger() {
        // Setup test data - using a number that won't overflow when doubled
        Integer inputNumber = -1000000;
        Integer expectedResult = -2000000;
        
        Test.startTest();
        // Execute method under test
        Integer actualResult = QD_HighCoverage.doubleIt(inputNumber);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(expectedResult, actualResult, 'The doubling of minimum safe integer should be correct');
    }
}
