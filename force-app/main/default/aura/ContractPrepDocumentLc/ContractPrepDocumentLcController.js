({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var contrId = myPageRef.state.c__contrId;
        component.set("v.contrId",contrId);

        var acc = myPageRef.state.c__account;
        component.set("v.account",acc);
        
        if(acc == 'Producers' || acc == 'Strategic Producer'){
            //do an error 
            helper.doRedirect(component, event, helper, false);
        }
        else{
            //get echosign_dev1__SIGN_Agreement__c
            var action = component.get("c.hasAgreements");
            action.setParams({ contractId : component.get("v.contrId") });
            action.setCallback(this, function(response){
                var state = response.getState();
                var pass;
                if (state === "SUCCESS") {
                    if(response.getReturnValue()){
                        component.set('v.showConfirmDialog', true);
                    }
                    else{
                        helper.getTemplates(component, event, helper);
                    }

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

        }

    },

    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        helper.doRedirect(component, event, helper, true);
    }
})