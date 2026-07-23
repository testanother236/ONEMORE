@isTest
public class InvoiceGeneratorTest {
  
  @isTest
  static void testGenerateInvoice() {
    // Create a test Opportunity
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert testOpportunity; // Insert the test Opportunity

    // Start the test for generating an invoice
    Test.startTest();
    String pdfUrl = InvoiceGenerator.generateInvoice(testOpportunity.Id); // Generate the invoice
    Test.stopTest();

    // Assert that the URL is not null
    System.assertNotEquals(null, pdfUrl, 'The PDF URL must not be empty');
    // Assert that the URL contains the document download path
    System.assert(
      pdfUrl.contains('/sfc/servlet.shepherd/document/download/'),
      'URL should contain the document path'
    );
  }

  @isTest
  static void testAttachInvoice() {
    // Create a test Opportunity
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert testOpportunity; // Insert the test Opportunity

    // Create a mock PDF document
    ContentVersion testContentVersion = new ContentVersion(
      Title = 'Test PDF',
      PathOnClient = 'Test.pdf',
      VersionData = Blob.valueOf('Test PDF Content')
    );
    insert testContentVersion; // Insert the mock PDF

    // Retrieve the document ID
    String mockContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :testContentVersion.Id
      LIMIT 1
    ].ContentDocumentId;

    // Attach the PDF to the Opportunity
    Test.startTest();
    InvoiceGenerator.attachInvoice(
      testOpportunity.Id,
      '/sfc/servlet.shepherd/document/download/' + mockContentDocumentId
    );
    Test.stopTest();

    // Assert that the link was created
    List<ContentDocumentLink> links = [
      SELECT Id
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :testOpportunity.Id
    ];
    System.assertEquals(
      1,
      links.size(),
      'There should be one ContentDocumentLink created'
    );
  }

  @isTest
  static void testGenerateInvoiceWithExistingVersion() {
    // Create a test Opportunity
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert testOpportunity; // Insert the test Opportunity

    // Generate the first PDF invoice
    String pdfUrl = InvoiceGenerator.generateInvoice(testOpportunity.Id);
    String documentId = pdfUrl.split('/')[5]; // Get the document ID from the URL

    // Regenerate the invoice
    Test.startTest();
    String newPdfUrl = InvoiceGenerator.generateInvoice(testOpportunity.Id);
    Test.stopTest();

    // Assert that a new document was created with a different ID
    String newDocumentId = newPdfUrl.split('/')[5];
    System.assertNotEquals(
      documentId,
      newDocumentId,
      'The new document must have a different ID than the previous one.'
    );
  }

  @isTest
  static void testAttachInvoiceAlreadyLinked() {
    // Create a test Opportunity
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert testOpportunity; // Insert the test Opportunity

    // Create a mock PDF document
    ContentVersion testContentVersion = new ContentVersion(
      Title = 'Test PDF',
      PathOnClient = 'Test.pdf',
      VersionData = Blob.valueOf('Test PDF Content')
    );
    insert testContentVersion; // Insert the mock PDF

    // Retrieve the document ID
    String mockContentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :testContentVersion.Id
      LIMIT 1
    ].ContentDocumentId;

    // Attach the PDF to the Opportunity
    InvoiceGenerator.attachInvoice(
      testOpportunity.Id,
      '/sfc/servlet.shepherd/document/download/' + mockContentDocumentId
    );

    // Attempt to attach the same document again
    Test.startTest();
    InvoiceGenerator.attachInvoice(
      testOpportunity.Id,
      '/sfc/servlet.shepherd/document/download/' + mockContentDocumentId
    );
    Test.stopTest();

    // Assert that only one link was created
    List<ContentDocumentLink> links = [
      SELECT Id
      FROM ContentDocumentLink
      WHERE LinkedEntityId = :testOpportunity.Id
    ];
    System.assertEquals(
      1,
      links.size(),
      'One Content Document Link must be created.'
    );
  }
}