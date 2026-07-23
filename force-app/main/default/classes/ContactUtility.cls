public class ContactUtility {
    // Method to create a new Contact
    public static Contact createContact(String firstName, String lastName, Id accountId) {
        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.AccountId = accountId;
        insert newContact;
        return newContact;
    }

    // Method to update an existing Contact's last name
    public static void updateContactLastName(Id contactId, String newLastName) {
        Contact existingContact = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
        existingContact.LastName = newLastName;
        update existingContact;
    }

    // Method to retrieve a Contact by Id
    public static Contact getContactById(Id contactId) {
        return [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
    }

    // Method to delete a Contact by Id
    public static void deleteContact(Id contactId) {
        Contact existingContact = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
        delete existingContact;
    }
}