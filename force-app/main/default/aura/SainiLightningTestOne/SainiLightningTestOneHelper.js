({
	calculateMonthlyPayment : function(component) {
        var investment = component.get('v.principal');
        var annualRate = component.get('v.rate');
        var years = component.get('v.years');
        var monthlyRate = annualRate / 12 / 100;
        var months = years * 12;
        var futureValue = 0;
        
        for ( var i = 1; i <= months; i++ ) {
            futureValue = futureValue + investment * Math.pow(1 + monthlyRate, months);
        }
        component.set('v.monthlyPayment',futureValue);
	}
})