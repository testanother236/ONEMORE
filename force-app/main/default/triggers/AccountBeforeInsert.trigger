trigger AccountBeforeInsert on Account (before insert) {
 for (Account acc : Trigger.new) {
        if (acc.Name == null || acc.Name == '') {
            acc.Name = 'Default Name';
        }
    }
}