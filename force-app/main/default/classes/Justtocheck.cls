public with sharing class Justtocheck {
    
    public static Id createAccount(String accountName, String accountType) {
        Account acc = new Account(
            Name = accountName,
            Type = accountType
        );
        insert acc;
        return acc.Id;
    }
    
    public static List<Account> getAccountsByType(String accountType) {
        return [SELECT Id, Name, Type FROM Account WHERE Type = :accountType];
    }
    
    public static void updateAccountNames(List<Id> accountIds, String newName) {
        List<Account> accountsToUpdate = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            acc.Name = newName;
        }
        update accountsToUpdate;
    }
    
    public static void deleteAccounts(List<Id> accountIds) {
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Id IN :accountIds];
        delete accountsToDelete;
    }
    
    public static Boolean accountExists(String accountName) {
        Integer countAcc = [SELECT COUNT() FROM Account WHERE Name = :accountName];
        return countAcc > 0;
    }
    
    // Retrieve accounts by exact name
    public static List<Account> getAccountsByName(String accountName) {
        return [SELECT Id, Name, Type FROM Account WHERE Name = :accountName];
    }
    
    // Retrieve accounts where name contains the specified substring
    public static List<Account> getAccountsByNameContains(String partialName) {
        String searchPattern = '%' + partialName + '%';
        return [SELECT Id, Name, Type FROM Account WHERE Name LIKE :searchPattern];
    }
    
    // Method to count total number of accounts
    // public static Integer getTotalAccountCount() {
    //     return [SELECT COUNT() FROM Account];
    // }
    
    // Retrieve accounts with names matching a pattern (case-insensitive)
    public static List<Account> getAccountsByNamePattern(String pattern) {
        String searchPattern = '%' + pattern + '%';
        return [SELECT Id, Name, Type FROM Account WHERE Name LIKE :searchPattern];
    }
    
    // Bulk create accounts
    public static List<Id> createMultipleAccounts(List<Map<String, String>> accountDataList) {
        List<Account> accountsToInsert = new List<Account>();
        for (Map<String, String> data : accountDataList) {
            accountsToInsert.add(new Account(
                Name = data.get('Name'),
                Type = data.get('Type')
            ));
        }
        insert accountsToInsert;
        List<Id> insertedIds = new List<Id>();
        for (Account acc : accountsToInsert) {
            insertedIds.add(acc.Id);
        }
        return insertedIds;
    }
    
    // Bulk delete accounts by name test
    public static void deleteAccountsByName(String accountName) {
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name = :accountName];
        delete accountsToDelete;
    }
}