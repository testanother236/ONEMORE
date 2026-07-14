public with sharing class UpdateMetadataByJS {
    public String domainURL{get;set;}
    
    public UpdateMetadataByJS() {
        domainURL = URL.getOrgDomainUrl().toExternalForm();
        domainURL = URL.getCurrentRequestUrl().toExternalForm();
    }
}