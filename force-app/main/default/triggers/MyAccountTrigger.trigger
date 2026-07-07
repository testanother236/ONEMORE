/**
 * Handles before insert logic for Account records to set default description. Test
 */
trigger MyAccountTrigger on Account (before insert) {
    for(Account acc : Trigger.new) {
        acc.Description = 'aaaaa';
    }
}