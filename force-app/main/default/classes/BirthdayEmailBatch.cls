global class BirthdayEmailBatch implements Database.Batchable<SObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    // Get all contacts with birthdays today.
    String soql = 'SELECT Id, Birthdate, Email FROM Contact Where Birthdate != null';
    return Database.getQueryLocator(soql);
  }

  global void execute(Database.BatchableContext BC, List<SObject> scope) {
    List<Contact> contactsToNotify = new List<Contact>();
    Date today = Date.today();
    for (SObject record : scope) {
      Contact contact = (contact) record;
      Date birthdate = contact.Birthdate;
      if (
        birthdate != null &&
        birthdate.month() == today.month() &&
        birthdate.day() == today.day()
      ) {
        contactsToNotify.add(contact);
      }
    }

    if (!contactsToNotify.isEmpty()) {
      List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
      for (Contact contact : contactsToNotify) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ contact.Email });
        email.setTemplateId(
          [
            SELECT Id
            FROM EmailTemplate
            WHERE Name = 'BirthdayNotication'
            LIMIT 1
          ]
          .Id
        );
        email.setTargetObjectId(contact.Id);
        email.setSaveAsActivity(false);
        emails.add(email);
      }

      Messaging.sendEmail(emails);
    }
  }

  global void finish(Database.BatchableContext BC) {
    // Logic at the end of the batch, if required
  }
}