public class NotificationService {
    public static void notifyNewUser(String firstName, String lastName, String email) {
        // Создаем пользователя, используя UserManager
        UserManager.createUser(firstName, lastName, email);
        
        // Логика уведомления
        System.debug('Notification sent for new user: ' + firstName + ' ' + lastName);
    }
    
    public static void emptyMethod () {
            
   }
    
    
}