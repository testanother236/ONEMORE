public class AccountService {
    
    // Method to get a list of accounts
    public List<Account> getAccounts() {
        // Query to retrieve all account records
        return [SELECT Id, Name FROM Account];
    }

    // Method to create a new account
    public Account createAccount(String accountName) {
        Account newAccount = new Account(Name = accountName);
        try {
            insert newAccount;
            return newAccount;
        } catch (DmlException e) {
            System.debug('Ошибка при создании аккаунта: ' + e.getMessage());
            return null;
        }
    }

    // Method to update an existing account
    public Account updateAccount(Id accountId, String newName) {
        try {
            Account existingAccount = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
            existingAccount.Name = newName;
            update existingAccount;
            return existingAccount;
        } catch (DmlException e) {
            System.debug('Ошибка при обновлении аккаунта: ' + e.getMessage());
            return null;
        }
    }

    // Method to delete an account
    public void deleteAccount(Id accountId) {
          try {
               Account existingAccount = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
                delete existingAccount;
            } catch (DmlException e) {
                System.debug('Ошибка при удалении аккаунта: ' + e.getMessage());
            }
    }
    
    public List<Account> getAccounts(String nameFilter) {
    String query = 'SELECT Id, Name FROM Account';
    
    if (!String.isEmpty(nameFilter)) {
        query += ' WHERE Name LIKE :nameFilter';
    }
    
    return Database.query(query);
    }
}