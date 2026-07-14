({
	doInit : function(component, event, helper) {
        console.log('doInit');
        var columns = [
        	{label: 'Id', fieldName: 'Id', type: 'text'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', type: 'text'}
        ];
        component.set("v.columns",columns);
        console.log('doInit');
        var action = component.get("c.getAccounts");
 		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.recList",result);
			}
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        })
        $A.enqueueAction(action);
        
	}
})