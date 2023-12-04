({
    doInit: function(component)
    {
       
       /* var action = component.get("c.getActionPlanById");
        //action.setParams({ actionplanId : component.get("v.recordId") });
        component.set("v.recordId",component.get("c.getActionPlanById"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var status =  response.getReturnValue()[0].iCoach_Form__r.Status__c;
                console.log('status',status);
                if(status == 'Submitted')
                {
					component.set('v.IsSubmitted', true);         
                }
                else
                {
                    component.set('v.IsSubmitted', false);   
                }
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
        
        $A.enqueueAction(action);*/
    }
})