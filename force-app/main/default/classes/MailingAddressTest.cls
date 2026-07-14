public with sharing class MailingAddressTest
{
    public MailingAddressTest()
    {
        List<Contact> conList = new List<Contact>();
        conList = [SELECT Id,MailingAddress FROM Contact];
        /*List<Contact> conList = new List<Contact>();
        conList = [SELECT Id,MailingAddress FROM Contact];*/
    }
}