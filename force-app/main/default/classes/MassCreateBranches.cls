global class MassCreateBranches implements Database.Batchable<sObject> {

    private Integer startNumber;
    private Integer endNumber;
    
    global MassCreateBranches(Integer startNumber, Integer endNumber) {
        this.startNumber = startNumber;
        this.endNumber = endNumber;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Flosum__Branch__c LIMIT 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Flosum__Branch__c> branchesToInsert = new List<Flosum__Branch__c>();
        
        for (Integer i = this.startNumber; i < this.startNumber + 20; i++) {
            Flosum__Branch__c newBranch = new Flosum__Branch__c();
            newBranch.Flosum__Branch_Name__c = 'MassDeleteBranch ' + i;
            newBranch.Flosum__Repository__c = 'a0QHn00000QbeSkMAJ';
            
            branchesToInsert.add(newBranch);
        }
        insert branchesToInsert;
        
        this.startNumber += 20;
        
    }

    global void finish(Database.BatchableContext bc) {
        system.debug('startNumber from finish: ' + this.startNumber);
        if (startNumber < endNumber) {
            MassCreateBranches newBatch = new MassCreateBranches(this.startNumber + 20, this.endNumber);
            Database.executeBatch(newBatch, 1);
        }
    }
}