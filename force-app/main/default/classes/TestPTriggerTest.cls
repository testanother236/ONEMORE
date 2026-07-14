@isTest
private class TestPTriggerTest
{
    static testMethod void myUnitTest()
    {
        TestP__c temp = new TestP__c();
        temp.Name = 'One';
        insert temp;
        /*TestP__c temp = new TestP__c();
        temp.Name = 'One';
        insert temp;*/
    }
}