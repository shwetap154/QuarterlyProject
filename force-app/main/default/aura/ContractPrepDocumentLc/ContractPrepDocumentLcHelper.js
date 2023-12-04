({
    doRedirect: function (component, event, helper, pass) {
        //Redirecting back to View page for Contract record
        var contractId = component.get("v.contrId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": contractId
        });
        navEvt.fire();
        if (!pass){
            var error = 'ERROR - Please use NEW LE Enrollment App to complete ALL LE Producer enrollments';
            helper.showToast(component, event, error);
        }
    },

    showToast: function (component, event, error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },

    getTemplates: function (component, event, helper) {
        var action = component.get("c.getTemplates");
            action.setParams({ id : component.get("v.contrId") });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.templates",response.getReturnValue());
                    var result =response.getReturnValue();
                    if(result != null && result.length > 0){
                        if(result.indexOf('Errors') != -1 ){
                            console.log('Errors :::'+result);
                            alert(result);
                        }
                        else{
                            var urlEvent = $A.get("e.force:navigateToURL");
                            var contractId = component.get("v.contrId")
                            urlEvent.setParams({
                            "url": '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + contractId + '&TemplateId=' + result
                            });
                            urlEvent.fire();
                        }
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
})