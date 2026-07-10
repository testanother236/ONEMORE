public class DynamicRelayScheduler implements Schedulable {
    
    private Database.Batchable<Object> batchToRun;
    private Integer batchSize;

    public DynamicRelayScheduler(Database.Batchable<Object> batchsss, Integer size) {
        this.batchToRun = batchsss;
        this.batchSize = size;
    }
    //newtestline

    public void execute(SchedulableContext sc) {
        if (batchToRun != null) {
            Database.executeBatch(batchToRun, batchSize);
        }
    }
}
//onemoreAAAAAAAAtestAGAIB