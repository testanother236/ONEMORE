public class myOpptyController {
    public List<Opportunity> opptyList {get;set;}
    public Contact primaryContact {get;set;}//awdawdawdawdaw
    public Id oppId {get;set;}//awdawdawdawdaw

    public myOpptyController() {
        //opportunity ID from currentpage
        oppId = ApexPages.currentPage().getParameters().get('Id');//awdawdawdawdaw
        //create list of opportunity and products
        opptyList = getOpptyList();
        //create string with needed information about client
        primaryContact = getPrimaryContact();

    }
    public List<Opportunity> getOpptyList() {//awdawdawdawdaw
        return [SELECT Id,Name,Account.Name, Amount, Invoice_Number__c,
        (SELECT Quantity, UnitPrice, TotalPrice, PricebookEntry.Name FROM OpportunityLineItems)
        FROM Opportunity WHERE Id=: oppId];
    }

    public Contact getPrimaryContact() {//awdawdawdawdaw
        return [SELECT Id,Name,Phone,Email,Account.Name FROM Contact WHERE Id IN (SELECT ContactId
        FROM OpportunityContactRole WHERE OpportunityId = :oppId AND IsPrimary = TRUE) LIMIT 1];//awdawdawdawdaw
    }

}//awdawdawdawdaw