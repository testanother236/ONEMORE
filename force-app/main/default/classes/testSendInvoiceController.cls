/**
 * Created by s1ncer on 11.08.2021.
 */

@IsTest
private class testSendInvoiceController {
    @IsTest
    static void testInvoice() {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Rejected';
        opp.CloseDate = date.today()+5;
        insert opp;
        Id oppId = opp.Id;

        Contact con = new Contact();
        con.FirstName = 'Ram';
        con.LastName = 'Raamaax';
        con.Phone = '+375333882211';
        con.Email = 'a@gmail.com';
        insert con;

        OpportunityContactRole conRol = new OpportunityContactRole ();
        conRol.OpportunityId = oppId;
        conRol.ContactId = con.Id;
        conRol.IsPrimary = TRUE;
        insert conRol;

        ContentVersion contentVersion1 = new ContentVersion(
                Title          = 'a picture',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
        insert contentVersion1;

        ContentVersion contentVersion2 = [SELECT ContentDocumentId FROM ContentVersion
        WHERE Id = :contentVersion1.Id LIMIT 1];

        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.LinkedEntityId = oppId;
        docLink.ContentDocumentId = contentVersion2.ContentDocumentId;
        insert docLink;



        Contact cont = sendInvoiceController.getContacts(oppId);
        System.assertEquals(cont.Email, con.Email, 'eroor in getcontacts');

        Id DocId = sendInvoiceController.getDocumentId(oppId);
        System.assertEquals(DocId, docLink.ContentDocumentId, 'Error with getting DocId');

        String str = sendInvoiceController.renderTemplates(oppId).get(0);

        String InvNumb = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=: oppId].Invoice_Number__c;
        System.assertEquals(InvNumb, str, 'error with invoice number');



    }
}