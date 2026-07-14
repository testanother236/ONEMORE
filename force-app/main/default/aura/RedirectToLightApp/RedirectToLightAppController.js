({
	viewCAT : function(component, event, helper) {
        var context = component.get('v.context');
        var evt = $A.get("e.force:navigateToComponent");
        var params = {
            componentDef : "c:ContractAssessmentToolApp",
            componentAttributes: {
                context: {
                      accountId : context.contract.AccountId,
                      modelId : null,
                      assessment : context.assessment
                 }
            }
        }

        evt.setParams(params);
        evt.fire();
    }
})