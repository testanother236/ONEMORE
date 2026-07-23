global class OrderResponseEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        // Extract the invoice number from the email subject
        String invoiceNumber = extractInvoiceNumber(email.subject);

        if (invoiceNumber != null) {
            // Check if the Opportunity object is accessible
            if (!Schema.sObjectType.Opportunity.isAccessible()) {
                System.debug('Insufficient permissions to read Opportunity');
                return result; // Return the result without changes
            }

            // Search for the Opportunity by invoice number
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Invoice_Number__c = :invoiceNumber LIMIT 1];

            if (opp != null) {
                String responseMessage = '';

                // Check the content of the email body
                if (email.plainTextBody != null) {
                    String emailBodyLower = email.plainTextBody.toLowerCase(); // Convert the body to lower case

                    if (emailBodyLower.contains('approved')) {
                        // Check if the Opportunity object is updateable
                        if (!Schema.sObjectType.Opportunity.isUpdateable()) {
                            System.debug('Insufficient permissions to update Opportunity');
                            return result; // Return the result without changes
                        }

                        // Update the Opportunity stage
                        opp.StageName = getNextStage(opp.StageName);
                        responseMessage = 'Thank you for approving the order. The opportunity has been updated.';
                    } else if (emailBodyLower.contains('rejected')) {
                        if (!Schema.sObjectType.Opportunity.isUpdateable()) {
                            System.debug('Insufficient permissions to update Opportunity');
                            return result; // Return the result without changes
                        }

                        // Mark the Opportunity as closed lost
                        opp.StageName = 'Closed Lost';
                        responseMessage = 'We are sorry to hear that. The opportunity has been marked as closed lost.';
                    }
                }
                
                // Update the Opportunity
                update opp;

                // Send a response email
                sendEmailResponse(envelope.fromAddress, responseMessage);
            }
        }

        return result; // Return the result
    }

    private void sendEmailResponse(String toAddress, String messageBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { toAddress });
        email.setSubject('Response to Your Order Confirmation');
        email.setPlainTextBody(messageBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    private String extractInvoiceNumber(String subject) {
        // Remove "Re:" and leading spaces before processing
        String cleanedSubject = subject.replaceAll('^Re:\\s*', '').trim();

        // Find the index of the invoice number
        Integer startIndex = cleanedSubject.indexOf('INV-');
        if (startIndex != -1) {
            // Extract the substring starting from the found index
            String invoiceNumber = cleanedSubject.substring(startIndex, startIndex + 10); // Assuming length of INV-000000
            return invoiceNumber;
        }
        return null; // Return null if not found
    }

    private String getNextStage(String currentStage) {
        // Logic to determine the next stage
        Map<String, String> stages = new Map<String, String>{
            'Prospecting' => 'Qualification',
            'Qualification' => 'Needs Analysis',
            'Needs Analysis' => 'Value Proposition',
            'Value Proposition' => 'Id. Decision Makers',
            'Id. Decision Makers' => 'Perception Analysis',
            'Perception Analysis' => 'Proposal/Price Quote',
            'Proposal/Price Quote' => 'Negotiation/Review',
            'Negotiation/Review' => 'Closed Won',
            'Closed Won' => 'Closed Lost'
        };
        return stages.get(currentStage) != null ? stages.get(currentStage) : currentStage;
    }
}