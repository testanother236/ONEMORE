({
	doInit : function(component, event, helper) {
		var accList = [];
        
        for(var index=0; index < 2; index++){
            var acc = {};
            acc.Name = '';
            acc.Type = '';
            acc.Phone = '';
            accList.push(acc);
        }
        component.set("v.accountList",accList);
	},
    getClone : function(component, event, helper) {
        console.log('getClone');
        
        var rowIndex = parseInt(event.getSource().get("v.name"));
        console.log('rowIndex-'+rowIndex);
        var accList = [];
        accList = component.get("v.accountList");
        var newList = [];
        for(var index=0; index < accList.length; index++){
            var rowRec = accList[index];
            newList.push(rowRec);
            console.log(index);
            console.log('index == rowIndex'+index == rowIndex);
            if(index == rowIndex){
                newList.push(JSON.parse(JSON.stringify(rowRec)));
            }
        }
        component.set("v.accountList",newList);
    }
})