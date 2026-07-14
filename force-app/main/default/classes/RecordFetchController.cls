public with sharing class RecordFetchController
{
    public String objectNameStr {get; set;}
    public List<String> fieldNamesLi {get; set;}
    
    //constructor
    public RecordFetchController()
    {
        testClassMethod();
    }
    
    public void testClassMethod()
    {
        //test
    }
    
    @RemoteAction
    public static List<sObject> listRecords(String objectName, String fieldNames,Integer queryLimit, String lastId)
    {
        String query = 'SELECT ';
        List<String> fieldLi = (List<String>) JSON.deserialize(fieldNames, List<String>.class);
        for(String fieldName : fieldNames.split(','))
        {
            if(query == 'SELECT ')
                query += fieldName;
            else
                query += ',' + fieldName;
        }
        if(lastId != null && lastId != '')
        {
            query += ' FROM '+objectName+' WHERE Id>:lastId ORDER BY Id LIMIT :queryLimit';
        }
        else
        {
            query += ' FROM '+objectName+' ORDER BY Id LIMIT :queryLimit';
        }
        return Database.query(query);
    }
}