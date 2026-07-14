trigger FieldSetTestTrigger on TempTest__FieldSetTest__c (before insert) {
	
    FieldSetTestTriggerHandler handler = new FieldSetTestTriggerHandler();
    if(Trigger.isBefore && Trigger.isInsert){
    	handler.beforeInsert(Trigger.New);//cc
    }
}