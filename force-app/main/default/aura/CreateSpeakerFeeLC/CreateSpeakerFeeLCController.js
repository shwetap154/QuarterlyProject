({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var contId = myPageRef.state.c__contId;
        component.set("v.contId",contId);

        var action = component.get("c.getObjects");
        action.setParams({ conid : component.get("v.contId") });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue().ZTS_US_Cal_Speaker_Flag__c){
                    component.set("v.errorMsg",false);
                    helper.doRecCreate(component, event, helper);
                }
                else{
                    component.set("v.errorMsg",true);
                    helper.doRedirect(component, event, helper);
                }
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