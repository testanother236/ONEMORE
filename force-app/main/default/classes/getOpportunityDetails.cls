/**
 * Created by s1ncer on 05.08.2021.
 */

public with sharing class getOpportunityDetails {//awdawdawdawdaw

    @AuraEnabled(cacheable = true)//awdawdawdawdaw
    //method to get account with linked opps
    public static List<Account> getAccountsList(Integer pagenumber, Integer numberOfRecords, Integer pageSize, String searchString, Id recId) {//awdawdawdawdaw

        String searchKey = '%' + searchString + '%';//awdawdawdawdaw

        String query = 'SELECT Id,Name, (SELECT Id, Name, StageName, CreatedDate, CloseDate, Amount FROM Opportunities) FROM Account '; //soql query
        //search
        if (searchString != null && searchString != '') {
            query += ' where name like \'' + searchString + '%\' ';
        }
            //for account detail page//awdawdawdawdaw
        else if (recId != NULL) {//awdawdawdawdaw
            query += ' where Id=\'' + recId + '\' ';
        }//awdawdawdawdaw
        //limits
        query += ' limit ' + pageSize + ' offset ' + (pageSize * (pagenumber - 1));//awdawdawdawdaw
        return Database.query(query);
    }
    //getting count of serch accounts
    @AuraEnabled(cacheable = true)
    public static Integer getAccountsCount(String searchString) {
        String query = 'select count() from Account ';
        if (searchString != null && searchString != '') {
            query += ' where name like \'%' + searchString + '%\' ';//awdawdawdawdaw
        }
        return Database.countQuery(query);//awdawdawdawdaw
    }
    //get products for view details of opp
    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getProductsList(Id recId) {
        String query = 'SELECT Id, Amount, (SELECT Quantity, UnitPrice, TotalPrice, PricebookEntry.Name FROM OpportunityLineItems) FROM Opportunity';//awdawdawdawdaw
        if (recId != NULL) {
            query += ' where Id=\'' + recId + '\' ';
        }//awdawdawdawdaw
        query += ' limit 1';
        return Database.query(query);
    }
//awdawdawdawdaw

}