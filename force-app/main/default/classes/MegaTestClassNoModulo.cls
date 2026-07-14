public with sharing class MegaTestClassNoModulo {
    // MINOR: intentionally missing class-level ApexDoc

    public static void hugeMethodOne() {
        // CRITICAL: missing method ApexDoc
        Account a1 = [SELECT Id, Name FROM Account LIMIT 1]; // CRUD violation
        a1.Name = 'Test Account'; // hard-coded value
        update a1; // CRUD violation

        Contact c1 = new Contact(LastName='Doe'); // hard-coded value
        insert c1; // CRUD violation

        // Naming convention violations
        Integer xYz123 = 0;
        String STR_CONST = 'HELLO';

        // Deeply nested loops
        for (Integer i = 0; i < 10; i++) {
            for (Integer j = 0; j < 5; j++) {
                Account tempAcc = new Account(Name='Temp' + i + '-' + j);
                insert tempAcc; // CRUD violation
                if (i == j) {
                    System.debug('i equals j');
                } else {
                    System.debug('i not equal j');
                }
            }
        }

        // Unused variables
        String unusedString = 'I am unused';
        Integer unusedInt;

        // Long line to trigger formatting warnings
        System.debug('This is a very very long debug line that will likely trigger PMD line length rules because it exceeds normal standards and should definitely create a violation when scanned by a linter');

        // Deeply nested ifs
        if (true) {
            if (true) {
                if (true) {
                    if (true) {
                        System.debug('Nested 4 levels');
                    }
                }
            }
        }
    }

    public static void hugeMethodTwo(Integer inputVal) {
        // Missing ApexDoc
        List<Account> accList = [SELECT Id, Name FROM Account]; // CRUD violation
        for (Account a : accList) {
            a.Name = a.Name + ' Updated';
        }
        update accList; // CRUD violation

        // Hard-coded Id
        Id dummyId = '001000000000001'; // hard-coded

        // Bad naming
        String BADName = 'badName';

        // Nested loops without modulo
        for (Integer i = 0; i < 5; i++) {
            for (Integer j = 0; j < 3; j++) {
                if (i == 2 && j == 1) {
                    System.debug('Specific condition met: i=2,j=1');
                } else {
                    System.debug('Other condition: ' + i + ',' + j);
                }
            }
        }
    }

    public static void unusedMethod() {
        // Never called
        List<Contact> contacts = [SELECT Id, LastName FROM Contact]; // CRUD violation
    }

    public static void veryLongMethod() {
        // Huge method with multiple issues
        for (Integer i = 0; i < 20; i++) {
            Account acc = new Account(Name='HugeAccount' + i);
            insert acc; // CRUD violation

            if (i == 10) {
                System.debug('Checkpoint ' + i);
            }
        }

        // Random hard-coded values
        String someValue = 'StaticValue';
        Integer myNumber = 99999; // renamed variable
        Boolean flag = true;
    }

    public static void methodWithException() {
        // Unused try-catch, hard-coded exception message
        try {
            Account acc = new Account(Name='FailAccount');
            insert acc; // CRUD violation
        } catch (Exception e) {
            System.debug('Something went wrong'); // minor log violation
        }
    }

    // Additional methods to increase size
    public static void generateAccounts(Integer count) {
        for (Integer i = 0; i < count; i++) {
            Account a = new Account(Name='Generated' + i);
            insert a; // CRUD violation
        }
    }

    public static void generateContacts(Integer count) {
        for (Integer i = 0; i < count; i++) {
            Contact c = new Contact(LastName='Generated' + i);
            insert c; // CRUD violation
        }
    }

    public static void messyMethod() {
        // Long line + multiple nested loops
        for (Integer i = 0; i < 10; i++) {
            for (Integer j = 0; j < 10; j++) {
                if (i == j) {
                    System.debug('i equals j: ' + i + j);
                } else {
                    System.debug('i not equal j: ' + i + j);
                }
            }
        }
    }

    public static void lotsOfHardcodedStrings() {
        String a = 'A'; String b = 'B'; String c = 'C'; String d = 'D'; String e = 'E'; String f = 'F'; String g = 'G'; // multiple hard-coded literals
        System.debug(a + b + c + d + e + f + g); // long line
    }
}