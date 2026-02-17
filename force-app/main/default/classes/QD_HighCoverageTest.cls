/**
 * Test class for QD_HighCoverage
 * @author Your Name
 * @date Today's Date
 * @description Provides test coverage for the QD_HighCoverage class methods
 */
@isTest
private class QD_HighCoverageTest {

    /**
     * Test method to verify the doubleIt method with a positive integer
     * This test verifies that the method correctly doubles a positive input value
     */
    @isTest
    static void testDoubleItPositive() {
        // Test setup: Define a positive input value
        Integer input = 5;
        Integer expected = 10;
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should double the positive integer correctly');
    }
    
    /**
     * Test method to verify the doubleIt method with a negative integer
     * This test verifies that the method correctly doubles a negative input value
     */
    @isTest
    static void testDoubleItNegative() {
        // Test setup: Define a negative input value
        Integer input = -3;
        Integer expected = -6;
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should double the negative integer correctly');
    }
    
    /**
     * Test method to verify the doubleIt method with zero
     * This test verifies that the method correctly handles zero input
     */
    @isTest
    static void testDoubleItZero() {
        // Test setup: Define zero as input value
        Integer input = 0;
        Integer expected = 0;
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should return zero when input is zero');
    }
    
    /**
     * Test method to verify the doubleIt method with maximum integer value
     * This test verifies edge case behavior with large numbers
     */
    @isTest
    static void testDoubleItMaxValue() {
        // Test setup: Use maximum safe integer value before overflow
        Integer input = 1073741823; // Half of max integer to avoid overflow
        Integer expected = 2147483646;
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should handle large integers correctly');
    }
    
    /**
     * Test method to verify the doubleIt method with minimum integer value
     * This test verifies edge case behavior with very small numbers
     */
    @isTest
    static void testDoubleItMinValue() {
        // Test setup: Use minimum safe integer value
        Integer input = -1073741823; // Half of min integer to avoid overflow
        Integer expected = -2147483646;
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should handle very small integers correctly');
    }
    
    /**
     * Test method to verify the doubleIt method with null input (negative scenario)
     * This test verifies that the method gracefully handles null input
     */
    @isTest
    static void testDoubleItNullInput() {
        // Test setup: Pass null as input
        Integer input = null;
        Integer expected = 0; // In Apex, null * 2 = 0
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method under test
        Integer result = QD_HighCoverage.doubleIt(input);
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(expected, result, 'The method should return zero when input is null');
    }
    
    /**
     * Test method for bulk data scenario
     * This test verifies the method works correctly with multiple calls
     */
    @isTest
    static void testDoubleItBulk() {
        // Test setup: Create a list of test values
        List<Integer> inputs = new List<Integer>{1, 2, 3, 4, 5};
        List<Integer> expected = new List<Integer>{2, 4, 6, 8, 10};
        List<Integer> results = new List<Integer>();
        
        // Start test execution context
        Test.startTest();
        
        // Execute the method multiple times
        for (Integer input : inputs) {
            results.add(QD_HighCoverage.doubleIt(input));
        }
        
        // Stop test execution context
        Test.stopTest();
        
        // Verify all results
        for (Integer i = 0; i < inputs.size(); i++) {
            System.assertEquals(expected[i], results[i], 
                'Bulk operation failed at index ' + i + '. Expected: ' + expected[i] + ', Actual: ' + results[i]);
        }
    }
}