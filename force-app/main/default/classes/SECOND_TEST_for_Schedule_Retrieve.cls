public class SECOND_TEST_for_Schedule_Retrieve {

    public static String getGreeting(String name) {
        if (String.isBlank(name)) {
            return 'Hello, TEST!';
        }

        return 'Hello, ' + name + '!';
    }
}