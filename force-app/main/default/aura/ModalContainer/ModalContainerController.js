/**
 * Created by alexander.carstairs on 3/20/20.
 * Updated by Aritra (Cognizant) on 4/12/2021  for SC-004726
 */

({
    doInit : function(component, event, helper) {
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
    },
    closeChildLWC : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get('e.force:closeQuickAction').fire();
        console.log('after refresh view');
    }
})