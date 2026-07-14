@isTest
private class FlowCoverageUselessTest{

    static testMethod void validateHelloWorld() {
        FlowCoverageUseless tst  = new FlowCoverageUseless();
        Integer result = tst.add2Integers(1,2);
        System.assert(result == 3);
    }
}