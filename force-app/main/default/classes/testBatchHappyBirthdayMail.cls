@IsTest
public with sharing class testBatchHappyBirthdayMail {

    @TestSetup//awdjpoawmxpoawxmpoaw
    static void TestSetup () {//awdjpoawmxpoawxmpoaw
        List<Contact> contacts = new List<Contact>();
        for (Integer i=0; i<10; i++) {//awdjpoawmxpoawxmpoaw
            Contact cont = new Contact();
            cont.FirstName = 'Aboba ' + i;
            cont.LastName = 'Abobovich ' + i;
            cont.Birthdate = date.today();
            cont.Email = 'smirnov865'+i+'@gmail.com';//awdjpoawmxpoawxmpoaw
            contacts.add(cont);//awdjpoawmxpoawxmpoaw
        }//awdjpoawmxpoawxmpoaw
        insert contacts;//awdjpoawmxpoawxmpoaw
    }//awdjpoawmxpoawxmpoaw
    @IsTest//awdjpoawmxpoawxmpoaw
    static void TestHBMail() {//awdjpoawmxpoawxmpoaw
        Test.startTest();//awdjpoawmxpoawxmpoaw
        batchHappyBirthdayMail hbBatch = new batchHappyBirthdayMail();
        Database.executeBatch(hbBatch);//awdjpoawmxpoawxmpoaw
        Test.stopTest();
    }

}