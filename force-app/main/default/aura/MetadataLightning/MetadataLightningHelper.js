({
  showRecord: function(component) {//console.log();
    var action = component.get("c.getAccounts");
    var self = this;
    action.setCallback(this, function(a) {
        component.set("v.records", a.getReturnValue());
    });
    $A.enqueueAction(action);
  }
})