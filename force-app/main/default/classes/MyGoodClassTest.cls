
@isTest
private class MyGoodClassTest {

    // Test method for the add method with positive numbers
    static testMethod void testAddPositiveNumbers() {
        // Test adding two positive integers
        Test.startTest();
        Integer result = MyGoodClass.add(5, 3);
        Test.stopTest();
        System.assertEquals(8, result, 'Adding 5 and 3 should return 8');
    }

    // Test method for the add method with negative numbers
    static testMethod void testAddNegativeNumbers() {
        // Test adding two negative integers
        Test.startTest();
        Integer result = MyGoodClass.add(-4, -6);
        Test.stopTest();
        System.assertEquals(-10, result, 'Adding -4 and -6 should return -10');
    }

    // Test method for the add method with zero values
    static testMethod void testAddWithZero() {
        // Test adding zero and a positive number
        Test.startTest();
        Integer result = MyGoodClass.add(0, 7);
        Test.stopTest();
        System.assertEquals(7, result, 'Adding 0 and 7 should return 7');
        
        // Test adding zero and a negative number
        Test.startTest();
        result = MyGoodClass.add(0, -7);
        Test.stopTest();
        System.assertEquals(-7, result, 'Adding 0 and -7 should return -7');
    }

    // Test method for the add method with null inputs (negative scenario)
    static testMethod void testAddWithNulls() {
        // Since the method requires Integer primitives and primitives cannot be null,
        // this test will verify behavior when passing null wrapper objects cast to Integer
        // We expect a NullPointerException if nulls are used, so use try-catch
        
        Integer a = null;
        Integer b = null;

        try {
            Test.startTest();
            // This will throw a NullPointerException because method uses primitive int signature
            Integer result = MyGoodClass.add(a, b);
            Test.stopTest();
            // If no exception, fail the test
            System.assert(false, 'Expected NullPointerException when passing null parameters');
        } catch (NullPointerException e) {
            // Test passed, exception expected when null is passed for primitive parameters
            System.assert(true);
        }
    }
}
