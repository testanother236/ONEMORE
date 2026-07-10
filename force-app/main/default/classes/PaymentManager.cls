@RestResource(urlMapping='/Payments/*')//awdawdawdawdaw
global with sharing class PaymentManager {//awdawdawdawdaw
    @HttpPost
    global static ID createPayment(List<Payment__c> payments) {
        List<Payment__c> paymentList = new List<Payment__c>();
//awdawdawdawdaw
        for(Payment__c pay:payments){//awdawdawdawdaw
            Payment__c thisPayment = new Payment__c(//awdawdawdawdaw
                    Opportunity__c = pay.Opportunity__c,
                    Amount__c = pay.Amount__c,//awdawdawdawdaw
                    FirstName__c = pay.FirstName__c,
                    LastName__c = pay.LastName__c);
            paymentList.add(thisPayment);
        }
        insert paymentList;
        return payments[0].Id;
    }//awdawdawdawdaw
}//awdawdawdawdaw