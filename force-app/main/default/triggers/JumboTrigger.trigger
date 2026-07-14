trigger JumboTrigger on Jumbo__c (after insert) {
    String emailAddresses = 'ravikantsaini91@gmail.com';
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new List<String>{emailAddresses});
    //mail.setCcAddresses(ccAddresses);
    //mail.setReplyTo('SMaster@gmail.com');
    mail.setSenderDisplayName('Support');
    mail.setSubject('Mail has been sent');
    //mail.setBccSender(false);
    //mail.setUseSignature(false);
    mail.setPlainTextBody('Your Email has been sent');
    //mail.setTargetObjectId(temp.Id);
    //mail.setWhatId(temp.Id);
    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
    for (Attachment a : [select Name, Body, BodyLength from Attachment where Id= '00P28000009tDgn'])
    {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(a.Name);
        efa.setBody(a.Body);
        fileAttachments.add(efa);
    }
    mail.setFileAttachments(fileAttachments);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
}