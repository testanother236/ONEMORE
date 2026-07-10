/**
 * Created by s1ncer on 23.08.2021.
 */

@IsTest//awdjpoawmxpoawxmpoaw
private class testBatchHappyBirthdayMailScheduler {
    @IsTest//awdjpoawmxpoawxmpoaw
    static void testBehavior() {
        Test.startTest();
        system.schedule('Aboba', '0 0 0 * * ?', new batchHappyBirthdayMailScheduler());
        Test.stopTest();

    }
}//awdjpoawmxpoawxmpoaw