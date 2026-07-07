public class addRec2 implements Database.Batchable<MetadataService.Metadata>, Database.AllowsCallouts {

    public Integer count;
    public addRec2(Integer i){
        this.count = i;
    }
    public Iterable<MetadataService.Metadata> start(Database.BatchableContext BC) {

        
        List<MetadataService.Metadata> fields = new List<MetadataService.Metadata>();
        for (Integer i=500; i<1000; i++){
            /*MetadataService.CustomObject  customobject = new MetadataService.CustomObject();
            customobject.fullName = 'custom_create'+i+'__c';
            customobject.label = 'Custom created object'+i;
            customobject.pluralLabel = 'Custom created objects'+i;
            customObject.nameField = new MetadataService.CustomField();
            customobject.nameField.type_x = 'Text';
            customobject.nameField.label = 'Custom created field';
            customobject.deploymentStatus = 'Deployed';
            customObject.sharingModel = 'ReadWrite';
            fields.add(customobject);*/

            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = 'custom_create'+count+'__c.custom_create_'+count+'field'+i+'__c';
            customField.label = 'Custom created '+count+'field'+i;
            customField.defaultvalue = 'true';
            customField.type_x = 'Checkbox';
            fields.add(customField);
        }
        return fields;

    }
    public void execute(Database.BatchableContext BC, List<MetadataService.Metadata> scope) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        MetadataService.SaveResult[] results = service.createMetadata(scope);
    }
    public void finish(Database.BatchableContext info) {
        if (count<400){
                Database.executeBatch(new addRec2(count+1),10);
        }
        //Integer alreadyThere =  [SELECT count() FROM TestMask1__c ];
        /*Integer alreadyThere =  [SELECT count() FROM Attachment WHERE ParentId = 'a065g00000B52VI'];*/
        /*Integer alreadyThere =  [SELECT count() FROM Metadata_Log__c WHERE Branch__c = 'a075C000002SWyFQAW'];
        if (alreadyThere<200000){
            Database.executeBatch(new addRec(),5000);
        }
        System.debug(Datetime.now());*/
    }
}