public class RandomAccountSelector {

    public static Account getSponsorAccount() {
        Integer accountCount = [SELECT COUNT() FROM Account];

        if (accountCount == 0) {
            return null;
        }

        Integer randomOffset = (Integer) (Math.random() * accountCount);

        Account randomAccount = [
            SELECT Id, Name, Type, Industry
            FROM Account
            LIMIT 1 OFFSET :randomOffset
        ];

        return randomAccount;
    }

    public static void runExample() {
        Account mySponsor = getSponsorAccount();

        if (mySponsor != null) {
            System.debug('--- Найден случайный аккаунт ---');
            System.debug('Имя: ' + mySponsor.Name);
            System.debug('Тип: ' + mySponsor.Type);
            System.debug('Отрасль: ' + mySponsor.Industry);
            System.debug('----------------------------------');
        } else {
            System.debug('Аккаунты не найдены в базе данных.');
        }
    }
}