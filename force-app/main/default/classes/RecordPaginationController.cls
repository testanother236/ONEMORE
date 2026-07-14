public with sharing class RecordPaginationController {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecordList(QueryWrapper recordQueryWrapper) {

        String query= 'SELECT Id';
        for(String str : recordQueryWrapper.fiedNames){
            query += ','+str;
        }
        query += ' FROM '+recordQueryWrapper.objectName;
        query += ' '+recordQueryWrapper.whereclause;
        query += ' LIMIT '+recordQueryWrapper.recordLimit;
        return Database.query(query);
    }

    public class QueryWrapper {
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public List<String> fiedNames;
        @AuraEnabled
        public String whereclause;
        @AuraEnabled
        public Integer recordLimit;
    }
}