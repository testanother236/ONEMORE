public with sharing class GitHubController
{
    public String clientId = '633a6ddc016777a22344';
    public String clientSecret = 'aa7e773fc3d3ddc476ef38eeaaaf602305bd8db9';
    
    private String accessToken;
    private String tokenType;
    
    public String code{get; set;}
    
    public String authUrl{get; set;}
    
    public GitHubController()
    {
    	authUrl = '';
    	code = ApexPages.currentPage().getParameters().get('code');
        System.debug('code---'+code);
    }
    
    public void authorize()
    {
    	System.debug('code----'+code);       
        String endpoint = 'https://github.com/login/oauth/access_token?'+
        				  'client_id='+clientId+
        				  '&client_secret='+clientSecret+
        				  '&code='+code;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Accept' ,'application/json');
        Http h = new Http();
        HttpResponse res;
        res= h.send(req);
        String resp = res.getBody();
        System.debug(resp);
        Map<String,String> jsnMap = new Map<String,String>();
		jsnMap = (Map<String,String>) JSON.deSerialize(resp,Map<String,String>.class);
        if(res.getStatusCode() == 200 && jsnMap.containsKey('access_token'))
        {
        	accessToken = jsnMap.get('access_token');
        	tokenType = jsnMap.get('token_type');
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Authentication successfull with GitHub.'));
        }
        else
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Authentication unsuccessfull with GitHub.'));
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resp));
    }
    
    public void directAuth()
    {
    	System.debug('code----'+code);       
        String endpoint = 'https://github.com/login/oauth/?';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept' ,'application/json');
        req.setHeader('Authorization',accessToken);
        Http h = new Http();
        HttpResponse res;
        res= h.send(req);
        String resp = res.getBody();
        System.debug(resp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resp));
    }
    
    public PageReference gitAuth()
	{
		authUrl = '';
		String redirect_uri = URL.getSalesforceBaseUrl().toExternalForm()+''+Page.AuthInner.getUrl();
		System.debug('redirect_uri----'+redirect_uri);
		authUrl = gitAuthUri(clientId , redirect_uri);
		return null;
	}
	
	// method for return ful uri for authorization 
	public String gitAuthUri(String cid,String callback_uri)
	{
		String key = EncodingUtil.urlEncode(cid , 'UTF-8');
		String uri = EncodingUtil.urlEncode(callback_uri , 'UTF-8');
		String base_url = 'https://github.com/login/oauth/authorize?' ;
		String final_uri;
			final_uri= base_url 
			+ '&client_id=' + clientId
			+ '&redirect_uri=' + uri; 
		return final_uri;
	}
	
}