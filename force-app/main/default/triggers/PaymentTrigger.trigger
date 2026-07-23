trigger PaymentTrigger on Payment__c(after insert, after update) {
  // Map to store payment sums by Opportunity name
  Map<String, Decimal> opportunityPaymentSums = new Map<String, Decimal>();

  // Collect Opportunity names from the payments
  for (Payment__c payment : Trigger.new) {
      if (payment.OpportunityName__c != null) {
          // Initialize the sum for a new Opportunity name
          if (!opportunityPaymentSums.containsKey(payment.OpportunityName__c)) {
              opportunityPaymentSums.put(payment.OpportunityName__c, 0);
          }
          // Add the payment amount to the corresponding Opportunity name
          opportunityPaymentSums.put(
              payment.OpportunityName__c,
              opportunityPaymentSums.get(payment.OpportunityName__c) +
              payment.Amount__c
          );
      }
  }

  // Retrieve related Opportunities by name
  List<Opportunity> opportunitiesToUpdate = [
      SELECT Id, Amount, Status_Paid__c, OwnerId, Name
      FROM Opportunity
      WHERE Name IN :opportunityPaymentSums.keySet()
  ];

  List<Task> tasksToInsert = new List<Task>(); // List for tasks to be created

  for (Opportunity opp : opportunitiesToUpdate) {
      Decimal totalPayments = opportunityPaymentSums.get(opp.Name); // Get total payments for the Opportunity
      Decimal totalAmount = opp.Amount;

      // Determine the status of the Opportunity
      if (totalPayments >= totalAmount) {
          opp.Status_Paid__c = 'Fully Paid'; // Set custom field to 'Fully Paid'

          // Create a task for delivery of goods
          DateTime reminderDateTime = DateTime.newInstance(
              Date.today().addDays(1),
              Time.newInstance(10, 0, 0, 0)
          );

          Task newTask = new Task(
              OwnerId = opp.OwnerId, // Assign the task to the Opportunity owner
              Priority = 'High',
              Status = 'Not Started',
              Subject = 'Delivery of goods',
              WhatId = opp.Id,
              IsReminderSet = true,
              ReminderDateTime = reminderDateTime // Set reminder for the next day at 10 AM
          );
          tasksToInsert.add(newTask); // Add the task to the list
      } else if (totalPayments > 0) {
          opp.Status_Paid__c = 'Partially Paid'; // Set custom field to 'Partially Paid'
      }
  }

  // Update Opportunities if there are any
  if (!opportunitiesToUpdate.isEmpty()) {
      update opportunitiesToUpdate;
  }

  // Insert tasks if there are any new tasks to create
  if (!tasksToInsert.isEmpty()) {
      insert tasksToInsert;
  }
}