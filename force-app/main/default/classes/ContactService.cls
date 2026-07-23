public class ContactService {
    
    // Метод для получения списка контактов по фильтру
    public List<Contact> getContacts(String nameFilter) {
        String query = 'SELECT Id, FirstName, LastName, Email FROM Contact';
        
        if (!String.isEmpty(nameFilter)) {
            query += ' WHERE FirstName LIKE :nameFilter OR LastName LIKE :nameFilter';
        }
        
        return Database.query(query);
    }

    // Метод для создания нового контакта
    public Contact createContact(String firstName, String lastName, String email) {
        Contact newContact = new Contact(FirstName = firstName, LastName = lastName, Email = email);
        try {
            insert newContact;
            return newContact;
        } catch (DmlException e) {
            System.debug('Ошибка при создании контакта: ' + e.getMessage());
            return null;
        }
    }

    // Метод для обновления существующего контакта
    public Contact updateContact(Id contactId, String firstName, String lastName, String email) {
        try {
            Contact existingContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :contactId LIMIT 1];
            existingContact.FirstName = firstName;
            existingContact.LastName = lastName;
            existingContact.Email = email;
            update existingContact;
            return existingContact;
        } catch (DmlException e) {
            System.debug('Ошибка при обновлении контакта: ' + e.getMessage());
            return null;
        }
    }

    // Метод для удаления контакта
    public void deleteContact(Id contactId) {
        try {
            Contact existingContact = [SELECT Id FROM Contact WHERE Id = :contactId LIMIT 1];
            delete existingContact;
        } catch (DmlException e) {
            System.debug('Ошибка при удалении контакта: ' + e.getMessage());
        }
    }
}