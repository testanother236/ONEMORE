public with sharing class VFRetrievalControl
{
    public static Integer version = 36;
    
    public VFRetrievalControl()
    {
        //public static Integer version = 45;
    }
    
    public static MetadataService.MetadataPort createService(String session, String instance)
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.timeout_x = 120000;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = session == null ? UserInfo.getSessionId(): session;
        service.setEndpoint_x(instance);     
        return service;
    }
    
    
    @RemoteAction
    public static MetadataService.FileProperties[] listMetadataItems(String MetaDataType)
    {     
        MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());              
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.folder = '';
        queryLayout.type_x = MetaDataType;
        queries.add(queryLayout);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, version );
        return fileProperties ;
    }
    
    @RemoteAction
    public static String createRetrievalRequest(String retrieveJson)
    {
        if(retrieveJson != null && retrieveJson != '')
        {
            Map<String,Set<String>> retrieveMap = new Map<String,Set<String>>();
            retrieveMap = (Map<String,Set<String>>) JSON.deserialize(retrieveJson, Map<String,Set<String>>.class);
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());              
            MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
            retrieveRequest.apiVersion = version ;
            retrieveRequest.packageNames = null;//new List<String>{'SDocs'};
            retrieveRequest.singlePackage = true;
            retrieveRequest.specificFiles = new List<String>();
            retrieveRequest.unpackaged = new MetadataService.Package_x();
            retrieveRequest.unpackaged.apiAccessLevel = 'Unrestricted';
            retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
            for(string keyType : retrieveMap.keySet())
            {
                MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
                packageType.name = keyType ;
                List<String> membersLi = new List<String>(retrieveMap.get(keyType));
                packageType.members = membersLi;
                retrieveRequest.unpackaged.types.add(packageType);
            }
            MetadataService.AsyncResult AsyncResult = service.retrieve_x(retrieveRequest);
            return AsyncResult.Id;
        }
        return null;
    }
    
    @RemoteAction
    public static MetadataService.RetrieveResult checkRequestRetrieveStatus(String asyncId)
    {
        if(asyncId != null && asyncId != '')
        {
            // Check the status of the retrieve request
            MetadataService.MetadataPort service = createService(UserInfo.getSessionId(),URL.getSalesforceBaseUrl().toExternalForm());
            MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(asyncId,true);
            return retrieveResult;
        }
        return null;
    }
}