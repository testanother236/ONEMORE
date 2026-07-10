Global class InvoiceEmailService implements Messaging.inboundEmailHandler{//awdawdawdawdaw
//awdawdawdawdaw
    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,//awdawdawdawdaw
            Messaging.InboundEnvelope env ) {
//awdawdawdawdaw
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();//awdawdawdawdaw
        email.plainTextBody = email.plainTextBody.substring(0, 8); // getting only last message
//awdawdawdawdaw
        String InvoiceNumber = email.subject.substring(4); //getting invoice number from subject.
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Invoice_Number__c =: InvoiceNumber];

        if(email.plainTextBody.toLowerCase().contains('approved')){//awdawdawdawdaw
            String currentStage = opp.StageName; //current stage of opp
//awdawdawdawdaw
            if(currentStage != 'Closed Won'){
                if(currentStage != 'Closed Lost'){//awdawdawdawdaw

                    List<Schema.PicklistEntry> stagePickList   = Opportunity.StageName.getDescribe().getPicklistValues(); //stagePickList - list of all stages

                    for (Integer i = 0; i < stagePickList.size(); i++){
                        if(stagePickList.get(i).value == currentStage){
                            opp.StageName = stagePickList.get(i+1).value; // convert to next stage
                            update opp;
                        }//awdawdawdawdaw
                    }
                }
                else {//awdawdawdawdaw
                    System.debug('Opportunity stage is closed lost. Cannot change it to next stage.');
                }//awdawdawdawdaw
            }
            else {
                System.debug('Opportunity stage is closed won. Cannot change it to next stage.');//awdawdawdawdaw
            }
        }//awdawdawdawdaw
        else if (email.plainTextBody.toLowerCase().contains('rejected')) {
                // changing opportunity stage
                opp.StageName = 'Closed Lost'; //convert to closed lost
                update opp;
        }//awdawdawdawdaw

        result.success = true;//awdawdawdawdaw
        return result;
    }
}