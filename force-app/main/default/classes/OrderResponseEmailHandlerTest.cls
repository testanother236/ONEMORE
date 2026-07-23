@isTest
private class OrderResponseEmailHandlerTest {
  @isTest
  static void testHandleInboundEmail_Approved() {
      // Create a test Opportunity
      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity',
          StageName = 'Prospecting',
          CloseDate = Date.today().addDays(30)
      );
      insert testOpportunity;

      // Update the Opportunity to retrieve the Invoice_Number__c value
      testOpportunity = [
          SELECT Id, Invoice_Number__c
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];

      // Create a test inbound email
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      email.subject = testOpportunity.Invoice_Number__c; // Use the invoice number from the test Opportunity
      email.plainTextBody = 'approved.';

      Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
      envelope.fromAddress = 'test@example.com';

      // Create an instance of the handler and process the inbound email
      OrderResponseEmailHandler handler = new OrderResponseEmailHandler();
      Messaging.InboundEmailResult result = handler.handleInboundEmail(
          email,
          envelope
      );

      // Verify that the Opportunity was updated
      Opportunity updatedOpportunity = [
          SELECT StageName
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];
      System.assertEquals(
          'Qualification',
          updatedOpportunity.StageName,
          'Opportunity stage should be updated to Qualification.'
      );

      // Verify that one email was sent
      System.assertEquals(
          1,
          Limits.getEmailInvocations(),
          'One email should have been sent.'
      );
  }

  @isTest
  static void testHandleInboundEmail_Rejected() {
      // Create a test Opportunity
      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity Rejected',
          StageName = 'Prospecting',
          CloseDate = Date.today().addDays(30)
      );
      insert testOpportunity;

      // Update the Opportunity to retrieve the Invoice_Number__c value
      testOpportunity = [
          SELECT Id, Invoice_Number__c
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];

      // Create a test inbound email
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      email.subject = testOpportunity.Invoice_Number__c; // Use the invoice number from the test Opportunity
      email.plainTextBody = 'rejected.';

      Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
      envelope.fromAddress = 'test@example.com';

      // Create an instance of the handler and process the inbound email
      OrderResponseEmailHandler handler = new OrderResponseEmailHandler();
      Messaging.InboundEmailResult result = handler.handleInboundEmail(
          email,
          envelope
      );

      // Verify that the Opportunity was updated
      Opportunity updatedOpportunity = [
          SELECT StageName
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];
      System.assertEquals(
          'Closed Lost',
          updatedOpportunity.StageName,
          'Opportunity stage should be updated to Closed Lost.'
      );

      // Verify that one email was sent
      System.assertEquals(
          1,
          Limits.getEmailInvocations(),
          'One email should have been sent.'
      );
  }

  @isTest
  static void testHandleInboundEmail_NoInvoiceNumber() {
      // Create a test inbound email without an invoice number
      Messaging.InboundEmail email = new Messaging.InboundEmail();
      email.subject = 'Order Confirmation';
      email.plainTextBody = 'The order has been approved.';

      Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
      envelope.fromAddress = 'test@example.com';

      // Create an instance of the handler and process the inbound email
      OrderResponseEmailHandler handler = new OrderResponseEmailHandler();
      Messaging.InboundEmailResult result = handler.handleInboundEmail(
          email,
          envelope
      );

      // Verify that no Opportunities were updated
      List<Opportunity> opportunities = [
          SELECT Id
          FROM Opportunity
          WHERE Name = 'Test Opportunity' OR Name = 'Test Opportunity Rejected'
      ];
      System.assertEquals(
          0,
          opportunities.size(),
          'No Opportunity should be updated.'
      );
  }
}