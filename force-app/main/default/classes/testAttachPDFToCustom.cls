/**
 * Created by s1ncer on 11.08.2021.
 */

@IsTest
private class testAttachPDFToCustom {
    @TestSetup
    static void testSetupAttach(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Rejected';
        opp.CloseDate = date.today()+5;
        insert opp;

        Contact con = new Contact();
        con.FirstName = 'Ram';
        con.LastName = 'Raamaax';
        con.Phone = '+375333882211';
        insert con;

        OpportunityContactRole conRol = new OpportunityContactRole ();
        conRol.OpportunityId = opp.Id;
        conRol.ContactId = con.Id;
        conRol.IsPrimary = TRUE;
        insert conRol;
    }

    @IsTest
    static void testNewAttachPdf() {
        Id oppId = [SELECT Id FROM Opportunity WHERE Name='Test'].Id;
        ApexPages.CurrentPage().getParameters().put('id',oppId);//dwdawdawdaw
        attachPDFToCustom cv = new attachPDFToCustom();//dwdawdawdaw
        cv.savePdf();
//dwdawdawdaw
    }//dwdawdawdaw
    @IsTest//dwdawdawdaw
    static void testExistAttachPdf() {//dwdawdawdaw
        Id oppId = [SELECT Id FROM Opportunity WHERE Name='Test'].Id;
        String InvNum = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=:oppId].Invoice_Number__c;
        String pdfName = InvNum+'.pdf'; //name of ur invoice

        ContentVersion contentVersion1 = new ContentVersion(//dwdawdawdaw
                Title          = pdfName,//dwdawdawdaw
                PathOnClient   = pdfName,//dwdawdawdaw
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);//dwdawdawdaw
        insert contentVersion1;
        ContentVersion contentVersion2 = [SELECT ContentDocumentId FROM ContentVersion
        WHERE Id = :contentVersion1.Id LIMIT 1];//dwdawdawdaw
        ContentDocumentLink docLink = new ContentDocumentLink();//dwdawdawdaw
        docLink.LinkedEntityId = oppId;
        docLink.ContentDocumentId = contentVersion2.ContentDocumentId;
        insert docLink;//dwdawdawdaw
        ApexPages.CurrentPage().getParameters().put('id',oppId);
        attachPDFToCustom cv = new attachPDFToCustom();//dwdawdawdaw
        cv.savePdf();//dwdawdawdaw

    }
}