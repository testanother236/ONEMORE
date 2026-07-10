
/**
 * Represents a dynamic scheduler for executing batchable jobs.
 */
public class DynamicRelayScheduler implements Schedulable {
    
    /**
     * Holds the batchable instance to be executed.
     */
    private Database.Batchable<Object> batchToRun;

    /**
     * Specifies the size of the batch.
     */
    private Integer batchSize;

    /**
     * Constructs a DynamicRelayScheduler with a given batchable job and batch size.
     */
    public DynamicRelayScheduler(Database.Batchable<Object> batch, Integer size) {
        this.batchToRun = batch;
        this.batchSize = size;
    }

    /**
     * Executes the scheduled batch job if it is not null.
     */
    public void execute(SchedulableContext sc) {
        if (batchToRun != null) {
            Database.executeBatch(batchToRun, batchSize);
        }
    }
}
