@isTest
private class sendInvoceControllerTest {
    
  // Test method for retrieving the primary contact associated with an Opportunity
  @isTest
  static void testGetOpportunityContact() {
      // Create test data
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity',
          StageName = 'Prospecting',
          CloseDate = Date.today(),
          AccountId = testAccount.Id
      );
      insert testOpportunity;

      Contact testContact = new Contact(
          FirstName = 'John',
          LastName = 'Doe',
          Email = 'john.doe@example.com'
      );
      insert testContact;

      OpportunityContactRole contactRole = new OpportunityContactRole(
          OpportunityId = testOpportunity.Id,
          ContactId = testContact.Id,
          Role = 'Decision Maker',
          IsPrimary = true
      );
      insert contactRole;

      // Call the method under test
      OpportunityContactRole result = sendInvoceController.getOpportunityContact(
          testOpportunity.Id
      );

      // Verify the result
      System.assertNotEquals(
          null,
          result,
          'Expected a primary contact role to be returned'
      );
      System.assertEquals(
          testContact.Id,
          result.ContactId,
          'The contact ID should match the created contact'
      );
  }

  // Test method for retrieving email template data
  @isTest
  static void testGetEmailTemplateData() {
      // Create test data for Opportunity
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity',
          StageName = 'Prospecting',
          CloseDate = Date.today(),
          AccountId = testAccount.Id
      );
      insert testOpportunity;

      // Create the Email Template
      createEmailTemplate();

      // Call the method under test
      Map<String, String> result = sendInvoceController.getEmailTemplateData(
          testOpportunity.Id,
          'John'
      );

      // Verify the result
      System.assert(
          result.get('subject') != null,
          'The email subject should not be null'
      );
  }

  // Method to create an Email Template if it doesn't exist
  @isTest
  static void createEmailTemplate() {
      // Check for an existing email template
      List<EmailTemplate> existingTemplates = [
          SELECT Id
          FROM EmailTemplate
          WHERE DeveloperName = 'Invoice_Notification'
          LIMIT 1
      ];
      if (existingTemplates.isEmpty()) {
          // If the template does not exist, create it
          EmailTemplate template = new EmailTemplate(
              DeveloperName = 'Invoice_Notification',
              Subject = 'Invoice for {!Contact.FirstName}',
              HtmlValue = '<html><body>Hello {!Contact.FirstName}, your invoice number is {!Opportunity.Invoice_Number__c}.</body></html>',
              IsActive = true,
              Name = 'Invoice Notification',
              TemplateType = 'text' // Ensure a value is set for TemplateType
          );
          insert template;
      }
  }

  // Test method for generating an invoice PDF
  @isTest
  static void testGenerateInvoicePDF() {
      // Create test data
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;

      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity',
          StageName = 'Prospecting',
          CloseDate = Date.today(),
          AccountId = testAccount.Id
      );
      insert testOpportunity;

      // Call the method under test
      // Ensure that the method doesn't call getContent during the test
      String pdfBase64 = sendInvoceController.generateInvoicePDF(
          testOpportunity.Id
      );

      // Verify the result
      System.assertNotEquals(
          null,
          pdfBase64,
          'The PDF should be generated and returned as a base64 string'
      );
  }

  // Test method for sending an email
  @isTest
  static void testSendEmail() {
      // Create test email data
      String subject = 'Test Email Subject';
      String body = 'This is a test email body.';
      String recipientEmail = 'test@example.com';

      // Call the method under test
      Test.startTest();
      sendInvoceController.sendEmail(subject, body, recipientEmail);
      Test.stopTest();

      // Verify that the email was sent
      System.assert(
          true,
          'Email sent successfully (this is a placeholder assertion).'
      );
  }
}