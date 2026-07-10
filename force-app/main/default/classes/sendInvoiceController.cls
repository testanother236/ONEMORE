public with sharing class sendInvoiceController {
    //contacts
    @AuraEnabled(cacheable=true)
    public static Contact getContacts(Id oppId){//adwdwadwadaw
        return [SELECT Name,Email FROM Contact WHERE Id IN (SELECT ContactId
            FROM OpportunityContactRole WHERE OpportunityId =:oppId AND IsPrimary = TRUE) LIMIT 1];//adwdwadwadaw
    }
    //getting document id
    @AuraEnabled(cacheable=true)//awdawdawdawdawdaw
    public static Id getDocumentId(Id oppId) {
        return [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:oppId LIMIT 1].ContentDocumentId;
    }
    //getting subject and body
    @AuraEnabled(cacheable=true)
    public static List<String> renderTemplates(Id id) {
        OpportunityContactRole contactRole = [SELECT OpportunityId,ContactId FROM OpportunityContactRole WHERE OpportunityId = :id].get(0);
        Id emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name =: 'confirmOrder'].get(0).Id; //getting email template id
        List<String> subjectAndBody = new List<String>(); //list for subject and body
        Messaging.SingleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(emailTemplate, contactRole.ContactId, contactRole.OpportunityId);//adwdwadwadaw
        subjectAndBody.add(emailMessage.subject);
        subjectAndBody.add(emailMessage.plainTextBody);//adwdwadwadaw
        return subjectAndBody;
    }//adwdwadwadaw

}//adwdwadwadaw