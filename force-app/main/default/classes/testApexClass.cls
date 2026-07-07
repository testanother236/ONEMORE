public class testApexClass {
    public String name {
        get { return name;}
        set { name = value;}
    } 
    public testApexClass() {
        system.debug('simple apwwdawdawdaвawdawdawdawwdex class to test');
    }
    public PageReference query() {
        String qryString = 'SELECT Id FROM Contact WHERE ' +
            '(IsDeleted = false and Name like \'%' + name + '%\')';
        List<Contact> queryResult = Database.query(qryString);
        System.debug('query result is ' + queryResult);
        return null;
    }
}