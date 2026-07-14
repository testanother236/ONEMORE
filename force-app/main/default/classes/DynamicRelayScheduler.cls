public class DynamicRelayScheduler implements Schedulable {
    
    private Database.Batchable<Object> batchToRun;
    private Integer batchSize;

    public DynamicRelayScheduler(Database.Batchable<Object> batch, Integer size) {
        this.batchToRun = batch;
        this.batchSize = size;
    }

    public void execute(SchedulableContext sc) {
        if (batchToRun != null) {
            Database.executeBatch(batchToRun, batchSize);
        }
    }
}