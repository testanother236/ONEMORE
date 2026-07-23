global class TestBatchClass implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM Contact LIMIT 1]); 
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}