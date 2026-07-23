public class AccountUtility {
    // Method to create a new Account
    public static Account createAccount(String name, String industry) {
        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.Industry = industry;
        insert newAccount;
        return newAccount;
    }

    // Method to update an existing Account's name
    public static void updateAccount(Id accountId, String newName) {
        Account existingAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
        existingAccount.Name = newName;
        update existingAccount;
    }

    // Method to delete an Account by Id
    public static void deleteAccount(Id accountId) {
        Account existingAccount = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        delete existingAccount;
    }

    // Method to retrieve an Account by Id
    public static Account getAccountById(Id accountId) {
        return [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId LIMIT 1];
    }
    
    // Method to get all Accounts
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name, Industry FROM Account];
    }

    // Method to get Accounts by Industry
    public static List<Account> getAccountsByIndustry(String industry) {
        return [SELECT Id, Name FROM Account WHERE Industry = :industry];
    }
}