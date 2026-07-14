public with sharing class AuthenticateController
{
    public String userName{get; set;}
    public String password{get; set;}
    public String authUrl{get; set;}
    
    private String consumerKey = '3MVG9ZL0ppGP5UrB9fJWpS5im1YzPFNnLiuCOt0UAEzPsSJGuGfB6ga9Vk8wPkPffmfBZycJBBuexMT7mzAap';
    private String consumerSecret = '5894393955638732157';
    
    public AuthenticateController()
    {
        //consumerKey = '3MVG9ZL0ppGP5UrB9fJWpS5im1YzPFNnLiuCOt0UAEzPsSJGuGfB6ga9Vk8wPkPffmfBZycJBBuexMT7mzAap';
        //consumerSecret = '5894393955638732157';
    }
    
    public PageReference authorize()
    {
        authUrl =   'https://login.salesforce.com/services/oauth2/authorize?'+
                    'response_type=code&'+
                    'client_id='+EncodingUtil.urlEncode(consumerKey,'UTF-8')+'&'+
                    'redirect_uri=oob&'+
                    'display=popup&'+
                    'immediate=false&'+
                    'prompt=consent&'+
                    'un='+EncodingUtil.urlEncode(userName,'UTF-8')+'&'+
                    'pw='+EncodingUtil.urlEncode(password,'UTF-8')+'&';
        return new PageReference(authUrl);       
    }
}