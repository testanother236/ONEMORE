public with sharing class AuraTableController {
	
    @AuraEnabled
    public static List<Account> getAccounts(){
        return [SELECT Id,Name,PHone FROM Account];
    }
}