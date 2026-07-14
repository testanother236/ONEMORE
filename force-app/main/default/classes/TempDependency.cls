public with sharing class TempDependency
{
    public TempDependency()
    {
        Metadata_Item__c meta = new Metadata_Item__c();
        meta.Attachment_Id__c = '';
        meta.CRC32__c = '';
        meta.File_Name__c = '';
        meta.Full_Name__c = '';
        meta.Last_Modified_By__c ='';
        meta.Last_Modified_Date_Source_Org__c = Date.today();
    }
}