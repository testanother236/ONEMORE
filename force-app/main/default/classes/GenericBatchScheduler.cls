public with sharing class GenericBatchScheduler {
  
  @AuraEnabled
  public static void scheduleBatch(
    String schedulerClassName,
    String batchClassName,
    String cronString
  ) {
    // Check if the scheduler class exists
    Type schedulerType = Type.forName(schedulerClassName);
    if (schedulerType == null) {
      throw new AuraHandledException(
        'Invalid Scheduler class name: ' + schedulerClassName
      );
    }

    // Ensure the class implements the Schedulable interface
    if (!Schedulable.class.isAssignableFrom(schedulerType)) {
      throw new AuraHandledException(
        'Scheduler class must implement Schedulable interface.'
      );
    }

    // Create an instance of the scheduler
    Schedulable schedulerInstance = (Schedulable) schedulerType.newInstance();

    // Set the batch class name if the scheduler is of type BatchScheduler
    if (schedulerInstance instanceof BatchScheduler) {
      ((BatchScheduler) schedulerInstance).setBatchClassName(batchClassName);
    } else {
      throw new AuraHandledException(
        'Scheduler class must be of type BatchScheduler.'
      );
    }

    // Schedule the job using the provided cron expression
    System.schedule(schedulerClassName + ' Job', cronString, schedulerInstance);
  }

  @AuraEnabled
  public static void runBatchOnce(String batchClassName) {
    // Check if the batch class exists
    Type batchType = Type.forName(batchClassName);
    if (batchType == null) {
      throw new AuraHandledException(
        'Invalid Batch class name: ' + batchClassName
      );
    }

    // Create an instance of the batch class
    Database.Batchable<SObject> batchInstance = (Database.Batchable<SObject>) batchType.newInstance();
    
    // Execute the batch
    Database.executeBatch(batchInstance);
  }

  @AuraEnabled
  public static void abortBatch(String schedulerClassName) {
    // Query for scheduled jobs to abort
    List<CronTrigger> jobsToAbort = [
      SELECT Id
      FROM CronTrigger
      WHERE CronJobDetail.JobType = '7' // JobType '7' is for scheduled jobs
    ];

    // Throw an exception if no jobs are found
    if (jobsToAbort.isEmpty()) {
      throw new CustomException(
        'No scheduled job found with the name: ' + schedulerClassName
      );
    }

    // Abort all scheduled jobs found
    for (CronTrigger job : jobsToAbort) {
      System.abortJob(job.Id);
    }

  }
}