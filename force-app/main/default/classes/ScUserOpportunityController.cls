public with sharing class ScUserOpportunityController {
    @AuraEnabled(cacheable=true)
    public static List<OpportunityWrapper> getMyOpportunities() {
        // Get the current user's ID
        Id currentUserId = UserInfo.getUserId();
        
        // Query Opportunities owned by the current user
        List<Opportunity> opportunities = [
            SELECT Id, Name, Type, OrderNumber__c, StageName, Amount, CloseDate, LeadSource, 
                   TrackingNumber__c, MainCompetitors__c, DeliveryInstallationStatus__c, CurrentGenerators__c
            FROM Opportunity 
            WHERE OwnerId = :currentUserId
        ];

        // Create a list to hold the Opportunity wrappers
        List<OpportunityWrapper> wrappers = new List<OpportunityWrapper>();
        for (Opportunity opp : opportunities) {
            // Add each Opportunity to the wrapper list
            wrappers.add(new OpportunityWrapper(opp));
        }
        return wrappers; // Return the list of wrappers
    }

    // Wrapper class for Opportunity
    public class OpportunityWrapper {
        @AuraEnabled
        public String opportunityName { get; set; }
        @AuraEnabled
        public Id opportunityId { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String stage { get; set; }
        @AuraEnabled
        public Decimal amount { get; set; }
        @AuraEnabled
        public Date closeDate { get; set; }
        @AuraEnabled
        public String leadSource { get; set; }
        @AuraEnabled
        public String trackingNumber { get; set; }
        @AuraEnabled
        public String mainCompetitors { get; set; }
        @AuraEnabled
        public String deliveryInstallationStatus { get; set; }
        @AuraEnabled
        public String currentGenerators { get; set; }
        @AuraEnabled
        public String orderNumber { get; set; }


        // Constructor for the OpportunityWrapper
        public OpportunityWrapper(Opportunity opp) {
            // Concatenate Name, Type, and Order Number for display
            this.opportunityName = opp.Name + ' ' + opp.Type + ' ' + opp.OrderNumber__c; // Ensure field names are correct
            this.opportunityId = opp.Id;
            this.type = opp.Type;
            this.stage = opp.StageName;
            this.amount = opp.Amount;
            this.orderNumber = opp.OrderNumber__c;
            this.closeDate = opp.CloseDate;
            this.leadSource = opp.LeadSource;
            this.trackingNumber = opp.TrackingNumber__c;
            this.mainCompetitors = opp.MainCompetitors__c;
            this.deliveryInstallationStatus = opp.DeliveryInstallationStatus__c;
            this.currentGenerators = opp.CurrentGenerators__c;
        }
    }
}