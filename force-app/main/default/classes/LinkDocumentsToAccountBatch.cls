
/**
 * Batch class that links ContentDocument records to Account records in a configurable manner.
 */
public class LinkDocumentsToAccountBatch implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * Enumerates the linking modes this batch can use.
     */
    public enum LinksType { AccountsPool, NewAccounts }

    /**
     * The selected linking mode for the current batch execution.
     */
    private LinksType type;

    /**
     * Number of links to create per processed document.
     */
    private Integer linksPerAccount;
    
    /**
     * Pool of accounts used when linking type is AccountsPool.
     */
    private List<Account> accountsPool;

    /**
     * The last account Id processed when linking new accounts incrementally.
     */
    private Id lastAccountId;

    /**
     * Current index in the accounts list for distributing links.
     */
    private Integer accountIndex = 0;
    
    /**
     * Counter for the total number of documents processed so far.
     */
    private Integer documentsProcessed = 0;

    /**
     * Cumulative count of successfully created document links.
     */
    private Integer linksCreated = 0;

    /**
     * Cumulative count of duplicate-value errors encountered during link insertion.
     */
    private Integer duplicateErrors = 0;

    /**
     * Constructor that initializes the batch with a link type and the number of links per document.
     */
    public LinkDocumentsToAccountBatch(LinksType type, Integer linksPerAccount) {
        this.linksPerAccount = linksPerAccount;
        this.type = type;
        
        if (type == LinksType.AccountsPool) {
            accountsPool = [
                SELECT Id 
                FROM Account 
                WHERE Id != null
                ORDER BY CreatedDate
                LIMIT :linksPerAccount
            ];
            
            for (Account acc : accountsPool) {
                System.debug('   - ' + acc.Id);
            }
        }
    }
    
    /**
     * Returns a QueryLocator for all ContentDocument records ordered by creation date.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {  
        return Database.getQueryLocator([
            SELECT Id, Title 
            FROM ContentDocument 
            ORDER BY CreatedDate
        ]);
    }
    
    /**
     * Processes a batch of ContentDocument records, filters out documents with existing links, and creates new links to Account records based on the configured linking strategy.
     */
    public void execute(Database.BatchableContext bc, List<ContentDocument> scope) {
        Map<Id, Integer> linkCountMap = new Map<Id, Integer>();
        for (AggregateResult ar : [SELECT ContentDocumentId, COUNT(Id) cnt 
                                   FROM ContentDocumentLink 
                                   WHERE ContentDocumentId IN :scope 
                                   GROUP BY ContentDocumentId]) {
            linkCountMap.put((Id)ar.get('ContentDocumentId'), (Integer)ar.get('cnt'));
        }
        
        List<ContentDocument> docsToProcess = new List<ContentDocument>();
        for (ContentDocument doc : scope) {
            Integer count = linkCountMap.containsKey(doc.Id) ? linkCountMap.get(doc.Id) : 0;
            if (count <= 1) {
                docsToProcess.add(doc);
            }
        }
        
        List<Account> accountsToLink = new List<Account>();
        
        if (type == LinksType.NewAccounts) {
            accountsToLink = [
                SELECT Id 
                FROM Account 
                WHERE Id > :lastAccountId
                ORDER BY Id 
                LIMIT :linksPerAccount * docsToProcess.size()
            ];
            
            if (!accountsToLink.isEmpty()) {
                lastAccountId = accountsToLink[accountsToLink.size() - 1].Id;
            }
        } else {
            accountsToLink = accountsPool;
        }
        
        if (accountsToLink.isEmpty() || docsToProcess.isEmpty()) {
            System.debug('No accounts or documents to process');
            return;
        }
        
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        Set<Id> processedDocIds = new Set<Id>();
        
        for (ContentDocument doc : docsToProcess) {
            processedDocIds.add(doc.Id);
            
            for (Integer i = 0; i < linksPerAccount; i++) {
                if (accountIndex >= accountsToLink.size()) {
                    accountIndex = 0;
                }
                
                Account acc = accountsToLink[accountIndex];
                
                linksToInsert.add(new ContentDocumentLink(
                    ContentDocumentId = doc.Id,
                    LinkedEntityId = acc.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
                
                accountIndex++;
            }
            
            documentsProcessed++;
        }
        
        if (!linksToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(linksToInsert, false);
            
            Integer successCount = 0;
            Integer failCount = 0;
            
            for (Database.SaveResult result : results) {
                if (result.isSuccess()) {
                    successCount++;
                } else {
                    failCount++;
                    for (Database.Error err : result.getErrors()) {
                        if (err.getStatusCode() == StatusCode.DUPLICATE_VALUE) {
                            duplicateErrors++;
                        }
                    }
                }
            }
            
            linksCreated += successCount;
            System.debug('Created ' + successCount + ' links, ' + failCount + ' failed');
            System.debug('Pool ' + accountsToLink.size() + ' accounts. Type: ' + type);
        }
        
        if (type == LinksType.AccountsPool && accountIndex >= accountsPool.size()) {
            accountIndex = 0;
        }
    }
    
    /**
     * Logs the final processing statistics after the batch completes.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug('Documents processed: ' + documentsProcessed);
        System.debug('Links created: ' + linksCreated);
        System.debug('Duplicate errors: ' + duplicateErrors);
    }
}
