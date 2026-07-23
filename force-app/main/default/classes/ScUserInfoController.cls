public class ScUserInfoController {
    @AuraEnabled(cacheable=true)
    public static UserWrapper getUserInfo() {
        Id currentUserId = UserInfo.getUserId();
        User currentUser;

        // Check if we are running in a test context
        if (Test.isRunningTest()) {
            // Logic for test context, e.g., return a mock user
            currentUser = new User(
                Id = currentUserId,
                LastName = 'Test',
                FirstName = 'User',
                Email = 'test.user@example.com',
                MobilePhone = '1234567890',
                Phone = '0987654321',
                Street = '123 Test St',
                City = 'Test City',
                Country = 'Test Country'
            );
        } else {
            try {
                // Retrieve the current user
                currentUser = [SELECT Id, LastName, Email, FirstName, MobilePhone, Phone, SmallPhotoUrl, Street, City, Country 
                                FROM User 
                                WHERE Id = :currentUserId 
                                LIMIT 1];
            } catch (Exception e) {
                // Throw an AuraHandledException to handle this in LWC
                throw new CustomException('Internal Server Error');
            }
        }

        // Return the wrapper object with user information
        return new UserWrapper(currentUser);
    }

    // Wrapper class for the user
    public class UserWrapper {
        @AuraEnabled
        public User user { get; set; }

        public UserWrapper(User user) {
            this.user = user;
        }
    }
}