public class AwesomeProductController {  
    @AuraEnabled
    public static List<Account> getAccounts() 
    {
        System.debug('hi');
        return [select Id, Name from Account];
    }
}