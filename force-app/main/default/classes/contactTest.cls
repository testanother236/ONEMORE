@isTest
public class contactTest {
    // Utility method that can be called by Apex tests to create price book entries.
    static testmethod void insertEntries() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact cc = new Contact();
        cc.FirstName = 'test';
        cc.LastName = 'Done';
        cc.AccountId = acc.Id;
        insert cc;
    }
}