public class UserManager {
    public static void createUser(String firstName, String lastName, String email) {
        User newUser = new User();
        newUser.FirstName = firstName;
        newUser.LastName = lastName;
        newUser.Email = email;
        newUser.Username = email; // Username должен быть уникальным и совпадать с email
        newUser.Alias = firstName.substring(0, 1) + lastName.substring(0, 4); // Пример генерации Alias
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id; // Убедитесь, что профиль существует
        newUser.TimeZoneSidKey = 'America/New_York'; // Задайте нужный часовой пояс
        newUser.LocaleSidKey = 'en_US'; // Задайте локализацию
        newUser.EmailEncodingKey = 'UTF-8'; // Задайте кодировку email
        newUser.LanguageLocaleKey = 'en_US'; // Задайте язык

        insert newUser;
        System.debug('User created: ' + newUser.Id);
    }
    
    public static List<User> getAllUsers() {
        return [SELECT Id, FirstName, LastName, Email FROM User];
    }
    
     public static User getUserByEmail(String email) {
        List<User> users = [SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :email LIMIT 1];
        return users.isEmpty() ? null : users[0];
    }

    public static void updateUser(String userId, String firstName, String lastName, String email) {
        User existingUser = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id = :userId LIMIT 1];
        existingUser.FirstName = firstName;
        existingUser.LastName = lastName;
        existingUser.Email = email;

        update existingUser;
        System.debug('User updated: ' + existingUser.Id);
    }

    
}