public class DynamicRelayScheduler implements Schedulable {
    
    private Database.Batchable<Object> batchToRun;
    private Integer batchSize;

    public DynamicRelayScheduler(Database.Batchable<Object> batchss, Integer size) {
        this.batchToRun = batchss;
        this.batchSize = size;
    }
    //newtestline

    public void execute(SchedulableContext sc) {
        if (batchToRun != null) {
            Database.executeBatch(batchToRun, batchSize);
        }
    }
}
//onemoreAAAAAAAAAAA