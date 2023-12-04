({
	doInit : function(component, event, helper) 
    {
        var response = confirm('Please confirm if you want to clone?');
        
        if(response == 1)
        {
            var action = component.get("c.cloneOrderAndOrderDetails");
            
            action.setParams({ orderId : component.get("v.recordId") });
    
            action.setCallback(this, function(response) 
            {
                var state = response.getState();
                
                if (state === "SUCCESS") 
                {
                    component.set('v.cloneRecordId', response.getReturnValue());
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                      "url": "/"+response.getReturnValue()+ '/e'
                                    });
                                    urlEvent.fire();
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                                        urlEvent.setParams({
                                          "url": "/"+component.get('v.cloneRecordId')
                                        });
                                        urlEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": component.get("v.recordId")
                    });
                    navEvt.fire();
        }
	},
})