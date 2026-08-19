public with sharing class FlosumReference {

    public FlosumReference() {
        Flosum.FlosumUtils controller = new Flosum.FlosumUtils();
        controller.authenticateAnOrg('organisationId');
    }
    
    public void query() {
        List<Flosum__Organisation__c> orgList = [SELECT Id,Name FROM Flosum__Organisation__c];
    }
}