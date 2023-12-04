({
    removeTerritories : function(component, event, helper) {
        var action = component.get("c.removeTerritories");
        action.setParams({ terrIdList : component.get("v.strTerrIds") });
        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                helper.removeTerritory(component, event, helper);

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
                        helper.doRedirect(component, event, helper, false, errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    removeTerritory : function(component, event, helper) {
        var action = component.get("c.removeTerritory");
        action.setParams({ terrIdList : component.get("v.strTerrIds") });
        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                helper.doRedirect(component, event, helper, true, '');

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
                        helper.doRedirect(component, event, helper, false, errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    doRedirect: function (component, event, helper, pass, error) {
        //Redirecting back to list view page
        var str = component.get("v.retUrlString");
        var listId = str.substring(str.indexOf("=")+1, str.length);
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": listId,
            "listViewName": null,
            "scope": "ZTS_EU_Territory__c"
        });
        navEvent.fire();
        //if there was an error registered fire of error toast
        if (!pass){
            //var error = 'Removal of territory failed.';
            helper.showToast(component, event, error);
        }
    },

    showToast: function (component, event, error) {
        //create error toast: type sticky and pre defined error text
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },
})