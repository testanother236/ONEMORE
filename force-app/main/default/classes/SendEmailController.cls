public with sharing class SendEmailController {
    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String body, String toSend, String subject){
        try{//awdawdawdwadawdawdawdwa
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();//adwdwadwadaw
            String[] toAddresses = new String[] {toSend};
            mail.setToAddresses(toAddresses); //send to adress
            mail.setSubject(subject); //subject
            mail.setHtmlBody('<h3>'+ body + '</h3>'); //message
            mail.setReplyTo('invoiceconfirm@s-2q7x0z8j3xajfumt8a2z9xpjw9jtivi2hm3520qmosa6gimemh.5g-5vbfwea4.ap24.apex.salesforce.com'); //our email in email service
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}