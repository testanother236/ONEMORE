public class addRec implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Integer count;
    public addRec(Integer i){
        this.count = i;
    }
    public Iterable<SObject> start(Database.BatchableContext BC) {

        
        List <Attachment> attlist = new List<Attachment>();
         Attachment att = new Attachment(
                 Body = Blob.valueOf('1'),
                 ParentId = '0030900001iS761AAC',
                 Description = 'MERGEBRANCHSET',
                 Name = 'MERGEBRANCHSET'+Datetime.now().getTime(),
                 ContentType = 'text/plain'
         );
         for (Integer index=0; index<100; index++){
             Attachment tmn = att.clone();
             tmn.Name = 'MERGEBRANCHSET'+Datetime.now().getTime();
             attlist.add(tmn);
         }
         return attlist;

    }
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        insert scope;
    }
    public void finish(Database.BatchableContext info) {
        /*if (count<400){
                Database.executeBatch(new addRec(count+1),10);
        }*/
        if (false){
            String s1='';
            String s2='';
            String s3='';
            String s4='';
        }
        //Integer alreadyThere =  [SELECT count() FROM TestMask1__c ];
        //Integer alreadyThere =  [SELECT count() FROM Attachment WHERE ParentId = '0030900001iS761AAC'];
        /*Integer alreadyThere =  [SELECT count() FROM Metadata_Log__c WHERE Branch__c = 'a075C000002SWyFQAW'];*/
        /*if (alreadyThere<1700000){
            Database.executeBatch(new addRec(1),500);
        }*/
        //System.debug(Datetime.now());
    }
}