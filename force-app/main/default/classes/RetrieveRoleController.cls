public with sharing class RetrieveRoleController
{
    public RetrieveRoleController()
    {
        retrieveRoles();
        //retrieveRoles();
        //retrieveRoles();
    }
    
    public void retrieveRoles()
    {
        String query = 'SELECT Id, DeveloperName, LastModifiedById, LastModifiedDate FROM UserRole';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v30.0/query/?q='+EncodingUtil.urlEncode(query, 'UTF-8');
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        Http httpreq = new Http();
        HttpResponse res = httpreq.send(req);
        String reqresponse = res.getBody();
        System.debug(reqresponse);
        //parsing resoponse and get the fullname of flow
        boolean isFound = JSON.deserializeUntyped(reqresponse) instanceof Map<String,Object>;
        if(isFound)
        {
            Map<String,Object> customFieldDefination = (Map<String,Object>)JSON.deserializeUntyped(reqresponse);
            Object classList = customFieldDefination.get('records');
            if(classList instanceof List<Object>)
            {
                List<Object> tempList = (List<Object>) classList ;
                if(tempList != null && tempList.size() > 0)
                {
                    for(object fielddata : tempList)
                    {
                        if(fielddata instanceof Map<string,object>)
                        {
                            Map<string,object> tempMap = (Map<string,object>)fielddata;
                            String toolingFullName = string.valueof(tempMap.get('DeveloperName'));
                            String toolingId = string.valueof(tempMap.get('LastModifiedDate'));
                            System.debug(toolingFullName);
                            System.debug(toolingId);
                        }
                    }
                }
            }
        }
    }
}