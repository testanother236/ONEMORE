public class AgentIAInvoker {
    public static void invokeJavaAction() {
      try {
         
          // Create an instance of the invocable action with type ‘generateAiAgentResponse’ and name ‘Agentforce_Service_Agent_new’
          Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', 'Agentforce_Service_Agent_new@1.0.0');
          
          action.setInvocationParameter('userMessage', 'Summarize my contact');
          action.setInvocationParameter('ContactId', '500VW0XXXXXXXXXXXX');
          
          // Execute the action
          List<Invocable.Action.Result> results = action.invoke();
          Invocable.Action.Result result = results[0];

          // Handle the response
          if (result.isSuccess()) {
              // Retrieve the Session ID and Agent Response
              System.debug('Output Session ID: ' + result.getOutputParameters().get('sessionId'));
              System.debug('Output Agent Response: ' + result.getOutputParameters().get('agentResponse'));

          } else {
              System.debug('Java action execution failed: ' + result.getErrors());
          }
      } catch (Exception e) {
          System.debug('Error invoking Java action: ' + e.getMessage());
      }
    }
}