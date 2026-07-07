
/**
 * This class is responsible for linking content documents to accounts in a batch process.
 */
public class ContentLink implements Database.Batchable<SObject>, Database.Stateful {

    private List<ContentDocument> contentDocuments;

    /**
     * Initializes a new instance of the ContentLink class and loads content documents.
     */
    public ContentLink() {
        this.contentDocuments = [
            SELECT Id
            FROM ContentDocument
            LIMIT 500
        ];
    }

    /**
     * Prepares the initial data required for processing in batch execution.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account LIMIT 900000
        ]);
    }

    /**
     * Executes the batch process for linking content documents to accounts.
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
            Integer randomIndex = Math.mod(rnd, docsCount);

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
     * Performs any final actions after the batch job has completed.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
    }
}
