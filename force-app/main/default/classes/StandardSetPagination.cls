public with sharing class StandardSetPagination
{
    Public Integer noOfRecords{get; set;}
    Public Integer size{get; set;}
    public String searchStr{get; set;}
    
    public ApexPages.StandardSetController setCon {get;set;}
    
    public StandardSetPagination()
    {
        //refresh();
        refresh();
        //refresh();
    }
     
    Public List<Account> getAccounts(){
        List<Account> accList = new List<Account>();
        for(Account a : (List<Account>)setCon.getRecords())
            accList.add(a);
        return accList;
    }
     
    public pageReference refresh() {
        size = 2;
        string queryString = 'Select Name, Type, BillingCity, BillingState, BillingCountry from Account order by Name';
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        return null;
    }
    
    public void searchRecs() {
        if(searchStr != null && searchStr != '') {
            size = 2;
            string tempInput = searchStr + '%';
            string queryString = 'Select Name, Type, BillingCity, BillingState, BillingCountry from Account WHERE Name LIKE :tempInput order by Name';
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        }
    }
}