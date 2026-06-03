public class AccountHelper {
    // Method to get account count based on a specific criteria
    public static Integer getAccountCountByType(String accountType) {
        return [SELECT COUNT() FROM Account WHERE Type = :accountType];
    }

    // Method to update account names
    public static void updateAccountNames(List<Id> accountIds, String newName) {
        List<Account> accountsToUpdate = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        for (Account acc : accountsToUpdate) {
            acc.Name = newName;
        }
        update accountsToUpdate;
    }
}