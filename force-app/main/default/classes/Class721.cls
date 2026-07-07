public class Class721 {
    public static void Method(){
        String s='Test';
        String d='Test';
        List<TestObj__c> listObj = [SELECT Id, Text__c FROM TestObj__c LIMIT 10];
        if (!listObj.isEmpty()){
            s = listObj[0].Text__c;
        }
        System.debug(s);
    }
}