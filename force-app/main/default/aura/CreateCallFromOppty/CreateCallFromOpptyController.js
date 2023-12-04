({
    doInit : function(component, event, helper) {
         //Check if the user is from INTL
         var action = component.get("c.isInternationalUser");
         action.setCallback(this, function(response) {
              var isInternationalUser = response.getReturnValue();
              var state = response.getState();
              if(state == 'SUCCESS') {
                component.set('v.isInternationalUser', response.getReturnValue());
                  //alert('Modal '+response.getReturnValue());
            }
         });
         $A.enqueueAction(action);
        //To pull Opportunity's related Account
        var action = component.get("c.getAccountIdfromOppty");
		action.setParams({ oppId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
              var accId = response.getReturnValue();
              var state = response.getState();
              if(state == 'SUCCESS') {
                component.set('v.accId', response.getReturnValue());
                  //alert('Modal '+response.getReturnValue());
            }
         });
         $A.enqueueAction(action);
    },
    closeChildLWC : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get('e.force:closeQuickAction').fire();
        console.log('after refresh view');
    }
})