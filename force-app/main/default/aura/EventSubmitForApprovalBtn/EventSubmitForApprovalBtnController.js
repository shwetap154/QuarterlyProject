({
    closeChildLWC : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        // $A.get('e.force:closeQuickAction').fire();
        console.log('after refresh view');
        var contractId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": contractId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        console.log('reInit happens');
    }
})