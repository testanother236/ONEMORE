public class SimpleGreetingService {

    public static String getGreeting(String name) {
        if (String.isBlank(name)) {
            return 'Hello, Guest!';
        }

        return 'Hello, ' + name + '!';
    }
}