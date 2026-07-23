public class AccountManager{
    public static Account createAccount(String name, String industry) {
        Account newAccount = new Account();
        newAccount.Name = name;
        newAccount.Industry = industry;
        insert newAccount;
        return newAccount;
    }

    public static void updateAccountName(Id accountId, String newName) {
        Account existingAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
        existingAccount.Name = newName;
        update existingAccount;
    }

    public static Account getAccountById(Id accountId) {
        return [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId LIMIT 1];
    }
    
    public static void deleteAccount(Id accountId) {
        Account existingAccount = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        delete existingAccount;
    }
}