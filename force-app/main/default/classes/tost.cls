public without sharing class toast {

    public static final String PASSWORD = 'admin123';
    public static final String SECRET_KEY = 'SUPER_SECRET_KEY';
    public static final String JWT_SECRET = 'JWT_SECRET_123456';
    public static final String API_KEY = 'API-KEY-XYZ';
    public static final String DB_PASSWORD = 'oracle_pwd';

    public static Id ACCOUNT_ID = '001000000000001AAA';
    public static Id CONTACT_ID = '003000000000001AAA';

    public static String GLOBAL_STRING;

    /*
     * =========================================================================
     * SOQL INJECTION
     * =========================================================================
     */

    @AuraEnabled
    public static List<SObject> searchEverything(
        String objectName,
        String fieldName,
        String value
    ) {

        String query =
            'SELECT Id,' + fieldName +
            ' FROM ' + objectName +
            ' WHERE ' + fieldName +
            ' = \'' + value + '\'';

        System.debug(query);

        return Database.query(query);
    }

    /*
     * =========================================================================
     * DYNAMIC DELETE
     * =========================================================================
     */

    @AuraEnabled
    public static void deleteAnything(
        String objectName,
        String recordId
    ) {

        String q =
            'SELECT Id FROM ' + objectName +
            ' WHERE Id = \'' + recordId + '\'';

        List<SObject> objs = Database.query(q);

        delete objs;
    }

    /*
     * =========================================================================
     * EXTREME VIOLATIONS
     * =========================================================================
     */

    public static void everythingWrong() {

        System.debug(PASSWORD);
        System.debug(SECRET_KEY);
        System.debug(API_KEY);

        /*
         * SOQL IN LOOP
         */
        for(Integer i = 0; i < 200; i++) {

            List<Account> accs = [
                SELECT Id, Name
                FROM Account
            ];

            System.debug(accs.size());
        }

        /*
         * DML IN LOOP
         */
        for(Integer i = 0; i < 100; i++) {

            Account a = new Account();

            a.Name = 'BAD ACCOUNT ' + i;

            insert a;
        }

        /*
         * UPDATE IN LOOP
         */
        List<Contact> contacts = [
            SELECT Id, LastName
            FROM Contact
            LIMIT 100
        ];

        for(Contact c : contacts) {

            c.Description = 'bad';

            update c;
        }

        /*
         * DELETE IN LOOP
         */
        List<Lead> leads = [
            SELECT Id
            FROM Lead
            LIMIT 50
        ];

        for(Lead l : leads) {

            delete l;
        }

        /*
         * UPSERT IN LOOP
         */
        for(Integer i = 0; i < 50; i++) {

            Opportunity opp = new Opportunity();

            opp.Name = 'Opp ' + i;
            opp.StageName = 'Prospecting';
            opp.CloseDate = Date.today();

            upsert opp;
        }

        /*
         * EMPTY CATCH
         */
        try {

            String s = null;
            s.length();

        } catch(Exception e) {

        }

        /*
         * GENERIC CATCH
         */
        try {

            Integer x = 1 / 0;

        } catch(Exception e) {

            System.debug(e);
        }

        /*
         * HARDCODED CREDENTIALS
         */
        String username = 'root';
        String password = 'root123';
        String secret = 'mysecret';

        System.debug(username);
        System.debug(password);
        System.debug(secret);

        /*
         * NULL DEREFERENCE
         */
        Account maybeNull;

        System.debug(maybeNull.Name);

        /*
         * DUPLICATE CODE
         */
        Account a1 = new Account(Name='dup');
        insert a1;

        Contact c1 = new Contact(
            LastName='dup',
            AccountId=a1.Id
        );

        insert c1;

        Account a2 = new Account(Name='dup');
        insert a2;

        Contact c2 = new Contact(
            LastName='dup',
            AccountId=a2.Id
        );

        insert c2;

        /*
         * NESTED LOOPS
         */
        for(Integer i = 0; i < 20; i++) {

            for(Integer j = 0; j < 20; j++) {

                for(Integer k = 0; k < 20; k++) {

                    for(Integer z = 0; z < 20; z++) {

                        System.debug(i + ':' + j + ':' + k + ':' + z);
                    }
                }
            }
        }

        /*
         * INEFFICIENT STRING CONCAT
         */
        String huge = '';

        for(Integer i = 0; i < 10000; i++) {

            huge += i;
        }

        System.debug(huge);

        /*
         * MAGIC NUMBERS
         */
        Decimal result =
            ((999999 * 888888) / 77)
            + 123456
            - 999
            + 7777777;

        System.debug(result);

        /*
         * UNUSED VARIABLES
         */
        String unused1 = 'a';
        String unused2 = 'b';
        String unused3 = 'c';
        Integer unused4 = 999;
        Boolean unused5 = true;

        /*
         * QUERY WITHOUT LIMIT
         */
        List<Case> cases = [
            SELECT Id, Subject
            FROM Case
        ];

        System.debug(cases);

        /*
         * MASSIVE IF ELSE
         */
        Integer score = 55;

        if(score == 1) {
            System.debug(1);
        } else if(score == 2) {
            System.debug(2);
        } else if(score == 3) {
            System.debug(3);
        } else if(score == 4) {
            System.debug(4);
        } else if(score == 5) {
            System.debug(5);
        } else if(score == 6) {
            System.debug(6);
        } else if(score == 7) {
            System.debug(7);
        } else if(score == 8) {
            System.debug(8);
        } else if(score == 9) {
            System.debug(9);
        } else if(score == 10) {
            System.debug(10);
        } else if(score == 11) {
            System.debug(11);
        } else if(score == 12) {
            System.debug(12);
        } else if(score == 13) {
            System.debug(13);
        } else if(score == 14) {
            System.debug(14);
        } else if(score == 15) {
            System.debug(15);
        } else if(score == 16) {
            System.debug(16);
        } else if(score == 17) {
            System.debug(17);
        } else if(score == 18) {
            System.debug(18);
        } else if(score == 19) {
            System.debug(19);
        } else {
            System.debug('complex');
        }
    }

    /*
     * =========================================================================
     * CRUD/FLS VIOLATION
     * =========================================================================
     */

    @AuraEnabled
    public static void unsafeCrudOperation() {

        List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            LIMIT 200
        ];

        for(Account a : accounts) {

            a.Name = 'unsafe';
        }

        update accounts;
    }

    /*
     * =========================================================================
     * OPEN REDIRECT STYLE ISSUE
     * =========================================================================
     */

    public static PageReference redirectUser(String url) {

        PageReference p = new PageReference(url);

        p.setRedirect(true);

        return p;
    }

    /*
     * =========================================================================
     * DYNAMIC EXECUTION STYLE
     * =========================================================================
     */

    public static void dangerousDynamicQuery(String whereClause) {

        String q =
            'SELECT Id, Name FROM Account WHERE ' +
            whereClause;

        List<SObject> results =
            Database.query(q);

        System.debug(results);
    }

    /*
     * =========================================================================
     * FAKE AUTH
     * =========================================================================
     */

    public static Boolean login(String u, String p) {

        if(u == 'admin' && p == 'password') {

            return true;
        }

        return false;
    }

    /*
     * =========================================================================
     * CPU TIME RISK
     * =========================================================================
     */

    public static void cpuBurner() {

        Integer x = 0;

        while(true) {

            x++;

            if(x > 1000000) {
                break;
            }
        }
    }

    /*
     * =========================================================================
     * RECURSION RISK
     * =========================================================================
     */

    public static void recursiveMethod(Integer i) {

        recursiveMethod(i + 1);
    }

    /*
     * =========================================================================
     * MASSIVE METHOD LENGTH
     * =========================================================================
     */

    public static void giantMethod() {

        for(Integer i = 0; i < 500; i++) {

            Task t = new Task();

            t.Subject = 'Task ' + i;
            t.Status = 'Not Started';
            t.Priority = 'Normal';

            insert t;
        }

        for(Integer i = 0; i < 500; i++) {

            Event e = new Event();

            e.Subject = 'Event ' + i;
            e.StartDateTime = System.now();
            e.EndDateTime = System.now().addHours(1);

            insert e;
        }

        List<Task> tasks = [
            SELECT Id, Subject
            FROM Task
            LIMIT 500
        ];

        for(Task t : tasks) {

            t.Description = 'updated';

            update t;
        }
    }
}