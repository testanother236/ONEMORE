/**
 * Created by s1ncer on 11.08.2021.
 */

@IsTest
private class testSendEmailController {//adwdawdwadawdaw
    @IsTest
    static void testSendEmail() {//adwdawdwadawdaw21
        string body = 'hello world';//adwdawdwadawdaw
        string tosend = 'smirnov8653@gmail.com';//adwdawdwadawdaw
        string subject = 'INV-00001';
        SendEmailController.sendEmailToController(body, tosend, subject);//adwdawdwadawdaw21
        tosend = '';
        try{
            SendEmailController.sendEmailToController(body, tosend, subject);
        } catch (Exception ex) {
            System.debug('error');
        }//adwdawdwadawdaw
        System.assertEquals(Limits.getEmailInvocations(), 1, 'Error');
    }
//adwdawdwadawdaw
}//adwdawdwadawdaw21