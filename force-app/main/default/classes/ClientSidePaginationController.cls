public with sharing class ClientSidePaginationController {
    @AuraEnabled
    public static List<sObject> getRecords() {
        // Example: Fetching Account records
        return [SELECT Id, Name FROM Account LIMIT 100];
    }
}