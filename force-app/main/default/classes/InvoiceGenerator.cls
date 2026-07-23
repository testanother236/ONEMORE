public with sharing class InvoiceGenerator {
  
  @AuraEnabled
  public static String generateInvoice(Id opportunityId) {
    // Check if the Opportunity object is queryable
    if (!Schema.sObjectType.Opportunity.isQueryable()) {
      throw new CustomException(
        'There are no permissions to read Opportunity.'
      );
    }

    // Retrieve the Opportunity by ID
    Opportunity opp = [
      SELECT Id, Invoice_Number__c
      FROM Opportunity
      WHERE Id = :opportunityId
      LIMIT 1
    ];

    // Generate PDF using Visualforce
    PageReference pdfPage = Page.Invoice; // Reference to the Visualforce page
    pdfPage.getParameters().put('id', opportunityId); // Pass the opportunity ID as a parameter
    Blob pdfBlob;

    if (Test.isRunningTest()) {
      // Return a test Blob during unit tests
      pdfBlob = Blob.valueOf('Unit.Test');
    } else {
      // Generate the PDF
      pdfBlob = pdfPage.getContentAsPDF();
      if (pdfBlob == null) {
        throw new CustomException('Error: PDF Blob is null.');
      }
    }

    // Define the filename for the PDF
    String fileName = opp.Invoice_Number__c + '.pdf';

    // Check permissions to create a ContentVersion
    if (!Schema.sObjectType.ContentVersion.isCreateable()) {
      throw new CustomException(
        'There are no rights to create ContentVersion.'
      );
    }

    String contentDocumentId;

    // Check if a version with the same title already exists
    List<ContentVersion> existingVersions = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Title = :fileName
      LIMIT 1
    ];

    if (existingVersions.isEmpty()) {
      // Create a new document if it does not exist
      ContentVersion newDoc = new ContentVersion();
      newDoc.Title = fileName;
      newDoc.PathOnClient = fileName;
      newDoc.VersionData = pdfBlob;

      try {
        insert newDoc; // Insert the new document
        contentDocumentId = newDoc.ContentDocumentId; // Get the document ID
      } catch (Exception e) {
        throw new CustomException(
          'Error creating the document: ' + e.getMessage()
        );
      }
    } else {
      // Update the existing version if it already exists
      ContentVersion existingDoc = existingVersions[0];

      // Create a new version of the existing document
      ContentVersion newVersion = new ContentVersion();
      newVersion.ContentDocumentId = existingDoc.ContentDocumentId;
      newVersion.Title = fileName;
      newVersion.PathOnClient = fileName;
      newVersion.VersionData = pdfBlob;

      try {
        insert newVersion; // This creates a new version of the existing document
        contentDocumentId = existingDoc.ContentDocumentId; // Get the document ID
      } catch (Exception e) {
        throw new CustomException(
          'Error creating new version of the document: ' + e.getMessage()
        );
      }
    }

    // Return the URL for accessing the document
    return '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
  }

  @AuraEnabled
  public static void attachInvoice(Id opportunityId, String pdfUrl) {
    // Check permissions to create a ContentDocumentLink
    if (!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
      throw new CustomException(
        'There are no rights to create ContentDocumentLink.'
      );
    }

    // Extract the document ID from the URL
    String contentDocumentId = pdfUrl.split('/')[5];

    // Check if a link between the document and the Opportunity already exists
    List<ContentDocumentLink> existingLinks = [
      SELECT Id
      FROM ContentDocumentLink
      WHERE
        ContentDocumentId = :contentDocumentId
        AND LinkedEntityId = :opportunityId
      LIMIT 1
    ];

    // If no link is found, create a new one
    if (existingLinks.isEmpty()) {
      ContentDocumentLink link = new ContentDocumentLink();
      link.ContentDocumentId = contentDocumentId;
      link.LinkedEntityId = opportunityId;
      link.ShareType = 'V'; // 'V' for view access

      try {
        insert link; // Insert the new link
      } catch (Exception e) {
        throw new CustomException(
          'Error attaching the document: ' + e.getMessage()
        );
      }
    } else {
      System.debug('Document is already attached to the Opportunity.');
    }
  }

  // Custom exception class for handling specific errors
  public class CustomException extends Exception {
  }
}