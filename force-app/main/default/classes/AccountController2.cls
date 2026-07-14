public class AccountController2 {
    
    @AuraEnabled
    public static List<Account> getAccountList(List<String> fieldNames){
        ////tstsede
        String str = 'SELECT ';
        for(String fieldName : fieldNames){
            
            if(str == 'SELECT '){
                str+= fieldName;
            }
            else{
                str+= ','+fieldName;
            } 
        }
        str+= ' FROM Account';
        return Database.query(str);
    }
    
    @AuraEnabled
    public static List<Contact> getContactList(List<String> fieldNames, String accountID){
        //
        String str = 'SELECT ';
        for(String fieldName : fieldNames){
            
            if(str == 'SELECT '){
                str+= fieldName;
            }
            else{
                str+= ','+fieldName;
            } 
        }
        str+= ' FROM Contact WHERE AccountId=:accountID';
        return Database.query(str);
    }
    
    @AuraEnabled
    public static List<Opportunity> getOppList(List<String> fieldNames, String accountID){
        String str = 'SELECT ';
        for(String fieldName : fieldNames){
            
            if(str == 'SELECT '){
                str+= fieldName;
            }
            else{
                str+= ','+fieldName;
            } 
        }
        str+= ' FROM Opportunity WHERE AccountId=:accountID';
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = Database.query(str);
        return oppList;
    }
}