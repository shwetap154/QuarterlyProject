({
    doInit : function(component, event, helper) {
        //get c__contrId param from the URL, is was set up on VF page before redirect to LC 
        //this param has string ID for Contract record. Use that Id to call APEX method and return
        //contract object with fields that we will use later
        var myPageRef = component.get("v.pageReference");
        var contrId = myPageRef.state.c__contrId;
        component.set("v.contrId",contrId);

        helper.onInit(component, event, helper);

    },

    handleComponentEvent: function(component, event, helper) {
        var message = event.getParam("evtConfirmed");
        // set the handler attributes based on event data
        if (message == false) {
            component.set("v.isValid", false);
        }
        else{
            component.set("v.showCalcCard", !message);
            helper.onInit(component, event, helper);
        }
        helper.doRedirect(component, event, helper, true, '');
    },
    
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})