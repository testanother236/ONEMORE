// File: classes/MyGoodClassTest.cls
@isTest
private class MyGoodClassTest {
    @isTest static void testAddPositiveNumbers() {
        System.assertEquals(4, MyGoodClass.add(2, 2));
    }

    @isTest static void testAddNegativeNumbers() {
        System.assertEquals(-3, MyGoodClass.add(-1, -2));
    }

    @isTest static void testAddWithZero() {
        System.assertEquals(5, MyGoodClass.add(5, 0));
        System.assertEquals(0, MyGoodClass.add(0, 0));
    }

    @isTest static void testAddLargeNumbers() {
        System.assertEquals(1_000_000_000, MyGoodClass.add(500_000_000, 500_000_000));
    }
}