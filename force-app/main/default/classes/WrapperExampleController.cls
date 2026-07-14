public with sharing class WrapperExampleController 
{
    // the list of accounts that will be displayed in the page
    private List<Account> accs;
    public Double myValue;   // Class Member variable
    public String myString;  // Class Member variable
    
    // the list of row wrappers that contain a transposed view of the account
    private List<RowWrapper> rows;
    
    // the headings for the row wrappers table
    private RowWrapper headings;
    
    public WrapperExampleController ()
    {
        myValue = 100;
    }
    
    // retrieves the list of accounts backing the page
    public List<Account> getAccounts()
    {
        if (null==accs)
        {
            accs=[select id, Name, BillingStreet, BillingCity, BillingPostalCode from Account 
                  where BillingCity != null and BillingPostalCode!=null limit 3];
        }
        
        return accs; 
    }
    
    // retrieves the row wrapper containing the wrapped account headings
    public RowWrapper getHeadWrap()
    {
        // set up the headings
        if (null==headings)
        {
            headings=new RowWrapper();
            for (Integer idx=1; idx<=getAccounts().size(); idx++)
            {
                headings.addValue('Account ' + idx);
            }
        }
                                     
        return headings;
    }
    
    // retrieves the list of row wrappers
    public List<RowWrapper> getRowWrappers()
    {
        if (null==rows)
        {
            rows=new List<RowWrapper>();
            
            // create a row for each field - there are 4 of these, Name, Street, City and PostCode
            for (Integer idx=0; idx<4; idx++)
            {
                rows.add(new RowWrapper());
            }
            
            // iterate the accounts and populate the rows
            for (Integer idx=0; idx<getAccounts().size(); idx++)
            {
                rows[0].addValue(getAccounts()[idx].Name);
                rows[1].addValue(getAccounts()[idx].BillingStreet);
                rows[2].addValue(getAccounts()[idx].BillingCity);
                rows[3].addValue(getAccounts()[idx].BillingPostalCode);
            }
        }
        
        return rows;
    }
    public Double getCalculatedValue () { // Method definition and body
        // do some calculation
        myValue = myValue+10;
        return myValue;
    }

    public Double getCalculatedValueViaPrice (Decimal price) 
    {
        // Method definition and body
        // do some calculation
        myValue = myValue+price; // Final Price would be 100+100=200.00
        return myValue;
    }
   
    public void sendEmail()
    {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'abc2@gmail.com', 'abc2@gmail.com' };
        message.optOutPolicy = 'FILTER';
        message.subject = 'Subject Test Message';
        message.plainTextBody = 'This is the message body.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    public void defineArray()
    {
        //Defining array
        String [] arrayOfProducts = new List<String>();
        
        //Adding elements in Array
        arrayOfProducts.add('HCL');
        arrayOfProducts.add('H2SO4');
        arrayOfProducts.add('NACL');
        arrayOfProducts.add('H2O');
        arrayOfProducts.add('N2');
        arrayOfProducts.add('U296');
        
        for (Integer i = 0; i<arrayOfProducts.size(); i++) {
           //This loop will print all the elements in array
           system.debug('Values In Array: '+arrayOfProducts[i]);
        }
    }
    public void removeString()
    {
        String myString1 = 'This Is MyString Example';
        String stringToRemove = 'MyString';
        String result = myString1.remove(stringToRemove);
        System.debug('Value of Result will be This Is Example as we have removed the MyString and Result is :'+result);
    }
   
    public void equalsIgnoreString()
    {
        String myString1 = 'MySTRING';
        String myString2 = 'MyString';
        Boolean result = myString2.equalsIgnoreCase(myString1);
        System.debug('Value of Result will be true as they are same and Result is:'+result);
    }
   
    public void removeEndString()
    {
        String myString1 = 'This Is MyString EXAMPLE';
        String stringToRemove = 'Example';
        String result = myString1.removeEndIgnoreCase(stringToRemove);
        System.debug('Value of Result will be This Is MyString as we have removed the Example and Result is :'+result);
    }
   
    public void prefixString()
    {
        String myString1 = 'This Is MyString EXAMPLE';
        String prefix = 'This';
        Boolean result = myString1.startsWith(prefix);
        System.debug(' This will return true as our String starts with string This and the Result is :'+result);
    }
   
    
    // nested class that wraps information about a row - in this case simply a list of strings 
    public class RowWrapper
    {
        // the values (cells) making up this row
        public List<String> values {get; set;}
        
        // constructor
        public RowWrapper()
        {
            values=new List<String>();
        }
        
        // append a value (cell) to the row
        public void addValue(String value)
        {
            values.add(value);
        }
    }
}