/**
 * Batch class that links random ContentDocument records to all Accounts.
 */
public class ContentLink implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * List of ContentDocument records to be linked to Accounts.
     */
    private List<ContentDocument> contentDocuments;

    /**
     * Initializes the batch by querying up to 500 ContentDocument records.
     */
    public ContentLink() {
        this.contentDocuments = [
            SELECT Id
            FROM ContentDocument
            LIMIT 500
        ];
    }

    /**
     * Provides a query locator for all Account records.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account LIMIT 900000
        ]);
    }

    /**
     * Links a random ContentDocument to each Account in the batch scope.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>) scope;
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        Integer docsCount = contentDocuments.size();
        if (docsCount == 0) {
            System.debug('No content documents available.');
            return;
        }

        for (Account acc : accounts) {
            Integer rnd = Math.abs(Crypto.getRandomInteger());
            Integer randomIndex = Math.mod(rnd, docsCount); // используем Math.mod вместо %

            links.add(new ContentDocumentLink(
                ContentDocumentId = contentDocuments[randomIndex].Id,
                LinkedEntityId = acc.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }

        if (!links.isEmpty()) {
            insert links;
        }
    }

    /**
     * Logs completion of the batch process.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
    }
}
//thats_a_test_commit