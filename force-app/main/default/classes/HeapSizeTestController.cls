public with sharing class HeapSizeTestController
{
    transient public List<Wraper> li{get;set;}
    public HeapSizeTestController()
    {
        li = new List<Wraper>();
    }
    
    @RemoteAction
    public Static List<Wraper> testHeapSize()
    {
        try
        {
            try
            {
                List<Wraper> li = new List<Wraper>();
                for(Attachment acc: [Select Id,Name,Body From Attachment])
                {
                    li.add(new Wraper(acc.Name,EncodingUtil.base64Encode(acc.Body)));
                }
                return li;
            }
            catch(Exception e)
            {
                
            }
        }
        catch(Exception e)
        {
            
        }
        return null;
    } 
    
    public void testHeapSize2()
    {
        li = new List<Wraper>();
        for(Attachment acc: [Select Id,Name,Body From Attachment])
        {
            li.add(new Wraper(acc.Name,EncodingUtil.base64Encode(acc.Body)));
        }

    }
    
    Public class Wraper
    {
        public String Name;
        public String Body;
        
        public Wraper(String Name,String Body)
        {
            this.Name = Name;
            this.Body = Body;
        }
    }
}