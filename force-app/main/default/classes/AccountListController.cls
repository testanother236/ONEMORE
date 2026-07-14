public class AccountListController {
    
    @AuraEnabled
    public static List<Account> getAccountList(List<String> fieldNames){
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
        str+= ' FROM Account';//stettest 
        return Database.query(str);
    }
}