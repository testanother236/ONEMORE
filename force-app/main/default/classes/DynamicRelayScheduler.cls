public class DynamicRelayScheduler implements Schedulable {
    
    private Database.Batchable<Object> batchToRun;
    private Integer batchSize;

    public DynamicRelayScheduler(Database.Batchable<Object> batchssssss, Integer size) {
        this.batchToRun = batchssssss;
        this.batchSize = size;
    }
    //newtestline

    public void execute(SchedulableContext sc) {
        if (batchToRun != null) {
            Database.executeBatch(batchToRun, batchSize);
        }
    }
}
//onemorelineTESTrwerstest