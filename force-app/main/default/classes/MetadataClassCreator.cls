public class MetadataClassCreator {
    
    public static void createApexClasses(Integer numberOfClasses) {
        List<MetadataService.CustomMetadata> records = new List<MetadataService.CustomMetadata>();
        
        for(Integer i = 1; i <= numberOfClasses; i++) {
            String className = 'GeneratedClass3' + i;
            createApexClassViaTooling(className);
        }
    }
    
    @Future(callout=true)
    private static void createApexClassViaTooling(String className) {
        String classBody = 'public class ' + className + ' {\n' +
                          '    public static void execute() {\n' +
                          '        System.debug(\'Hello from ' + className + '\');\n' +
                          '    }\n' +
                          '}';
        
        // Используем Tooling API для создания класса
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v58.0/tooling/sobjects/ApexClass');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        
        String requestBody = '{"Name": "' + className + '", "Body": "' + 
                           classBody.escapeJava() + '"}';
        request.setBody(requestBody);
        
        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 201) {
                System.debug('Создан класс: ' + className);
            } else {
                System.debug('Ошибка: ' + response.getStatusCode() + ' - ' + response.getBody());
            }
        } catch(Exception e) {
            System.debug('Исключение: ' + e.getMessage());
        }
    }
}