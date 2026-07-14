public with sharing class LogController
{
    public String recId{get;set;}
    
    public String getRunTestLog()
    {
        String logStr = '';
        List<Attachment> attList = new List<Attachment>();
        attList = [SELECT Id,Name,BODY FROM Attachment WHERE ParentId=:recId LIMIT 1];
        if(attList.size() == 1)
        {
            logStr = attList[0].Body.toString();
        }
        else
            logStr = 'Log Not Found.'+recId;
        return logStr;
    }
}