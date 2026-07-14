public with sharing class CreateMetadataByScriptController{

    public Integer noOfObjects{get;set;}
    public Integer noOfFields{get;set;}
    public Integer noOfOApexClass{get;set;}
    public String pageHeader{get;set;}
    public String componentHeader{get;set;}
    public Integer noOfOApexPage{get;set;}
    public Integer noOfOApexComponent{get;set;}
    public Integer noOfOApexTrigger{get;set;}
    
    public CreateMetadataByScriptController(){
        pageHeader = '<apex:page></apex:page>';
        componentHeader = '<apex:component></apex:component>';
        noOfObjects = 1;
        noOfFields = 0;
        noOfOApexClass = 1;
        noOfOApexPage = 1;
        noOfOApexComponent = 1;
        noOfOApexTrigger = 1;
    }
}