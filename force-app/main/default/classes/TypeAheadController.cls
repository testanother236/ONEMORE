public with sharing class TypeAheadController
{
    public TypeAheadController()
    {
        
    }
    
    @RemoteAction
    public static List<sObject> retrieveSameRecords(String text, String objectName, String fieldName, List<String> fieldLi)
    {
        String query = 'SELECT ';
        String midQuery = '';
        for(String fieldStr : fieldLi)
        {
            if(midQuery == '')
                midQuery += fieldStr;
            else
                midQuery += ','+fieldStr;
        }
        String endQuery = ' FROM '+objectName+' WHERE '+fieldName+' LIKE \''+text+'%\' LIMIT 10';
        System.debug(query+midQuery+endQuery);
        return Database.query(query+midQuery+endQuery);
    }
}