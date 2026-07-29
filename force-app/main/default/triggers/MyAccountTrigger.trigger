// File: triggers/MyAccountTrigger.trigger
trigger MyAccountTrigger on Account (before insert) {
    for(Account acc : Trigger.new) {
        acc.Description = 'Trigger ran';
    }
}