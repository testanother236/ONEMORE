@isTest
private class FlowCoverageTriggerTest{
    
    static testMethod void validateHelloWorld() {
        
        insert new FlowCoverageTest__c(Name = 'test');
    }
}