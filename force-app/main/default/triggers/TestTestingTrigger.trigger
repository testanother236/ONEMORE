trigger TestTestingTrigger on Custom_Account__c (before insert) {
	System.debug('Hello World!');
}