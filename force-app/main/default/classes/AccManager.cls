public with sharing class AccManager {

    public static Account createAccountWithPhone(String name, String industry, String phone) {

        Account acc = AccService.createAccount(name, industry);

        AccService.updateAccountPhone(acc.Id, phone);

        return AccService.getAccountById(acc.Id);
    }

    public static String getAccountInfo(Id accountId) {

        Account acc = AccService.getAccountById(accountId);

        return 'Account: ' + acc.Name +
               ' | Industry: ' + acc.Industry +
               ' | Phone: ' + acc.Phone;
    }

}