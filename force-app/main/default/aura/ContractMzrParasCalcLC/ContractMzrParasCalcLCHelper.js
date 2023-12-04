({

    doGetMZRCalc: function (component, event, helper) {

        var action = component.get("c.docParasList");
        action.setCallback(this, function(response){
            var state = response.getState();
            var pass;
            if (state === "SUCCESS") {
                if(response.getReturnValue().length == 0){
                    pass = false;
                    helper.doRedirect(component, event, helper, pass);
                }
                else{
                    pass = true;
                    var calDocument = response.getReturnValue();
                    var documentId = calDocument[0].Id;
                    helper.fileDownload(component, event, helper, documentId);
                    helper.doRedirect(component, event, helper, pass);
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
    },
    doRedirect: function (component, event, helper, pass) {
        //Redirecting back to View page for Contract record
        var contractId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": contractId
        });
        navEvt.fire();
        if (!pass){
            var error = 'No MZR BIOS Calculator Excel found in Documents';
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

    fileDownload: function (component, event, helper, documentId) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf('force.com/')+10);
        window.open( 
            baseURL+"/sfc/servlet.shepherd/document/download/"+documentId, "_blank"
        );
        
    }
})