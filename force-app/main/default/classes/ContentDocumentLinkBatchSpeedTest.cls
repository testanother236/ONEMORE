public class ContentDocumentLinkBatchSpeedTest implements Database.Batchable<SObject>, Database.Stateful {
    
    private Double totalTime = 0;
    private Integer totalRecords = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM ContentDocument');
    }
    
    public void execute(Database.BatchableContext bc, List<ContentDocument> scope) {
        Long batchStartTime = System.currentTimeMillis();
        Integer batchRecords = 0;
        
        for (ContentDocument doc : scope) {
            Long startTime = System.currentTimeMillis();
            
            List<ContentDocumentLink> results = [
                SELECT Id FROM ContentDocumentLink 
                WHERE ContentDocumentId = :doc.Id
            ];
            
            Long endTime = System.currentTimeMillis();
            Long executionTime = endTime - startTime;
            totalTime += executionTime;
            batchRecords += results.size();
        }
        
        totalRecords += batchRecords;
        System.debug('Обработано документов: ' + scope.size());
        System.debug('Найдено связей в этой партии: ' + batchRecords);
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Итоговое время выполнения: ' + ((totalTime) / 1000) + ' секунд');
        System.debug('Всего найдено записей: ' + totalRecords);
        System.debug('Среднее время на запрос: ' + (totalTime / totalRecords) + ' мс');
    }
}