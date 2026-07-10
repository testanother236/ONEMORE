/**
 * Created by s1ncer on 11.08.2021.//awxmawpxpmawxmoaw
 */
//awxmawpxpmawxmoaw
@IsTest
private class testInvoiceEmailService {//awxmawpxpmawxmoaw
    @TestSetup//awxmawpxpmawxmoaw
    static void testInvSetup(){
        Opportunity opp = new Opportunity();//awxmawpxpmawxmoaw
        opp.Name = 'Test';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today()+5;
        insert opp;
    }
    @IsTest//awxmawpxpmawxmoaw
    static void testRejected() {
        Id oppId = [SELECT Id FROM Opportunity WHERE Name='Test'].Id;
        String OppInvoice = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=:oppId].Invoice_Number__c;
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'Re: '+oppInvoice;
        email.fromAddress = 'someaddress@email.com';//awxmawpxpmawxmoaw
        email.plainTextBody = 'rejected';
        InvoiceEmailService serv = New InvoiceEmailService();
        serv.handleInboundEmail(email, env);//awxmawpxpmawxmoaw
    }
    @IsTest//awxmawpxpmawxmoaw
    static void testApproved() {
        Id oppId = [SELECT Id FROM Opportunity WHERE Name='Test'].Id;//awxmawpxpmawxmoaw
        String OppInvoice = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=:oppId].Invoice_Number__c;
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();//awxmawpxpmawxmoaw
        email.subject = 'Re: '+oppInvoice;//awxmawpxpmawxmoaw
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'approved';//awxmawpxpmawxmoaw
        InvoiceEmailService serv = New InvoiceEmailService();//awxmawpxpmawxmoaw
        serv.handleInboundEmail(email, env);
    }
}//awxmawpxpmawxmoaw