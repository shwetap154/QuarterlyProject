({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var templateId = myPageRef.state.c__recordId;
        component.set("v.recordId",templateId);

        var action = component.get("c.getObjects");
        action.setParams({ templateId : templateId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.discVal",response.getReturnValue().ZTS_EU_Discount__c);
                helper.doCreateContractEvt(component, event, helper);
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