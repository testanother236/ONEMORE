public class ContentDocumentLinkDeleteLimitedBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private Integer totalDocsProcessed = 0;
    private Integer totalLinksDeleted = 0;
    private Set<Id> failedDocIds = new Set<Id>();
    private List<Id> usersIds = new List<Id>();
    private List<Id> orgsIds = new List<Id>();
    
    private Integer leaveCount = 0;
    
    public ContentDocumentLinkDeleteLimitedBatch(Integer leaveCount) {
        this.leaveCount = leaveCount;
        
        for (User u : [SELECT Id FROM User]) {
            usersIds.add(u.Id);
        }
        for (Organization o : [SELECT Id FROM Organization]) {
            orgsIds.add(o.Id);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM ContentDocument ORDER BY Id
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<ContentDocument> scope) {
        Set<Id> docIds = new Set<Id>();
        for (ContentDocument doc : scope) {
            docIds.add(doc.Id);
        }

        List<ContentDocumentLink> allLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :docIds
            AND LinkedEntityId NOT IN :usersIds
            AND LinkedEntityId NOT IN :orgsIds
            ORDER BY ContentDocumentId DESC
        ];
        
        Map<Id, List<ContentDocumentLink>> linksByDocument = new Map<Id, List<ContentDocumentLink>>();
        for (ContentDocumentLink link : allLinks) {
            if (!linksByDocument.containsKey(link.ContentDocumentId)) {
                linksByDocument.put(link.ContentDocumentId, new List<ContentDocumentLink>());
            }
            linksByDocument.get(link.ContentDocumentId).add(link);
        }
        
        List<ContentDocumentLink> linksToDelete = new List<ContentDocumentLink>();
        for (Id docId : linksByDocument.keySet()) {
            List<ContentDocumentLink> docLinks = linksByDocument.get(docId);
            
            if (docLinks.size() > leaveCount) {
                for (Integer i = leaveCount; i < docLinks.size(); i++) {
                    linksToDelete.add(docLinks[i]);
                }
            }
        }
        
        if (!linksToDelete.isEmpty()) {
            Database.DeleteResult[] results = Database.delete(linksToDelete, false);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    totalLinksDeleted++;
                } else {
                    failedDocIds.add(linksToDelete[i].ContentDocumentId);
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Error for Doc ' + linksToDelete[i].ContentDocumentId + ': ' + err.getMessage());
                    }
                }
            }
        }
        
        totalDocsProcessed += scope.size();
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Total docs processed: ' + totalDocsProcessed);
        System.debug('Total links deleted: ' + totalLinksDeleted);
        System.debug('Docs with errors: ' + failedDocIds.size());
    }
}