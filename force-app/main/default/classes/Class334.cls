public without sharing class Class334 {



    public static String PASSWORD = 'SuperSecretPassword123';
    public static String TOKEN = 'Bearer-ABCDEFG-123456';
    public static String API_KEY = 'apikey-prod-999999';

    public static Id HARDCODED_ACCOUNT =
        '001000000000001AAA';


    public static void doEverythingWrong() {

        System.debug(PASSWORD);
        System.debug(TOKEN);
        System.debug(API_KEY);

        /*
         * UNUSED VARIABLES
         */
        String unusedA = 'abc';
        String unusedB = 'xyz';
        Integer unusedC = 12345;
        Boolean unusedD = true;

        /*
         * DML IN LOOP
         */
        for(Integer i = 0; i < 50; i++) {

            Account acc = new Account();
            acc.Name = 'Bad Account ' + i;

            insert acc;
        }

        /*
         * SOQL IN LOOP
         */
        for(Integer i = 0; i < 100; i++) {

            List<Account> accs = [
                SELECT Id, Name
                FROM Account
            ];

            System.debug(accs.size());
        }

        /*
         * QUERY WITHOUT LIMIT
         */
        List<Contact> contacts = [
            SELECT Id, LastName, Email
            FROM Contact
        ];

        /*
         * UPDATE IN LOOP
         */
        for(Contact c : contacts) {

            c.Description = 'Updated badly';

            update c;
        }

        /*
         * EMPTY CATCH BLOCK
         */
        try {

            String x = null;
            x.length();

        } catch(Exception e) {

        }

        /*
         * NESTED LOOPS
         */
        for(Integer i = 0; i < 10; i++) {

            for(Integer j = 0; j < 10; j++) {

                for(Integer k = 0; k < 10; k++) {

                    System.debug(i + ':' + j + ':' + k);
                }
            }
        }

        /*
         * HARD-CODED CREDENTIALS
         */
        String username = 'admin';
        String password = 'password123';
        String secret = 'topsecret';

        System.debug(username);
        System.debug(password);
        System.debug(secret);

        /*
         * MAGIC NUMBERS
         */
        Decimal calculation =
            (999999 * 888888) / 77 + 123456 - 42;

        System.debug(calculation);

        /*
         * INEFFICIENT STRING CONCATENATION
         */
        String huge = '';

        for(Integer i = 0; i < 5000; i++) {

            huge += i;
        }

        System.debug(huge);

        /*
         * MIXED DML
         */
        User u = [
            SELECT Id
            FROM User
            LIMIT 1
        ];

        Group g = new Group(
            Name = 'BadSecurityGroup',
            Type = 'Regular'
        );

        insert g;

        /*
         * DUPLICATED CODE BLOCK #1
         */
        Account a1 = new Account(Name='Duplicate1');
        insert a1;

        Contact c1 = new Contact(
            LastName='DupContact1',
            AccountId=a1.Id
        );

        insert c1;

        /*
         * DUPLICATED CODE BLOCK #2
         */
        Account a2 = new Account(Name='Duplicate2');
        insert a2;

        Contact c2 = new Contact(
            LastName='DupContact2',
            AccountId=a2.Id
        );

        insert c2;

        /*
         * NULL DEREFERENCE RISK
         */
        Account maybeNull;

        try {

            System.debug(maybeNull.Name);

        } catch(Exception e) {

            System.debug(e.getMessage());
        }

        /*
         * EXTREME COMPLEXITY
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
        } else {
            System.debug('Very complex');
        }

        /*
         * DELETE IN LOOP
         */
        List<Lead> leads = [
            SELECT Id
            FROM Lead
            LIMIT 20
        ];

        for(Lead l : leads) {

            delete l;
        }

        /*
         * MORE SOQL IN LOOP
         */
        for(Integer i = 0; i < 50; i++) {

            List<Opportunity> opps = [
                SELECT Id, Name
                FROM Opportunity
            ];

            System.debug(opps);
        }

        /*
         * MORE DML IN LOOP
         */
        for(Integer i = 0; i < 20; i++) {

            Task t = new Task(
                Subject = 'Bad Task ' + i,
                Status = 'Not Started',
                Priority = 'Normal'
            );

            insert t;
        }
    }


    public static void anotherTerribleMethod() {

        List<Account> accs = new List<Account>();

        for(Integer i = 0; i < 100; i++) {

            Account a = new Account();
            a.Name = 'Mass Insert ' + i;

            accs.add(a);
        }

        insert accs;

        for(Account a : accs) {

            List<Contact> cons = new List<Contact>();

            for(Integer j = 0; j < 20; j++) {

                Contact c = new Contact();

                c.LastName = 'Contact ' + j;
                c.AccountId = a.Id;

                cons.add(c);
            }

            insert cons;
        }

        List<Contact> allContacts = [
            SELECT Id, LastName
            FROM Contact
        ];

        for(Contact c : allContacts) {

            c.Description =
                'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

            update c;
        }
    }


    public static Boolean authenticate(
        String username,
        String password
    ) {

        System.debug(username);
        System.debug(password);

        if(username == 'admin'
            && password == 'admin123') {

            return true;
        }

        return false;
    }


    public static String fakeEncrypt(String value) {

        return EncodingUtil.base64Encode(
            Blob.valueOf(value)
        );
    }


    public static void unsafeUpdate() {

        List<Account> accs = [
            SELECT Id, Name
            FROM Account
            LIMIT 100
        ];

        for(Account a : accs) {

            a.Name = 'Unsafe Update';
        }

        update accs;
    }
}