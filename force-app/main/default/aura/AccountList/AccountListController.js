({
	newAccount : function(component, event, helper) {
		// Here we assign the value of this into the self variable
		var modal = component.find("newAccountModal");
        $A.util.removeClass(modal, 'hideDiv');  
        helper.showPopupHelper(component, 'newAccountModal', 'slds-fade-in-');
		helper.showPopupHelper(component,'newAccountBackdrop','slds-backdrop--');
        //
        $A.createComponent("c:AccountCreate",{'recordId': ''}, 
                           function (newAccountForm, status, errorMsg) {
                               if (status === "SUCCESS") {
                                   
                                    var body = component.find('driveDiv').get('v.body');
                    				body = newAccountForm;
                    				component.find('driveDiv').set('v.body', body);
                                   
                                   //component.set("v.body", newAccountForm);
                               } else {
                                   // show error
                               }
                           });
        //
	},
    newMassAccount : function(component, event, helper) {
        
        console.log('newMassAccount');
        // Here we assign the value of this into the self variable
		var modal = component.find("newAccountModal");
        $A.util.removeClass(modal, 'hideDiv');  
        helper.showPopupHelper(component, 'newAccountModal', 'slds-fade-in-');
		helper.showPopupHelper(component,'newAccountBackdrop','slds-backdrop--');
        $A.createComponent("c:MassAccountInsert",{}, 
                           function (newAccountForm, status, errorMsg) {
                               if (status === "SUCCESS") {
                                   
                                    var body = component.find('driveDiv').get('v.body');
                    				body = newAccountForm;
                    				component.find('driveDiv').set('v.body', body);
                                   
                                   //component.set("v.body", newAccountForm);
                               } else {
                                   // show error
                               }
                           });
    },
    doInit : function(component, event, helper) {
        var recordActions = [
            { label: 'Show Details', name: 'show_details' },
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        var cList = [
            {label: 'Account Name', fieldName: 'Name', type: 'text'},
            {label: 'Type', fieldName: 'Type', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', type: 'phone'},
            { type: 'action', typeAttributes: { rowActions: recordActions } }
        ];
        component.set('v.columns', cList);
        
        var columns = [];
        for(var index in cList){
            if(cList[index].fieldName != undefined)
            	columns.push(cList[index].fieldName);
        }
        var action = component.get("c.getAccountList");
        action.setParams({ fieldNames : columns });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.data",result);
                component.set("v.maxRowSelection",result.length);
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
        });
        $A.enqueueAction(action);
        //hide
        helper.hidePopupHelper(component, 'newAccountModal', 'slds-fade-in-');
		helper.hidePopupHelper(component, 'newAccountBackdrop', 'slds-backdrop--');
	},
    updateSelectedText: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    showNewAccountModal : function(component, event, helper) {  
        console.log('showNewAccountModal');
        var modal = component.find("newAccountModal");
        $A.util.removeClass(modal, 'hideDiv');  
        
        helper.showPopupHelper(component, 'newAccountModal', 'slds-fade-in-');
		helper.showPopupHelper(component,'newAccountBackdrop','slds-backdrop--');
    },
    hideNewAccountModal : function(component, event, helper) {
        var modal = component.find("newAccountModal");
        $A.util.addClass(modal, 'hideDiv');
        console.log('hide');
        
        helper.hidePopupHelper(component, 'newAccountModal', 'slds-fade-in-');
		helper.hidePopupHelper(component, 'newAccountBackdrop', 'slds-backdrop--');
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'show_details':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
                alert('delete: ' + JSON.stringify(row));
                break;
            case 'edit':
                //
             	var modal = cmp.find("newAccountModal");
                $A.util.removeClass(modal, 'hideDiv');  
                helper.showPopupHelper(cmp, 'newAccountModal', 'slds-fade-in-');
                helper.showPopupHelper(cmp,'newAccountBackdrop','slds-backdrop--');
                console.log(row);
                console.log(row.Id);
                $A.createComponent("c:AccountCreate",{'recordId': row.Id}, 
                           function (newAccountForm, status, errorMsg) {
                               if (status === "SUCCESS") {
                                   
                                    var body = cmp.find('driveDiv').get('v.body');
                    				body = newAccountForm;
                    				cmp.find('driveDiv').set('v.body', body);
                               } else {
                                   // show error
                               }
                           });
        		//
                break;
        }
    },
    
    refreshChild : function (cmp, event, helper) {
        console.log('refreshChild');
        helper.hidePopupHelper(cmp, 'newAccountModal', 'slds-fade-in-');
		helper.hidePopupHelper(cmp, 'newAccountBackdrop', 'slds-backdrop--');
	}
})