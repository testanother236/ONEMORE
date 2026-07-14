public class DeleteAccountFileLinksBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Параметры поведения
    private Boolean DRY_RUN = false; // Если true — не делает DML, только логирует
    private Boolean DELETE_ORPHAN_DOCUMENTS = false; // Если true — удаляет ContentDocument без связей

    // Статистика для finish()
    private Integer totalLinksFound = 0;
    private Integer totalLinksDeleted = 0;
    private Integer totalDocsDeleted = 0;
    private Set<Id> candidateDocIds = new Set<Id>();

    // start: перебираем аккаунты (или можно ограничить WHERE условиями)
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
        ]);
    }

    // execute: для пачки аккаунтов находим все ContentDocumentLink и удаляем их
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>) scope;
        if (accounts.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        for (Account a : accounts) accIds.add(a.Id);

        // Получаем ссылки на документы, связанные с этими аккаунтами
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accIds
        ];

        totalLinksFound += links.size();

        // Собираем candidate docIds (для возможного удаления документов)
        for (ContentDocumentLink l : links) {
            if (l.ContentDocumentId != null) candidateDocIds.add(l.ContentDocumentId);
        }

        if (DRY_RUN) {
            System.debug('[DRY RUN] Found ' + links.size() + ' ContentDocumentLink records for ' + accIds.size() + ' accounts.');
            // Для диагностики можно вывести часть
            Integer i = 0;
            for (ContentDocumentLink l : links) {
                if (i++ > 50) break;
                System.debug('[DRY RUN] Link: ' + l.Id + ' Doc: ' + l.ContentDocumentId + ' LinkedTo: ' + l.LinkedEntityId);
            }
            return;
        }

        // Удаляем ссылки пачками (в пределах execute-пакета это допустимо)
        if (!links.isEmpty()) {
            try {
                delete links;
                totalLinksDeleted += links.size();
            } catch (DmlException de) {
                // Если при удалении какие-то ошибки — логируем и пробуем частично (по одиночке)
                System.debug('Error deleting batch of links: ' + de.getMessage());
                for (ContentDocumentLink l : links) {
                    try {
                        delete l;
                        totalLinksDeleted++;
                    } catch (DmlException d2) {
                        System.debug('Failed to delete link ' + l.Id + ': ' + d2.getMessage());
                    }
                }
            }
        }
    }

    // finish: опционально удаляем osirotevshie ContentDocument (если включено)
    public void finish(Database.BatchableContext bc) {
        System.debug('DeleteAccountFileLinksBatch finished. Found links: ' + totalLinksFound + ', deleted links: ' + totalLinksDeleted);

        if (DRY_RUN) {
            System.debug('DRY_RUN enabled — no deletions performed. To perform deletion set DRY_RUN = false in the class.');
            return;
        }

        if (DELETE_ORPHAN_DOCUMENTS && !candidateDocIds.isEmpty()) {
            // Для каждого candidate doc проверяем, остались ли у него ссылки
            Set<Id> docsToDelete = new Set<Id>();
            for (AggregateResult ar : [
                SELECT ContentDocumentId docId, COUNT(Id) cnt
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :candidateDocIds
                GROUP BY ContentDocumentId
            ]) {
                Id docId = (Id) ar.get('docId');
                Integer cnt = ((Long) ar.get('cnt')).intValue();
                if (cnt == 0) {
                    docsToDelete.add(docId);
                }
            }

            // NOTE: AggregateResult above вернет только документы с COUNT>0, 
            // поэтому нам нужно вычислить разницу: candidates - keysOfAggregate
            // Поэтому пересчитаем правильно:
            Set<Id> docsWithLinks = new Set<Id>();
            for (AggregateResult ar2 : [
                SELECT ContentDocumentId docId, COUNT(Id) cnt
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :candidateDocIds
                GROUP BY ContentDocumentId
            ]) {
                docsWithLinks.add((Id) ar2.get('docId'));
            }
            for (Id c : candidateDocIds) {
                if (!docsWithLinks.contains(c)) docsToDelete.add(c);
            }

            if (!docsToDelete.isEmpty()) {
                try {
                    // Для удаления документов достаточно удалить ContentDocument; это удалит версии.
                    List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id IN :docsToDelete];
                    delete docs;
                    totalDocsDeleted += docs.size();
                    System.debug('Deleted orphan ContentDocument count: ' + docs.size());
                } catch (DmlException dex) {
                    System.debug('Error deleting ContentDocument(s): ' + dex.getMessage());
                }
            } else {
                System.debug('No orphan documents to delete.');
            }
        }

        System.debug('Summary: LinksFound=' + totalLinksFound + ', LinksDeleted=' + totalLinksDeleted + ', DocsDeleted=' + totalDocsDeleted);
    }
}