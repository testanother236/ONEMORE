public class AccountCreatorQueueable implements Queueable {
    private Integer recordsCreated;
    private static final Integer BATCH_SIZE = 1;
    private static final Integer TOTAL_TARGET = 10;

    public AccountCreatorQueueable(Integer recordsCreated) {
        this.recordsCreated = recordsCreated;
    }

    public void execute(QueueableContext context) {
        if (recordsCreated >= TOTAL_TARGET) {
            System.debug('✅ AccountCreatorQueueable: Target reached. Job chain completed.');
            return;
        }

        try {
            List<Account> accountsToInsert = new List<Account>();
            for (Integer i = 0; i < BATCH_SIZE; i++) {
                accountsToInsert.add(new Account(
                        Name = 'Auto-Account ' + (recordsCreated + i + 1),
                        Industry = 'Technology',
                        Description = 'Created by Queueable chain at ' + System.now()
                ));
            }

            Long startTime = System.currentTimeMillis();
            while (System.currentTimeMillis() - startTime < 45000) {
                Math.random();
            }

            insert accountsToInsert;
            recordsCreated += accountsToInsert.size();

            System.debug('📦 Created ' + accountsToInsert.size() + ' accounts. Total so far: ' + recordsCreated);

            if (recordsCreated < TOTAL_TARGET) {
                System.enqueueJob(new AccountCreatorQueueable(recordsCreated));
            }
        } catch (Exception e) {
            System.debug('❌ AccountCreatorQueueable Error: ' + e.getMessage());
        }
    }
}

//take 3 ya'all