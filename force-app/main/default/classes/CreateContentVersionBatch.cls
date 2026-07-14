public class CreateContentVersionBatch implements Database.Batchable<Integer>, Database.Stateful {
    public Integer totalCreated = 0;
    public Integer targetAmount;
    public Integer batchSize;

    public CreateContentVersionBatch(Integer target, Integer batchSize) {
        this.targetAmount = target;
        this.batchSize = batchSize;
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        List<Integer> scope = new List<Integer>();
        for (Integer i = 0; i < (targetAmount / batchSize); i++) {
            scope.add(i);
        }
        return scope;
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        for (Integer i = 0; i < batchSize; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'StressTest_Doc_' + (totalCreated + i);
            cv.PathOnClient = 'test_' + Crypto.getRandomInteger() + '.txt';
            cv.VersionData = Blob.valueOf('1');
            cv.IsMajorVersion = true;
            cvList.add(cv);
        }

        try {
            insert cvList;
            totalCreated += cvList.size();
            System.debug('Создано документов: ' + totalCreated);
        } catch (Exception e) {
            System.debug('Лимит достигнут или ошибка: ' + e.getMessage());
            System.abortJob(bc.getJobId());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Итого создано: ' + totalCreated);
    }
}