@IsTest
private class SnapshotToBranchCommitControllerTest {
    @TestSetup
    private static void setupBefore() {
        List<HerokuCredentials__c> hc = new List<HerokuCredentials__c>();
        hc.add(
            new HerokuCredentials__c(
                AccessPoint__c = 'https://service',
                Username__c = 'testname',
                Password__c = 'p123',
                Username_Resource__c = 'login',
                Password_Resource__c = 'pwd',
                Service_Type__c = 'REVIEW',
                MultiService_Type__c = 'REVIEW',
                Settings__c = '["ApexClass"]',
                isAutoSync__c = true,
                IsFullReview__c = true
            )
        );
        insert hc;

        Organisation__c org = new Organisation__c(
            Username__c = 'Test12345678@testorg.com',
            Name = 'Test12345678@testorg.com'
        );
        insert org;

        Snapshot__c sc = new Snapshot__c(Organisation__c = org.Id, Name = 'Test', Is_Completed__c = true);
        insert sc;

        Repository__c rep = new Repository__c();
        Map<Integer, String> buildOrgs = new Map<Integer, String>();
        buildOrgs.put(0, org.Id);

        rep.Name = 'repTest';
        rep.Build_and_Deploy_Organization__c = org.Id;
        rep.Run_Tests_on_Deployment__c = FlosumConstants.NO_TEST_RUN;
        rep.Is_Build_For_Repository__c = true;
        rep.Is_Build_For_Branch__c = true;
        rep.Build_and_Deploy_Organizations__c = JSON.serialize(buildOrgs);
        insert rep;

        Repository_Permission__c repPerm = new Repository_Permission__c();
        repPerm.Repository__c = rep.Id;
        repPerm.User__c = UserInfo.getUserId();
        insert repPerm;

        Pipeline__c pipeline = new Pipeline__c(Name = 'Test');
        insert pipeline;
        PipelineStep__c pipelineStep = new PipelineStep__c(
            Pipeline__c = pipeline.Id,
            Destination__c = org.Id,
            Step__c = 'Validate'
        );
        insert pipelineStep;

        Branch__c br = new Branch__c();
        br.Branch_Name__c = 'Branch 1';
        br.Repository__c = rep.Id;
        br.Pipeline__c = pipeline.Id;
        insert br;

        Attachment att = new Attachment(Name = 'testAttachment', Body = Blob.valueOf('Test attach'), ParentId = sc.Id);
        insert att;

        Map<String, String> tempCrcMap = new Map<String, String>();

        List<Metadata_Item__c> metaList = new List<Metadata_Item__c>();
        for (RecordType rt : [
            SELECT Id, Name
            FROM RecordType
            WHERE Name = 'ApexClass' AND SobjectType = :Schema.SObjectType.Metadata_Item__c.getName()
            LIMIT 1
        ]) {
            metaList.add(
                new Metadata_Item__c(
                    Snapshot__c = sc.Id,
                    CRC32__c = '+123',
                    API_Name__c = 'Test_Item__C',
                    Name__c = 'Test',
                    RecordTypeId = rt.Id,
                    Label__c = 'Test_Item__C',
                    Attachment_ID__c = att.Id
                )
            );
            metaList.add(
                new Metadata_Item__c(
                    Snapshot__c = sc.Id,
                    CRC32__c = '-123',
                    API_Name__c = 'Test_Item2__C',
                    Name__c = 'Test2',
                    RecordTypeId = rt.Id,
                    Label__c = 'Test_Item2__C',
                    Attachment_ID__c = att.Id
                )
            );
            metaList.add(
                new Metadata_Item__c(
                    Snapshot__c = sc.Id,
                    CRC32__c = '-1234',
                    API_Name__c = 'Test_Missing__C',
                    Name__c = 'Test2',
                    RecordTypeId = rt.Id,
                    Label__c = 'Test_Missing__C',
                    Attachment_ID__c = att.Id
                )
            );
        }

        if (metaList.size() > 0) {
            insert metaList;

            for (Metadata_Item__c meta : metaList) {
                tempCrcMap.put(meta.Id, '12345678');
            }
            //collection record types
            Map<String, Id> rTypMap = new Map<String, Id>();
            for (RecordType rt : [
                SELECT Id, Name
                FROM RecordType
                WHERE
                    SobjectType = :Schema.SObjectType.Component__c.getName()
                    AND (Name = 'Repository'
                    OR Name = 'Branch')
                LIMIT 2
            ]) {
                rTypMap.put(rt.Name, rt.Id);
            }

            if (rTypMap.size() == 2) {
                Component__c comp = new Component__c();
                comp.Component_Type__c = 'ApexClass';
                comp.Component_Name__c = 'Test_Item__C';
                comp.File_Name__c = 'Test_Item__C';
                comp.Version__c = 1;
                comp.Repository__c = rep.Id;
                comp.RecordTypeId = rTypMap.get('Repository');
                insert comp;

                Component__c comp2 = new Component__c();
                comp2.Version__c = 1;
                comp2.Component_Type__c = 'ApexClass';
                comp2.Component_Name__c = 'Test_Item2__C';
                comp2.File_Name__c = 'Test_Item__C';
                comp2.RecordTypeId = rTypMap.get('Branch');
                comp2.Branch__c = br.Id;
                insert comp2;

                Component_History__c his = new Component_History__c();
                his.Version__c = 1;
                his.Component__c = comp.Id;
                his.CRC32__c = '12345678';
                insert his;

                Component_History__c his2 = new Component_History__c();
                his2.Version__c = 1;
                his2.Component__c = comp2.Id;
                his2.CRC32__c = '123456784';
                insert his2;
            }
        }

        Patch__c patch = new Patch__c(Name = 'patch');
        insert patch;
    }

    @IsTest
    static void snapshotCommitTest() {
        Test.setMock(HttpCalloutMock.class, new MetadataUtils.MockHttpResponseGenerator());
        Test.setMock(WebServiceMock.class, new MetadataUtils.WebServiceMockImpl());
        HTTPService.mock = new MockHerokuServiceResponse();

        Snapshot__c sc = [SELECT Id FROM Snapshot__c LIMIT 1];
        Branch__c br = [SELECT Id FROM Branch__c LIMIT 1];
        List<Metadata_Item__c> metaList = [SELECT Id FROM Metadata_Item__c LIMIT 3];

        Test.startTest();
        ApexPages.currentPage().getParameters().put('sid', sc.Id);
        SnapshotToBranchCommitController controller = new SnapshotToBranchCommitController();
        controller.getBundleTypesListJSON();
        controller.getEditableExtListJSON();
        System.assertEquals(1, controller.repositoryOptions.size());

        controller.commitTo = br.Id;

        SnapshotToBranchCommitController.CommitWraper cw = new SnapshotToBranchCommitController.CommitWraper();
        cw.metaIds = new List<String>{ metaList[0].Id, metaList[1].Id };
        cw.dataMap = new Map<String, SnapshotToBranchCommitController.CommitFileWraper>();
        SnapshotToBranchCommitController.CommitFileWraper cfw = new SnapshotToBranchCommitController.CommitFileWraper();
        cfw.data = '';
        cfw.crc32 = '123';
        cfw.filename = 'Test_Item__C';
        cw.dataMap.put('ApexClass#Test_Item__C', cfw);

        SnapshotToBranchCommitController.CommitFileWraper cfw2 = new SnapshotToBranchCommitController.CommitFileWraper();
        cfw2.data = '';
        cfw2.crc32 = '1234';
        cfw2.filename = 'Test_Item2__C';
        cw.dataMap.put('ApexClass#Test_Item2__C', cfw2);

        controller.commitChunkJSON = JSON.serialize(cw);
        controller.commitInChunk();

        SnapshotToBranchCommitController.CompareRequest cr = new SnapshotToBranchCommitController.CompareRequest();
        cr.metaIdList = new List<String>{ metaList[0].Id, metaList[1].Id };
        cr.crcMap = new Map<String, String>();
        cr.crcMap.put(metaList[0].Id, '123');
        cr.crcMap.put(metaList[1].Id, '1236');

        SnapshotToBranchCommitController.getComparison(sc.Id, br.Id, JSON.serialize(cr), '');
        SnapshotToBranchCommitController.getAllItems(sc.Id, '', '');
        SnapshotToBranchCommitController.getItems(
            sc.Id,
            JSON.serialize(new List<String>{ metaList[0].Id, metaList[1].Id }),
            ''
        );
        controller.commitTo = null; //br.Id;
        controller.newBranchName = 'testbranchname';
        controller.tests = '';
        controller.goToCommit();
        controller.backToSnap();
        controller.snapCommit();

        Attachment att = new Attachment();
        att.ParentId = sc.Id;
        att.Body = Blob.valueOf('public class test{}');
        att.Description = 'Profile';
        att.Name = 'Profile';
        insert att;
        SnapshotToBranchCommitController.getAttachments(JSON.serialize(new List<String>{ att.Id }));
        SnapshotToBranchCommitController.getSnapshotAttInfo(JSON.serialize(new List<String>{ att.Id }));
        System.assertEquals(sc.Id, controller.snapId);

        List<Component_History__c> componentHistory = [SELECT Id FROM Component_History__c LIMIT 1];
        Attachment histAtt = new Attachment();
        histAtt.ParentId = componentHistory.get(0).Id;
        histAtt.Body = Blob.valueOf('public class test{}');
        histAtt.Description = 'Apex';
        histAtt.Name = 'Apex';
        insert histAtt;
        List<SnapshotToBranchCommitController.AttachmentWraper> wrap = SnapshotToBranchCommitController.getComponentAttachment(
            componentHistory.get(0).Id
        );
        System.assertEquals(false, wrap.isEmpty());

        controller.commitTo = br.Id;
        controller.createBuildRecords();
        controller.attStr = 'zip';
        controller.logId = '123';
        List<Patch__c> patchLi = [SELECT Id FROM Patch__c LIMIT 1];
        if (patchLi.size() > 0) {
            controller.patchId = patchLi[0].Id;
        }
        SnapshotToBranchCommitController.collectBackupInfo(controller.patchId);
        controller.idHistoryLi = new List<Id>();
        controller.snapName = 'snapname';
        controller.synchronize();
        controller.setFilter();

        controller.commitChunkJSON = '1';
        controller.isError = false;
        controller.commitInChunk();
        System.assertEquals(true, controller.isError);

        Test.stopTest();
    }

    @IsTest
    static void jsCommitTest() {
        Snapshot__c snap = [SELECT Id FROM Snapshot__c LIMIT 1];
        Branch__c br = [SELECT Id FROM Branch__c LIMIT 1];

        SnapshotToBranchCommitController.CommitWraper commitWrapper = new SnapshotToBranchCommitController.CommitWraper();
        SnapshotToBranchCommitController.JSCommitWraper jsCommitWraper = new SnapshotToBranchCommitController.JSCommitWraper();

        commitWrapper.metaIds = new List<String>();
        commitWrapper.dataMap = new Map<String, SnapshotToBranchCommitController.CommitFileWraper>();

        jsCommitWraper.idsComponents = new Set<String>();
        jsCommitWraper.idHistoryLi = new List<String>();

        for (Metadata_Item__c meta : [
            SELECT Id, RecordType.Name, Label__c, CRC32__c, API_Name__c
            FROM Metadata_Item__c
            LIMIT 3
        ]) {
            commitWrapper.metaIds.add(meta.Id);
            jsCommitWraper.idsComponents.add(meta.Id);
            jsCommitWraper.idHistoryLi.add(meta.Id);

            SnapshotToBranchCommitController.CommitFileWraper commitFileWrapper = new SnapshotToBranchCommitController.CommitFileWraper();
            commitFileWrapper.filename = meta.Label__c;
            commitFileWrapper.data = meta.API_Name__c + ' some data';
            commitFileWrapper.crc32 = meta.CRC32__c;

            commitWrapper.dataMap.put(meta.RecordType.Name + '#' + meta.API_Name__c, commitFileWrapper);
        }

        Test.startTest();
        SnapshotToBranchCommitController controller = new SnapshotToBranchCommitController();
        controller.commitChunkJSON = JSON.serialize(jsCommitWraper);
        controller.nextByJS();
        controller.commitTo = br.Id;
        controller.branchComponentId = [SELECT Id FROM Component__c LIMIT 1].Id;
        controller.metadataItemId = [SELECT Id FROM Metadata_Item__c LIMIT 1].Id;
        controller.compareComponent();
        controller.message = 'message#confirm';
        controller.fullPipelineRun = false;
        controller.pipelineId = [SELECT Id FROM Pipeline__c LIMIT 1].Id;
        controller.showMessage();
        controller.fullPipelineRun = true;
        controller.showMessage();
        controller.analyticsTrack();
        controller.back();

        SnapshotToBranchCommitController.jsCommit(JSON.serialize(commitWrapper), snap.Id, br.Id, 'ApexClass');

        Test.stopTest();

        System.assert(
            ![SELECT Id FROM Component__c WHERE Branch__c = :br.Id AND Component_Name__c = 'Test_Item__C' LIMIT 1]
                .isEmpty()
        );
    }


    //  Case 00014701 (Request to link Org and Repo so that we can display only the Repo based on the orgs selected on the 'commit to branch' page.)
    @IsTest
    static void listRepositoriesTest() {
        Restriction_Setting__c reposet = Restriction_Setting__c.getOrgDefaults();
        reposet.Repository_Restrictions_On__c = true;
        upsert reposet;

        Snapshot__c sc = [SELECT Id FROM Snapshot__c LIMIT 1];
        Organisation__c org = [SELECT Id FROM Organisation__c LIMIT 1];
        Repository__c rep1 = [SELECT Id FROM Repository__c LIMIT 1];

        Repository__c rep2 = new Repository__c(Name = 'repTest2');
        Repository__c rep3 = new Repository__c(Name = 'repTest3');
        insert new List<Repository__c>{ rep2, rep3 };

        Repository_Permission__c repPerm2 = new Repository_Permission__c(
            Repository__c = rep2.Id,
            User__c = UserInfo.getUserId()
        );
        Repository_Permission__c repPerm3 = new Repository_Permission__c(
            Repository__c = rep3.Id,
            User__c = UserInfo.getUserId()
        );
        insert new List<Repository_Permission__c>{ repPerm2, repPerm3 };

        Org_Restriction__c org1ResRep1 = new Org_Restriction__c(
            Org__c = org.Id,
            Repository__c = rep1.Id,
            Type__c = RepoRestrictionController.DEPLOY_RESTRICTION
        );
        Org_Restriction__c org1ResRep2 = new Org_Restriction__c(
            Org__c = org.Id,
            Repository__c = rep2.Id,
            Type__c = RepoRestrictionController.DEPLOY_RESTRICTION
        );
        insert new List<Org_Restriction__c>{ org1ResRep1, org1ResRep2 };

        Test.startTest();

        ApexPages.currentPage().getParameters().put('sid', sc.Id);
        SnapshotToBranchCommitController controller = new SnapshotToBranchCommitController();

        Test.stopTest();

        System.assertEquals(2, controller.repositoryOptions.size());
    }

    @IsTest
    static void testParseCatchMessage() {
        // Case 1: Standard formatted message
        String raw1 =
            'FIELD_CUSTOM_VALIDATION_EXCEPTION, Amount must be greater than 100: []';
        String expected1 = 'Amount must be greater than 100';
        System.assertEquals(expected1, FlosumConstants.parseCatchMessage(raw1));

        Test.startTest();
        // Case 2: Message without comma and colon
        String raw2 = 'Just a plain error message';
        System.assertEquals(raw2, FlosumConstants.parseCatchMessage(raw2));

        // Case 3: Empty string
        String raw3 = '';
        System.assertEquals(raw3, FlosumConstants.parseCatchMessage(raw3));

        // Case 4: Null value
        String raw4;
        System.assertEquals(null, FlosumConstants.parseCatchMessage(raw4));
        Test.stopTest();

        // Case 5: Message with extra spaces
        String raw5 =
            'FIELD_CUSTOM_VALIDATION_EXCEPTION,   Another error occurred   : []';
        String expected5 = 'Another error occurred';
        System.assertEquals(expected5, FlosumConstants.parseCatchMessage(raw5));
    }


}