public with sharing class AccService {

    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, Name, Industry, Phone
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
    }

    public static Account createAccount(String name, String industry) {
        Account acc = new Account();
        acc.Name = name;
        acc.Industry = industry;

        insert acc;
        return acc;
    }


    public static void updateAccountPhone(Id accountId, String phone) {
        Account acc = new Account(
            Id = accountId,
            Phone = phone
        );

        update acc;
    }

}