({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var accId = myPageRef.state.c__accId;
        component.set("v.accId",accId);
        console.log('accId ::: '+accId);
        console.log('22222 ::: '+component.get("v.accId"));

        var action = component.get("c.getObjects");
        action.setParams({ account : component.get("v.accId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response :: '+response.getReturnValue());
                component.set("v.account",response.getReturnValue());
                helper.doRecCreate(component, event, helper);
            }
            else{
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
    }
})