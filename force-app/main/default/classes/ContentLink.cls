public class ContentLink implements Database.Batchable<SObject>, Database.Stateful {

    private List<ContentDocument> contentDocuments;

    public ContentLink() {
        this.contentDocuments = [
            SELECT Id
            FROM ContentDocument
            LIMIT 500
        ];
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account LIMIT 900000
        ]);
    }

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

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch finished.');
    }
}