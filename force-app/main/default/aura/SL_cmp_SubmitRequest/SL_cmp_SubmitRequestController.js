({
	doInit : function(component, event, helper) 
    {
        var requestId = component.get("v.recordId");
        var action = component.get("c.submitRecord");
        
        action.setParams({
            "recid" : requestId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") 
            {
                window.location.reload();
            }
            else if (state === "ERROR") 
            {
                component.set("v.isError", true);
            }
        });

        $A.enqueueAction(action);
	}
})