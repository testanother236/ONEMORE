public class CountContentLinksBatchNoField implements Database.Batchable<SObject>, Database.Stateful {

    // Храним в памяти (stateful) результаты подсчёта: AccountId -> count
    private Map<Id, Integer> counts = new Map<Id, Integer>();

    // Сколько верхних записей вывести в finish()
    private Integer topN = 10;

    public CountContentLinksBatchNoField() {
        // можно поменять topN через конструктор при необходимости
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Берём все аккаунты (можно ограничить в WHERE или добавить фильтры)
        return Database.getQueryLocator([
            SELECT Id FROM Account
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>) scope;
        if (accounts.isEmpty()) return;

        // Собираем Id аккаунтов текущего батча
        Set<Id> accIds = new Set<Id>();
        for (Account a : accounts) accIds.add(a.Id);

        // Агрегируем ContentDocumentLink по аккаунтам в батче
        Map<Id, Integer> localCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT LinkedEntityId linkedId, COUNT(Id) cnt
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accIds
            GROUP BY LinkedEntityId
        ]) {
            Id linkedId = (Id) ar.get('linkedId');
            Integer cnt = ((Long) ar.get('cnt')).intValue();
            localCounts.put(linkedId, cnt);
        }

        // Заполняем общую карту counts для finish()
        for (Account a : accounts) {
            Integer cnt = localCounts.containsKey(a.Id) ? localCounts.get(a.Id) : 0;
            counts.put(a.Id, cnt);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (counts.isEmpty()) {
            System.debug('No accounts processed or no ContentDocumentLink found.');
            return;
        }

        // Найдём топ N (простым алгоритмом — эффективно для ограниченного N)
        Map<Id, Integer> temp = new Map<Id, Integer>(counts);
        List<Id> topIds = new List<Id>();

        for (Integer i = 0; i < topN && !temp.isEmpty(); i++) {
            Id bestId = null;
            Integer bestVal = -1;
            for (Id idKey : temp.keySet()) {
                Integer val = temp.get(idKey);
                if (val > bestVal) {
                    bestVal = val;
                    bestId = idKey;
                }
            }
            if (bestId == null) break;
            topIds.add(bestId);
            temp.remove(bestId);
        }

        // Подгружаем имена аккаунтов для удобного вывода
        Map<Id, Account> accMap = new Map<Id, Account>();
        if (!topIds.isEmpty()) {
            for (Account a : [SELECT Id, Name FROM Account WHERE Id IN :topIds]) {
                accMap.put(a.Id, a);
            }
        }

        System.debug('=== TOP ' + String.valueOf(topIds.size()) + ' Accounts by ContentDocumentLink count ===');
        for (Id accId : topIds) {
            String name = accMap.containsKey(accId) ? accMap.get(accId).Name : '(no name)';
            Integer cnt = counts.get(accId);
            System.debug(name + ' (' + accId + ') -> ' + String.valueOf(cnt));
        }

        // Дополнительно: можно отправить уведомление, создать записи в кастомном объекте
        // или сохранить результаты где-то ещё — напиши, если нужно сохранять.
    }
}