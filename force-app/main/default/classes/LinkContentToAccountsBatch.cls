public class LinkContentToAccountsBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Id contentDocumentId;

    public LinkContentToAccountsBatch(Id contentVersionId) {
        // Получаем связанный ContentDocumentId
        ContentVersion cv = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersionId
            LIMIT 1
        ];
        this.contentDocumentId = cv.ContentDocumentId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Берём все аккаунты (можно ограничить, если нужно)
        return Database.getQueryLocator([
            SELECT Id FROM Account
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for (Account acc : scope) {
            links.add(new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = acc.Id,
                ShareType = 'V',  // Viewer
                Visibility = 'AllUsers'
            ));
        }

        insert links;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('✅ Linking complete for ContentDocumentId = ' + contentDocumentId);
    }
}