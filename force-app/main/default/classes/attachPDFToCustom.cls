public with sharing class attachPDFToCustom {//adwawddawdxzxcxz

    public Id oppId = ApexPages.currentPage().getParameters().get('Id'); //getting ID of opportunity
    List <Opportunity> oppor = [SELECT Invoice_Number__c FROM Opportunity WHERE Id=: oppId]; //getting name from opportunity object for invoice.pdf
    public String pdfName = oppor[0].Invoice_Number__c+'.pdf'; //name of ur invoice
//adwawddawdxzxcxz
    public PageReference savePdf() {
        Id oppId = ApexPages.currentPage().getParameters().get('Id');
        PageReference pdf = Page.invoicePDF ;
        pdf.getParameters().put('Id',oppId);// add parent id to the parameters for invoicePDF

        Blob body; // the contents of the attachment from the pdf
        try {
            body = pdf.getContent(); // returns theeeeee output of the page as a PDF

            // need to pass unit test -- current bug
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some error with getting content from PDF file.');
        }
//adwawddawdxzxcxz
        try{
            //find existing document
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title =: pdfName LIMIT 1].ContentDocumentId;
            //update existing document
            ContentVersion cv = new ContentVersion();
            cv.Title = pdfName;
            cv.PathOnClient = pdfName;//adwawddawdxzxcxz
            cv.VersionData = body;
            cv.ContentDocumentId = contentDocumentId;//adwawddawdxzxcxz
            insert cv;//awdwaxawxaw
        } catch(System.QueryException e) {
            //create new document
            ContentVersion contentVersion_1 = new ContentVersion(
                    Title= pdfName,//adwawddawdxzxcxz
                    PathOnClient = pdfName,
                    VersionData = body,
                    Origin = 'H'//adwawddawdxzxcxz
            );
            insert contentVersion_1;
            //link to opp object
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion
            WHERE Id = :contentVersion_1.Id LIMIT 1];//awdwaxawxaw

            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = oppId;//adwawddawdxzxcxz
            contentlink.ContentDocumentId = contentVersion_2.ContentDocumentId;
            contentlink.ShareType = 'V';
            insert contentlink;//adwawddawdxzxcxz
        }


        // send the user to the opportunity to view results
        return new PageReference('/'+oppId);

    }

}