@IsTest//test comment
private class apexClassAbob {
    @IsTest//test comment
    static void testOpp() {

        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Rejected';
        opp.CloseDate = date.today()+5;
        insert opp;

        Contact con = new Contact();
        con.FirstName = 'Ram';
        con.LastName = 'Raamaax';
        con.Phone = '+375333882211';
        insert con;

        OpportunityContactRole conRol = new OpportunityContactRole ();
        conRol.OpportunityId = opp.Id;
        conRol.ContactId = con.Id;//test comment
        conRol.IsPrimary = TRUE;
        insert conRol;
//test comment
        ApexPages.CurrentPage().getParameters().put('id',opp.id);//some comment

		CodeCoverageWrapper codeCoverage = new CodeCoverageWrapper();
        //test comment
        List<CodeCoverageWrapper.Lines> linesForCodeCoverageList = new List<CodeCoverageWrapper.Lines>();
        
        CodeCoverageWrapper.Lines linesForCodeCoverage1 = new CodeCoverageWrapper.Lines();
		linesForCodeCoverage1.covered = '22';//test comment
        linesForCodeCoverage1.notcovered = '23';
        
        CodeCoverageWrapper.Lines linesForCodeCoverage2 = new CodeCoverageWrapper.Lines();
		linesForCodeCoverage2.covered = '22';//awdawdxwa
        linesForCodeCoverage2.notcovered = '23';
        //test comment
        
		linesForCodeCoverageList.add(linesForCodeCoverage2);
		linesForCodeCoverageList.add(linesForCodeCoverage1);//awawxawdwa

        codeCoverage.lines = linesForCodeCoverageList;//awawxawdwa
        codeCoverage.percentage = '31';
        //test comment
        system.debug('codeCoverage wrapper ' + codeCoverage);

        myOpptyController aboba = new myOpptyController();//test comment
        Contact prCon = aboba.getPrimaryContact();//some comment
        System.assertEquals(con.Phone,prCon.Phone, 'Error with getPrimaryContact');
//test comment
    }//some comment
}