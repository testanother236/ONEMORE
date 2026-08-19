
@IsTest
private class AccessCheckTest {
    
    // Utility method to generate a unique string for user fields (e.g., Username/Email)
    private static String uniqueSuffix() {
        return String.valueOf(DateTime.now().getTime());
    }
    
    // Test setup to create a standard user for runAs tests
    @TestSetup
    static void setupData() {
        // Try to get a common "Standard User" profile; if not found, fallback to any standard profile
        Profile p;
        try {
            p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        } catch (Exception ex) {
            p = [SELECT Id FROM Profile WHERE UserType = 'Standard' LIMIT 1];
        }
        
        User u = new User(
            ProfileId        = p.Id,
            Username         = 'std.user.' + uniqueSuffix() + '@test.com',
            Alias            = 'stdusr',
            Email            = 'stdusr' + uniqueSuffix() + '@test.com',
            LastName         = 'Test',
            TimeZoneSidKey   = 'America/Los_Angeles',
            LocaleSidKey     = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'en_US'
        );
        insert u;
    }
    
    @IsTest
    static void testConstructorExecutesQueriesAndDoesNotThrow() {
        // Purpose: Verify that constructing AccessCheck triggers method1 and method2 (via constructor)
        // and executes SOQL without throwing any exceptions.
        Test.startTest();
        Integer beforeQueries = Limits.getQueries();
        AccessCheck checker = new AccessCheck();
        Integer afterQueries = Limits.getQueries();
        Test.stopTest();
        
        System.assertNotEquals(null, checker, 'Constructor should return a valid AccessCheck instance.');
        System.assert(afterQueries > beforeQueries,
            'Constructor (which invokes method2) should execute at least one SOQL query.');
    }
    
    @IsTest
    static void testExplicitMethodInvocations() {
        // Purpose: Explicitly call public methods method1() and method2() to ensure they are invocable
        // and that method2 performs SOQL in a controlled test context.
        AccessCheck checker = new AccessCheck(); // Also covers constructor path
        
        Test.startTest();
        Integer beforeQueries = Limits.getQueries();
        checker.method1(); // No-op but should be callable without errors
        checker.method2(); // Executes multiple SOQL queries
        Integer afterQueries = Limits.getQueries();
        Test.stopTest();
        
        System.assertNotEquals(null, checker, 'AccessCheck instance should not be null.');
        System.assert(afterQueries > beforeQueries,
            'Explicit method2 invocation should increase the SOQL query count.');
    }
    
    @IsTest
    static void testRunAsStandardUserContext() {
        // Purpose: Ensure the logic runs under a non-admin (standard) user context using System.runAs.
        // Even if the org has no data for those setup objects, queries should execute without exceptions.
        User runAsUser = [
            SELECT Id, Username, Email 
            FROM User 
            WHERE Alias = 'stdusr' 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        Test.startTest();
        System.runAs(runAsUser) {
            Integer beforeQueries = Limits.getQueries();
            AccessCheck checker = new AccessCheck(); // Triggers queries via constructor
            checker.method2();                        // Direct method invocation as well
            Integer afterQueries = Limits.getQueries();
            
            System.assertNotEquals(null, checker, 'AccessCheck should instantiate under runAs user.');
            System.assert(afterQueries > beforeQueries, 'SOQL should execute under runAs user.');
        }
        Test.stopTest();
    }
}
