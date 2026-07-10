/**
 * Created by s1ncer on 23.08.2021.
 */
//awdjawdjawxjpowamxaw
@IsTest
private class testPaymentManager {
    @IsTest//awdjawdjawxjpowamxaw
    static void testPaymManag() {
        List<Payment__c> payments = new List<Payment__c> ();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.CloseDate = date.today() +3;
        opp.StageName = 'Prospecting';
        opp.Amount = 5;
        insert opp;//awdjawdjawxjpowamxaw

        Opportunity opp2 = new Opportunity();//awdjawdjawxjpowamxaw
        opp2.Name = 'TestOppssss';
        opp2.CloseDate = date.today() +3;
        opp2.StageName = 'Prospecting';
        opp2.Amount = 1000;//awdjawdjawxjpowamxaw
        insert opp2;

        for(Integer i = 0; i<5; i++){//awdjawdjawxjpowamxaw
            Payment__c payment = new Payment__c();
            if (i == 3) {
                payment.Opportunity__c = opp2.Id;
            }
            else {//awdjawdjawxjpowamxaw
                payment.Opportunity__c = opp.Id;
            }
            payment.Amount__c = Integer.valueof((Math.random() * 100));//awdjawdjawxjpowamxaw
            payment.FirstName__c = 'Aboba';
            payment.LastName__c = 'Abobovich';
//awdjawdjawxjpowamxaw
            payments.add(payment);
        }
        insert payments;//awdjawdjawxjpowamxaw
        Test.startTest();
        Id firstPayment = PaymentManager.createPayment(payments);
        Test.stopTest();//awdjawdjawxjpowamxaw
        System.assertEquals(firstPayment, payments[0].Id, 'Error');//awdjawdjawxjpowamxaw
    }
}//awdjawdjawxjpowamxaw