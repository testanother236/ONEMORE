public with sharing class OpptiesOverAmountApex {
    public OpptiesOverAmountApex() {}

        @AuraEnabled(cacheable=true)
        public static Opportunity getOpptyOverAmount(){
        return [SELECT Id, Name,amount FROM Opportunity LIMIT 1];
     }
      @AuraEnabled(cacheable=true)
        public static Opportunity updateOpptyStage(){
        return [SELECT Id, Name FROM Opportunity LIMIT 1];
     }


    
}