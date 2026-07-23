public with sharing class sendInvoceController {
    
  // Method to get the primary contact associated with an Opportunity
  @AuraEnabled(cacheable=true)
  public static OpportunityContactRole getOpportunityContact(Id opportunityId) {
      // Check if the user has access to OpportunityContactRole
      if (!Schema.sObjectType.OpportunityContactRole.isAccessible()) {
          throw new AuraHandledException(
              'Insufficient permissions to access OpportunityContactRole.'
          );
      }

      // Retrieve the primary contact for the given Opportunity
      List<OpportunityContactRole> contactRoles = [
          SELECT Contact.Name, Contact.Email
          FROM OpportunityContactRole
          WHERE OpportunityId = :opportunityId AND IsPrimary = TRUE
          LIMIT 1
      ];

      if (contactRoles.isEmpty()) {
          // If no primary contact is found, return null
          return null;
      }

      return contactRoles[0]; // Return the primary contact role
  }

  // Method to get email template data for a specific Opportunity
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getEmailTemplateData(Id opportunityId, String customerName) {
      // Check read permissions for Opportunity
      if (!Schema.sObjectType.Opportunity.isAccessible()) {
          throw new AuraHandledException(
              'Insufficient permissions to access Opportunity.'
          );
      }
      
      // Retrieve the Opportunity
      Opportunity opp = [
          SELECT Id, Invoice_Number__c
          FROM Opportunity
          WHERE Id = :opportunityId
          LIMIT 1
      ];

      // Check read permissions for EmailTemplate
      if (!Schema.sObjectType.EmailTemplate.isAccessible()) {
          throw new AuraHandledException(
              'Insufficient permissions to access EmailTemplate.'
          );
      }

      // Retrieve the email template
      EmailTemplate template = [
          SELECT Subject, HtmlValue
          FROM EmailTemplate
          WHERE DeveloperName = 'Invoice_Notification'
          LIMIT 1
      ];

      // Replace placeholders in subject and body
      String emailSubject = opp.Invoice_Number__c;
      String emailBody = template.HtmlValue
          .replace('{!Contact.FirstName}', customerName) // Replace with actual customer name
          .replace('{!Opportunity.Invoice_Number__c}', opp.Invoice_Number__c);

      // Remove HTML tags from emailBody
      emailBody = removeHtmlTags(emailBody);

      // Return subject and body as a Map
      return new Map<String, String>{
          'subject' => emailSubject,
          'body' => emailBody
      };
  }

  // Method to remove HTML tags from a string
  private static String removeHtmlTags(String html) {
      return html.replaceAll('<[^>]+>', ''); // Replace HTML tags with an empty string
  }

  // Method to generate a PDF for the given Opportunity
  @AuraEnabled
  public static String generateInvoicePDF(Id opportunityId) {
      // Check read permissions for Opportunity
      if (!Schema.sObjectType.Opportunity.isAccessible()) {
          throw new AuraHandledException(
              'Insufficient permissions to access Opportunity.'
          );
      }

      // Retrieve the Opportunity
      Opportunity opp = [
          SELECT Id, Name, Invoice_Number__c
          FROM Opportunity
          WHERE Id = :opportunityId
          LIMIT 1
      ];

      // Create PageReference for generating PDF
      PageReference pdfPage = Page.Invoice; // Replace with your Visualforce page name
      pdfPage.getParameters().put('id', opp.Id);

      Blob pdfBlob;

      if (Test.isRunningTest()) {
          // Return a test Blob when running tests
          pdfBlob = Blob.valueOf('Unit.Test');
      } else {
          // Generate PDF content
          pdfBlob = pdfPage.getContent();
          if (pdfBlob == null) {
              throw new CustomException('Error: PDF Blob is null.');
          }
      }

      // Return PDF as a base64 string
      return EncodingUtil.base64Encode(pdfBlob);
  }

  // Method to send an email with the given subject and body
  @AuraEnabled
  public static void sendEmail(String subject, String body, String recipientEmail) {
      // Convert HTML to plain text
      String plainTextBody = convertHtmlToPlainText(body);
      // Create email message
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setSubject(subject);
      email.setPlainTextBody(plainTextBody);
      email.setToAddresses(new List<String>{ recipientEmail });

      email.setReplyTo(
          'orderconfirmationservice@t-205m8pkbcsekl8ychmpa8j5tuq1x39wd54a08csiy1uli0h5sf.bm-8it10eaa.usa876.apex.salesforce.com'
      );

      // Send the email
      Messaging.SendEmailResult[] results = Messaging.sendEmail(
          new List<Messaging.SingleEmailMessage>{ email }
      );

      // Check for errors in sending email
      for (Messaging.SendEmailResult result : results) {
          if (!result.isSuccess()) {
              throw new AuraHandledException(
                  'Error sending email: ' + result.getErrors()[0].getMessage()
              );
          }
      }
  }

  // Method to convert HTML to plain text
  private static String convertHtmlToPlainText(String html) {
      // Remove HTML tags using a regular expression
      return html.replaceAll('<[^>]*>', ''); // Remove all tags
  }
}