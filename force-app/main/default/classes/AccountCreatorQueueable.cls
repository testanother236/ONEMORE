/**
 * Queueable job that creates Account records in small batches and chains itself until a total of ten accounts are created.
 */
public class AccountCreatorQueueable implements Queueable {
    /**
     * The number of account records created so far across the chain.
     */
    private Integer recordsCreated;
    /**
     * Number of accounts to create per execution.
     */
    private static final Integer BATCH_SIZE = 1;
    /**
     * Total number of accounts to create before stopping the chain.
     */
    private static final Integer TOTAL_TARGET = 10;

    /**
     * Constructor that sets the initial count of records already created.
     */
    public AccountCreatorQueueable(Integer recordsCreated) {
        this.recordsCreated = recordsCreated;
    }

    /**
     * Executes the queueable job: creates accounts if the target is not yet reached, inserts them, and chains a new job if needed.
     */
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