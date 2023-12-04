({
    doInit : function(component, event, helper) {
    
        var myPageRef = component.get("v.pageReference");
        var contractId = myPageRef.state.c__contrId;
        component.set("v.recordId",contractId);
        helper.doGetMZRCalc(component, event, helper);
    }
})