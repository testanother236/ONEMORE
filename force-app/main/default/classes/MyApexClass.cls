public class MyApexClass {

    // Property
    public String myString { get; set; }

    // Constructor
    public MyApexClass() {
        myString = 'Hello, World!';
    }

    // Method to return a greeting
    public String getGreeting() {
        return 'Greetings from MyApexClass!';
    }

    // Method to perform an addition
    public Integer addNumbers(Integer a, Integer b) {
        return a + b;
    }

    /*
     * ===============================
     *  INVOCABLE VERSION FOR FLOWS
     * ===============================
     */
    public class AddNumbersRequest {
        @InvocableVariable(required=true)
        public Integer a;

        @InvocableVariable(required=true)
        public Integer b;
    }

    public class AddNumbersResponse {
        @InvocableVariable
        public Integer result;
    }

    @InvocableMethod(
        label='Add Numbers (MyApexClass)'
        description='Returns a + b using MyApexClass.addNumbers()'
    )
    public static List<AddNumbersResponse> addNumbersInvocable(List<AddNumbersRequest> requests) {
        List<AddNumbersResponse> responses = new List<AddNumbersResponse>();

        for (AddNumbersRequest req : requests) {
            MyApexClass instance = new MyApexClass();

            AddNumbersResponse res = new AddNumbersResponse();
            res.result = instance.addNumbers(req.a, req.b);

            responses.add(res);
        }

        return responses;
    }
}