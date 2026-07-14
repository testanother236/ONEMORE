public with sharing class MomentJSExample
{
    public String localZoneStr{get;set;}
    
    public MomentJSExample()
    {
        localZoneStr = UserInfo.getTimeZone().getID();
    }
    /*public MomentJSExample()
    {
        localZoneStr = UserInfo.getTimeZone().getID();
    }*/
}