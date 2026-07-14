public class FieldSetTestTriggerHandler {
    public void beforeInsert(List<TempTest__FieldSetTest__c> newList){
        for(TempTest__FieldSetTest__c rec : newList){
            rec.Name = 'Test';
        }
    }
}