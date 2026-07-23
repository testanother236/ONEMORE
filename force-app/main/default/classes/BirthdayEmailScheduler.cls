global class BirthdayEmailScheduler implements Schedulable, BatchScheduler {
  global String batchClassName;

  // Empty constructor
  global BirthdayEmailScheduler() {
  }

  // Method for setting the name of the butch class
  global void setBatchClassName(String batchClassName) {
    this.batchClassName = batchClassName;
  }

  global void execute(SchedulableContext sc) {
    // Create instance DynamicBatchScheduler
    DynamicBatchScheduler dynamicScheduler = new DynamicBatchScheduler();
    dynamicScheduler.batchClassName = batchClassName; // Setting the name of the butch class
    dynamicScheduler.execute(sc);
  }
}