// File: classes/MyGoodClassTest.cls
@isTest
private class MyGoodClassTest {
    @isTest static void testAdd() {
        System.assertEquals(4, MyGoodClass.add(2,2));
    }
}