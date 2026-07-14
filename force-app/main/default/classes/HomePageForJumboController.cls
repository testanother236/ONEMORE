public with sharing class HomePageForJumboController
{
    public HomePageForJumboController()
    {
        //return Page.CreateNewUser;
    }
    
    public PageReference redirectToCreateNewUser()
    {
        return Page.CreateNewUser;
    }
}