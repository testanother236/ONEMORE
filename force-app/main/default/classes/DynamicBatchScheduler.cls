global class DynamicBatchScheduler implements Schedulable {
  global String batchClassName;

  // Empty constructor
  global DynamicBatchScheduler() {
  }

  global void execute(SchedulableContext sc) {
    Type batchType = Type.forName(batchClassName);
    if (batchType == null) {
      throw new AuraHandledException(
        'Invalid Batch class name: ' + batchClassName
      );
    }

    // Create instance of the batch class
    Database.Batchable<SObject> batchInstance = (Database.Batchable<SObject>) batchType.newInstance();
    Database.executeBatch(batchInstance);
  }
}