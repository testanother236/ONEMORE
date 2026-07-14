global class CaseWithEmailAndAttachmentBatch implements Database.Batchable<Integer> {
    global Integer totalCases = 1;
    global Integer batchSize = 1;

    global Iterable<Integer> start(Database.BatchableContext BC) {
        List<Integer> ids = new List<Integer>();
        for (Integer i = 1; i <= totalCases; i++) {
            ids.add(i);
        }
        return ids;
    }

    global void execute(Database.BatchableContext BC, List<Integer> scope) {
        List<Case> caseList = new List<Case>();
        for (Integer idx : scope) {
            caseList.add(new Case(
                Subject = 'Case #' + idx,
                Status = 'New',
                Origin = 'Web'
            ));
        }
        insert caseList;

        List<EmailMessage> emailList = new List<EmailMessage>();
        for (Case c : caseList) {
            emailList.add(new EmailMessage(
                ParentId = c.Id,
                Subject = 'Email for Case ' + c.Subject,
                FromAddress = 'test@example.com',
                ToAddress = 'user@example.com',
                TextBody = 'Message for case ' + c.Subject,
                Status = '0' // Draft
            ));
        }
        insert emailList;

        List<Attachment> attachList = new List<Attachment>();
        for (EmailMessage email : emailList) {
            attachList.add(new Attachment(
                ParentId = email.Id,
                Name = 'Attachment for ' + email.Subject + '.txt',
                Body = Blob.valueOf('Some file content for ' + email.Subject),
                ContentType = 'text/plain'
            ));
        }
        insert attachList;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Готово! Создано 100,000 кейсов, каждому добавлен EmailMessage с Attachment.');
    }
}


//Database.executeBatch(new CaseWithEmailAndAttachmentBatch(), 2000);
//