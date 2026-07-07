global class ScheduledDeleteJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        // This section is dedicated to the deletion of snapshots.
        Set<Id> snapshotIdSet = new Set<Id>();
        // The following query may be adjusted to meet specific requirements.
        for (Flosum__Snapshot__c snap : [SELECT Id FROM Flosum__Snapshot__c WHERE Name  ='full_P_Source_21.02.2025_Agent']) {
            snapshotIdSet.add(snap.Id);
        }
        Map<String, Object> dataMap1 = new Map<String, Object>();
        dataMap1.put('selectedIdSet', snapshotIdSet);
        dataMap1.put('batchType', Flosum.MassDeleteSnapshotController.DELETE_SNAPSHOT_BATCH);
        Flosum.MassDeleteSnapshotController b1 = new Flosum.MassDeleteSnapshotController(dataMap1);
        if(!snapshotIdSet.isEmpty()) {
            Database.executeBatch(b1);
        }
        // This section is dedicated to the deletion of branches.
        Set<Id> branchIdSet = new Set<Id>();
        // The following query may be adjusted to meet specific requirements.
        for (Flosum__Branch__c snap : [SELECT Id FROM Flosum__Branch__c WHERE Flosum__Branch_Name__c   ='test manual step merge #5']) {
            branchIdSet.add(snap.Id);
        }
        Map<String, Object> dataMap2 = new Map<String, Object>();
        dataMap2.put('selectedIdSet', branchIdSet);
        dataMap2.put('batchType', Flosum.MassDeleteSnapshotController.DELETE_BRANCH_BATCH);
        Flosum.MassDeleteSnapshotController b2 = new Flosum.MassDeleteSnapshotController(dataMap2);
        if(!branchIdSet.isEmpty()) {
            Database.executeBatch(b2);
        }
    }
}