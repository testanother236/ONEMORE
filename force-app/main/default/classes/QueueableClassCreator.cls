public class QueueableClassCreator implements Queueable, Database.AllowsCallouts {
    
    private Integer startIndex;
    private Integer totalClasses;
    private Integer batchSize;
    
    public QueueableClassCreator(Integer startIndex, Integer totalClasses, Integer batchSize) {
        this.startIndex = startIndex;
        this.totalClasses = totalClasses;
        this.batchSize = batchSize;
    }
    
    public void execute(QueueableContext context) {
        Integer endIndex = Math.min(startIndex + batchSize - 1, totalClasses);
        Integer created = 0;
        
        for(Integer i = startIndex; i <= endIndex; i++) {
            String className = 'QueueClass2' + i;
            if(createClassWithWait(className)) {
                created++;
            }
            
            // Задержка между созданиями
            if(i < endIndex) {
                waitBetweenOperations(1000); // 1 секунды
            }
        }
        
        System.debug('Создано ' + created + ' классов в батче ' + startIndex + '-' + endIndex);
        
        // Запускаем следующий батч, если нужно
        Integer nextStart = endIndex + 1;
        if(nextStart <= totalClasses) {
            System.enqueueJob(new QueueableClassCreator(nextStart, totalClasses, batchSize));
        }
    }
    
    private Boolean createClassWithWait(String className) {
        Integer attempts = 0;
        while(attempts < 3) {
            try {
                createSingleClass(className);
                return true;
            } catch(CalloutException e) {
                attempts++;
                if(attempts >= 3) {
                    System.debug('Не удалось создать класс ' + className);
                    return false;
                }
                waitBetweenOperations(1000); // 1 секунд перед повторной попыткой
            }
        }
        return false;
    }
    
    private void createSingleClass(String className) {
        String classBody = 'public class ' + className + ' {\n' +
                          '    public static void run() {\n' +
                          '        System.debug(\'Running: ' + className + '\');\n' +
                          '    }\n' +
                          '}';
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v58.0/tooling/sobjects/ApexClass');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        
        String escapedBody = classBody.replace('"', '\\"')
                                     .replace('\n', '\\n')
                                     .replace('\r', '\\r')
                                     .replace('\t', '\\t');
        
        String requestBody = '{"Name": "' + className + '", "Body": "' + escapedBody + '"}';
        request.setBody(requestBody);
        request.setTimeout(30000);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() != 201) {
            throw new CalloutException('HTTP ' + response.getStatusCode() + ': ' + response.getBody());
        }
    }
    
    private static void waitBetweenOperations(Integer milliseconds) {
        Long startTime = DateTime.now().getTime();
        while(DateTime.now().getTime() - startTime < milliseconds) {
            // Ожидание
        }
    }
    
    // Метод для запуска
    public static void startCreation(Integer totalClasses, Integer batchSize) {
        System.enqueueJob(new QueueableClassCreator(1, totalClasses, batchSize));
    }
}