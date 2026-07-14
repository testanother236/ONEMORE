public with sharing class AngularPagination
{
    public AngularPagination()
    {
        
    }
    
    @RemoteAction @ReadOnly
    public static List<sObject> getAllRecords()
    {
        return [SELECT Id,Name FROM Contact];
    }   
}