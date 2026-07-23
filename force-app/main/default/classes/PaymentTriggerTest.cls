@isTest
public class PaymentTriggerTest {
  @isTest
  static void testFullyPaidOpportunity() {
      // Create a test Opportunity
      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity',
          Amount = 1000,
          StageName = 'Prospecting',
          CloseDate = Date.today().addDays(30)
      );
      insert testOpportunity;

      // Create test payments
      Payment__c payment1 = new Payment__c(
          OpportunityName__c = testOpportunity.Name,
          Amount__c = 500
      );

      Payment__c payment2 = new Payment__c(
          OpportunityName__c = testOpportunity.Name,
          Amount__c = 500
      );

      // Insert payments
      insert new List<Payment__c>{ payment1, payment2 };

      // Check that the status has updated to 'Fully Paid'
      Opportunity updatedOpportunity = [
          SELECT Id, Status_Paid__c
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];
      System.assertEquals(
          'Fully Paid',
          updatedOpportunity.Status_Paid__c,
          'The Opportunity should be marked as Fully Paid.'
      );

      // Check that a task was created
      List<Task> tasks = [
          SELECT Id, Subject, ReminderDateTime
          FROM Task
          WHERE WhatId = :testOpportunity.Id
      ];
      System.assertEquals(
          1,
          tasks.size(),
          'There should be one task created for the opportunity.'
      );
      System.assertEquals(
          'Delivery of goods',
          tasks[0].Subject,
          'The task subject should be "Delivery of goods".'
      );
  }

  @isTest
  static void testPartiallyPaidOpportunity() {
      // Create a test Opportunity
      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity 2',
          Amount = 1000,
          StageName = 'Prospecting',
          CloseDate = Date.today().addDays(30)
      );
      insert testOpportunity;

      // Create a test payment
      Payment__c payment = new Payment__c(
          OpportunityName__c = testOpportunity.Name,
          Amount__c = 500
      );

      // Insert the payment
      insert payment;

      // Check that the status has updated to 'Partially Paid'
      Opportunity updatedOpportunity = [
          SELECT Id, Status_Paid__c
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];
      System.assertEquals(
          'Partially Paid',
          updatedOpportunity.Status_Paid__c,
          'The Opportunity should be marked as Partially Paid.'
      );

      // Check that no task was created
      List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :testOpportunity.Id];
      System.assertEquals(
          0,
          tasks.size(),
          'There should be no task created for partially paid opportunities.'
      );
  }

  @isTest
  static void testNoPayments() {
      // Create a test Opportunity with no payments
      Opportunity testOpportunity = new Opportunity(
          Name = 'Test Opportunity 3',
          Amount = 1000,
          StageName = 'Prospecting',
          CloseDate = Date.today().addDays(30)
      );
      insert testOpportunity;

      // Check the status with no payments
      Opportunity updatedOpportunity = [
          SELECT Id, Status_Paid__c
          FROM Opportunity
          WHERE Id = :testOpportunity.Id
      ];
      System.assertEquals(
          null,
          updatedOpportunity.Status_Paid__c,
          'The Opportunity should have no status set.'
      );
  }
}