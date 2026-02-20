trigger QD_AccountTrigger on Account (before insert) {
     for (Account acc : Trigger.new) {
        acc.Description = 'Processed by Quick Deploy test trigger';
    }

}