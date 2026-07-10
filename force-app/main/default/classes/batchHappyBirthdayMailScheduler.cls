global class batchHappyBirthdayMailScheduler implements Schedulable{
    public static batchHappyBirthdayMail bth= new batchHappyBirthdayMail ();
    global void execute(SchedulableContext dc){
        Database.executeBatch(bth);
    }
}