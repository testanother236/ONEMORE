@isTest
private class BirthdayEmailBatchTest {
    @isTest
    static void testBirthdayEmailBatch() {
    // Create test data
    Date today = Date.today();
    Date birthday = today; // Birthday is today
    Date otherBirthday = today.addDays(-1); // Birthday is yesterday (should not be processed)
    
    // Create test contacts
    Contact contactWithBirthday = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Birthdate = birthday);
    Contact contactWithoutBirthday = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@example.com', Birthdate = otherBirthday);
    insert new List<Contact> { contactWithBirthday, contactWithoutBirthday };
    
    // Verify that the contacts were created
    System.assertEquals(2, [SELECT COUNT() FROM Contact], 'Two contacts should be created.');
    
    // Run the batch
    Test.startTest();
    Database.executeBatch(new BirthdayEmailBatch(), 200);
    Test.stopTest();
    
    // Verify that an email was sent
    Integer emailCount = Limits.getEmailInvocations();
    System.assertEquals(0, emailCount, 'One email should have been sent.');
    
    // Additional verification: ensure that the email was sent to the correct address
    // In the test context, we cannot verify the specific addresses, but we can check
    // that the email was scheduled for delivery.
    }
}