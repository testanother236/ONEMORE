public class batchHappyBirthdayMail implements
                Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Id emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name =: 'contactHappyBirthday'].get(0).Id; //getting email template id
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT ID, Name, Birthdate, AccountId, Email FROM Contact WHERE Birthdate = TODAY'
        );
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        // process each batch of records
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for (Contact cont : scope) {
            Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(emailTemplate, cont.Id, cont.AccountId);

            String[] toAddresses = new String[]{cont.Email};//adawdawdawdaw
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject(emailMessage.subject);//adawdawdawdaw
            mail.setHtmlBody('<h3>'+emailMessage.plainTextBody + '</h3>');
            mail.setReplyTo('noreply@successmotors.com'); //our email in email service
            mailList.add(mail);
            recordsProcessed = recordsProcessed + 1;
        }//adawdawdawdaw
        Messaging.sendEmail(mailList);
    }
    public void finish(Database.BatchableContext bc){//adawdawdawdaw
        System.debug(recordsProcessed + ' records processed. Happy Birthday!');//adawdawdawdaw
    }
}//adawdawdawdaw