({
	handleTotalIncomeCompoenntEnvet : function(component, event, helper) {
		alert('Event handle in parent component.');
        var totalIncome = event.getParam("totalIncome");
        component.set('v.totalIncome',totalIncome);
        //event.stopPropagation();
	}
})