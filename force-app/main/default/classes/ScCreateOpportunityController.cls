public with sharing class ScCreateOpportunityController {
    @AuraEnabled
    public static Id createOpportunity(String name, Decimal amount) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.Amount = amount;
        opp.Type = 'New Customer';
        opp.LeadSource = 'Partner Referral';
        opp.OrderNumber__c = String.valueOf(generateRandomSixDigitNumber());
        opp.TrackingNumber__c = String.valueOf(generateRandomSixDigitNumber());
        opp.CloseDate = System.today().addMonths(1);
        opp.StageName = 'Prospecting';
        opp.DeliveryInstallationStatus__c = 'In progress';
        
        try {
            insert opp;
            return opp.Id; // Return the ID of the created Opportunity
        } catch (DmlException e) {
            // Handle the DML exception
            throw new AuraHandledException('Failed to create Opportunity: ' + e.getMessage());
        }
    }

    private static Integer generateRandomSixDigitNumber() {
        // Generate a random number between 100000 and 999999
        return Integer.valueOf(Math.round(Math.random() * 899999) + 100000);
    }
}