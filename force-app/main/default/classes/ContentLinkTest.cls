
@isTest
public class ContentLinkTest {

    /**
     * Tests the batch execution when ContentDocuments exist.
     * Verifies that for each Account a ContentDocumentLink is created,
     * and the linked ContentDocumentId belongs to the set of existing documents.
     */
    @isTest
    static void testBatchWithContentDocuments() {
        // Create ContentDocuments indirectly via ContentVersion
        ContentVersion cv1 = new ContentVersion(
            Title = 'Test Document 1',
            PathOnClient = 'doc1.txt',
            VersionData = Blob.valueOf('Test content 1')
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Test Document 2',
            PathOnClient = 'doc2.txt',
            VersionData = Blob.valueOf('Test content 2')
        );
        insert new List<ContentVersion>{ cv1, cv2 };

        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;

        // Retrieve the auto‑generated ContentDocument IDs
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocument cd : [
            SELECT Id FROM ContentDocument WHERE Title LIKE 'Test Document%'
        ]) {
            contentDocIds.add(cd.Id);
        }
        System.assert(contentDocIds.size() >= 2, 'At least two ContentDocuments should exist');

        Test.startTest();
        ContentLink batch = new ContentLink();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify ContentDocumentLink records
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accounts
        ];
        System.assertEquals(accounts.size(), links.size(), 'One link per Account expected');

        for (ContentDocumentLink link : links) {
            System.assert(contentDocIds.contains(link.ContentDocumentId),
                'Linked ContentDocument must be one of the existing ones');
        }
    }

    /**
     * Tests the batch when no ContentDocuments are present.
     * The execute method should log a debug message and not create any links.
     */
    @isTest
    static void testBatchWithNoContentDocuments() {
        // Ensure no ContentDocuments exist in the org
        delete [SELECT Id FROM ContentDocument];

        // Create Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'NoDoc Account ' + i));
        }
        insert accounts;

        Test.startTest();
        ContentLink batch = new ContentLink();  // constructor finds zero documents
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // No ContentDocumentLink should be inserted
        System.assertEquals(
            0,
            [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId IN :accounts],
            'No links expected when zero ContentDocuments exist'
        );
    }

    /**
     * Tests the start() method directly to ensure it returns a QueryLocator
     * targeting the Account object.
     */
    @isTest
    static void testStartMethod() {
        Test.startTest();
        ContentLink batch = new ContentLink();
        Database.QueryLocator locator = batch.start(null);
        // Verify the underlying query contains 'Account'
        System.assert(locator.getQuery().contains('Account'),
            'QueryLocator should query the Account object');
        Test.stopTest();
    }

    /**
     * Tests the finish() method to ensure it runs without exceptions.
     */
    @isTest
    static void testFinishMethod() {
        Test.startTest();
        ContentLink batch = new ContentLink();
        // The finish method simply outputs a debug message
        batch.finish(null);
        System.assert(true, 'Finish method executed successfully');
        Test.stopTest();
    }
}
