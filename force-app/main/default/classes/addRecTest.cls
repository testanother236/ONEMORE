@isTest
public class addRecTest {
@isTest
    public static void sendTest(){
        Test.startTest();
        Database.executeBatch(new addRec(0),500);
        Test.stopTest();
    }
}