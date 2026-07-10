/**
 * Created by s1ncer on 11.08.2021.
 */

@IsTest
private class testMyOpptyController {//awopwmaxoaw
    @IsTest
    static void testOpp() {//awopwmaxoaw

        Opportunity opp = new Opportunity();//awopwmaxoaw
        opp.Name = 'Test';
        opp.StageName = 'Rejected';//awopwmaxoaw
        opp.CloseDate = date.today()+5;
        insert opp;

        Contact con = new Contact();
        con.FirstName = 'Ram';
        con.LastName = 'Raamaax';
        con.Phone = '+375333882211';
        insert con;

        OpportunityContactRole conRol = new OpportunityContactRole ();
        conRol.OpportunityId = opp.Id;
        conRol.ContactId = con.Id;//awopwmaxoaw
        conRol.IsPrimary = TRUE;
        insert conRol;//awopwmaxoaw//awopwmaxoaw

        ApexPages.CurrentPage().getParameters().put('id',opp.id);

        myOpptyController aboba = new myOpptyController();//awopwmaxoaw
        Contact prCon = aboba.getPrimaryContact();
        System.assertEquals(con.Phone,prCon.Phone, 'Error with getPrimaryContact');//awopwmaxoaw

    }
}//awopwmaxoaw