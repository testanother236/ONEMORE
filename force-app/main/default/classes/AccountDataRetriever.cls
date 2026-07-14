public with sharing class AccountDataRetriever 
{
    private String SessionId = '00D90000000xAkK!ARgAQADBWOopTXWYPdinM0zr2oPiKKlBAvD8TctrK6XddZrtqtNHCwUj.H95reYMEtl8rbJUJIAg9tOcn8Eh6P9atKPzvRkh';
    public AccountDataRetriever()
    {
        //ClassMyWebService.MyWebService service = new ClassMyWebService.MyWebService();
    }
    
    public String getData()
    {
        ClassMyWebService.MyWebService service = new ClassMyWebService.MyWebService();
        service.SessionHeader = new ClassMyWebService.SessionHeader_element();
        service.SessionHeader.sessionId = SessionId;
        return service.getBase64();
    }
}